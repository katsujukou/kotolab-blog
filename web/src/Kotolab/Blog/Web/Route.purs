module Kotolab.Blog.Web.Route where

import Prelude hiding ((/))

import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)
import Kotolab.Blog.Types (ArticleId)
import Routing.Duplex as RD
import Routing.Duplex.Generic as RDG
import Routing.Duplex.Generic.Syntax ((/))

data Route
  = Home
  | Articles ArticleId
  | NewArticle
  | EditArticle ArticleId

derive instance eqRoute :: Eq Route
derive instance ordRoute :: Ord Route
derive instance genericRoute :: Generic Route _
instance showRoute :: Show Route where
  show = genericShow

route :: RD.RouteDuplex' Route
route = RD.root $ RDG.sum
  { "Home": RDG.noArgs
  , "Articles": "articles" / RD.segment
  , "NewArticle": "new-article" / RDG.noArgs
  , "EditArticle": "articles" / RD.segment / "edit"
  }
