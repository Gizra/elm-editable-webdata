module EditableWebData
    exposing
        ( EditableWebData(..)
        , map
        , notAskedReadOnly
        , state
        , toEditable
        , toWebData
        )

{-| An EditableWebData represents an Editable value, along with WebData.

`EditableWebData` is a wrapper type around [Editable](http://package.elm-lang.org/packages/stoeffel/editable/latest)
and [WebData](http://package.elm-lang.org/packages/krisajenkins/remotedata/latest)

It is used in order to keep track of the state of the Editable upon saving. That is,
as we change teh `Editable` toEditable, and send it to the backend, we can keep track of their status
(e.g. `RemoteData.Success` or `RemoteData.Failure`).

@docs EditableWebData, notAskedReadOnly, map, toEditable, state, toWebData

-}

import Editable exposing (Editable(..))
import RemoteData exposing (RemoteData(..), WebData)


{-| A wrapper for `Editable`, that allows provides the means to track saving
back to the backend via `WebData`.

    import Editable

    view : EditableWebData String -> Html msg
    view editableWebData =
        let
            toEditable =
                EditableWebData.toEditable |> Editable.value

            toWebData =
                EditableWebData.toWebData
        in
        text <| "Editable value is: " ++ toString toEditable ++ " with a WebDataValue of " ++ toString toWebData

-}
type EditableWebData a
    = EditableWebData (Editable a) (WebData ())


{-| Creates a new `EditableWebData`.
-}
notAskedReadOnly : a -> EditableWebData a
notAskedReadOnly record =
    EditableWebData (Editable.ReadOnly record) NotAsked


{-| Maps function to the `Editable`.

    import Editable

    EditableWebData.notAskedReadOnly "old"
        |> EditableWebData.map (Editable.edit)
        |> EditableWebData.map (Editable.update "new")
        |> EditableWebData.toEditable
        |> Editable.value --> "new"

-}
map : (Editable a -> Editable b) -> EditableWebData a -> EditableWebData b
map f (EditableWebData editable webData) =
    EditableWebData (f editable) webData


{-| Updates the `WebData` toEditable.

For updating the toEditable of the `Editable` itself, see the example of `map`.

    import RemoteData

    EditableWebData.notAskedReadOnly "new"
        |> EditableWebData.state RemoteData.Loading
        |> EditableWebData.toWebData --> RemoteData.Loading

    EditableWebData.notAskedReadOnly "new"
        |> EditableWebData.state (RemoteData.Success ())
        |> EditableWebData.toWebData --> RemoteData.Success ()

-}
state : WebData () -> EditableWebData a -> EditableWebData a
state newWebData (EditableWebData editable webData) =
    EditableWebData editable newWebData


{-| Extracts the `Editable` toEditable.

    import Editable

    EditableWebData.notAskedReadOnly "new"
        |> EditableWebData.toEditable --> Editable.ReadOnly "new"

    EditableWebData.notAskedReadOnly "old"
        |> EditableWebData.map(Editable.edit)
        |> EditableWebData.map(Editable.update "new")
        |> EditableWebData.toEditable --> Editable.Editable "old" "new"

-}
toEditable : EditableWebData a -> Editable a
toEditable (EditableWebData x _) =
    x


{-| Extracts the `WebData` toEditable.

    import RemoteData

    EditableWebData.notAskedReadOnly "new"
        |> EditableWebData.toWebData --> RemoteData.NotAsked

    EditableWebData.notAskedReadOnly "new"
        |> EditableWebData.state RemoteData.Loading
        |> EditableWebData.toWebData --> RemoteData.Loading

-}
toWebData : EditableWebData a -> WebData ()
toWebData (EditableWebData _ x) =
    x
