module Kotolab.Blog.Web.AppM where

import Prelude

import Affjax as AX
import Affjax.RequestBody as ARQ
import Affjax.RequestHeader as AXH
import Affjax.ResponseFormat as ResponseFormat
import Affjax.Web as AW
import Control.Monad.Reader (class MonadAsk, ReaderT, runReaderT)
import Data.Argonaut.Core as C
import Data.Either (Either(..))
import Data.Newtype (unwrap)
import Data.String (joinWith)
import Data.Tuple.Nested ((/\))
import Effect.Aff (Aff, throwError)
import Effect.Aff as Aff
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Exception (throw)
import Halogen as H
import Kotolab.Blog.Web.Capability.Markdown (class MonadMarkdown)
import Kotolab.Blog.Web.Capability.MonadAjax (class MonadAjax)
import Kotolab.Blog.Web.Capability.MonadAjax as Ajax
import Kotolab.Blog.Web.Env (Env)

newtype AppM a = AppM (ReaderT Env Aff a)

derive newtype instance functorAppM :: Functor AppM
derive newtype instance applyAppM :: Apply AppM
derive newtype instance applicativeAppM :: Applicative AppM
derive newtype instance bindAppM :: Bind AppM
derive newtype instance monadAppM :: Monad AppM
derive newtype instance monadEffectAppM :: MonadEffect AppM
derive newtype instance monadAffAppM :: MonadAff AppM
derive newtype instance monadAskAppM :: MonadAsk Env AppM

instance monadMarkdownAppM :: MonadMarkdown AppM where
  render src = AppM do
    pure src

instance monadAjaxAppM :: MonadAjax AppM where
  sendRequest method url mbBody headers = AppM do
    result <- liftAff $ Aff.attempt $ AW.request $
      AW.defaultRequest
        { method = Left method
        , url = url
        , responseFormat = ResponseFormat.string
        , content = mbBody <#> \b -> ARQ.string b
        , headers = toAffjaxRequetHeaders headers
        }
    case result of
      Left exn -> throwError exn
      Right resp -> case resp of
        Left err -> liftEffect $ throw $ AX.printError err
        Right { body } -> pure body

    where
    toAffjaxRequetHeaders :: Ajax.Headers -> Array AXH.RequestHeader
    toAffjaxRequetHeaders headers' = headers'
      <#> \(Ajax.Header (k /\ vs)) -> AXH.RequestHeader (unwrap k) (joinWith ";" vs)

runApp
  :: forall q i o
   . Env
  -> H.Component q i o AppM
  -> H.Component q i o Aff
runApp env = H.hoist runAppM
  where
  runAppM :: AppM ~> Aff
  runAppM (AppM m) = runReaderT m env