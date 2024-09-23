module Kotolab.Blog.Web.Style where

import Prelude

import Data.Foldable (foldMap)
import Data.String (Pattern(..), Replacement(..))
import Data.String as Str
import Data.String.Regex as Re
import Data.String.Regex.Flags (global, unicode)
import Data.String.Regex.Unsafe (unsafeRegex)
import Data.Tuple (Tuple)
import Data.Tuple.Nested ((/\))

newtype Style = Style String

instance Semigroup Style where
  append (Style s1) (Style s2) = case s1, s2 of
    "", _ -> Style s2
    _, "" -> Style s1
    _, _ -> Style (s1 <> ";" <> s2)

instance Monoid Style where
  mempty = Style ""

inlineStyle :: Array (Tuple String String) -> String
inlineStyle styles' =
  let
    Style styles = foldMap (\(k /\ v) -> Style (k <> ":" <> v)) styles'
  in
    styles
