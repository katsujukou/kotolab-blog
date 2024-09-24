module Kotolab.Blog.Web.Foreign.CryptoSubtle where

import Prelude

import Control.Promise (Promise, toAffE)
import Data.ArrayBuffer.Types (ArrayBuffer, Uint8Array)
import Effect.Aff (Aff)
import Effect.Uncurried (EffectFn1, runEffectFn1)

foreign import digestSHA256Impl
  :: EffectFn1 Uint8Array (Promise ArrayBuffer)

digestSHA256 :: Uint8Array -> Aff ArrayBuffer
digestSHA256 = runEffectFn1 digestSHA256Impl >>> toAffE