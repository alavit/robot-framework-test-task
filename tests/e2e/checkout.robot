*** Settings ***
Documentation    Guest checkout journey. No credentials are entered and no order is placed.

Resource         ../resources/common.resource

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
    Add Product Once And Verify In Basket    ${IBUPROFEN}
    Find Product Suggestion    ${PANTHENOL}
    ${search_raw}    ${search_price}=    Get Search Selling Price    ${PANTHENOL}
    Open Suggested Product    ${PANTHENOL}
    Add Product Once And Verify In Basket    ${PANTHENOL}
    Increase Basket Quantity From One To Two    ${IBUPROFEN}
    Basket Price Should Match Search Price    ${PANTHENOL}    ${search_raw}    ${search_price}
    Proceed To Authentication
