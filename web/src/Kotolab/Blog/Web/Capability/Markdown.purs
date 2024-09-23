module Kotolab.Blog.Web.Capability.Markdown where

import Prelude

import Effect.Aff.Class (class MonadAff)
import Halogen (HalogenM, lift)
import Halogen.Hooks (HookM)

class MonadAff m <= MonadMarkdown m where
  render :: String -> m String

instance monadMarkdownHalogenM ::
  MonadMarkdown m =>
  MonadMarkdown (HalogenM st act slo o m) where
  render = render >>> lift

instance monadMarkdownHookM ::
  MonadMarkdown m =>
  MonadMarkdown (HookM m) where
  render = render >>> lift