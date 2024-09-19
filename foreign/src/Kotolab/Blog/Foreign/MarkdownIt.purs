module Kotolab.Blog.Foreign.MarkdownIt where

import Data.Function.Uncurried (Fn2, runFn2)
import Effect (Effect)

foreign import data MarkdownIt :: Type

foreign import md :: Effect MarkdownIt

foreign import renderImpl :: Fn2 MarkdownIt String String

render :: MarkdownIt -> String -> String
render m = runFn2 renderImpl m