module Benchmarks exposing (main)

import Benchmark exposing (..)
import Benchmark.Runner exposing (BenchmarkProgram, program)
import PAAPI.Time
import PAAPI.V2Signer


suite : Benchmark
suite =
    let
        posixMillisExample =
            1514597074995

        stringToEscape =
            "abcdefg-=~:/_+*あいうえお"
    in
        describe "PAAPI"
            [ benchmark "Time.toUtcIsoString" <|
                \_ -> PAAPI.Time.toUtcIsoString posixMillisExample
            , benchmark "V2Signer.urlEscape" <|
                \_ -> PAAPI.V2Signer.urlEscape stringToEscape
            ]


main : BenchmarkProgram
main =
    program suite
