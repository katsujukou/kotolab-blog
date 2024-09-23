module Kotolab.Blog.Web.App where

import Prelude

import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect.Class (class MonadEffect)
import Fmt as Fmt
import Halogen (ClassName(..))
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import Halogen.Hooks as Hooks
import Kotolab.Blog.Web.Asset (assetUrls, src, url)
import Kotolab.Blog.Web.Component.HeaderMenu as HeaderMenu
import Kotolab.Blog.Web.Hooks.UseApp (useApp)
import Kotolab.Blog.Web.Route as Route
import Kotolab.Blog.Web.Style (inlineStyle)
import Kotolab.Blog.Web.Views.ArticleView as ArticleView
import Kotolab.Blog.Web.Views.EditArticleView as EditArticleView
import Kotolab.Blog.Web.Views.HomeView as HomeView
import Type.Proxy (Proxy(..))

make :: forall q i o m. MonadEffect m => H.Component q i o m
make = Hooks.component \_ _ -> Hooks.do
  appApi <- useApp

  let
    ctx =
      { currentRoute: appApi.currentRoute.route
      }

  Hooks.pure $ render ctx

  where
  render { currentRoute } = do

    HH.div [ HP.class_ $ ClassName " min-h-[100vh] text-pink-700" ]
      [ -- header 
        HH.div []
          [ HH.slot_ (Proxy :: _ "headerMenu") unit HeaderMenu.make {} ]

      , -- content
        HH.div
          [ HP.class_ $ ClassName "min-h-[100vh] relative"
          ]
          [ HH.div
              [ HP.class_ $ ClassName $
                  "h-[300px] w-[100%] absolute opacity-80 "
                    <> "sm:top-[-138px] sm:bg-60% bg-140% top-[-143px]"
              , HP.style $ inlineStyle
                  [ "background-image" /\ url assetUrls.laceOrnament02
                  , "background-position" /\ "0"
                  , "transform" /\ "rotate(180deg)"
                  ]
              ]
              []
          , HH.div [ HP.class_ $ ClassName "static -z-50" ]
              [ renderRouterView currentRoute
              ]
          ]
      ]

  renderRouterView Nothing = HH.text "Page Not Found."
  renderRouterView (Just route) = case route of
    Route.Home -> HH.slot_ (Proxy @"main-view") unit HomeView.make {}
    Route.Articles articleId -> HH.slot_ (Proxy @"article-view") unit ArticleView.make { articleId }
    Route.EditArticle articleId -> HH.slot_ (Proxy @"article-view") unit EditArticleView.make { articleId }
