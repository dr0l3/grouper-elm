module Types exposing (..)

{-|
@docs Styles, SchoolClass, School, Student, Group, Alias, Msg, TwoWayCompare
-}

import Http
import Bootstrap.Modal as Modal
import Random exposing (Seed)


{-| Some comment -}
type alias SchoolClass =
    { name: String
    , id: String
    , schoolId: String}

{-| Some comment -}
type alias School =
    { name: String
    , id: String }

{-| Some comment -}
type alias Student =
    { firstname: String
    , secondname: String}

{-| Some comment -}
type alias Group =
    { students: List(Student)
    , number: Int
    , color: Maybe String}

{-| Some comment -}
type alias Model =
    { movingStudent: Maybe(Student)
    , numberOfGroups : Int
    , selectedSchool: Maybe(School)
    , selectedSchoolClass: Maybe(SchoolClass)
    , debug: String
    , matrix: Bool
    , exportVisible: Modal.State
    , randomStudentVisible: Modal.State
    , randomStudent: Maybe(Student)
    , showTableHeaderModal: Bool
    , showColors: Bool
    , groups: List(Group)
    , students: List Student
    , removedStudents: List Student
    , schoolClasses: List SchoolClass
    , schools: List School
    , colors : List(String)}

{-| Some comment -}
type TwoWayCompare = First | Second | Neither


{-| Some comment -}
type Msg
  = NoOp
  | DebugMessage(String)
  | FetchSchools
  | NewSchools(Result Http.Error (List(School)))
  | SelectSchool(String)
  | FetchClasses
  | NewClasses(Result Http.Error (List(SchoolClass)))
  | SelectSchoolClass(String)
  | FetchStudents
  | NewStudents(Result Http.Error (List(Student)))
  | SelectNumberOfGroups(Int)
  | SelectMinStudentsInGroup(Int)
  | SelectMaxStudentsInGroup(Int)
  | ToggleMatrix(Bool)
  | RandomizeGroups
  | AssignRandomizedGroup(List(Student))
  | RemoveStudent(Student)
  | AddStudent(Student)
  | Move(Student)
  | CancelMove
  | DropOn(Group)
  | Export(Modal.State)
  | ToggleTableHeader(Bool)
  | ToggleColors(Bool)
  | SwapStudents(Student)
  | PickRandomStudent(Modal.State)
  | SetRandomStudent(Maybe(Student), List(Student))