module Tests exposing (..)

import Editable
import EditableWebData exposing (EditableWebData(..))
import Expect
import Fuzz exposing (..)
import Test exposing (..)


all : Test
all =
    describe "EditableWebData"
        [ describe "#toEditable"
            [ fuzz string "return the `Editable` value" <|
                \value ->
                    EditableWebData.notAskedReadOnly value
                        |> EditableWebData.toEditable
                        |> Expect.equal (Editable.ReadOnly value)
            ]
        ]
