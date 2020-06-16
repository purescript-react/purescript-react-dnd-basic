module Basic where

import Prelude
import Data.Array ((!!), drop, mapWithIndex, take)
import Data.Foldable (traverse_)
import Data.Int as Int
import Data.Maybe (fromMaybe, maybe)
import Effect (Effect)
import React.Basic.DOM as R
import React.Basic.DOM.Events (targetChecked)
import React.Basic.Events as Events
import React.Basic.Hooks (Component, component, fragment, mkReducer, useReducer, (/\))
import React.Basic.Hooks as React
import React.Basic.ReactDND (dndProvider, mergeTargets, useDrag, useDrop)
import React.Basic.ReactDND.Backends.HTML5Backend (html5Backend)

data Action
  = Move { from :: Int, to :: Int }
  | SetDone String Boolean

type Todo
  = { id :: String, text :: String, done :: Boolean }

mkTodoExample :: Component Unit
mkTodoExample = do
  todo <- mkTodo
  reducer <- mkReducer update
  React.component "TodoExample" \_ -> React.do
    state /\ dispatch <- useReducer initialState reducer
    pure
      $ dndProvider html5Backend
      $ fragment
          [ R.h1_ [ R.text "Todos" ]
          , R.p_ [ R.text "Drag to reorder the list:" ]
          , R.section_
              $ state.todos
              # mapWithIndex \index t -> todo { index, todo: t, dispatch }
          ]
  where
  initialState =
    { todos:
        [ { id: "a", text: "PureScript", done: true }
        , { id: "b", text: "React Basic", done: true }
        , { id: "c", text: "React Basic DND", done: false }
        ]
    }

  update state = case _ of
    Move { from, to } ->
      state
        { todos = moveItem from to state.todos
        }
    SetDone id done ->
      state
        { todos =
          state.todos
            <#> \t ->
                if t.id == id then
                  t { done = done }
                else
                  t
        }

mkTodo ::
  Component
    { index :: Int
    , todo :: Todo
    , dispatch :: Action -> Effect Unit
    }
mkTodo = do
  let
    todoDND = "todo-dnd"
  component "Todo" \{ index, todo, dispatch } -> React.do
    { isDragging, connectDrag } <- useDrag { type: todoDND, id: show index }
    { id: maybeDragItem, isOver, connectDrop } <-
      useDrop
        { accept: todoDND
        , onDrop: Int.fromString >>> traverse_ \id -> dispatch $ Move { from: id, to: index }
        }
    pure
      $ R.label
          { ref: mergeTargets connectDrag connectDrop
          , style:
              R.css
                { display: "block"
                , padding: "0.3rem 0.8rem"
                , alignItems: "center"
                , borderTop:
                    if isOver && maybe false ((_ > show index)) maybeDragItem then
                      "0.2rem solid #0044e4"
                    else
                      "0.2rem solid transparent"
                , borderBottom:
                    if isOver && maybe false ((_ < show index)) maybeDragItem then
                      "0.2rem solid #0044e4"
                    else
                      "0.2rem solid transparent"
                , opacity: if isDragging then 0.1 else 1.0
                }
          , children:
              [ R.input
                  { type: "checkbox"
                  , checked: todo.done
                  , onChange:
                      Events.handler targetChecked \checked -> do
                        dispatch $ SetDone todo.id $ fromMaybe false checked
                  }
              , R.text todo.text
              ]
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
