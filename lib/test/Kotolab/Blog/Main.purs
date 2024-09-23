module Test.Kotolab.Blog.Main where

import Prelude

import Effect (Effect)
import Test.Kotolab.Blog.Json as Test.Kotolab.Blog.Json
import Test.Spec (describe)
import Test.Spec.Reporter (consoleReporter)
import Test.Spec.Runner.Node (runSpecAndExitProcess)

main :: Effect Unit
main = runSpecAndExitProcess [ consoleReporter ] do
  describe "Unit tests for package `kotolab-blog-lib`" do
    Test.Kotolab.Blog.Json.spec