module Kotolab.Blog.Web.Views.NewArticleView where

import Prelude

import Data.Tuple.Nested ((/\))
import Halogen (ClassName(..))
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties (InputType(..))
import Halogen.HTML.Properties as HP
import Halogen.Hooks (useState)
import Halogen.Hooks as Hooks
import Type.Proxy (Proxy(..))
import Web.UIEvent.MouseEvent (MouseEvent)

make :: forall q i o m. H.Component q i o m
make = Hooks.component \_ _ -> Hooks.do
  title /\ titleId <- useState ""
  value /\ valueId <- useState ""
  renderedHtml /\ renderedHtmlId <- useState ""
  previewMode /\ previewModeId <- useState false

  let
    handlePreviewClicked :: MouseEvent -> Hooks.HookM m Unit
    handlePreviewClicked _ = do
      pure unit
    -- Hooks.get previewModeId >>=
    --   if _ then do
    --     Hooks.put previewModeId false
    --   else do
    --     src <- Hooks.get valueId
    --     out <- MD.render src
    --     Hooks.put renderedHtmlId out
    --     Hooks.put previewModeId true

    ctx =
      { title
      , value
      , previewMode
      , renderedHtml
      , setTitle: Hooks.put titleId
      , setValue: Hooks.put valueId
      , handlePreviewClicked
      }

  Hooks.pure (render ctx)

  where

  render ctx = do
    let
      titleClass =
        "w-full border-b border-pink-400 bg-transparent rounded-sm pt-3 pb-1 text-xl font-bold text-pink-400 "
          <> "focus:border-b focus:outline-none focus:border-b-2 "
          <> "placeholder-pink-300 placeholder:text-xl placeholder:font-bold "
          <> "transition-all duration-300 "

      textareaClass =
        "border-none resize-none bg-white w-full  min-h-[1000px] rounded focus p-4 overflow-hidden "
          <> "focus:border-none focus:outline-none "

    HH.div
      [ HP.class_ $ ClassName "max-w-[780px] mx-auto p-5 "
      ]
      [ HH.div [ HP.class_ $ ClassName "flex flex-row-reverse" ]
          [ HH.div [ HP.class_ $ ClassName "w-[64px]" ]
              [ HH.button
                  [ HP.class_ $ ClassName ""
                  , HE.onClick ctx.handlePreviewClicked
                  ]
                  [ HH.text $ if ctx.previewMode then "プレビューOFF" else "プレビューON" ]
              ]
          ]
      , if ctx.previewMode then do
          HH.text "preview"
        -- HH.slot_ (Proxy @"preview-article") unit Article.make
        --   { title: ctx.title
        --   , html: ctx.renderedHtml
        --   }
        else do
          HH.div []
            [ HH.div [ HP.class_ $ ClassName "m-3 w-[calc(100%-64px)]" ]
                [ HH.input
                    [ HP.type_ $ InputText
                    , HP.class_ $ ClassName titleClass
                    , HP.placeholder "タイトル"
                    , HP.value ctx.title
                    , HE.onValueInput ctx.setTitle
                    ]
                ]
            , HH.div [ HP.class_ $ ClassName "m-3" ]
                [ HH.textarea
                    [ HP.class_ $ ClassName textareaClass
                    , HP.value ctx.value
                    , HE.onValueInput ctx.setValue
                    ]
                ]
            ]
      ]
