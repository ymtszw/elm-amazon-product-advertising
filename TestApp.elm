module TestApp exposing (main)

import Time
import Task
import Xml.Decode
import PAAPI


type alias Model =
    { creds : PAAPI.Credentials
    , tag : PAAPI.AssociateTag
    }


type Msg
    = GetRes (Result PAAPI.Error (List String))
    | PostRes (Result PAAPI.Error (List String))


init : Model -> ( Model, Cmd Msg )
init flags =
    ( flags
    , tryGetCmd flags
    )


tryGetCmd : Model -> Cmd Msg
tryGetCmd { creds, tag } =
    PAAPI.doGet PAAPI.JP
        creds
        tag
        (Xml.Decode.path [ "Items", "Item", "ASIN" ] (Xml.Decode.list Xml.Decode.string))
        [ ( "Operation", "ItemSearch" )
        , ( "SearchIndex", "Books" )
        , ( "Keywords", "われはロボット" )
        ]
        |> Task.attempt GetRes


tryPostCmd : Model -> Cmd Msg
tryPostCmd { creds, tag } =
    PAAPI.doPost PAAPI.JP
        creds
        tag
        (Xml.Decode.path [ "Items", "Item", "ASIN" ] (Xml.Decode.list Xml.Decode.string))
        [ ( "Operation", "ItemSearch" )
        , ( "SearchIndex", "Books" )
        , ( "Keywords", "われはロボット" )
        ]
        |> Task.attempt PostRes


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetRes (Ok asins) ->
            Debug.log "GET request successful" asins |> always ( model, tryPostCmd model )

        PostRes (Ok asins) ->
            Debug.log "POST request successful" asins |> always ( model, Cmd.none )

        GetRes (Err PAAPI.RateLimit) ->
            ( model, tryGetCmd model )

        PostRes (Err PAAPI.RateLimit) ->
            ( model, tryPostCmd model )

        _ ->
            -- Unexpectedly failed
            Debug.crash "Request unexpectedly failed!"


main : Program Model Model Msg
main =
    Platform.programWithFlags
        { init = init
        , update = update
        , subscriptions = always Sub.none
        }
