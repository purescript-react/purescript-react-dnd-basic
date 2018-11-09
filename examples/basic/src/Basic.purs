module Basic where

import Prelude

import Data.Array ((!!), drop, mapWithIndex, take)
import Data.Foldable (for_)
import Data.Maybe (Maybe(Nothing), fromMaybe, maybe)
import React.Basic (Component, JSX, StateUpdate(..), createComponent, fragment, make, send)
import React.Basic.DOM as R
import React.Basic.DOM.Events (targetChecked)
import React.Basic.Events as Events
import React.Basic.ReactDND (DragDrop, DragDropItemType(..), createDragDrop, createDragDropContext)
import React.Basic.ReactDND.Backends.HTML5Backend (html5Backend)

dndContext :: JSX -> JSX
dndContext = createDragDropContext html5Backend

dnd :: DragDrop { itemId :: String, index :: Int }
dnd = createDragDrop (DragDropItemType "TODO_ITEM")

data Action
  = Move { from :: Int, to :: Int }
  | SetDone String Boolean

component :: Component Unit
component = createComponent "TodoExample"

todoExample :: JSX
todoExample = unit # make component { initialState, update, render }
  where
    initialState =
      { todos:
          [ { id: "a", text: "PureScript", done: true }
          , { id: "b", text: "React-Basic", done: true }
          , { id: "c", text: "React-DND-Basic", done: false }
          ]
      }

    update self = case _ of
      Move { from, to } ->
        Update self.state { todos = moveItem from to self.state.todos }

      SetDone id done ->
        Update self.state
          { todos = self.state.todos <#> \t ->
              if t.id == id
              then t { done = done }
              else t
          }

    render self =
      dndContext $
        fragment
          [ R.h1_ [ R.text "Todos" ]
          , R.p_ [ R.text "Drag to reorder the list:" ]
          , R.section_ (mapWithIndex renderTodo self.state.todos)
          ]

      where
        renderTodo index todo =
          dnd.dragSource
            { beginDrag: \_ -> pure
                { itemId: todo.id
                , index
                }
            , endDrag: const (pure unit)
            , canDrag: const (pure true)
            , isDragging: \{ item: draggingItem } ->
                pure $ maybe false (\i -> i.itemId == todo.id) draggingItem
            , render: \{ connectDragSource, isDragging } ->
                dnd.dropTarget
                  { drop: \{ item: dragItem } -> do
                      for_ (_.index <$> dragItem) \dragItemIndex ->
                        send self $ Move { from: dragItemIndex, to: index }
                      pure Nothing
                  , hover: const (pure unit)
                  , canDrop: const (pure true)
                  , render: \{ connectDropTarget, isOver, item: maybeDragItem } ->
                      connectDragSource $ connectDropTarget $
                        R.div
                          { style: R.css
                              { padding: "0.3rem 0.8rem"
                              , alignItems: "center"
                              , borderTop:
                                  if isOver && (fromMaybe false ((\dragItem -> dragItem.index > index) <$> maybeDragItem))
                                  then "0.2rem solid #0044e4"
                                  else "0.2rem solid transparent"
                              , borderBottom:
                                  if isOver && (fromMaybe false ((\dragItem -> dragItem.index < index) <$> maybeDragItem))
                                  then "0.2rem solid #0044e4"
                                  else "0.2rem solid transparent"
                              , opacity: if isDragging then 0.1 else 1.0
                              }
                          , children:
                              [ R.input
                                  { "type": "checkbox"
                                  , checked: todo.done
                                  , onChange: Events.handler targetChecked \checked -> do
                                      send self $ SetDone todo.id $ fromMaybe false checked
                                  }
                              , R.text todo.text
                              ]
                          }
                  }
            }

moveItem :: forall a. Int -> Int -> Array a -> Array a
moveItem fromIndex toIndex items =
  let
    item = items !! fromIndex
    items' = take fromIndex items <> drop (fromIndex + 1) items
  in
    take toIndex items'
      <> maybe [] pure item
      <> drop toIndex items'
