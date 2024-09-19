module Kotolab.Blog.API.V1.Endpoint where

import Prelude hiding ((/))

import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe)
import Data.Show.Generic (genericShow)
import Routing.Duplex (RouteDuplex', optional, prefix, root, string)
import Routing.Duplex.Generic (noArgs, sum)
import Routing.Duplex.Generic.Syntax ((?), (/))

data Route
  = Greet { name :: Maybe String }
  | RenderPreview

derive instance Eq Route
derive instance Generic Route _
instance Show Route where
  show = genericShow

route :: RouteDuplex' Route
route = root $ prefix "api" $ prefix "v1" $ sum
  { "Greet": "greet" ? { name: optional <<< string }
  , "RenderPreview": "render-preview" / noArgs
  }

