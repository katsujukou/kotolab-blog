module Kotolab.Blog.Web.App where

import Prelude

import Halogen as H
import Halogen.HTML as HH
import Halogen.Hooks as Hooks

make :: forall q i o m. H.Component q i o m
make = Hooks.component \_ _ -> Hooks.do
  Hooks.pure $ render {}
  where
  render _ = do
    HH.div []
      [ HH.text "ことねっとつうしん" ]