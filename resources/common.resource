*** Settings ***
Documentation    Shared browser session setup and teardown for the guest journey.

Resource         libraries.resource
Resource         search.resource
Resource         product.resource
Resource         basket.resource
Resource         checkout.resource


*** Variables ***
${BASE_URL}    https://www.shop-apotheke.com
${HEADLESS}    ${True}
${DENY_COOKIES_BUTTON}    button[data-testid="uc-deny-all-button"]


*** Keywords ***
Start Isolated Guest Session
    [Documentation]    Open a fresh browser context and verify the guest basket is empty.
    New Browser    chromium    headless=${HEADLESS}
    New Context    viewport={'width': 1440, 'height': 900}    locale=de-DE
    New Page    ${BASE_URL}/    wait_until=domcontentloaded
    Handle Cookie Consent If Present
    Open Basket
    Get Element States    [data-qa-id="cart-empty-container"]    contains    visible
    Click    a[data-qa-id="brand-log"]:visible
    Get Url    ==    ${BASE_URL}/

Handle Cookie Consent If Present
    [Documentation]    Allow a late consent prompt to appear and dismiss it when visible.
    TRY
        Wait For Elements State    ${DENY_COOKIES_BUTTON}    visible    timeout=5s
    EXCEPT    *Timeout*    type=GLOB
        RETURN
    END
    Click    ${DENY_COOKIES_BUTTON}

Close Guest Session
    [Documentation]    Capture failure details when possible, then close the context and browser.
    IF    '${TEST STATUS}' == 'FAIL'
        Run Keyword And Warn On Failure    Log Current Page URL
        Run Keyword And Warn On Failure    Take Screenshot
    END
    Close Context
    Close Browser

Log Current Page URL
    [Documentation]    Log the current URL to help diagnose a failed test.
    ${url}=    Get Url
    Log    Current URL on failure: ${url}
