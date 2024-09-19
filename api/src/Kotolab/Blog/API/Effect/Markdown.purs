module Kotolab.Blog.API.Effect.Markdown where

import Prelude

import Kotolab.Blog.Foreign (Highlighter)
import Kotolab.Blog.Foreign.MarkdownIt (MarkdownIt)
import Kotolab.Blog.Foreign.MarkdownIt as MarkdownIt
import Kotolab.Blog.Foreign.Shiki as Shiki
import Run (AFF, Run, EFFECT, liftAff)
import Run as Run
import Type.Proxy (Proxy(..))
import Type.Row (type (+))

data Markdown a
  = Render String (String -> a)
  | MkHighlighter (Highlighter -> a)
  | UseHighlighter Highlighter a

derive instance Functor Markdown

type MARKDOWN r = (markdown :: Markdown | r)

_markdown :: Proxy "markdown"
_markdown = Proxy

interpret :: forall r. (forall a. Markdown a -> Run r a) -> Run (MARKDOWN + r) ~> Run r
interpret h = Run.interpret (Run.on _markdown h Run.send)

markdownItWithShikiHandler :: forall r. MarkdownIt -> Markdown ~> Run (AFF + EFFECT + r)
markdownItWithShikiHandler md = case _ of
  Render src reply -> pure $ reply (MarkdownIt.render md src)
  MkHighlighter reply -> do
    hl <- liftAff Shiki.createHighlighter
    pure $ reply hl
  UseHighlighter hl next -> do
    Run.liftEffect $ Shiki.useHighlighter hl { theme: "huacat-pink" } md
    pure next

render :: forall r. String -> Run (MARKDOWN + r) String
render src = Run.lift _markdown $ Render src identity

mkHighlighter :: forall r. Run (MARKDOWN + r) Highlighter
mkHighlighter = Run.lift _markdown $ MkHighlighter identity

useHighlighter :: forall r. Highlighter -> Run (MARKDOWN + r) Unit
useHighlighter hl = Run.lift _markdown $ UseHighlighter hl unit