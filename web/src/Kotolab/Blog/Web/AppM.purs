module Kotolab.Blog.Web.AppM where

import Prelude

import Control.Monad.Reader (ReaderT, runReaderT)
import Data.Argonaut.Core as C
import Data.Array (foldl)
import Data.Array as Array
import Data.ArrayBuffer.Cast (toUint8Array)
import Data.ArrayBuffer.DataView as ABDV
import Data.ArrayBuffer.Typed as AB
import Data.Either (Either(..))
import Data.Foldable (foldMap)
import Data.Int (hexadecimal)
import Data.Int as Int
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Data.String (joinWith)
import Data.Tuple.Nested ((/\))
import Data.UInt as UInt
import Effect.Aff (Aff)
import Effect.Aff as Aff
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Exception as Exn
import Fetch (fetch)
import Foreign.Object as Object
import Halogen as H
import Kotolab.Blog.Web.Capability.Markdown (class MonadMarkdown)
import Kotolab.Blog.Web.Capability.MonadAjax (class MonadAjax)
import Kotolab.Blog.Web.Capability.MonadAjax as Ajax
import Kotolab.Blog.Web.Env (Env)
import Kotolab.Blog.Web.Foreign.CryptoSubtle (digestSHA256)
import Kotolab.Blog.Web.Foreign.String (padStart)
import Partial.Unsafe (unsafeCrashWith)
import Record as Record
import Type.Proxy (Proxy(..))
import Unsafe.Coerce (unsafeCoerce)
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

instance monadAjaxAppM :: MonadAjax C.Json AppM where
  sendRequest method url mbBody headers' = AppM do
    let
      headers :: {}
      headers = unsafeCoerce $ headers' # foldl
        (\obj (Ajax.Header (k /\ vs)) -> Object.insert (unwrap k) (joinWith ";" vs) obj)
        (Object.singleton "Content-Type" "application/json")

    resp <- liftAff $ Aff.attempt
      case mbBody of
        Nothing -> sendRequestWithEmptyBody headers
        Just body -> sendRequestWithBody headers body

    case resp of
      Left err -> liftEffect $ Exn.throw ("An error occurred during sending request: " <> Exn.message err)
      Right { ok, json }
        | ok -> liftAff (unsafeCoerce json)
        | otherwise -> unsafeCrashWith "Oops!"

    where
    sendRequestWithEmptyBody headers = fetch url { method, headers }
    sendRequestWithBody headers body = do
      -- When content body is not empty (POST/PUT), one must contains
      -- sha256 hash of content in the request header's `x-amz-content-sha256` key.
      -- @See https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-lambda.html
      encoder <- liftEffect TextEncoder.new
      buf <- digestSHA256 $ TextEncoder.encode body encoder
      hashbytes <- liftEffect $ toUint8Array (ABDV.whole buf) >>= AB.foldl Array.snoc []
      let contentHash = foldMap (UInt.toInt >>> Int.toStringAs hexadecimal >>> padStart 2 '0') hashbytes
      fetch url
        { method
        , body
        , headers: headers # Record.insert (Proxy @"x-amz-content-sha256") contentHash
        }

runApp
  :: forall q i o
   . Env
  -> H.Component q i o AppM
  -> H.Component q i o Aff
runApp env = H.hoist runAppM
  where
  runAppM :: AppM ~> Aff
  runAppM (AppM m) = runReaderT m env