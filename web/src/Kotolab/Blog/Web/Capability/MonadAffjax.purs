module Kotolab.Blog.Web.Capability.MonadAffjax where

import Prelude

import Data.Argonaut.Core (Json)
import Data.HTTP.Method (Method)
import Data.Maybe (Maybe)
import Data.Tuple (Tuple)
import Effect.Aff.Class (class MonadAff)
import Foreign (Foreign)
import Halogen (HalogenM, lift)
import Halogen.Hooks (HookM)

type URL = String

newtype Headers = Headers (Tuple String (Array String))

class MonadAff m <= MonadAffjax m where
  sendRequest :: Method -> URL -> Maybe String -> Array Headers -> m Json

instance monadAffjaxHalogenM ::
  MonadAffjax m =>
  MonadAffjax (HalogenM st act slo o m) where
  sendRequest method url body headers = lift $ sendRequest method url body headers

instance monadAffjaxHookM ::
  MonadAffjax m =>
  MonadAffjax (HookM m) where
  sendRequest method url body headers = lift $ sendRequest method url body headers

