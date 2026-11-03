*** Settings ***
Documentation    Basket navigation, quantity checks, and price comparison.
Resource         libraries.resource


*** Keywords ***
Open Basket
    [Documentation]    Open the basket from the visible cart button.
    Click    a[data-qa-id="cart-button"]:visible

Basket Row
    [Documentation]    Return the basket row selector for the given PZN.
    [Arguments]    ${pzn}
    VAR    ${row}=    [data-qa-id="cart-entry-product"]:has([data-pzn="${pzn}"])
    RETURN    ${row}

Basket Quantity Should Be
    [Documentation]    Verify the displayed quantity for a product.
    [Arguments]    ${pzn}    ${quantity}
    ${row}=    Basket Row    ${pzn}
    Get Text
    ...    ${row} [data-qa-id="cart-entry-quantity-select"]
    ...    ==
    ...    ${quantity}
    ...    message=Unexpected basket quantity for PZN ${pzn}; expected ${quantity}

Increase Basket Quantity From One To Two
    [Documentation]    Click once to increase the quantity and verify the result.
    [Arguments]    ${pzn}
    ${row}=    Basket Row    ${pzn}
    Click    ${row} button[data-qa-id="form-cart-entry-increaseQuantity-button"]
    Basket Quantity Should Be    ${pzn}    2

Get Basket Selling Price
    [Documentation]    Return the raw and parsed basket line price for a product.
    [Arguments]    ${pzn}
    ${row}=    Basket Row    ${pzn}
    ${raw}=    Get Text    ${row} [data-qa-id="cart-entry-totalSumTerm"] > span
    ${price}=    Parse Euro Price    ${raw}
    RETURN    ${raw}    ${price}

Basket Price Should Match Search Price
    [Documentation]    Compare the quantity-one basket price with the captured search price.
    [Arguments]    ${pzn}    ${search_raw}    ${search_price}
    Basket Quantity Should Be    ${pzn}    1
    ${basket_raw}    ${basket_price}=    Get Basket Selling Price    ${pzn}
    Log    Basket price for PZN ${pzn}, quantity=1: raw="${basket_raw}", normalized=${basket_price} EUR    console=True
    ${message}=    Catenate    SEPARATOR=${SPACE}
    ...    Price mismatch for PZN ${pzn}, quantity=1: search raw="${search_raw}" normalized=${search_price} EUR;
    ...    basket raw="${basket_raw}" normalized=${basket_price} EUR
    Should Be Equal
    ...    ${basket_price}
    ...    ${search_price}
    ...    msg=${message}
