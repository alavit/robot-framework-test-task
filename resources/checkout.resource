*** Settings ***
Documentation    Checkout navigation up to the authentication page.

Resource         libraries.resource


*** Keywords ***
Proceed To Authentication
    [Documentation]    Open checkout and verify that the authentication page is displayed.
    Click    button[data-qa-id="form-cart-sumBox-doCheckout-button"]
    Get Url    *=    /nx/login/?
    Get Url    *=    targetPageCode=checkoutAddress
    Get Element States    [data-qa-id="login-registration-page"]    contains    visible
    Get Element States    form[data-qa-id="loginModal"] input[data-qa-id="login-form-username"]    contains    visible
    Get Element States
    ...    form[data-qa-id="loginModal"] button[data-qa-id="login-form-loginForm-submit-button"]
    ...    contains
    ...    visible
