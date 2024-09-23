module Test.E2E.Kotolab.Blog.Web where

import Prelude

import Effect (Effect)
import Test.Spec (describe, it)
import Test.Spec.Assertions (shouldEqual)
import Test.Spec.Reporter (consoleReporter)
import Test.Spec.Runner.Node (runSpecAndExitProcess)

main :: Effect Unit
main = runSpecAndExitProcess [ consoleReporter ] do
  describe "E2E Test" do
    it "shuold pass" do
      42 `shouldEqual` 42