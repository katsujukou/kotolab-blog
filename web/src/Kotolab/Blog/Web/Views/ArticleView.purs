module Kotolab.Blog.Web.Views.ArticleView where

import Prelude

import Halogen as H
import Halogen.HTML as HH
import Halogen.Hooks as Hooks

make :: forall q i o m. H.Component q i o m
make = Hooks.component \_ _ -> Hooks.do
  let
    ctx = {}
  Hooks.pure $ render ctx
  where
  render _ = do
    HH.div []
      [ HH.text "article" ]