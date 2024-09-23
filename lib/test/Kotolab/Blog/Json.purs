module Test.Kotolab.Blog.Json where

import Prelude

import Data.Codec.Argonaut (JsonCodec)
import Data.Codec.Argonaut as CA
import Data.Codec.Argonaut.Record as CAR
import Data.Codec.Argonaut.Variant as CAV
import Data.Either (Either(..))
import Data.Generic.Rep (class Generic)
import Data.Profunctor (dimap)
import Data.Show.Generic (genericShow)
import Data.Variant as V
import Kotolab.Blog.Json (parse, stringify)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import Type.Proxy (Proxy(..))

type T1 =
  { foo :: Int, bar :: Boolean, baz :: Array String }

codec1 :: JsonCodec T1
codec1 = CA.object "T1" $
  CAR.record
    { foo: CA.int
    , bar: CA.boolean
    , baz: CA.array CA.string
    }

data T2 = Foo Int | Bar Boolean | Baz (Array String)

derive instance Eq T2
derive instance Generic T2 _
instance Show T2 where
  show = genericShow

codec2 :: JsonCodec T2
codec2 =
  dimap toVariant fromVariant $ CAV.variantMatch
    { foo: Right CA.int
    , bar: Right CA.boolean
    , baz: Right (CA.array CA.string)
    }
  where
  toVariant = case _ of
    Foo i → V.inj (Proxy ∷ _ "foo") i
    Bar b → V.inj (Proxy ∷ _ "bar") b
    Baz ss → V.inj (Proxy ∷ _ "baz") ss
  fromVariant = V.match
    { foo: Foo
    , bar: Bar
    , baz: Baz
    }

spec :: Spec Unit
spec = describe "module Kotolab.Blog.Json" do
  it "should success to parse object" do
    parse codec1 """{ "foo": 42, "bar": true, "baz": ["a", "b", "c"] }"""
      `shouldEqual`
        (Right { foo: 42, bar: true, baz: [ "a", "b", "c" ] })

    parse codec2 """{"tag":"foo","value":42}"""
      `shouldEqual`
        (Right (Foo 42))

  it "should success to print json" do
    let t = { foo: 42, bar: true, baz: [ "a", "b", "c" ] }
    parse codec1 (stringify codec1 { foo: 42, bar: true, baz: [ "a", "b", "c" ] })
      `shouldEqual` (Right t)

  it "should success to print json" do
    parse codec2 (stringify codec2 $ Bar false)
      `shouldEqual` (Right $ Bar false)

    parse codec2 (stringify codec2 $ Baz [ "Hello", "World" ])
      `shouldEqual` (Right $ Baz [ "Hello", "World" ])