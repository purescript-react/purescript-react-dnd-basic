module React.Basic.ReactDND
  ( Backend
  , DragDropItemType(..)
  , Coords
  , SharedCollectArgs
  , DragSourceCollectArgs
  , DropTargetCollectArgs
  , DragLayerCollectArgs
  , DragDropContextProps
  , DragSourceProps
  , DropTargetProps
  , DragLayerProps
  , DragDrop
  , createDragDropContext
  , createDragDrop
  ) where

import Prelude

import Data.Function.Uncurried (Fn2, mkFn1, runFn2)
import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toMaybe, toNullable)
import Effect (Effect)
import Effect.Uncurried (mkEffectFn1)
import React.Basic (Component, JSX, element, stateless)

data Backend

newtype DragDropItemType = DragDropItemType String

type Coords = { x :: Number, y :: Number }

type SharedCollectArgs item =
  ( itemType :: Maybe DragDropItemType
  , item :: Maybe item
  , initialClientOffset :: Maybe Coords
  , initialSourceClientOffset :: Maybe Coords
  , clientOffset :: Maybe Coords
  , differenceFromInitialOffset :: Maybe Coords
  , sourceClientOffset :: Maybe Coords
  )

type DragSourceCollectArgs item =
  { connectDragSource :: JSX -> JSX
  , connectDragPreview :: JSX -> JSX
  , canDrag :: Maybe Boolean
  , isDragging :: Boolean
  , dropResult :: Maybe item
  , didDrop :: Boolean
  | SharedCollectArgs item
  }

type DropTargetCollectArgs item =
  { connectDropTarget :: JSX -> JSX
  , canDrop :: Boolean
  , isOver :: Boolean
  , isOverShallow :: Boolean
  , dropResult :: Maybe item
  , didDrop :: Boolean
  | SharedCollectArgs item
  }

type DragLayerCollectArgs item =
  { isDragging :: Boolean
  | SharedCollectArgs item
  }

type DragDropContextProps =
  { child :: JSX
  }

type DragSourceProps item =
  { beginDrag :: DragSourceCollectArgs item -> Effect item
  , endDrag :: DragSourceCollectArgs item -> Effect Unit
  , canDrag :: DragSourceCollectArgs item -> Effect Boolean
  , isDragging :: DragSourceCollectArgs item -> Effect Boolean
  , render :: DragSourceCollectArgs item -> JSX
  }

type DropTargetProps item =
  { drop :: DropTargetCollectArgs item -> Effect (Maybe item)
  , hover :: DropTargetCollectArgs item -> Effect Unit
  , canDrop :: DropTargetCollectArgs item -> Effect Boolean
  , render :: DropTargetCollectArgs item -> JSX
  }

type DragLayerProps item =
  { render :: DragLayerCollectArgs item -> JSX
  }

type DragDrop item =
  { dragSource :: Component (DragSourceProps item)
  , dropTarget :: Component (DropTargetProps item)
  , dragLayer :: Component (DragLayerProps item)
  }

createDragDrop
  :: forall item
   . DragDropItemType
  -> DragDrop { | item }
createDragDrop itemType =
  { dragSource
  , dropTarget
  , dragLayer
  }
  where
    dragSource =
      let jsDragSource = runFn2 unsafeCreateDragSource toMaybe itemType
      in stateless
        { displayName: "DragSource"
        , render: \props -> element jsDragSource
            { beginDrag: mkEffectFn1 props.beginDrag
            , endDrag: mkEffectFn1 props.endDrag
            , canDrag: mkEffectFn1 props.canDrag
            , isDragging: mkEffectFn1 props.isDragging
            , render: mkFn1 props.render
            }
        }

    dropTarget =
      let jsDropTarget = runFn2 unsafeCreateDropTarget toMaybe itemType
      in stateless
        { displayName: "DropTarget"
        , render: \props -> element jsDropTarget
            { drop: mkEffectFn1 (map toNullable <<< props.drop)
            , hover: mkEffectFn1 props.hover
            , canDrop: mkEffectFn1 props.canDrop
            , render: mkFn1 props.render
            }
        }

    dragLayer =
      let jsDragLayer = unsafeCreateDragLayer toMaybe
      in stateless
        { displayName: "DragLayer"
        , render: element jsDragLayer
        }

foreign import createDragDropContext :: Backend -> Component DragDropContextProps

foreign import unsafeCreateDragSource
  :: forall a
   . Fn2
      (Nullable ~> Maybe)
      DragDropItemType
      (Component { | a })

foreign import unsafeCreateDropTarget
  :: forall a
   . Fn2
      (Nullable ~> Maybe)
      DragDropItemType
      (Component { | a })

foreign import unsafeCreateDragLayer
  :: forall a
   . (Nullable ~> Maybe)
  -> Component { | a }
