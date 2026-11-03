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
    Wait For Load State    load

Handle Cookie Consent If Present
    [Documentation]    Wait for the consent prompt or search box and deny consent if prompted.
    # Usercentrics renders inside a shadow root; absence is valid for this session.
    Wait For Elements State
    ...    button[data-testid="uc-deny-all-button"]:visible, input[data-qa-id="search-box-query"]:visible >> nth=0
    ...    visible
    ...    timeout=10s
    ${present}=    Get Element Count    button[data-testid="uc-deny-all-button"]:visible
    IF    ${present} > 0    Click    button[data-testid="uc-deny-all-button"]

Close Guest Session
    [Documentation]    Capture failure details when possible, then close the context and browser.
    IF    '${TEST STATUS}' == 'FAIL'
        Run Keyword And Warn On Failure    Log Current Page URL
        Run Keyword And Warn On Failure    Take Screenshot
    END
    Run Keyword And Warn On Failure    Close Context
    Run Keyword And Warn On Failure    Close Browser

Log Current Page URL
    [Documentation]    Log the current URL to help diagnose a failed test.
    ${url}=    Get Url
    Log    Current URL on failure: ${url}
