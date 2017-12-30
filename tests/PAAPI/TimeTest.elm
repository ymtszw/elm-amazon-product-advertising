module PAAPI.TimeTest exposing (suite)

import Regex
import Expect exposing (..)
import Fuzz exposing (..)
import Test exposing (..)
import PAAPI.Time as T


suite : Test
suite =
    describe "Time"
        [ fuzz posInt "toUtcIsoString should always produce UTC timestamps" <|
            \i ->
                match
                    (T.toUtcIsoString (toFloat i))
                    "^\\d{4,}-\\d\\d-\\d\\dT\\d\\d:\\d\\d:\\d\\d.\\d{3}Z$"
        , test "toUtcDatetime should produce proper UTC datetime" <|
            \_ ->
                equal
                    (T.toUtcDatetime posixMillisExample)
                    ( ( 2017, 12, 30 ), ( 1, 24, 34 ), 995 )
        ]


posInt : Fuzzer Int
posInt =
    map abs int


match : String -> String -> Expectation
match str pattern =
    str
        |> Regex.contains (Regex.regex pattern)
        |> true ("Expected ISO8601 string. Got: " ++ str)


{-| Dec 30 2017 01:24:34.995 UTC
-}
posixMillisExample : Int
posixMillisExample =
    1514597074995
