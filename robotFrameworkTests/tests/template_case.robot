*** Settings ***
Documentation     Template test case for one pairwise vector.
Library           SeleniumLibrary
Library           Collections
Library           BuiltIn
Suite Setup       No Operation
Suite Teardown    No Operation
Test Setup        Open App Headless
Test Teardown     Template Test Teardown

*** Variables ***
# `APP_URL` points to the MDS_html.html in the repository root
# Template file now lives in robotFrameworkTests/tests, so go two levels up
${APP_URL}        file://${CURDIR}/../../MDS_html.html
${SCREENSHOT_DIR}  ${CURDIR}/../../results_full/screenshots
${BROWSER}        chrome
${RESIDENT_NAME}  Test Resident
${AGE}            70
${ARD}            
${DPOA}           John Doe
${ORIENTATION}    
${BIMS}           
${PHQ}            
${BEHAVIOR}       
${CARE_CONFERENCE}
${POLST}          
${NOTE_TYPE}      Admission

*** Test Cases ***
Pairwise Template Case
    [Tags]    regression    pairwise    ${BROWSER}    ${NOTE_TYPE}
    Wait Until Element Is Visible    id=residentName    5s
    Input Text    id=residentName    ${RESIDENT_NAME}
    Input Text    id=dpoa             ${DPOA}
    Run Keyword If    '${AGE}' != ''    Input Text    id=age    ${AGE}
    Run Keyword If    '${ARD}' != ''    Input Text    id=ard    ${ARD}
    Run Keyword If    '${ORIENTATION}' != ''    Select From List By Label    id=orientation    ${ORIENTATION}
    Run Keyword If    '${BIMS}' != ''    Select From List By Label    id=bims    ${BIMS}
    Run Keyword If    '${PHQ}' != ''    Select From List By Label    id=phq    ${PHQ}
    Run Keyword If    '${BEHAVIOR}' != ''    Select From List By Label    id=behavior    ${BEHAVIOR}
    Run Keyword If    '${CARE_CONFERENCE}' != ''    Select From List By Label    id=careConference    ${CARE_CONFERENCE}
    Run Keyword If    '${POLST}' != ''    Select From List By Label    id=polst    ${POLST}
    Run Keyword If    '${NOTE_TYPE}' != ''    Select From List By Label    id=noteType    ${NOTE_TYPE}
    Click Button    id=generateBtn
    Wait Until Element Is Visible    id=output    5s
    ${note}=    Get Value    id=output
    Should Contain    ${note}    ${RESIDENT_NAME}

*** Keywords ***
Open App Headless
    [Arguments]
    # Open browser directly using Selenium/WebDriver options so generated
    # tests do not rely on project-specific helper keywords.
    IF    '${BROWSER}' == 'chrome'
        ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
        Call Method    ${options}    add_argument    --headless
        Call Method    ${options}    add_argument    --no-sandbox
        ${status}    ${msg}=    Run Keyword And Ignore Error    Create WebDriver    Chrome    options=${options}
        Run Keyword If    '${status}' == 'FAIL'    Fail    Could not start Chrome WebDriver: ${msg}
    ELSE IF    '${BROWSER}' == 'firefox'
        ${options}=    Evaluate    sys.modules['selenium.webdriver'].FirefoxOptions()    sys, selenium.webdriver
        Call Method    ${options}    add_argument    -headless
        ${status}    ${msg}=    Run Keyword And Ignore Error    Create WebDriver    Firefox    options=${options}
        Run Keyword If    '${status}' == 'FAIL'    Fail    Could not start Firefox WebDriver: ${msg}
    ELSE IF    '${BROWSER}' == 'edge'
        ${options}=    Evaluate    sys.modules['selenium.webdriver'].EdgeOptions()    sys, selenium.webdriver
        Call Method    ${options}    add_argument    --headless
        ${status}    ${msg}=    Run Keyword And Ignore Error    Create WebDriver    Edge    options=${options}
        Run Keyword If    '${status}' == 'FAIL'    Fail    Could not start Edge WebDriver: ${msg}
    END
    Go To    ${APP_URL}

Template Test Teardown
    [Arguments]
    ${is_happy}=    Run Keyword And Return Status    List Should Contain Value    @{TEST_TAGS}    happy_path
    # Ensure screenshot dir exists (best-effort)
    Run Keyword And Ignore Error    Create Directory    ${SCREENSHOT_DIR}
    IF    '${TEST STATUS}' == 'FAIL'
        Capture Page Screenshot    ${SCREENSHOT_DIR}/${TEST_NAME}_FAIL.png
    END
    IF    ${is_happy}
        IF    '${TEST STATUS}' == 'PASS'
            Capture Page Screenshot    ${SCREENSHOT_DIR}/${TEST_NAME}_PASS.png
        END
    END
    Close Browser
