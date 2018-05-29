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

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Uncurried (mkEffFn1)
import Data.Function.Uncurried (Fn2, mkFn1, runFn2)
import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toMaybe, toNullable)
import React.Basic (JSX, ReactComponent, ReactFX, createElement, stateless)

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
  { beginDrag :: DragSourceCollectArgs item -> Eff (react :: ReactFX) item
  , endDrag :: DragSourceCollectArgs item -> Eff (react :: ReactFX) Unit
  , canDrag :: DragSourceCollectArgs item -> Eff (react :: ReactFX) Boolean
  , isDragging :: DragSourceCollectArgs item -> Eff (react :: ReactFX) Boolean
  , render :: DragSourceCollectArgs item -> JSX
  }

type DropTargetProps item =
  { drop :: DropTargetCollectArgs item -> Eff (react :: ReactFX) (Maybe item)
  , hover :: DropTargetCollectArgs item -> Eff (react :: ReactFX) Unit
  , canDrop :: DropTargetCollectArgs item -> Eff (react :: ReactFX) Boolean
  , render :: DropTargetCollectArgs item -> JSX
  }

type DragLayerProps item =
  { render :: DragLayerCollectArgs item -> JSX
  }

type DragDrop item =
  { dragSource :: ReactComponent (DragSourceProps item)
  , dropTarget :: ReactComponent (DropTargetProps item)
  , dragLayer :: ReactComponent (DragLayerProps item)
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
        , render: \props -> createElement jsDragSource
            { beginDrag: mkEffFn1 props.beginDrag
            , endDrag: mkEffFn1 props.endDrag
            , canDrag: mkEffFn1 props.canDrag
            , isDragging: mkEffFn1 props.isDragging
            , render: mkFn1 props.render
            }
        }

    dropTarget =
      let jsDropTarget = runFn2 unsafeCreateDropTarget toMaybe itemType
      in stateless
        { displayName: "DropTarget"
        , render: \props -> createElement jsDropTarget
            { drop: mkEffFn1 (map toNullable <<< props.drop)
            , hover: mkEffFn1 props.hover
            , canDrop: mkEffFn1 props.canDrop
            , render: mkFn1 props.render
            }
        }

    dragLayer =
      let jsDragLayer = unsafeCreateDragLayer toMaybe
      in stateless
        { displayName: "DragLayer"
        , render: createElement jsDragLayer
        }

foreign import createDragDropContext :: Backend -> ReactComponent DragDropContextProps

foreign import unsafeCreateDragSource
  :: forall a
   . Fn2
      (Nullable ~> Maybe)
      DragDropItemType
      (ReactComponent { | a })

foreign import unsafeCreateDropTarget
  :: forall a
   . Fn2
      (Nullable ~> Maybe)
      DragDropItemType
      (ReactComponent { | a })

foreign import unsafeCreateDragLayer
  :: forall a
   . (Nullable ~> Maybe)
  -> ReactComponent { | a }
