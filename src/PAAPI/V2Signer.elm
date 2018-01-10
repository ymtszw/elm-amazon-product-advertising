module PAAPI.V2Signer exposing (Method(..), signedUrl, signedParams, urlEscape, urlEscapeC)

{-| Generates AWS Request Signature V2 for PAAPI.
-}

import Bitwise
import Char
import Http
import Regex
import Crypto.HMAC as HMAC
import Word.Bytes as Bytes
import Word.Hex as Hex
import BinaryBase64


type Method
    = GET
    | POST


{-| Generates signed URL.

Always uses https.

-}
signedUrl : Method -> String -> String -> String -> String -> List ( String, String ) -> String
signedUrl method endpoint path accessKeyId secretAccessKey params =
    "https://"
        ++ endpoint
        ++ path
        ++ "?"
        ++ signedParams method endpoint path accessKeyId secretAccessKey params


{-| Generates URL-encoded signed parameters.
-}
signedParams : Method -> String -> String -> String -> String -> List ( String, String ) -> String
signedParams method endpoint path accessKeyId secretAccessKey params =
    let
        cp =
            canonicalParams <| ( "AWSAccessKeyId", accessKeyId ) :: params
    in
        cp ++ "&Signature=" ++ sign method endpoint path secretAccessKey cp


canonicalParams : List ( String, String ) -> String
canonicalParams params =
    params
        |> List.map (\( k, v ) -> urlEscapeC k ++ "=" ++ urlEscapeC v)
        |> List.sort
        |> String.join "&"


sign : Method -> String -> String -> String -> String -> String
sign method endpoint path secretAccessKey canonicalParams =
    canonicalRequest method endpoint path canonicalParams
        |> Bytes.fromUTF8
        |> HMAC.digestBytes HMAC.sha256 (Bytes.fromUTF8 secretAccessKey)
        |> BinaryBase64.encode
        |> urlEscapeC


canonicalRequest : Method -> String -> String -> String -> String
canonicalRequest method endpoint path canonicalParams =
    [ methodToString method
    , endpoint
    , path
    , canonicalParams
    ]
        |> String.join "\n"


methodToString : Method -> String
methodToString method =
    case method of
        GET ->
            "GET"

        POST ->
            "POST"


{-| Escapes strings per AWS's request signing standard (both V2 and current V4).

It basically uses `encodeURIComponent` of JavaScript (via `Http.encodeUri`),
though additionaly, replaces characters other than [URL-Unreserved characters][unr] and '*'.

[unr]: https://tools.ietf.org/html/rfc3986#section-2.3

See [here](http://docs.aws.amazon.com/AWSECommerceService/latest/DG/Query_QueryAuth.html)
for PAAPI authenticaton requirements (V2 signing).
And [here](https://github.com/aws/aws-sdk-js/blob/master/lib/util.js#L41)
for aws-sdk implementation.

-}
urlEscape : String -> String
urlEscape str =
    str
        |> Http.encodeUri
        |> Regex.replace Regex.All (Regex.regex (Regex.escape "*")) (\_ -> "%2A")


urlEscapeC : String -> String
urlEscapeC str =
    str
        |> Http.encodeUri
        |> String.foldr escapeReducer ""


{-| Keep URL-unreserved characters and '%', otherwise escape.
-}
escapeReducer : Char -> String -> String
escapeReducer char acc =
    let
        code =
            Char.toCode char
    in
        if isUnreserved code then
            String.cons char acc
        else
            toHex code "" ++ acc


isUnreserved : Int -> Bool
isUnreserved i =
    -- % - . _ ~
    List.member i [ 37, 45, 46, 95, 126 ]
        || -- 0-9
           (48 <= i && i <= 57)
        || -- A-Z
           (65 <= i && i <= 90)
        || -- a-z
           (97 <= i && i <= 122)


toHex : Int -> String -> String
toHex i acc =
    let
        escaped =
            "%" ++ (i |> Hex.fromByte |> String.toUpper) ++ acc
    in
        case Bitwise.shiftRightBy 8 i of
            0 ->
                escaped

            nonzero ->
                toHex nonzero escaped
