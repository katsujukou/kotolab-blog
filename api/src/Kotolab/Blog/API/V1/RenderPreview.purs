module Kotolab.Blog.API.V1.RenderPreview where

import Prelude

import Data.Codec.Argonaut (string)
import Data.Codec.Argonaut as C
import Data.Codec.Argonaut as CA
import Data.Codec.Argonaut.Record as CAR

type Input =
  { src :: String }

input :: C.JsonCodec Input
input = CA.object "Input" $
  CAR.record
    { src: string
    }
