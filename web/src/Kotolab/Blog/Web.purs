module Kotolab.Blog.Web where

import Prelude

import Effect (Effect)
import Halogen.Aff (awaitBody, runHalogenAff)
import Halogen.VDom.Driver (runUI)
import Kotolab.Blog.Web.App as App

main :: Effect Unit
main = runHalogenAff do
  body <- awaitBody
  runUI App.make {} body