module Kotolab.Blog.API.Scheme where

import Prelude

class Schemable :: Symbol -> Constraint
class Schemable name

data Path

foreign import data Slash :: Symbol -> Path -> Path
foreign import data NoArgs :: Path

infixr 5 type Slash as /

-- data Method
-- foreign import data GET :: Method
-- foreign import data POST :: Method

data Endpoint

foreign import data GET :: Path -> Endpoint

type Foo = "api" / "v1" / "foo" / NoArgs

type GetFoo = GET ("api" / "v1" / "foo" / NoArgs)