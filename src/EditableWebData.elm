module EditableWebData
    exposing
        ( EditableWebData(..)
        , create
        , map
        , mapEditable
        , update
        , value
        , webDataUpdate
        , webDataValue
        )

{-| An EditableWebData represents an Editable value, along with WebData.

`EditableWebData` is a wrapper type around [Editable](http://package.elm-lang.org/packages/stoeffel/editable/latest)
and [WebData](http://package.elm-lang.org/packages/krisajenkins/remotedata/latest)

It is used in order to keep track of the state of the Editable upon saving. That is,
as we change teh `Editable` value, and send it to the backend, we can keep track of their status
(e.g. `RemoteData.Success` or `RemoteData.Failure`).

@docs EditableWebData, create, map, mapEditable, update, value, webDataUpdate, webDataValue

-}

import Editable exposing (Editable(..))
import RemoteData exposing (RemoteData(..), WebData)


{-| A wrapper for `Editable`, that allows provides the means to track saving
back to the backend via `WebData`.

    import Editable

    view : EditableWebData String -> Html msg
    view editableWebData =
        let
            value =
                EditableWebData.value |> Editable.value

            webDataValue =
                EditableWebData.webDataValue
        in
        text <| "Editable value is: " ++ toString value ++ " with a WebDataValue of " ++ toString webDataValue

-}
type EditableWebData a
    = EditableWebData (Editable a) (WebData ())


{-| Creates a new `EditableWebData`.
-}
create : a -> EditableWebData a
create record =
    EditableWebData (Editable.ReadOnly record) NotAsked


{-| Pipes function to `Editable.map`
-}
map : (a -> a) -> EditableWebData a -> EditableWebData a
map f (EditableWebData editable webData) =
    EditableWebData (Editable.map f editable) webData


{-| Maps `Editable` functions. That is, unlike `map` it keeps the `Editable`
value wrapped.
-}
mapEditable : (Editable a -> Editable a) -> EditableWebData a -> EditableWebData a
mapEditable f (EditableWebData editable webData) =
    EditableWebData (f editable) webData


{-| Pipes update to `Editable.update`.
-}
update : a -> EditableWebData a -> EditableWebData a
update value =
    map (always value)


{-| Updates the `WebData` value.
-}
webDataUpdate : WebData () -> EditableWebData a -> EditableWebData a
webDataUpdate newWebData (EditableWebData editable webData) =
    EditableWebData editable newWebData


{-| Extracts the `Editable` value.

    import Editable

    EditableWebData.create "new"
        |> EditableWebData.value --> Editable.ReadOnly "new"

    EditableWebData.create "old"
        |> EditableWebData.mapEditable(Editable.edit)
        |> EditableWebData.mapEditable(Editable.update "new")
        |> EditableWebData.value --> Editable.Editable "old" "new"

-}
value : EditableWebData a -> Editable a
value (EditableWebData x _) =
    x


{-| Extracts the `WebData` value.
-}
webDataValue : EditableWebData a -> WebData ()
webDataValue (EditableWebData _ x) =
    x
