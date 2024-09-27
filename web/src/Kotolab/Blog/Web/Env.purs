module Kotolab.Blog.Web.Env where

import Prelude

import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Show.Generic (genericShow)

data Mode = Development | Production | Test

derive instance Eq Mode
derive instance Ord Mode
derive instance Generic Mode _
instance Show Mode where
  show = genericShow

parseMode :: String -> Maybe Mode
parseMode = case _ of
  "development" -> Just Development
  "production" -> Just Production
  "test" -> Just Test
  _ -> Nothing

type Env =
  { mode :: Mode
  , baseURL :: String
  }