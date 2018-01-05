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
                    (Signer.urlEscape "***")
                    "%2A%2A%2A"
        ]
