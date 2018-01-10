module PAAPI.Internal exposing (signedUrlForGet, signedParamsForPost)

import Http
import PAAPI.V2Signer as Signer exposing (Method(GET, POST))


signedUrlForGet :
    String
    -> { accessKeyId : String, secretAccessKey : String }
    -> String
    -> List ( String, String )
    -> String
signedUrlForGet endpoint { accessKeyId, secretAccessKey } tag params =
    Signer.signedUrl GET
        endpoint
        paapiPath
        accessKeyId
        secretAccessKey
        (requiredParams tag ++ params)


signedParamsForPost :
    String
    -> { accessKeyId : String, secretAccessKey : String }
    -> String
    -> List ( String, String )
    -> ( String, Http.Body )
signedParamsForPost endpoint { accessKeyId, secretAccessKey } tag params =
    ( "https://" ++ endpoint ++ paapiPath
    , Signer.signedParams POST
        endpoint
        paapiPath
        accessKeyId
        secretAccessKey
        (requiredParams tag ++ params)
        |> Http.stringBody "application/x-www-form-urlencoded; charset=utf-8"
    )


paapiPath : String
paapiPath =
    "/onca/xml"


requiredParams : String -> List ( String, String )
requiredParams tag =
    [ ( "Service", "AWSECommerceService" )
    , ( "Version", "2013-08-01" ) -- Optional, though include it for locking
    , ( "AssociateTag", tag )
    ]
