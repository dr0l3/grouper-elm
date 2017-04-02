module State exposing (init, update)

{-|
@docs init, update
-}

import Random
import Random.List
import Types exposing (..)
import Rest exposing (..)
import Util.Util exposing (..)
import Bootstrap.Modal as Modal


{-| The init function -}
init : (Model, Cmd Msg)
init =
      ( Model Nothing 1 Nothing Nothing "" False Modal.hiddenState True True [] [] [] [] []
      ["#29c6cd","#f6e4c4", "#fea386", "#2980b9", "#a2d5f2", "#1fab89", "#aea1ea", "#ebe9f6", "#ffce3e", "#ff4D4D", "#ff5200", "#ebe9f6" ]
      , getSchools
      )

{-| The update function -}
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
        (model, Cmd.none)

    DebugMessage message ->
        ({model | debug = message}, Cmd.none)

    FetchSchools ->
        (model, getSchools)

    NewSchools (Ok value) ->
        ({model | schools = value}, Cmd.none)

    NewSchools (Err val) ->
        ({model | debug = toString val}, Cmd.none)

    SelectSchool(selected) ->
        let
            maybeSchool = List.head( List.filter (\m -> m.name == selected) model.schools)
        in
            ({model | selectedSchool = maybeSchool}, case maybeSchool of
                Nothing -> Cmd.none
                Just val -> getClasses val)

    FetchClasses ->
      (model, case model.selectedSchool of
        Nothing -> Cmd.none
        Just val -> getClasses val)

    NewClasses (Ok value) ->
      ({model | schoolClasses = value}, Cmd.none)

    NewClasses (Err value) ->
      ({model | debug = toString value}, Cmd.none)

    SelectSchoolClass(selected) ->
        let
            maybeSchoolClass = List.head( List.filter (\m -> m.name == selected) model.schoolClasses)
        in
            ({model | selectedSchoolClass = maybeSchoolClass}, case maybeSchoolClass of
                Nothing -> Cmd.none
                Just val -> getStudents val)

    FetchStudents ->
      (model, case model.selectedSchoolClass of
        Nothing -> Cmd.none
        Just val -> getStudents val)

    NewStudents (Ok value) ->
      ({model | students = value}, Cmd.none)

    NewStudents (Err value) ->
      ({model | debug = toString value}, Cmd.none)

    SelectNumberOfGroups value ->
        let
            groups = divideStudentsFixedAmountOfGroups model.colors 1 (toFloat value) model.students
        in
            ({model | groups = groups, numberOfGroups = value}, Cmd.none)

    SelectMinStudentsInGroup value ->
        let
            numberOfGroups = List.length model.students // value
            groups = divideStudentsFixedAmountOfGroups model.colors 1 (toFloat numberOfGroups) model.students
        in
            ({model | groups = groups, numberOfGroups = numberOfGroups}, Cmd.none)

    SelectMaxStudentsInGroup value ->
        let
            numberOfGroups = ceiling ((toFloat (List.length model.students)) / (toFloat value))
            groups = divideStudentsFixedAmountOfGroups model.colors 1 (toFloat numberOfGroups) model.students
        in
            ({model | groups = groups, numberOfGroups = numberOfGroups}, Cmd.none)
    ToggleMatrix val ->
        ({model | matrix = val}, Cmd.none)

    RandomizeGroups ->
        (model, Random.generate AssignRandomizedGroup (Random.List.shuffle model.students))

    AssignRandomizedGroup students ->
        let
            groups = divideStudentsFixedAmountOfGroups model.colors 1 (toFloat model.numberOfGroups) students
        in
            ({model | groups = groups}, Cmd.none)

    RemoveStudent student ->
        let
            students = List.filter (\std -> student /= std) model.students
            removedStudents = model.removedStudents ++ [student]
            groups = divideStudentsFixedAmountOfGroups model.colors 1 (toFloat model.numberOfGroups) students
        in
            ({model | students = students, groups = groups, removedStudents = removedStudents}, Cmd.none)
    AddStudent student ->
        let
            students = model.students ++ [student]
            groups = divideStudentsFixedAmountOfGroups model.colors 1 (toFloat model.numberOfGroups) students
            removedStudents = List.filter (\std -> student /= std) model.removedStudents
        in
            ({model | students = students, removedStudents = removedStudents, groups = groups}, Cmd.none)

    Move student ->
        ({model | movingStudent = Just student}, Cmd.none)

    DropOn group ->
        let
            groups = case model.movingStudent of
                            Nothing -> model.groups
                            Just val -> List.map (\group -> {group | students = List.filter (\stud -> stud /= val) group.students}) model.groups

            addedGroup = case model.movingStudent of
                Nothing -> model.groups
                Just val -> List.map (\gr -> if group.number == gr.number then {gr | students = val :: gr.students} else gr) groups

        in
            ({model | movingStudent = Nothing, groups = addedGroup}, Cmd.none)
            {-(model, Cmd.none)-}

    CancelMove ->
        ({model | movingStudent = Nothing}, Cmd.none)

    Export showModal ->
        ({model | exportVisible = showModal}, Cmd.none)

    ToggleTableHeader showHeader ->
        ({model | showTableHeaderModal = showHeader}, Cmd.none)

    ToggleColors showColor ->
        ({model | showColors = showColor}, Cmd.none)

    SwapStudents student ->
        let
            something = []
            groups = case model.movingStudent of
                                     Nothing -> model.groups
                                     Just val -> List.map (\g -> {g | students = List.map (\s -> case (twoWayComparison s val student) of
                                         First -> student
                                         Second -> val
                                         Neither -> s) g.students}) model.groups
        in
            ({model | groups = groups, movingStudent = Nothing}, Cmd.none)