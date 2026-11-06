*** Settings ***
Documentation    Guest checkout journey. No credentials are entered and no order is placed.

Resource         ../../resources/common.resource

Test Setup       Start Isolated Guest Session
Test Teardown    Close Guest Session


*** Variables ***
${IBUPROFEN}    18300010
${PANTHENOL}    20175954


*** Test Cases ***
Guest Compares Panthenol Price Before Checkout
    [Documentation]    Compare the search and basket prices before reaching authentication as a guest.
    Find Product Suggestion    ${IBUPROFEN}
    Open Suggested Product    ${IBUPROFEN}
    Add Product Once    ${IBUPROFEN}
    Basket Quantity Should Be    ${IBUPROFEN}    1

    Find Product Suggestion    ${PANTHENOL}
    ${search_raw}    ${search_price}=    Get Search Selling Price    ${PANTHENOL}
    Open Suggested Product    ${PANTHENOL}
    Add Product Once    ${PANTHENOL}

    Basket Quantity Should Be    ${PANTHENOL}    1
    Increase Basket Quantity By One    ${IBUPROFEN}    1
    ${basket_raw}    ${basket_price}=    Get Basket Line Total    ${PANTHENOL}
    Log
    ...    Basket line total for PZN ${PANTHENOL}, quantity=1: raw="${basket_raw}", normalized=${basket_price} EUR
    ...    console=True
    ${message}=    Catenate    SEPARATOR=${SPACE}
    ...    Price mismatch for PZN ${PANTHENOL}, quantity=1: search raw="${search_raw}" normalized=${search_price} EUR;
    ...    basket raw="${basket_raw}" normalized=${basket_price} EUR
    Should Be Equal    ${basket_price}    ${search_price}    msg=${message}
    Proceed To Authentication
