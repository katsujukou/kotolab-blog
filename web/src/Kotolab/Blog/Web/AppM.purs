module Kotolab.Blog.Web.AppM where

import Prelude

import Affjax as AX
import Affjax.RequestBody as AXRB
import Affjax.RequestHeader as AXH
import Affjax.ResponseFormat (json)
import Affjax.Web as AW
import Control.Monad.Reader (ReaderT, lift, runReaderT)
import Data.Array (fold)
import Data.Array as Array
import Data.ArrayBuffer.Cast (toUint8Array)
import Data.ArrayBuffer.DataView as ABDV
import Data.ArrayBuffer.Typed as AB
import Data.Either (Either(..))
import Data.Foldable (foldMap)
import Data.Int (hexadecimal)
import Data.Int as Int
import Data.UInt as UInt
import Data.MediaType.Common (applicationJSON)
import Data.Traversable (for)
import Effect.Aff (Aff)
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Class.Console as Console
import Effect.Exception (throw)
import Halogen as H
import Kotolab.Blog.Web.Capability.Markdown (class MonadMarkdown)
import Kotolab.Blog.Web.Capability.MonadAffjax (class MonadAffjax)
import Kotolab.Blog.Web.Env (Env)
import Kotolab.Blog.Web.Foreign.CryptoSubtle (digestSHA256)
import Kotolab.Blog.Web.Foreign.String (padStart)
import Web.Encoding.TextEncoder as TextEncoder

newtype AppM a = AppM (ReaderT Env Aff a)

derive newtype instance functorAppM :: Functor AppM
derive newtype instance applyAppM :: Apply AppM
derive newtype instance applicativeAppM :: Applicative AppM
derive newtype instance bindAppM :: Bind AppM
derive newtype instance monadAppM :: Monad AppM
derive newtype instance monadEffectAppM :: MonadEffect AppM
derive newtype instance monadAffAppM :: MonadAff AppM

instance monadMarkdownAppM :: MonadMarkdown AppM where
  render src = AppM do
    pure src

instance monadAffjaxAppM :: MonadAffjax AppM where
  sendRequest method url mbBody headers' = AppM do

    -- When content body is not empty (POST/PUT), one must contains
    -- sha256 hash of content in the request header's `x-amz-content-sha256` key.
    -- @See https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-lambda.html
    contentHash <- for mbBody \body -> do
      encoder <- liftEffect TextEncoder.new
      buf <- liftAff $ digestSHA256 $ TextEncoder.encode body encoder
      hashbytes <- liftEffect $ toUint8Array (ABDV.whole buf) >>= AB.foldl Array.snoc []
      pure $ hashbytes
        # foldMap (UInt.toInt >>> Int.toStringAs hexadecimal >>> padStart 2 '0')

    Console.logShow contentHash

    let
      headers = fold
        [ [ AXH.ContentType applicationJSON
          ]
        ]

      req = AX.defaultRequest
        { method = Left method
        , url = url
        , headers = headers
        , responseFormat = json
        , content = AXRB.string <$> mbBody
        }

    resp <- lift $ AW.request req
    case resp of
      Left err -> liftEffect $ throw ("An error occurred during sending request: " <> AX.printError err)
      Right { body } -> pure body

runApp
  :: forall q i o
   . Env
  -> H.Component q i o AppM
  -> H.Component q i o Aff
runApp env = H.hoist runAppM
  where
  runAppM :: AppM ~> Aff
  runAppM (AppM m) = runReaderT m env