module PAAPI.Time exposing (toUtcIsoString, toUtcDatetime)

import Time exposing (Time)


type alias PosixMillis =
    Int


type alias YearMonthDay =
    ( Int -- Year
    , Int -- Month
    , Int -- Day
    )


type alias TimeOfDay =
    ( Int -- Hour
    , Int -- Minute
    , Int -- Second
    )


type alias GregorianDateTime =
    ( YearMonthDay
    , TimeOfDay
    , Int -- Millis
    )


{-| Generate UTC ISO8601 timestamp.

Assuming the time is positive unix time, i.e. after 1970/1/1

-}
toUtcIsoString : Time -> String
toUtcIsoString =
    toPosixMillis >> toUtcDatetime >> formatToIsoString


{-| In core@5.x, `Time` is in `Float`
-}
toPosixMillis : Time -> PosixMillis
toPosixMillis =
    Time.inMilliseconds >> floor


{-| yyyy-MM-dd'T'HH:mm:ss.SSSxxx
-}
formatToIsoString : GregorianDateTime -> String
formatToIsoString ( ( y, mon, d ), ( h, min, s ), ms ) =
    [ String.padLeft 4 '0' (toString y)
    , "-"
    , String.padLeft 2 '0' (toString mon)
    , "-"
    , String.padLeft 2 '0' (toString d)
    , "T"
    , String.padLeft 2 '0' (toString h)
    , ":"
    , String.padLeft 2 '0' (toString min)
    , ":"
    , String.padLeft 2 '0' (toString s)
    , "."
    , String.padLeft 3 '0' (toString ms)
    , "Z"
    ]
        |> String.join ""


toUtcDatetime : PosixMillis -> GregorianDateTime
toUtcDatetime posixMillis =
    let
        ( posixDays, hms, ms ) =
            toUtcTimeOfDay posixMillis
    in
        ( toUtcYearMonthDay posixDays
        , hms
        , ms
        )


toUtcTimeOfDay : PosixMillis -> ( Int, TimeOfDay, Int )
toUtcTimeOfDay posixMillis =
    let
        millis =
            posixMillis % 1000

        posixSeconds =
            posixMillis // 1000

        second =
            posixSeconds % 60

        posixMinutes =
            posixSeconds // 60

        utcMinute =
            posixMinutes % 60

        posixHours =
            posixMinutes // 60

        utcHourOfDay =
            posixHours % 24

        posixDays =
            posixHours // 24
    in
        ( posixDays, ( utcHourOfDay, utcMinute, second ), millis )


toUtcYearMonthDay : Int -> YearMonthDay
toUtcYearMonthDay posixDays =
    let
        gregorianDays =
            posixDays + 719468

        -- 400-year period
        era =
            gregorianDays // 146097

        -- [0, 146096]
        dayOfEra =
            gregorianDays % 146097

        -- [0, 399]
        yearOfEra =
            (dayOfEra - dayOfEra // 1460 + dayOfEra // 36524 - dayOfEra // 146096) // 365

        year =
            yearOfEra + era * 400

        -- [0, 365]
        dayOfYear =
            dayOfEra - (365 * yearOfEra + yearOfEra // 4 - yearOfEra // 100)

        -- [0, 11]
        mp =
            (5 * dayOfYear + 2) // 153

        -- [1, 12]
        month =
            mp + (ite (mp < 10) 3 -9)
    in
        ( year + (ite (month <= 2) 1 0)
        , month
        , dayOfYear - (153 * mp + 2) // 5 + 1
        )



-- HELPERS


ite : Bool -> a -> a -> a
ite p t f =
    if p then
        t
    else
        f
