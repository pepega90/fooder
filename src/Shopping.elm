module Shopping exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias Makanan =
    { id : Int
    , nama : String
    , img : String
    , harga : Float
    }


type alias CartFood =
    { id : Int
    , nama : String
    , harga : Float
    , qty : Int
    }


seedMakanan : List Makanan
seedMakanan =
    [ Makanan 1 "Bakso Malang" "https://img-global.cpcdn.com/recipes/4e4073d7dcc225a8/680x482cq70/84-bakso-malang-ala-mamang-yang-lewat-depan-rumah-foto-resep-utama.webp" 5000
    , Makanan 2 "Nasi Goreng" "https://img-global.cpcdn.com/recipes/941d382eeb82c620/680x482cq70/nasi-goreng-ala-resto-chinese-food-foto-resep-utama.webp" 14000
    , Makanan 3 "Martabak Telur" "https://img-global.cpcdn.com/recipes/dd94640e66555cfa/680x482cq70/martabak-tahu-telur-kulit-lumpia-foto-resep-utama.webp" 10000
    ]


toRupiah : Float -> String
toRupiah price =
    let
        -- Convert the price to an integer for simplicity if it's a whole number
        roundedPrice =
            round price

        -- Convert to a string
        priceStr =
            String.fromInt roundedPrice

        -- Reverse the string to simplify adding dots every three digits
        reversedStr =
            String.reverse priceStr

        -- Function to insert dots every three characters in the reversed string
        insertDots : String -> String
        insertDots str =
            if String.length str <= 3 then
                str

            else
                String.slice 0 3 str ++ "." ++ insertDots (String.dropLeft 3 str)
    in
    -- Reverse back, add dots, then concatenate with "Rp" prefix
    "Rp" ++ String.reverse (insertDots reversedStr)


findMakanan : Int -> List Makanan -> Maybe Makanan
findMakanan idMakan makanans =
    List.foldl
        (\makanan acc ->
            case acc of
                Just _ ->
                    acc

                Nothing ->
                    if makanan.id == idMakan then
                        Just makanan

                    else
                        Nothing
        )
        Nothing
        makanans


type alias Model =
    { makanans : List Makanan
    , carts : List CartFood
    , total : Float
    , checkout : Bool
    }


type Msg
    = MsgDummy
    | AddToCart Int
    | ChangeQty Int
    | Beli


initModel : Model
initModel =
    { makanans = seedMakanan
    , carts = []
    , total = 0
    , checkout = False
    }


view : Model -> Html Msg
view model =
    div []
        [ div []
            [ div [ class "has-background-primary" ] [ h1 [ class "title p-2 has-text-white" ] [ text "Fooder" ] ]
            , div
                [ style "display" "flex"
                , style "justify-content" "space-around"
                , style "margin-top" "25px"
                ]
                (List.map foodList model.makanans)
            ]
        , h2
            [ class "title is-4"
            , style "text-align" "center"
            , style "margin-top" "50px"
            ]
            [ text "Cart" ]
        , hr [] []
        , case model.checkout of
            True ->
                h1 [ class "title has-text-centered is-5" ]
                    [ text "Terima kasih telah berbelanja! 🛒"
                    ]

            False ->
                tableCart model.carts model.total
        ]


foodList : Makanan -> Html Msg
foodList makan =
    div [ class "card", style "width" "200px", style "height" "300px" ]
        [ div [ class "card-image" ]
            [ figure []
                [ img [ alt "img", src makan.img, style "width" "100%" ]
                    []
                ]
            ]
        , div [ class "card-content" ]
            [ div [ class "media" ]
                [ div [ class "media-content" ]
                    [ p [ class "title is-5" ]
                        [ text makan.nama ]
                    , p [ class "subtitle is-6" ]
                        [ text (toRupiah makan.harga) ]
                    ]
                ]
            , div [ class "content" ]
                [ button [ class "button is-primary", onClick (AddToCart makan.id) ]
                    [ text "Add To Cart" ]
                ]
            ]
        ]



-- div []
--     [ h1 [] [ text makan.nama ]
--     , p [] [ text (toRupiah makan.harga) ]
--     , button [ onClick (AddToCart makan.id) ] [ text "Add to Cart" ]
--     ]


tableCart : List CartFood -> Float -> Html Msg
tableCart carts total =
    div [ class "container" ]
        [ table [ class "table is-striped is-hoverable is-fullwidth" ]
            [ thead []
                [ tr []
                    [ th [] [ text "No" ]
                    , th [] [ text "Nama Makanan" ]
                    , th [] [ text "Harga" ]
                    , th [] [ text "Quantity" ]
                    ]
                ]
            , tbody []
                (case carts of
                    [] ->
                        [ tr []
                            [ td [ colspan 4, class "has-text-centered" ]
                                [ text "Keranjang kosong. Checkout sekarang!" ]
                            ]
                        ]

                    _ ->
                        List.indexedMap viewCarts carts
                )
            ]
        , div [ class "section is-flex is-justify-content-space-between" ]
            [ button [ class "button is-success is-medium", onClick Beli ] [ text "Beli" ]
            , div []
                [ h1 [ class "title is-4" ] [ text "Total Harga" ]
                , p [ class "subtitle is-6" ] [ text <| toRupiah total ]
                ]
            ]
        ]


viewCarts : Int -> CartFood -> Html Msg
viewCarts index cf =
    tr []
        [ td [] [ text (String.fromInt (index + 1)) ]
        , td [] [ text cf.nama ]
        , td [] [ text (toRupiah cf.harga) ]
        , td []
            [ input [ type_ "number", class "input", value (String.fromInt cf.qty), onInput (\newQty -> ChangeQty cf.id) ] []
            ]
        ]


update : Msg -> Model -> Model
update msg model =
    case msg of
        AddToCart idMakan ->
            let
                food =
                    findMakanan idMakan model.makanans

                cartFood =
                    case food of
                        Just makanan ->
                            Just (CartFood makanan.id makanan.nama makanan.harga 0)

                        Nothing ->
                            Nothing

                itemExists cartItem =
                    case cartFood of
                        Just cf ->
                            cartItem.id == cf.id

                        Nothing ->
                            False

                updateCarts =
                    case cartFood of
                        Just cf ->
                            if List.any itemExists model.carts then
                                -- Item already exists, so we leave the carts unchanged.
                                model.carts

                            else
                                -- Item does not exist, append the new item.
                                model.carts ++ [ { id = cf.id, nama = cf.nama, harga = cf.harga, qty = 1 } ]

                        Nothing ->
                            model.carts

                updateTotal =
                    List.foldl (\e acc -> acc + (e.harga * toFloat e.qty)) 0 updateCarts
            in
            { model | carts = updateCarts, total = updateTotal }

        ChangeQty id ->
            let
                updatedCartFood =
                    List.map
                        (\e ->
                            if e.id == id then
                                { e | qty = e.qty + 1 }

                            else
                                e
                        )
                        model.carts

                updateTotal =
                    List.foldl (\e acc -> acc + (e.harga * toFloat e.qty)) 0 updatedCartFood
            in
            { model | carts = updatedCartFood, total = updateTotal }

        Beli ->
            { model | carts = [], checkout = True }

        MsgDummy ->
            model


main =
    Browser.sandbox
        { init = initModel
        , view = view
        , update = update
        }
