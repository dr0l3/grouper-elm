module Views exposing (view)

{-|
@docs view
-}

import Bootstrap.Grid.Col
import Html exposing (..)
import Types exposing (..)
import Util.DragAndDrop exposing (..)
import Util.Util exposing (..)
import Bootstrap.CDN as CDN
import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Form as Form
import Bootstrap.Form.Select as Select
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Checkbox as Checkbox
import Bootstrap.Grid.Row as Row
import Bootstrap.ListGroup as ListGroup
import Bootstrap.Table as Table exposing (RowOption, cellAttr, rowAttr)
import Bootstrap.Modal as Modal
import Html.Attributes exposing (attribute, class, id, required, style, type_, value)
import Html.Events exposing (on, onClick, onWithOptions, targetValue)

schoolOptions: School -> Html Msg
schoolOptions school =
    option [value (school.name)] [text (school.name)]

schoolClassOptions: SchoolClass -> Html Msg
schoolClassOptions schoolClass =
    option [value (schoolClass.name)] [ text (schoolClass.name)]


fullClassView: Bool -> Model -> Html Msg
fullClassView dnd model =
    case model.matrix of
        False -> Grid.row [] (List.map2 nonmatrixGroupView (List.repeat (List.length model.groups) dnd) model.groups)
        True -> Grid.row [] [matrixGroupView dnd model]



nonmatrixGroupView: Bool -> Group -> Grid.Column Msg
nonmatrixGroupView dnd group =
    let
        nondndattrs = [style [("border", "1px solid black"),("background-color", color), ("margin-bottom", "10px"), ("min-width", "120px")]]
        dndattrs = [attribute "ondragover" "return false", onDrop <| DropOn group]
        divattrs = case dnd of
            False -> nondndattrs
            True -> nondndattrs ++ dndattrs
        color =  case group.color of
            Nothing -> "white"
            Just val -> val
    in
        Grid.col []
            [ div divattrs ( [nonMatrixGroupTitle dnd group] ++ (List.map2 studentView (List.repeat (List.length group.students) dnd)  group.students))]

nonMatrixGroupTitle: Bool -> Group -> Html.Html Msg
nonMatrixGroupTitle dnd group =
    let
        nondndattrs = [ class "text-center", style [("margin-bottom", "5px"), ("text-decoration", "underline")]]
        dndattrs = [attribute "ondragover" "return false", onDrop <| DropOn group ]
        divattrs = case dnd of
                False -> nondndattrs
                True -> nondndattrs ++ dndattrs
    in
        div divattrs [ text ("Group " ++ (groupNumberToGroupMarker group.number))]

studentView: Bool -> Student -> Html Msg
studentView dnd student =
    let
        nondndattrs = [ class "text-center"]
        dndattrs = [ attribute "draggable" "true"
                   , onDragEnd <| CancelMove
                   , onDragStart <| Move student
                   , onDrop <| SwapStudents student
                   , attribute "ondragstart" "event.dataTransfer.setData(\"text/plain\", \"dummy\")"]
        divattrs = case dnd of
            False -> nondndattrs
            True -> nondndattrs ++ dndattrs
        firstname = case List.head(String.split " " student.firstname) of
            Nothing -> "No first name"
            Just name -> name
        lastname = String.left 1 student.secondname
    in
        div divattrs [ text (firstname ++ " " ++ lastname)]


matrixGroupView: Bool -> Model -> Grid.Column Msg
matrixGroupView dnd model =
    let
        groups = max 1 model.numberOfGroups -- numberOfGroups might be zero
        maybeMaxStudents = List.maximum (List.map (\gr -> (List.length gr.students)) model.groups)
        maxStudents = case maybeMaxStudents of
            Nothing -> 0
            Just val -> val
        numberOfStudents = ceiling ((toFloat (List.length model.students))  / (toFloat groups))
        tableheaders = case model.showTableHeaderModal of
            False -> []
            True -> List.map maxtrixTableHeaderView (List.range 1 maxStudents)
    in
        Grid.col [] [
            Table.simpleTable
                (Table.simpleThead ( [Table.th [] []] ++ tableheaders)
                                   , Table.tbody [] (List.map2 groupTr (List.repeat (List.length model.groups) dnd) model.groups))]

maxtrixTableHeaderView: Int -> Table.Cell Msg
maxtrixTableHeaderView number =
    Table.th [cellAttr (class "text-center")] [text (toString number)]

groupTr: Bool -> Group -> Table.Row Msg
groupTr dnd group =
    let
        nondndattrs = [ (rowAttr (style [("background-color", color)]))]
        dndattrs = [ rowAttr (attribute "ondragover" "return false"), rowAttr (onDrop <| DropOn group)]
        rowattrs = case dnd of
            False -> nondndattrs
            True -> nondndattrs ++ dndattrs
        color =  case group.color of
            Nothing -> "white"
            Just val -> val
    in
        Table.tr rowattrs ([groupMarkerTd (groupNumberToGroupMarker group.number)] ++ (List.map2 studentTd (List.repeat (List.length group.students) dnd) group.students))


groupMarkerTd: String -> Table.Cell Msg
groupMarkerTd marker =
    Table.td [] [text marker]

