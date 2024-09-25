module Kotolab.Blog.API.V1 where

import Prelude

import Control.Monad.Trans.Class (lift)
import Data.Codec.Argonaut (JsonCodec)
import Data.Codec.Argonaut as C
import Data.Either (Either(..))
import Data.Maybe (fromMaybe)
import Effect.Aff (Aff, attempt)
import Effect.Class (liftEffect)
import Effect.Class.Console as Console
import Effect.Exception as Exn
import Fmt as Fmt
import HTTPurple (Method(..), badRequest, internalServerError, notFound, ok, usingCont)
import HTTPurple as HTTPurple
import HTTPurple.AWS.Lambda (APIGatewayV2, LambdaExtRequest, LambdaHandler, lambdaRouter, mkHandlerWithStreaming)
import Kotolab.Blog.API.Effect.Markdown (MARKDOWN)
import Kotolab.Blog.API.Effect.Markdown as Markdown
import Kotolab.Blog.API.V1.Endpoint (Route)
import Kotolab.Blog.API.V1.Endpoint as Endpoint
import Kotolab.Blog.API.V1.RenderPreview as RenderPreview
import Kotolab.Blog.Foreign.MarkdownIt (MarkdownIt)
import Kotolab.Blog.Foreign.MarkdownIt as MarkdownIt
import Kotolab.Blog.Json as Json
import Run (AFF, EFFECT, Run, runBaseAff')
import Run.Except (EXCEPT, runExcept)
import Type.Row (type (+))

type ErrorType = String

type ServerEffects = (MARKDOWN + EXCEPT ErrorType + AFF + EFFECT ())

router
  :: forall ext
   . LambdaExtRequest APIGatewayV2 Route ext
  -> Run ServerEffects HTTPurple.Response
router = lambdaRouter \{ method, route, body } -> usingCont
  case method, route of
    Get, Endpoint.Greet { name } -> do
      ok $ Fmt.fmt @"Hello, {name}!" { name: fromMaybe "World" name }

    Post, Endpoint.RenderPreview -> do
      { src } <- HTTPurple.fromJson (decoder RenderPreview.input) body

      rendered <- lift do
        hl <- Markdown.mkHighlighter
        Markdown.useHighlighter hl
        Markdown.render src

      ok rendered
    _, _ -> notFound

decoder :: forall a. JsonCodec a -> HTTPurple.JsonDecoder String a
decoder codec = HTTPurple.JsonDecoder (Json.parse codec)

encoder :: forall a. C.JsonCodec a -> HTTPurple.JsonEncoder a
encoder codec = HTTPurple.JsonEncoder (Json.stringify codec)

handler :: LambdaHandler APIGatewayV2
handler = mkHandlerWithStreaming
  { route: Endpoint.route
  , router: runApp router
  }
  where
  runApp
    :: forall trg ext
     . (LambdaExtRequest trg _ ext -> Run ServerEffects HTTPurple.Response)
    -> LambdaExtRequest trg _ ext
    -> HTTPurple.ResponseM
  runApp router' req = do
    markdownit <- liftEffect $ MarkdownIt.md
    res <- attempt $ runEffects markdownit (router' req)
    case res of
      Left msg -> do
        Console.error $ Exn.message msg
        Console.error $ show $ Exn.stack msg
        internalServerError (Exn.message msg)
      Right resp -> case resp of
        Left msg -> do
          Console.error msg
          badRequest msg
        Right a -> pure a

  runEffects :: forall a. MarkdownIt -> Run ServerEffects a -> Aff (Either ErrorType a)
  runEffects md m = m
    # Markdown.interpret (Markdown.markdownItWithShikiHandler md)
    # runExcept
    # runBaseAff'