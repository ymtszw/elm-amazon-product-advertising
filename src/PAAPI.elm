module PAAPI
    exposing
        ( Credentials
        , AssociateTag
        , Locale(..)
        , Error(..)
        , get
        , endpoint
        , doGet
        )

{-| Amazon Product Advertising API (PAAPI) Client module.

Performs AWS V2 signing for request authentication.

<http://docs.aws.amazon.com/AWSECommerceService/latest/DG/Query_QueryAuth.html>

It uses GET request with query strings in URL.


## Types

@docs Locale, Credentials, AssociateTag, Error


## APIs

@docs get, doGet


## Helpers

@docs endpoint

-}

import Task exposing (Task)
import Time exposing (Time)
import Http
import Http.Xml
import Xml.Decode exposing (Decoder)
import PAAPI.Internal exposing (signedUrl)
import PAAPI.Time exposing (toUtcIsoString)


{-| Locales available in PAAPI.

<https://docs.aws.amazon.com/AWSECommerceService/latest/DG/Locales.html>

-}
type Locale
    = BR
    | CA
    | CN
    | FR
    | DE
    | IN
    | IT
    | JP
    | MX
    | ES
    | UK
    | US


{-| Credentials required for PAAPI.
-}
type alias Credentials =
    { accessKeyId : String
    , secretAccessKey : String
    }


{-| Associate tag required for PAAPI.

<https://docs.aws.amazon.com/AWSECommerceService/latest/DG/AssociateTag.html>

-}
type alias AssociateTag =
    String


{-| Dict of `Locale` to endpoint domain.
-}
endpoint : Locale -> String
endpoint locale =
    case locale of
        BR ->
            "webservices.amazon.com.br"

        CA ->
            "webservices.amazon.ca"

        CN ->
            "webservices.amazon.cn"

        FR ->
            "webservices.amazon.fr"

        DE ->
            "webservices.amazon.de"

        IN ->
            "webservices.amazon.in"

        IT ->
            "webservices.amazon.it"

        JP ->
            "webservices.amazon.co.jp"

        MX ->
            "webservices.amazon.com.mx"

        ES ->
            "webservices.amazon.es"

        UK ->
            "webservices.amazon.co.uk"

        US ->
            "webservices.amazon.com"


{-| Error representation of PAAPI.

In case of rate-limit, PAAPI returns HTTP 503,
that will be translated to `RateLimit`.
Other `Http.Error` will be wrapped in `HttpError`.

-}
type Error
    = RateLimit
    | HttpError Http.Error


{-| Generate `Http.Request` to PAAPI.

Always uses GET method.

-}
get :
    Time
    -> Locale
    -> Credentials
    -> AssociateTag
    -> Decoder a
    -> List ( String, String )
    -> Http.Request a
get time locale creds tag decoder params =
    Http.Xml.get
        (signedUrl (endpoint locale)
            creds
            tag
            (( "Timestamp", toUtcIsoString time ) :: params)
        )
        decoder


{-| Task to attempt requesting PAAPI.

It fetches current time and generate GET request to PAAPI, then send it.

-}
doGet : Locale -> Credentials -> AssociateTag -> Decoder a -> List ( String, String ) -> Task Error a
doGet locale creds tag decoder params =
    let
        getTask time =
            Http.toTask <| get time locale creds tag decoder params
    in
        Time.now
            |> Task.andThen getTask
            |> Task.mapError convertError



-- HELPERS


convertError : Http.Error -> Error
convertError error =
    case error of
        Http.BadStatus { status } ->
            case status.code of
                503 ->
                    RateLimit

                _ ->
                    HttpError error

        _ ->
            HttpError error
