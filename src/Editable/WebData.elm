module Editable.WebData
    exposing
        ( EditableWebData(..)
        , create
        , map
        , state
        , toEditable
        , toWebData
        )

{-| An EditableWebData represents an Editable value, along with WebData.

`EditableWebData` is a wrapper type around [Editable](http://package.elm-lang.org/packages/stoeffel/editable/latest)
and [WebData](http://package.elm-lang.org/packages/krisajenkins/remotedata/latest)

It is used in order to keep track of the state of the Editable upon saving. That is,
as we change the `Editable` value, and send it to the backend, we can keep track of their state
(e.g. `RemoteData.Success` or `RemoteData.Failure`).

@docs EditableWebData, create, map, toEditable, state, toWebData

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
                Editable.WebData.toEditable |> Editable.value

            toWebData =
                Editable.WebData.toWebData
        in
        text <| "Editable value is: " ++ toString value ++ " with a WebDataValue of " ++ toString toWebData

-}
type EditableWebData a
    = EditableWebData (Editable a) (WebData ())


{-| Creates a new `EditableWebData`.

This will create the `EditableWebData` with the default values `ReadOnly` for
the `Editable` and `NotAsked` for the WebData, as those are the values you are
likely to begin with. You can of course later updated it, for example:

    import Editable
    import RemoteData

    -- Change the `Editable` value
    Editable.WebData.create "old"
        |> Editable.WebData.map (Editable.edit)
        |> Editable.WebData.map (Editable.update "new")
        |> Editable.WebData.toEditable
        |> Editable.value --> "new"

    -- Change the `WebData` state
    Editable.WebData.create "original"
        |> Editable.WebData.state RemoteData.Loading
        |> Editable.WebData.toWebData --> RemoteData.Loading

-}
create : a -> EditableWebData a
create record =
    EditableWebData (Editable.ReadOnly record) NotAsked


{-| Maps function to the `Editable`.

    import Editable

    Editable.WebData.create "old"
        |> Editable.WebData.map (Editable.edit)
        |> Editable.WebData.map (Editable.update "new")
        |> Editable.WebData.toEditable
        |> Editable.value --> "new"

-}
map : (Editable a -> Editable a) -> EditableWebData a -> EditableWebData a
map f (EditableWebData editable webData) =
    EditableWebData (f editable) webData


{-| Updates the `WebData` value.

For updating the value of the `Editable` itself, see the example of `map`.

    import RemoteData

    Editable.WebData.create "new"
        |> Editable.WebData.state RemoteData.Loading
        |> Editable.WebData.toWebData --> RemoteData.Loading

    Editable.WebData.create "new"
        |> Editable.WebData.state (RemoteData.Success ())
        |> Editable.WebData.toWebData --> RemoteData.Success ()

-}
state : WebData () -> EditableWebData a -> EditableWebData a
state newWebData (EditableWebData editable webData) =
    EditableWebData editable newWebData


{-| Extracts the `Editable` value.

    import Editable

    Editable.WebData.create "new"
        |> Editable.WebData.toEditable --> Editable.ReadOnly "new"

    Editable.WebData.create "old"
        |> Editable.WebData.map(Editable.edit)
        |> Editable.WebData.map(Editable.update "new")
        |> Editable.WebData.toEditable --> Editable.Editable "old" "new"

-}
toEditable : EditableWebData a -> Editable a
toEditable (EditableWebData x _) =
    x


{-| Extracts the `WebData` value.

    import RemoteData

    Editable.WebData.create "new"
        |> Editable.WebData.toWebData --> RemoteData.NotAsked

    Editable.WebData.create "new"
        |> Editable.WebData.state RemoteData.Loading
        |> Editable.WebData.toWebData --> RemoteData.Loading

-}
toWebData : EditableWebData a -> WebData ()
toWebData (EditableWebData _ x) =
    x
