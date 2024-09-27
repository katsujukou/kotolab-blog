module Kotolab.Blog.Web.Views.HomeView where

import Prelude

import Halogen (ClassName(..))
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import Halogen.Hooks as Hooks

make :: forall q i o m. H.Component q i o m
make = Hooks.component \_ _ -> Hooks.do
  let
    ctx = {}

  Hooks.pure $ render ctx

  where
  render ctx = do
    HH.div [ HP.class_ $ ClassName "max-w-[780px] mx-auto p-5" ]
      [ HH.div [ HP.class_ $ ClassName "block whitespace-pre overflow-x-scroll" ]
          []
      ]
