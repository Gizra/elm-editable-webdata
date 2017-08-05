module Tests exposing (..)

import Editable
import Editable.WebData exposing (EditableWebData(..))
import Expect
import Fuzz exposing (..)
import Test exposing (..)


all : Test
all =
    describe "Editable.WebData"
        [ describe "#toEditable"
            [ fuzz string "return the `Editable` value" <|
                \value ->
                    Editable.WebData.notAskedReadOnly value
                        |> Editable.WebData.toEditable
                        |> Expect.equal (Editable.ReadOnly value)
            ]
        ]
