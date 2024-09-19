module Kotolab.Blog.Foreign.Shiki
  ( createHighlighter
  , useHighlighter
  ) where

import Prelude

import Control.Promise (Promise, toAffE)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Uncurried (EffectFn3, runEffectFn3)
import Kotolab.Blog.Foreign (Highlighter)
import Kotolab.Blog.Foreign.MarkdownIt (MarkdownIt)

createHighlighter :: Aff Highlighter
createHighlighter = toAffE createHighlighterImpl

foreign import createHighlighterImpl :: Effect (Promise Highlighter)

useHighlighter :: forall op. Highlighter -> { | op } -> MarkdownIt -> Effect Unit
useHighlighter hl op md = runEffectFn3 useHighlighterImpl md hl op

foreign import useHighlighterImpl :: forall r. EffectFn3 MarkdownIt Highlighter { | r } Unit