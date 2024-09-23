module Kotolab.Blog.Web.Asset where

import Prelude

import Halogen.HTML.Properties as HP
import Unsafe.Coerce (unsafeCoerce)

foreign import data AssetUrl :: Type

foreign import assetUrls
  :: { laceOrnament01 :: AssetUrl
     , laceOrnament02 :: AssetUrl
     }

url :: AssetUrl -> String
url u = "url('" <> unsafeCoerce u <> "')"

src :: forall r i. AssetUrl -> HP.IProp (src ∷ String | r) i
src = unsafeCoerce >>> HP.src
