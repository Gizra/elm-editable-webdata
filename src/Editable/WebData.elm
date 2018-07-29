module Editable.WebData
    exposing
        ( EditableWebData
        , EditableWebDataWrapper
        , create
        , map
        , state
        , toEditable
        , toWebData
        )

{-| An EditableWebDataWrapper represents an Editable value, along with WebData.

`EditableWebDataWrapper` is a wrapper type around [Editable](http://package.elm-lang.org/packages/stoeffel/editable/latest)
and [WebData](http://package.elm-lang.org/packages/krisajenkins/remotedata/latest)

It is used in order to keep track of the state of the Editable upon saving. That is,
as we change the `Editable` value, and send it to the backend, we can keep track of their state
(e.g. `RemoteData.Success` or `RemoteData.Failure`).

@docs EditableWebData, EditableWebDataWrapper, create, map, toEditable, state, toWebData

-}

import Editable exposing (Editable(..))
import RemoteData exposing (RemoteData(..), WebData)


{-| Most typical use case, is to wrap an `Editable` value, and have a unit (`()`)
act the the value of the WebData.
-}
type alias EditableWebData a =
    EditableWebDataWrapper a ()


{-| A wrapper for `Editable`, that allows provides the means to track saving
back to the backend via `WebData`.

If there is not value for WebData to track (i.e. it doesn't need to hold the
success value), you can pass a unit value (`()`).

    import Editable

    view : EditableWebDataWrapper String -> Html msg
    view editableWebData =
        let
            value =
                Editable.WebData.toEditable |> Editable.value

            toWebData =
                Editable.WebData.toWebData
        in
        text <| "Editable value is: " ++ toString value ++ " with a WebDataValue of " ++ toString toWebData

-}
type EditableWebDataWrapper a b
    = EditableWebDataWrapper (Editable a) (WebData b)


{-| Creates a new `EditableWebDataWrapper`.

This will create the `EditableWebDataWrapper` with the default values `ReadOnly` for
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
create : a -> EditableWebDataWrapper a b
create record =
    EditableWebDataWrapper (Editable.ReadOnly record) NotAsked


{-| Maps function to the `Editable`.

    import Editable

    Editable.WebData.create "old"
        -- Convert to `Editable` and update the value in one go.
        |> Editable.WebData.map (Editable.edit >> Editable.map (always "new"))
        |> Editable.WebData.toEditable
        |> Editable.value --> "new"

    Editable.WebData.create "old"
        -- Convert to `Editable` and update the value in one go.
        |> Editable.WebData.map (Editable.edit >> Editable.map (\val -> val ++ " is now new"))
        |> Editable.WebData.toEditable
        |> Editable.value --> "old is now new"

-}
map : (Editable a -> Editable a) -> EditableWebDataWrapper a b -> EditableWebDataWrapper a b
map f (EditableWebDataWrapper editable webData) =
    EditableWebDataWrapper (f editable) webData


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
state : WebData b -> EditableWebDataWrapper a b -> EditableWebDataWrapper a b
state newWebData (EditableWebDataWrapper editable webData) =
    EditableWebDataWrapper editable newWebData


{-| Extracts the `Editable` value.

    import Editable

    Editable.WebData.create "new"
        |> Editable.WebData.toEditable --> Editable.ReadOnly "new"

    Editable.WebData.create "old"
        |> Editable.WebData.map(Editable.edit)
        |> Editable.WebData.map(Editable.update "new")
        |> Editable.WebData.toEditable --> Editable.Editable "old" "new"

-}
toEditable : EditableWebDataWrapper a b -> Editable a
toEditable (EditableWebDataWrapper x _) =
    x


{-| Extracts the `WebData` value.

    import RemoteData

    Editable.WebData.create "new"
        |> Editable.WebData.toWebData --> RemoteData.NotAsked

    Editable.WebData.create "new"
        |> Editable.WebData.state RemoteData.Loading
        |> Editable.WebData.toWebData --> RemoteData.Loading

-}
toWebData : EditableWebDataWrapper a b -> WebData b
toWebData (EditableWebDataWrapper _ x) =
    x
