module PAAPI
    exposing
        ( Credentials
        , AssociateTag
        , Locale(..)
        , Error(..)
        , get
        , post
        , endpoint
        , doGet
        , doPost
        )

{-| Amazon Product Advertising API (PAAPI) Client module.

Performs AWS V2 signing for request authentication.

<http://docs.aws.amazon.com/AWSECommerceService/latest/DG/Query_QueryAuth.html>


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
import PAAPI.Internal as Internal
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


{-| Generates `Http.Request` to PAAPI with GET.

All parameters appear in query parameters of request URL.
For that it will fail with Bad Request when requests got longer.

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
    params
        |> timedParams time
        |> Internal.signedUrlForGet (endpoint locale)
            creds
            tag
        |> flip Http.Xml.get decoder


timedParams : Time -> List ( String, String ) -> List ( String, String )
timedParams time params =
    ( "Timestamp", toUtcIsoString time ) :: params


{-| Generates `Http.Request` to PAAPI with POST.

All parameters appear in request body.

-}
post :
    Time
    -> Locale
    -> Credentials
    -> AssociateTag
    -> Decoder a
    -> List ( String, String )
    -> Http.Request a
post time locale creds tag decoder params =
    params
        |> timedParams time
        |> Internal.signedParamsForPost (endpoint locale)
            creds
            tag
        |> flip (uncurry Http.Xml.post) decoder


{-| Task to attempt GET request to PAAPI.
-}
doGet : Locale -> Credentials -> AssociateTag -> Decoder a -> List ( String, String ) -> Task Error a
doGet locale creds tag decoder params =
    Time.now
        |> Task.andThen (\time -> get time locale creds tag decoder params |> Http.toTask)
        |> Task.mapError convertError


{-| Task to attempt POST request to PAAPI.
-}
doPost : Locale -> Credentials -> AssociateTag -> Decoder a -> List ( String, String ) -> Task Error a
doPost locale creds tag decoder params =
    Time.now
        |> Task.andThen (\time -> post time locale creds tag decoder params |> Http.toTask)
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
