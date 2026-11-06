*** Settings ***
Documentation    Search suggestions and their displayed selling prices.

Resource         libraries.resource


*** Variables ***
${SEARCH_BOX}    input[data-qa-id="search-box-query"]


*** Keywords ***
Find Product Suggestion
    [Documentation]    Search for a product by PZN.
    [Arguments]    ${pzn}
    Click    ${SEARCH_BOX}
    Wait For Elements State    ${SEARCH_BOX}    focused
    Wait For Elements State    [data-qa-id="suggest-list"]    visible
    Fill Text    ${SEARCH_BOX}    ${pzn}
    ${suggestion}=    Suggestion Selector    ${pzn}
    Wait For Elements State    ${suggestion}    visible

Get Search Selling Price
    [Documentation]    Return the raw and parsed selling price from the product suggestion.
    [Arguments]    ${pzn}
    ${suggestion}=    Suggestion Selector    ${pzn}
    VAR    ${prices}=    ${suggestion} [data-qa-id="product-prices-list-in-suggest"]
    ${raw}=    Get Text    ${prices} > div:first-child
    ${price}=    Parse Euro Price    ${raw}
    Log    Search price for PZN ${pzn}: raw="${raw}", normalized=${price} EUR    console=True
    RETURN    ${raw}    ${price}

Open Suggested Product
    [Documentation]    Open the suggested product matching the PZN.
    [Arguments]    ${pzn}
    ${suggestion}=    Suggestion Selector    ${pzn}
    Click    ${suggestion}

Suggestion Selector
    [Documentation]    Return the search suggestion selector for the PZN.
    [Arguments]    ${pzn}
    RETURN    a[data-qa-id="suggest-items"][href*="/${pzn}/"]
