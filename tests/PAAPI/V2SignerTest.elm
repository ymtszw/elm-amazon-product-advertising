module PAAPI.V2SignerTest exposing (suite)

import Expect exposing (..)
import Fuzz exposing (..)
import Test exposing (..)
import PAAPI.V2Signer as Signer


suite : Test
suite =
    describe "V2Signer"
        [ test "urlEscape should produce properly escaped string" <|
            \_ ->
                equal
                    (Signer.urlEscape "Aa0_-~*(Ω)%あいうå")
                    "Aa0_-~%2A(%CE%A9)%25%E3%81%82%E3%81%84%E3%81%86%C3%A5"
        , test "urlEscapeC should produce properly escaped string" <|
            \_ ->
                equal
                    (Signer.urlEscapeC "Aa0_-~*(Ω)%あいうå")
                    "Aa0_-~%2A%28%CE%A9%29%25%E3%81%82%E3%81%84%E3%81%86%C3%A5"
        ]
