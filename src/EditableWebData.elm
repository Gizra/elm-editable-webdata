module EditableWebData
    exposing
        ( EditableWebData(..)
        , create
        , mapEditable
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

@docs EditableWebData, create, mapEditable, value, webDataUpdate, webDataValue

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


{-| Maps function to the `Editable`.

    import Editable

    EditableWebData.create "old"
        |> EditableWebData.mapEditable (Editable.edit)
        |> EditableWebData.mapEditable (Editable.update "new")
        |> EditableWebData.value
        |> Editable.value --> "new"

-}
mapEditable : (Editable a -> Editable a) -> EditableWebData a -> EditableWebData a
mapEditable f (EditableWebData editable webData) =
    EditableWebData (f editable) webData


{-| Updates the `WebData` value.

For updating the value of the `Editable` itself, see the example of `mapEditable`.

    import RemoteData

    EditableWebData.create "new"
        |> EditableWebData.webDataUpdate RemoteData.Loading
        |> EditableWebData.webDataValue --> RemoteData.Loading

    EditableWebData.create "new"
        |> EditableWebData.webDataUpdate (RemoteData.Success ())
        |> EditableWebData.webDataValue --> RemoteData.Success ()

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

    import RemoteData

    EditableWebData.create "new"
        |> EditableWebData.webDataValue --> RemoteData.NotAsked

    EditableWebData.create "new"
        |> EditableWebData.webDataUpdate RemoteData.Loading
        |> EditableWebData.webDataValue --> RemoteData.Loading

-}
webDataValue : EditableWebData a -> WebData ()
webDataValue (EditableWebData _ x) =
    x
