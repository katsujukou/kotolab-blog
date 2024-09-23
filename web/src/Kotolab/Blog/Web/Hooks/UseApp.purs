module Kotolab.Blog.Web.Hooks.UseApp where

import Prelude

import Data.Bifunctor (lmap)
import Data.Either (Either(..), either)
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Class.Console as Console
import Halogen.Helix (HelixMiddleware, UseHelix, UseHelixHook, makeStore)
import Halogen.Hooks (class HookNewtype, type (<>), HookType, UseEffect, useLifecycleEffect)
import Halogen.Hooks as Hooks
import Halogen.Subscription as HS
import Kotolab.Blog.Web.Route (Route)
import Kotolab.Blog.Web.Route as Route
import Record as Record
import Routing.Duplex as RD
import Routing.PushState as PushState
import Type.Proxy (Proxy(..))
import Unsafe.Coerce (unsafeCoerce)

type AppState =
  { currentRoute ::
      { rawPath :: String
      , route :: Maybe Route
      }
  }

data AppAction = SetCurrentRoute (Either String Route)

reducer :: AppState -> AppAction -> AppState
reducer st = case _ of
  SetCurrentRoute to -> case to of
    Left rawPath -> do
      st { currentRoute = { route: Nothing, rawPath: rawPath } }
    Right route -> do
      st { currentRoute = { route: Just route, rawPath: RD.print Route.route route } }

useAppStore :: forall m a. Eq a => MonadEffect m => UseHelixHook AppState AppAction a m
useAppStore = makeStore "app" reducer initialState middlewareStack
  where
  initialState =
    { currentRoute: { route: Nothing, rawPath: "" } }

  middlewareStack :: HelixMiddleware AppState AppAction _
  middlewareStack _ act next = do
    case act of
      SetCurrentRoute to -> do
        liftEffect do
          { pushState } <- PushState.makeInterface
          pushState (unsafeCoerce {}) $
            to # either identity (RD.print Route.route)
        next act

foreign import data UseApp :: HookType

type UseApp' = UseHelix AppState
  <> UseEffect
  <> Hooks.Pure

instance HookNewtype UseApp UseApp'

type AppAPI m =
  { currentRoute :: { route :: Maybe Route, rawPath :: String }
  , getCurrentRoute :: Hooks.HookM m { route :: Maybe Route, rawPath :: String }
  , setCurrentRoute :: Either String Route -> Hooks.HookM m Unit
  }

useApp :: forall m. MonadEffect m => Hooks.Hook m UseApp (AppAPI m)
useApp = Hooks.wrap hook
  where
  hook :: _ _ UseApp' _
  hook = Hooks.do
    appState /\ appStoreApi <- useAppStore identity

    useLifecycleEffect do
      let
        updateRoute :: PushState.LocationState -> Hooks.HookM m Unit
        updateRoute lc = do
          Console.logShow (Record.delete (Proxy @"state") lc)
          appStoreApi.dispatch $
            SetCurrentRoute (lmap (const lc.path) $ RD.parse Route.route lc.path)

      inst <- liftEffect PushState.makeInterface

      { unlistenLoc, emitter } <- liftEffect do
        { emitter, listener } <- HS.create
        unlistenLoc <- inst.listen (HS.notify listener)
        -- inst.locationState >>= updateRoute
        pure { unlistenLoc, emitter: emitter <#> updateRoute }

      -- 初期化直後のパス情報をStore反映させる
      liftEffect inst.locationState >>= updateRoute

      subscriptionId <- Hooks.subscribe emitter
      pure $ Just (liftEffect unlistenLoc *> Hooks.unsubscribe subscriptionId)

    Hooks.pure
      { currentRoute: appState.currentRoute
      , getCurrentRoute: appStoreApi.getState <#> _.currentRoute
      , setCurrentRoute: appStoreApi.dispatch <<< SetCurrentRoute
      }