studentTd: Bool ->Student -> Table.Cell Msg
studentTd dnd student =
    let
        nondndattrs = []
        dndattrs = [ cellAttr (attribute "draggable" "true")
                   , cellAttr (onDragStart <| Move student)
                   , cellAttr (attribute "ondragstart" "event.dataTransfer.setData(\"text/plain\", \"dummy\")")
                   , cellAttr (onDrop <| SwapStudents student)
                   , cellAttr (onDragEnd <| CancelMove)]
        cellattrs = case dnd of
            False -> nondndattrs
            True -> nondndattrs ++ dndattrs
        firstname = case List.head(String.split " " student.firstname) of
                        Nothing -> "No first name"
                        Just name -> name
        lastname = String.left 1 student.secondname
    in
        Table.td cellattrs [ text (firstname ++ " " ++ lastname)]

matrixStudentView: Student -> Grid.Column Msg
matrixStudentView student =
    let
        firstname = case List.head(String.split " " student.firstname) of
            Nothing -> "No first name"
            Just name -> name
        lastname = String.left 1 student.secondname
    in
        Grid.col [ Bootstrap.Grid.Col.attrs [class "text-center"]] [ text (firstname ++ " " ++ lastname)]


customHandler: (Int -> Msg) -> String -> Msg
customHandler message input =
    case String.toInt input of
        Err err -> DebugMessage err
        Ok val -> (message val)


numberSelect: Int -> Select.Item Msg
numberSelect number =
    Select.item [] [text (toString number)]

schoolSelect: School -> Select.Item Msg
schoolSelect school =
    Select.item [] [text school.name]

schoolClassSelect: SchoolClass -> Select.Item Msg
schoolClassSelect schoolClass =
    Select.item [] [text schoolClass.name]

studentList: List(Student) -> Html.Html Msg
studentList students =
    ListGroup.ul (List.map studentListItem students)

studentListItem: Student -> ListGroup.Item Msg
studentListItem student =
    let
            firstname = case List.head(String.split " " student.firstname) of
                            Nothing -> "No first name"
                            Just name -> name
            lastname = String.left 1 student.secondname
    in
        ListGroup.li [ListGroup.attrs [ class "justify-content-between" ]]
            [ text (firstname ++ " " ++ lastname)
            , Button.button [Button.small, Button.attrs [(onClick (RemoveStudent student)), class "float-right"]] [text "-"]]

studentListRemoved: List(Student) -> Html.Html Msg
studentListRemoved students =
    ListGroup.ul (List.map studentListItemRemoved students)

studentListItemRemoved: Student -> ListGroup.Item Msg
studentListItemRemoved student =
    let
            firstname = case List.head(String.split " " student.firstname) of
                            Nothing -> "No first name"
                            Just name -> name
            lastname = String.left 1 student.secondname
    in
        ListGroup.li [ListGroup.attrs [ class "justify-content-between" ]]
            [ text (firstname ++ " " ++ lastname)
            , Button.button [Button.small, Button.attrs [(onClick (AddStudent student)), class "float-right"]] [text "+"]]


exportModal: Model -> Html.Html Msg
exportModal model =
    Modal.config Export
        |> Modal.large
        |> Modal.h3 [] [ text "Group export"]
        |> Modal.body []
            [ fullClassView False model ]
        |> Modal.footer []
            [ Button.button [Button.attrs [onClick (Export Modal.hiddenState)]] [text "close"]
            , Checkbox.custom [Checkbox.onCheck ToggleTableHeader] "Toggle Table header"
            , Checkbox.custom [Checkbox.onCheck ToggleMatrix] "Toggle Matrix"]
        |> Modal.view model.exportVisible

{-| The view function -}

view : Model -> Html Msg
view model =
  Grid.container [ id "maincontainer"]
    [ CDN.stylesheet
    , nav [class "navbar navbar-inverse navbar-fixed-top", style [("background-color", "lightblue")]] [h1 [class "text-center"] [text "Group Utility"]]
    , Grid.row []
        [ Grid.col []
            [ Form.label [] [text "Select school"]
            , Select.custom [Select.onInput SelectSchool] (List.map  schoolSelect model.schools)
            , Form.label [] [text "Select class"]
            , Select.custom [Select.onInput SelectSchoolClass] (List.map schoolClassSelect model.schoolClasses)
            , Form.label [] [text "Number of groups"]
            , Select.custom [Select.onInput (customHandler SelectNumberOfGroups)] (List.map numberSelect (List.range 1 10))
            , Form.label [] [text "Max Students In Group"]
            , Select.custom [Select.onInput (customHandler SelectMaxStudentsInGroup)] (List.map numberSelect (List.range 1 10))
            , Form.label [] [text "Min Students In Group"]
            , Select.custom [Select.onInput (customHandler SelectMinStudentsInGroup)] (List.map numberSelect (List.range 1 10))
            , hr [] []
            , Grid.row []
                [ Grid.col []
                    [ Checkbox.custom [Checkbox.onCheck ToggleMatrix] "Toggle matrix"]
                , Grid.col []
                    [ Button.button [Button.secondary, Button.attrs [ onClick RandomizeGroups]] [text "Shuffle groups"]]
                , Grid.col []
                    [ Button.button [Button.secondary, Button.attrs [ onClick (Export Modal.visibleState)]] [text "Export"]]]
            , hr [] []
            , fullClassView True model
            , hr [] []
            , exportModal model]
        , Grid.col [Bootstrap.Grid.Col.sm3]
            [ Form.label [] [text "Students"]
            , studentList model.students
            , Form.label [] [text "Removed Students"]
            , studentListRemoved model.removedStudents]]
    ]