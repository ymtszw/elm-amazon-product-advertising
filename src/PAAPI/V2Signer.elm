module PAAPI.V2Signer exposing (Method(..), signedUrl, urlEscape)

{-| Generates AWS Request Signature V2 for PAAPI.
-}

import Http
import Regex
import Crypto.HMAC as HMAC
import Word.Bytes as Bytes
import BinaryBase64


type Method
    = GET
    | POST


{-| Generates signed URL.

Always uses https.

-}
signedUrl : Method -> String -> String -> String -> String -> List ( String, String ) -> String
signedUrl method endpoint path accessKeyId secretAccessKey params0 =
    let
        cp =
            canonicalParams <| ( "AWSAccessKeyId", accessKeyId ) :: params0

        signature =
            sign method endpoint path secretAccessKey cp
    in
        "https://"
            ++ endpoint
            ++ path
            ++ ("?" ++ cp)
            ++ ("&Signature=" ++ urlEscape signature)


canonicalParams : List ( String, String ) -> String
canonicalParams params =
    params
        |> List.map (\( k, v ) -> urlEscape k ++ "=" ++ urlEscape v)
        |> List.sort
        |> String.join "&"


sign : Method -> String -> String -> String -> String -> String
sign method endpoint path secretAccessKey canonicalParams =
    canonicalRequest method endpoint path canonicalParams
        |> Bytes.fromUTF8
        |> HMAC.digestBytes HMAC.sha256 (Bytes.fromUTF8 secretAccessKey)
        |> BinaryBase64.encode


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
though additionaly, replaces '*' to '%20'.

See [here](http://docs.aws.amazon.com/AWSECommerceService/latest/DG/Query_QueryAuth.html)
for PAAPI authenticaton requirements (V2 signing).
And [here](https://github.com/aws/aws-sdk-js/blob/master/lib/util.js#L41)
for aws-sdk implementation.

-}
urlEscape : String -> String
urlEscape str =
    str
        |> Http.encodeUri
        |> Regex.replace Regex.All (Regex.regex (Regex.escape "*")) (\_ -> "%20")
