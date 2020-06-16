module React.Basic.ReactDND
  ( Backend
  , DNDContext
  , dndProvider
  , useDrag
  , UseDrag
  , useDrop
  , UseDrop
  , mergeTargets
  ) where

import Prelude
import Data.Maybe (Maybe)
import Data.Nullable (Nullable)
import Data.Nullable as Nullable
import Effect (Effect)
import Effect.Uncurried (EffectFn1, runEffectFn1)
import React.Basic.Hooks (Hook, JSX, ReactComponent, Ref, element, unsafeHook)
import Web.DOM (Node)

foreign import data Backend :: Type

foreign import data DNDContext :: Type

dndProvider :: Backend -> JSX -> JSX
dndProvider backend children = element dndProvider_ { backend, children }

type Coords
  = { x :: Number, y :: Number }

useDrag ::
  { type :: String
  , id :: String
  } ->
  Hook UseDrag
    { isDragging :: Boolean
    , connectDrag :: Ref (Nullable Node)
    }
useDrag item =
  unsafeHook do
    runEffectFn1 useDrag_
      { item
      , collect: Nullable.null
      }

foreign import data UseDrag :: Type -> Type

useDrop ::
  { accept :: String
  , onDrop :: String -> Effect Unit
  } ->
  Hook UseDrop
    { id :: Maybe String
    , isOver :: Boolean
    , connectDrop :: Ref (Nullable Node)
    }
useDrop opts =
  unsafeHook do
    { id, isOver, connectDrop } <-
      runEffectFn1 useDrop_ opts
    pure { id: Nullable.toMaybe id, isOver, connectDrop }

foreign import data UseDrop :: Type -> Type

foreign import dndProvider_ :: ReactComponent { backend :: Backend, children :: JSX }

foreign import useDrag_ ::
  forall props.
  EffectFn1
    { item :: { type :: String, id :: String }
    , collect :: Nullable (Unit -> props)
    }
    { isDragging :: Boolean
    , connectDrag :: Ref (Nullable Node)
    }

foreign import useDrop_ ::
  EffectFn1
    { accept :: String
    , onDrop :: String -> Effect Unit
    }
    { id :: Nullable String
    , isOver :: Boolean
    , connectDrop :: Ref (Nullable Node)
    }

foreign import mergeTargets :: Ref (Nullable Node) -> Ref (Nullable Node) -> Ref (Nullable Node)
