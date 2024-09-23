module Test.Kotolab.Blog.Foreign where

import Prelude

import Effect (Effect)
import Test.Spec (describe, it)
import Test.Spec.Assertions (shouldEqual)
import Test.Spec.Reporter (consoleReporter)
import Test.Spec.Runner.Node (runSpecAndExitProcess)

main :: Effect Unit
main = runSpecAndExitProcess [ consoleReporter ] do
  describe "Unit tests for package `kotolab-blog-foreign`" do
    it "should pass" do
      42 `shouldEqual` 42