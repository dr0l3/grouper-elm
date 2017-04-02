module Util.Util exposing (..)

{-|
@docs divideStudentsFixedAmountOfGroups, groupNumberToGroupMarker
-}

import Types exposing (..)
import Array
import List exposing (drop, take)

{-| Some comment -}
divideStudentsFixedAmountOfGroups: List(String) -> Int -> Float -> List(Student) -> List(Group)
divideStudentsFixedAmountOfGroups colors index numberOfGroups students =
    let
        groups = max 1 numberOfGroups -- numberOfGroups might be zero
        numberOfStudents = ceiling ((toFloat (List.length students))  / groups)
        color =  Array.get index (Array.fromList colors)
    in
        case take numberOfStudents students of
            [] -> []
            list -> (Group list index color) :: (divideStudentsFixedAmountOfGroups colors (index + 1) (groups - 1) (drop numberOfStudents students))

{-| Some comment -}
groupNumberToGroupMarker: Int -> String
groupNumberToGroupMarker number =
    let
        chars = [ "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U" ]
        assignedChar = Array.get (number - 1 ) (Array.fromList chars)
        actualChar = case assignedChar of
                                 Nothing -> ""
                                 Just val -> val
    in
        actualChar