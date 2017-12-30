module PAAPI.Internal exposing (signedUrl)

import PAAPI.V2Signer as Signer exposing (Method(GET))


signedUrl :
    String
    -> { accessKeyId : String, secretAccessKey : String }
    -> String
    -> List ( String, String )
    -> String
signedUrl endpoint { accessKeyId, secretAccessKey } tag params =
    Signer.signedUrl GET
        endpoint
        paapiPath
        accessKeyId
        secretAccessKey
        (requiredParams tag ++ params)


paapiPath : String
paapiPath =
    "/onca/xml"


requiredParams : String -> List ( String, String )
requiredParams tag =
    [ ( "Service", "AWSECommerceService" )
    , ( "Version", "2013-08-01" ) -- Optional, though include it for locking
    , ( "AssociateTag", tag )
    ]
