module Kotolab.Blog.Web.Capability.MonadAjax where

import Prelude

import Data.HTTP.Method (Method)
import Data.Maybe (Maybe)
import Data.String.CaseInsensitive (CaseInsensitiveString)
import Data.Tuple (Tuple)
import Effect.Aff.Class (class MonadAff)
import Halogen (HalogenM, lift)
import Halogen.Hooks (HookM)

type URL = String

newtype Header = Header (Tuple CaseInsensitiveString (Array String))

type Headers = Array Header

class MonadAff m <= MonadAjax resp m | m -> resp where
  sendRequest :: Method -> URL -> Maybe String -> Headers -> m resp

instance monadAjaxHalogenM ::
  MonadAjax json m =>
  MonadAjax json (HalogenM st act slo o m) where
  sendRequest method url body headers = lift $ sendRequest method url body headers

instance monadAjaxHookM ::
  MonadAjax json m =>
  MonadAjax json (HookM m) where
  sendRequest method url body headers = lift $ sendRequest method url body headers

