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
    Get Element States    text="Beliebte Produkte"    contains    visible
    Fill Text    ${SEARCH_BOX}    ${pzn}

Get Search Selling Price
    [Documentation]    Return the raw and parsed selling price from the product suggestion.
    [Arguments]    ${pzn}
    ${suggestion}=    Suggestion Selector    ${pzn}
    VAR    ${prices}=    ${suggestion} [data-qa-id="product-prices-list-in-suggest"]
    ${raw}=    Get Text    ${prices} >> xpath=./div[starts-with(normalize-space(text()), "€")]
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
