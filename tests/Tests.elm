module Tests exposing (..)

import Editable
import EditableWebData exposing (EditableWebData(..))
import Expect
import Fuzz exposing (..)
import Test exposing (..)


all : Test
all =
    describe "EditableWebData"
        [ describe "#value"
            [ fuzz string "return the `Editable` value" <|
                \value ->
                    EditableWebData.notAskedReadOnly value
                        |> EditableWebData.value
                        |> Expect.equal (Editable.ReadOnly value)
            ]
        ]
