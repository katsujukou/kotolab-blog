module Kotolab.Blog.Web.API where

import Prelude

import Control.Monad.Reader (class MonadAsk, ask)
import Data.Array (fold, foldMap, snoc)
import Data.ArrayBuffer.Cast (toUint8Array)
import Data.ArrayBuffer.DataView as ABDV
import Data.ArrayBuffer.Typed as AB
import Data.HTTP.Method (Method)
import Data.Int (hexadecimal)
import Data.Int as Int
import Data.Maybe (Maybe(..))
import Data.Traversable (for)
import Data.UInt as UInt
import Effect.Aff.Class (liftAff)
import Effect.Class (liftEffect)
import Kotolab.Blog.API.Scheme.V1 as SchemeV1
import Kotolab.Blog.Web.Capability.MonadAjax (class MonadAjax, (:))
import Kotolab.Blog.Web.Capability.MonadAjax as Ajax
import Kotolab.Blog.Web.Foreign.CryptoSubtle (digestSHA256)
import Kotolab.Blog.Web.Foreign.String (padStart)
import Routing.Duplex as RD
import Web.Encoding.TextEncoder as TextEncoder

sendApiRequest
  :: forall m env a b
   . MonadAjax m
  => MonadAsk { baseURL :: String | env } m
  => { encoder :: Maybe (a -> String), decoder :: String -> m b }
  -> Method
  -> SchemeV1.Route
  -> Maybe a
  -> m b
sendApiRequest { encoder, decoder } method endpoint a = do
  let body = encoder <*> a
  { baseURL } <- ask
  mbHash <- liftAff $ for body contentHash
  decoder =<< Ajax.sendRequest
    method
    (baseURL <> RD.print SchemeV1.route endpoint)
    body
    (headers mbHash)
  where
  -- When content body is not empty (POST/PUT), one must contains
  -- sha256 hash of content in the request header's `x-amz-content-sha256` key.
  -- @See https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-lambda.html
  contentHash body = do
    textEncoder <- liftEffect TextEncoder.new
    buf <- digestSHA256 $ TextEncoder.encode body textEncoder
    hashbytes <- liftEffect $ toUint8Array (ABDV.whole buf) >>= AB.foldl snoc []
    pure $ foldMap (UInt.toInt >>> Int.toStringAs hexadecimal >>> padStart 2 '0') hashbytes

  headers mbHash = fold
    [ [ "Content-Type" : "application/json"
      ]
    , case mbHash of
        Nothing -> []
        Just hash -> [ "X-Amz-Content-Sha256" : hash ]
    ]
