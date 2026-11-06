*** Settings ***
Documentation    Basket navigation, quantity checks, and price comparison.

Resource         libraries.resource


*** Keywords ***
Open Basket
    [Documentation]    Open the basket from the visible cart button.
    Click    header a[data-qa-id="cart-button"]:visible

Basket Row
    [Documentation]    Return the basket row selector for the given PZN.
    [Arguments]    ${pzn}
    RETURN    [data-qa-id="cart-entry-product"]:has([data-pzn="${pzn}"])

Basket Quantity Should Be
    [Documentation]    Verify the displayed quantity for a product.
    [Arguments]    ${pzn}    ${quantity}
    ${row}=    Basket Row    ${pzn}
    ${quantity}=    Convert To String    ${quantity}
    Get Text
    ...    ${row} [data-qa-id="cart-entry-quantity-select"]
    ...    ==
    ...    ${quantity}
    ...    message=Unexpected basket quantity for PZN ${pzn}; expected ${quantity}

Increase Basket Quantity By One
    [Documentation]    Check the starting quantity, click once, then verify the increment.
    [Arguments]    ${pzn}    ${current_quantity}
    ${row}=    Basket Row    ${pzn}
    Basket Quantity Should Be    ${pzn}    ${current_quantity}
    # The basket can render its quantity controls before their click handlers are ready.
    Wait For Load State    load
    Click    ${row} button[data-qa-id="form-cart-entry-increaseQuantity-button"]
    ${expected_quantity}=    Evaluate    ${current_quantity} + 1
    Basket Quantity Should Be    ${pzn}    ${expected_quantity}

Get Basket Line Total
    [Documentation]    Return the raw and parsed total price for one product row.
    [Arguments]    ${pzn}
    ${row}=    Basket Row    ${pzn}
    ${raw}=    Get Text    ${row} [data-qa-id="cart-entry-totalSumTerm"] > span
    ${price}=    Parse Euro Price    ${raw}
    RETURN    ${raw}    ${price}
