module Rest exposing (getClasses, getSchools, getStudents)

{-|

@docks getClasses, getSchools, getStudents,

-}

import Http
import Json.Decode exposing (Decoder)
import Types exposing (..)
import Json.Decode exposing (Decoder, list)
import Json.Decode.Pipeline exposing (decode, required)

urlbase = "http://46.101.185.34:8084"

{-| Fetch classes for a specific school through local proxy -}
getClasses : School -> Cmd Msg
getClasses school =
    let
        url = urlbase ++ "/ajax/classes?schoolId=" ++ school.id
    in
        Http.send NewClasses (Http.get url decodeClasses)

{-| Fetch schools through local proxy -}
getSchools : Cmd Msg
getSchools =
    let
        url = urlbase ++ "/ajax/schools"
    in
        Http.send NewSchools (Http.get url decodeSchools)

{-| Fetch students for a specific class through local proxy -}
getStudents : SchoolClass -> Cmd Msg
getStudents schoolClass =
    let
        url = urlbase ++ "/ajax/students?classId=" ++ schoolClass.id ++ "&schoolId=" ++ schoolClass.schoolId
    in
        Http.send NewStudents (Http.get url decodeStudents)

decodeStudents: Decoder (List Student)
decodeStudents =
    list studentDecoder

studentDecoder: Decoder Student
studentDecoder =
    decode Student
        |> Json.Decode.Pipeline.required "firstName" Json.Decode.string
        |> Json.Decode.Pipeline.required "secondName" Json.Decode.string


decodeClasses: Decoder (List SchoolClass)
decodeClasses =
    list schoolClassDecoder

schoolClassDecoder: Decoder SchoolClass
schoolClassDecoder =
  decode SchoolClass
    |> Json.Decode.Pipeline.required "name" Json.Decode.string
    |> Json.Decode.Pipeline.required "classId" Json.Decode.string
    |> Json.Decode.Pipeline.required "schoolId" Json.Decode.string


decodeSchools: Decoder (List School)
decodeSchools =
  list schoolDecoder

schoolDecoder : Decoder School
schoolDecoder =
  decode School
    |> Json.Decode.Pipeline.required "name" Json.Decode.string
    |> Json.Decode.Pipeline.required "schoolId" Json.Decode.string