module Util.DragAndDrop exposing (onDragEnd, onDragStart, onDrop, onDragHelper, onPreventHelper)

{-| Drag and drop helpers. I just want to be able to compile

# Common helpers
@docs onDragEnd, onDragStart, onDrop, onDragHelper

# Other helpers
@docs onPreventHelper
-}

import Html exposing (Attribute)
import Html.Events exposing (onWithOptions)
import Json.Decode as JD

{-| A small comment -}
onDragEnd : msg -> Attribute msg
onDragEnd message =
    onDragHelper "dragend" message

{-| A small comment -}
onDragStart : msg -> Attribute msg
onDragStart message =
    onDragHelper "dragstart" message

{-| A small comment -}
onDrop : msg -> Attribute msg
onDrop message =
    onPreventHelper "drop" message

{-| A small comment -}
onDragHelper : String -> msg -> Attribute msg
onDragHelper eventName message =
    onWithOptions
        eventName
        { preventDefault = False
        , stopPropagation = False
        }
        (JD.succeed message)

{-| A small comment -}
onPreventHelper : String -> msg -> Attribute msg
onPreventHelper eventName message =
    onWithOptions
        eventName
        { preventDefault = True
        , stopPropagation = False
        }
        (JD.succeed message)