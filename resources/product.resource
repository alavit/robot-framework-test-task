*** Settings ***
Documentation    Product page checks and adding a product to the basket.
Resource         libraries.resource
Resource         basket.resource


*** Keywords ***
Add Product Once And Verify In Basket
    [Documentation]    Verify the product, add it once, and check its basket quantity.
    [Arguments]    ${pzn}
    Get Element States    [data-qa-id="product-details-page"]    contains    visible
    Get Text    [data-qa-id="product-attribute-pzn"]    contains    ${pzn}
    Get Text    [data-qa-id="product-quantity-select"]    ==    1
    Click    button[data-qa-id="add-to-cart-button"]
    # The intermediate cart link appears only after the add operation completes.
    Wait For Elements State    a[data-qa-id="cart-button"].button-deprecated    visible
    Click    a[data-qa-id="cart-button"].button-deprecated
    Get Url    *=    /nx/cart/
    Wait For Load State    load
    Basket Quantity Should Be    ${pzn}    1
