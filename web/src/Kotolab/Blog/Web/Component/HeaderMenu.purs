module Kotolab.Blog.Web.Component.HeaderMenu where

import Prelude

import Halogen (ClassName(..))
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import Halogen.Hooks as Hooks

make :: forall q i o m. H.Component q i o m
make = Hooks.component \_ _ -> Hooks.do
  Hooks.pure $ render {}
  where
  render _ = do
    HH.div [ HP.class_ $ ClassName "w-[100vw] bg-pink-300 text-white" ]
      [ HH.h1
          [ HP.class_ $ ClassName "font-yomogi font-bold text-xl p-4 text-center"
          ]
          [ HH.text "＊ことねっと通信＊" ]
      ]