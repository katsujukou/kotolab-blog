module Kotolab.Blog.Web where

import Prelude

import Data.Maybe (fromMaybe)
import Effect (Effect)
import Effect.Aff (Aff)
import Foreign.Object as Object
import Halogen (liftEffect)
import Halogen as H
import Halogen.Aff (awaitBody, runHalogenAff)
import Halogen.VDom.Driver (runUI)
import Kotolab.Blog.Web.App as App
import Kotolab.Blog.Web.AppM as AppM
import Kotolab.Blog.Web.Env (Env, Mode(..), parseMode)
import Kotolab.Blog.Web.Foreign.ImportMeta as ImportMeta

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
    env <- liftEffect ImportMeta.env
    let
      mode = env
        # (Object.lookup "MODE" >=> parseMode)
        # fromMaybe Development
      baseURL = case mode of
        Production -> "https://blog.kotolab.net"
        _ -> "http://localhost:3000"
    pure
      { mode
      , baseURL
      }
