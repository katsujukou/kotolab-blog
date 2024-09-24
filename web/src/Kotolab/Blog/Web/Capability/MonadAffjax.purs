module Kotolab.Blog.Web.Capability.MonadAffjax where

import Prelude

import Affjax.RequestHeader as AXH
import Data.Argonaut.Core (Json)
import Data.HTTP.Method (Method)
import Data.Maybe (Maybe)
import Data.String as Str
import Data.Tuple (Tuple)
import Data.Tuple.Nested ((/\))
import Effect.Aff.Class (class MonadAff)
import Halogen (HalogenM, lift)
import Halogen.Hooks (HookM)

type URL = String

newtype Header = Header (Tuple String (Array String))

type Headers = Array Header

toAffjaxRequestHeaders :: Headers -> Array AXH.RequestHeader
toAffjaxRequestHeaders headers = map go headers
  where
  go (Header (k /\ vs)) = AXH.RequestHeader k (Str.joinWith ";" vs)

class MonadAff m <= MonadAffjax m where
  sendRequest :: Method -> URL -> Maybe String -> Headers -> m Json

instance monadAffjaxHalogenM ::
  MonadAffjax m =>
  MonadAffjax (HalogenM st act slo o m) where
  sendRequest method url body headers = lift $ sendRequest method url body headers

instance monadAffjaxHookM ::
  MonadAffjax m =>
  MonadAffjax (HookM m) where
  sendRequest method url body headers = lift $ sendRequest method url body headers

