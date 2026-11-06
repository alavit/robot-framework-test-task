*** Settings ***
Documentation    Product page checks and adding a product to the basket.

Resource         libraries.resource


*** Keywords ***
Add Product Once
    [Documentation]    Verify the product identity and default quantity, then add it once.
    [Arguments]    ${pzn}
    Get Element States    [data-qa-id="product-details-page"]    contains    visible
    Get Text    [data-qa-id="product-attribute-pzn"]    contains    ${pzn}
    Get Text    [data-qa-id="product-quantity-select"]    ==    1
    Click    button[data-qa-id="add-to-cart-button"]
    # Open the basket from the confirmation after the add operation completes.
    Click    [data-qa-id="cartIntermediateDrawer"] a[data-qa-id="cart-button"]
