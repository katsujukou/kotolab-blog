module Kotolab.Blog.Web.AppM where

import Prelude

import Control.Monad.Reader (ReaderT, runReaderT)
import Effect.Aff (Aff)
import Effect.Aff.Class (class MonadAff)
import Effect.Class (class MonadEffect)
import Halogen as H
import Kotolab.Blog.Web.Capability.Markdown (class MonadMarkdown)
import Kotolab.Blog.Web.Env (Env)

newtype AppM a = AppM (ReaderT Env Aff a)

derive newtype instance functorAppM :: Functor AppM
derive newtype instance applyAppM :: Apply AppM
derive newtype instance applicativeAppM :: Applicative AppM
derive newtype instance bindAppM :: Bind AppM
derive newtype instance monadAppM :: Monad AppM
derive newtype instance monadEffectAppM :: MonadEffect AppM
derive newtype instance monadAffAppM :: MonadAff AppM

instance monadMarkdownAppM :: MonadMarkdown AppM where
  render src = AppM do
    pure src

runApp
  :: forall q i o
   . Env
  -> H.Component q i o AppM
  -> H.Component q i o Aff
runApp env = H.hoist runAppM
  where
  runAppM :: AppM ~> Aff
  runAppM (AppM m) = runReaderT m env