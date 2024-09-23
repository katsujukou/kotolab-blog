module Kotolab.Blog.Web where

import Prelude

import Effect (Effect)
import Effect.Aff (Aff)
import Halogen as H
import Halogen.Aff (awaitBody, runHalogenAff)
import Halogen.VDom.Driver (runUI)
import Kotolab.Blog.Web.App as App
import Kotolab.Blog.Web.AppM as AppM
import Kotolab.Blog.Web.Env (Env)

main :: Effect Unit
main = runHalogenAff do
  body <- awaitBody
  rootComponent <- runApp
  runUI rootComponent {} body
  where

  runApp :: Aff (H.Component _ _ _ Aff)
  runApp = do
    env <- mkEnv
    pure $ AppM.runApp env App.make

  mkEnv :: Aff Env
  mkEnv = do
    pure { foo: 42 }
