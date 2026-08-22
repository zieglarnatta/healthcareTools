*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Library    Process

Suite Setup    Prepare Suite
Suite Teardown    Teardown Suite
Test Teardown    Capture Failure Screenshot

*** Variables ***
${HTML}    file://${CURDIR}/../../MDS_html.html
@{BROWSERS}    chrome    firefox    edge
${SCREEN_DIR}    ${CURDIR}/../../screenshots
${GECKO_PROC}    

*** Test Cases ***
Age, Name, and Calendar Field Limits - Chrome
    [Tags]    browser:chrome    regression_test
    Open Browser Headless    chrome
    ${ageMin}=    Get Element Attribute    id=age    min
    ${ageMax}=    Get Element Attribute    id=age    max
    Should Be Equal As Strings    ${ageMin}    18
    Should Be Equal As Strings    ${ageMax}    110
    ${nameMax}=    Get Element Attribute    id=residentName    maxlength
    ${dpoaMax}=    Get Element Attribute    id=dpoa    maxlength
    Should Be Equal As Strings    ${nameMax}    30
    Should Be Equal As Strings    ${dpoaMax}    30

    ${today}=    Evaluate    __import__('datetime').date.today().isoformat()
    ${minDate}=    Evaluate    (__import__('datetime').date.today() - __import__('datetime').timedelta(days=365)).isoformat()
    ${ardMin}=    Get Element Attribute    id=ard    min
    ${ardMax}=    Get Element Attribute    id=ard    max
    Should Be Equal As Strings    ${ardMin}    ${minDate}
    Should Be Equal As Strings    ${ardMax}    ${today}
    # behavior checks: typing over-long names should be truncated to maxlength
    ${longname}=    Evaluate    'A'*35
    Input Text    id=residentName    ${longname}
    ${val}=    Get Value    id=residentName
    ${len}=    Evaluate    len(r'''${val}''')
    Should Be Equal As Integers    ${len}    30
    ${longdpoa}=    Evaluate    'B'*35
    Input Text    id=dpoa    ${longdpoa}
    ${val2}=    Get Value    id=dpoa
    ${len2}=    Evaluate    len(r'''${val2}''')
    Should Be Equal As Integers    ${len2}    30

    # invalid age (below min) should prevent note generation
    Input Text    id=age    17
    Select From List By Label    id=noteType    Admission
    Click Button    id=generateBtn
    Sleep    0.5s
    ${note_low}=    Get Value    id=output
    Should Be Empty    ${note_low}

    # invalid age (above max) should prevent note generation
    Input Text    id=age    120
    Select From List By Label    id=noteType    Admission
    Click Button    id=generateBtn
    Sleep    0.5s
    ${note_high}=    Get Value    id=output
    Should Be Empty    ${note_high}

    # invalid ARD (future) should prevent note generation
    ${tomorrow}=    Evaluate    (__import__('datetime').date.today() + __import__('datetime').timedelta(days=1)).isoformat()
    Execute Javascript    document.getElementById('ard').value = '${tomorrow}';
    Input Text    id=age    82
    Select From List By Label    id=noteType    Admission
    Click Button    id=generateBtn
    Sleep    0.5s
    ${note}=    Get Value    id=output
    Should Be Empty    ${note}
    Close Browser

Age, Name, and Calendar Field Limits - Firefox
    [Tags]    browser:firefox    regression_test
    Open Browser Headless    firefox
    ${ageMin}=    Get Element Attribute    id=age    min
    ${ageMax}=    Get Element Attribute    id=age    max
    Should Be Equal As Strings    ${ageMin}    18
    Should Be Equal As Strings    ${ageMax}    110
    ${nameMax}=    Get Element Attribute    id=residentName    maxlength
    ${dpoaMax}=    Get Element Attribute    id=dpoa    maxlength
    Should Be Equal As Strings    ${nameMax}    30
    Should Be Equal As Strings    ${dpoaMax}    30

    ${today}=    Evaluate    __import__('datetime').date.today().isoformat()
    ${minDate}=    Evaluate    (__import__('datetime').date.today() - __import__('datetime').timedelta(days=365)).isoformat()
    ${ardMin}=    Get Element Attribute    id=ard    min
    ${ardMax}=    Get Element Attribute    id=ard    max
    Should Be Equal As Strings    ${ardMin}    ${minDate}
    Should Be Equal As Strings    ${ardMax}    ${today}
    # behavior checks: typing over-long names should be truncated to maxlength
    ${longname}=    Evaluate    'A'*35
    Input Text    id=residentName    ${longname}
    ${val}=    Get Value    id=residentName
    ${len}=    Evaluate    len(r'''${val}''')
    Should Be Equal As Integers    ${len}    30
    ${longdpoa}=    Evaluate    'B'*35
    Input Text    id=dpoa    ${longdpoa}
    ${val2}=    Get Value    id=dpoa
    ${len2}=    Evaluate    len(r'''${val2}''')
    Should Be Equal As Integers    ${len2}    30

    # invalid ARD (future) should prevent note generation
    ${tomorrow}=    Evaluate    (__import__('datetime').date.today() + __import__('datetime').timedelta(days=1)).isoformat()
    Execute Javascript    document.getElementById('ard').value = '${tomorrow}';
    Input Text    id=age    82
    Select From List By Label    id=noteType    Admission
    Click Button    id=generateBtn
    Sleep    0.5s
    ${note}=    Get Value    id=output
    Should Be Empty    ${note}
    Close Browser

Age, Name, and Calendar Field Limits - Edge
    [Tags]    browser:edge    regression_test
    Open Browser Headless    edge
    ${ageMin}=    Get Element Attribute    id=age    min
    ${ageMax}=    Get Element Attribute    id=age    max
    Should Be Equal As Strings    ${ageMin}    18
    Should Be Equal As Strings    ${ageMax}    110
    ${nameMax}=    Get Element Attribute    id=residentName    maxlength
    ${dpoaMax}=    Get Element Attribute    id=dpoa    maxlength
    Should Be Equal As Strings    ${nameMax}    30
    Should Be Equal As Strings    ${dpoaMax}    30

    ${today}=    Evaluate    __import__('datetime').date.today().isoformat()
    ${minDate}=    Evaluate    (__import__('datetime').date.today() - __import__('datetime').timedelta(days=365)).isoformat()
    ${ardMin}=    Get Element Attribute    id=ard    min
    ${ardMax}=    Get Element Attribute    id=ard    max
    Should Be Equal As Strings    ${ardMin}    ${minDate}
    Should Be Equal As Strings    ${ardMax}    ${today}
    # behavior checks: typing over-long names should be truncated to maxlength
    ${longname}=    Evaluate    'A'*35
    Input Text    id=residentName    ${longname}
    ${val}=    Get Value    id=residentName
    ${len}=    Evaluate    len(r'''${val}''')
    Should Be Equal As Integers    ${len}    30
    ${longdpoa}=    Evaluate    'B'*35
    Input Text    id=dpoa    ${longdpoa}
    ${val2}=    Get Value    id=dpoa
    ${len2}=    Evaluate    len(r'''${val2}''')
    Should Be Equal As Integers    ${len2}    30

    # invalid ARD (future) should prevent note generation
    ${tomorrow}=    Evaluate    (__import__('datetime').date.today() + __import__('datetime').timedelta(days=1)).isoformat()
    Execute Javascript    document.getElementById('ard').value = '${tomorrow}';
    Input Text    id=age    82
    Select From List By Label    id=noteType    Admission
    Click Button    id=generateBtn
    Sleep    0.5s
    ${note}=    Get Value    id=output
    Should Be Empty    ${note}
    Close Browser

Generate Note - Chrome
    [Tags]    browser:chrome    happy_path    smoke_test
    Open Browser Headless    chrome
    Fill Form And Generate Note
    Verify Generated Note
    Capture Full Page Screenshot    ${SCREEN_DIR}/chrome_success.png
    Close Browser

Generate Note - Firefox
    [Tags]    browser:firefox    happy_path    smoke_test
    Open Browser Headless    firefox
    Fill Form And Generate Note
    Verify Generated Note
    Capture Full Page Screenshot    ${SCREEN_DIR}/firefox_success.png
    Close Browser

Generate Note - Edge
    [Tags]    browser:edge    happy_path    smoke_test
    Open Browser Headless    edge
    Fill Form And Generate Note
    Verify Generated Note
    Capture Full Page Screenshot    ${SCREEN_DIR}/edge_success.png
    Close Browser

*** Keywords ***
Prepare Suite
    File Should Exist    ${CURDIR}/../../MDS_html.html
    Create Directory    ${SCREEN_DIR}
    Log Driver Versions

Log Driver Versions
    ${status}    ${result}=    Run Keyword And Ignore Error    Run Process    ${CURDIR}/../../drivers/chromedriver    --version    shell=False    stdout=PIPE    stderr=STDOUT    cwd=${CURDIR}
    IF    '${status}' == 'PASS'
        Log    Chromedriver: ${result.stdout}
    ELSE
        Log    Chromedriver: not found
    END

    ${status}    ${result}=    Run Keyword And Ignore Error    Run Process    ${CURDIR}/../../drivers/geckodriver    --version    shell=False    stdout=PIPE    stderr=STDOUT    cwd=${CURDIR}
    IF    '${status}' == 'PASS'
        Log    Geckodriver: ${result.stdout}
    ELSE
        Log    Geckodriver: not found
    END

    ${status}    ${result}=    Run Keyword And Ignore Error    Run Process    ${CURDIR}/../../drivers/msedgedriver    --version    shell=False    stdout=PIPE    stderr=STDOUT    cwd=${CURDIR}
    IF    '${status}' == 'PASS'
        Log    MSEdge driver: ${result.stdout}
    ELSE
        Log    MSEdge driver: not found
    END

    ${status}    ${result}=    Run Keyword And Ignore Error    Run Process    firefox    --version    shell=False    stdout=PIPE    stderr=STDOUT    cwd=${CURDIR}
    IF    '${status}' == 'PASS'
        Log    Firefox: ${result.stdout}
    ELSE
        Log    Firefox: not found
    END

    ${status}    ${result}=    Run Keyword And Ignore Error    Run Process    google-chrome    --version    shell=False    stdout=PIPE    stderr=STDOUT    cwd=${CURDIR}
    IF    '${status}' == 'PASS'
        Log    Chrome: ${result.stdout}
    ELSE
        Log    Chrome: not found
    END

Teardown Suite
    Close All Browsers
    Run Keyword And Ignore Error    Terminate Process    ${GECKO_PROC}

Open Browser Headless
    [Arguments]    ${browser}
    IF    '${browser}' == 'chrome'
        Create Chrome Headless
    ELSE IF    '${browser}' == 'firefox'
        Create Firefox Headless
    ELSE IF    '${browser}' == 'edge'
        Create Edge Headless
    END
    Go To    ${HTML}
    Wait Until Element Is Visible    id=generateBtn    timeout=5s

Create Chrome Headless
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${options}    add_argument    --headless
    Call Method    ${options}    add_argument    --no-sandbox
    Create WebDriver    Chrome    options=${options}

Create Firefox Headless
    ${firefox_bin}=    Set Variable    ${CURDIR}/../../drivers/firefox/firefox
    ${options}=    Evaluate    (lambda p: ((opts := sys.modules['selenium.webdriver'].FirefoxOptions()), setattr(opts, 'binary_location', p), opts)[2])('${firefox_bin}')    sys, selenium.webdriver
    Call Method    ${options}    add_argument    -headless
    ${geckodriver}=    Set Variable    ${CURDIR}/../../drivers/geckodriver
    ${logpath}=    Set Variable    ${CURDIR}/../../screenshots/geckodriver.log
    ${service}=    Evaluate    sys.modules['selenium.webdriver.firefox.service'].Service(executable_path=r'''${geckodriver}''', log_path=r'''${logpath}''')    sys, selenium.webdriver
    ${status}    ${msg}=    Run Keyword And Ignore Error    Create WebDriver    Firefox    options=${options}    service=${service}
    IF    '${status}' == 'PASS'
        RETURN_FROM_KEYWORD
    END

    # Fallback: start geckodriver as a standalone process and connect via Remote WebDriver
    ${proc}=    Start Process    ${geckodriver}    --port    4444    --log    trace    stdout=${logpath}    stderr=STDOUT    shell=False
    Set Suite Variable    ${GECKO_PROC}    ${proc}
    Sleep    1s
    ${fcaps}=    Evaluate    {'moz:firefoxOptions': {'args': ['-headless']}}    sys
    ${status2}    ${msg2}=    Run Keyword And Ignore Error    Open Browser    about:blank    browser=firefox    remote_url=http://127.0.0.1:4444    desired_capabilities=${fcaps}
    IF    '${status2}' == 'PASS'
        RETURN_FROM_KEYWORD
    END
    # If still failing, stop geckodriver process and fail
    Run Keyword And Ignore Error    Terminate Process    ${proc}
    Fail    Could not start Firefox WebDriver: ${msg2}

Create Edge Headless
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].EdgeOptions()    sys, selenium.webdriver
    Call Method    ${options}    add_argument    --headless
    Create WebDriver    Edge    options=${options}

Fill Form And Generate Note
    Input Text    id=residentName    John Doe
    Input Text    id=age    82
    ${valid_ard}=    Evaluate    (__import__('datetime').date.today() - __import__('datetime').timedelta(days=90)).isoformat()
    Execute JavaScript    document.getElementById('ard').value = '${valid_ard}';
    Input Text    id=dpoa    Jane Smith
    Select From List By Label    id=noteType    Admission
    Select From List By Label    id=orientation    Resident is alert and oriented x4.
    Select From List By Label    id=bims    with a score of 15/15. SW proceeded to PHQ-2 to 9 assessment.
    Select From List By Label    id=phq    9/27, indicating mild depression.
    Select From List By Label    id=behavior    Resident's behavior is stable. No physical, verbal or other behaviors noted or reported.
    Select From List By Label    id=careConference    offered and accepted.
    Select From List By Label    id=polst    FULL CODE / FULL TREATMENT
    Click Button    id=generateBtn
    Wait Until Page Contains Element    id=output
    Sleep    0.5s

Verify Generated Note
    ${note}=    Get Value    id=output
    Should Contain    ${note}    MDS Admission NOTE
    Should Contain    ${note}    Resident prefers to be called John Doe
    Should Contain    ${note}    82 years old
    Should Contain    ${note}    ARD:
    Should Contain    ${note}    Resident is alert and oriented x4.
    Should Contain    ${note}    with a score of 15/15
    Should Contain    ${note}    9/27, indicating mild depression.
    Should Contain    ${note}    POLST code status is FULL CODE / FULL TREATMENT
    Should Contain    ${note}    DPOA specifies decision maker is Jane Smith

Capture Failure Screenshot
    ${tname}=    Get Variable Value    ${TEST NAME}    unknown_test
    ${tstatus}=    Get Variable Value    ${TEST STATUS}    UNKNOWN
    Capture Full Page Screenshot    ${SCREEN_DIR}/${tname}_${tstatus}.png

Capture Full Page Screenshot
    [Arguments]    ${path}
    # Only take success screenshots for happy_path tests. Always capture on failure.
    ${is_happy}=    Run Keyword And Return Status    List Should Contain Value    @{TEST_TAGS}    happy_path
    IF    not ${is_happy}
        RETURN_FROM_KEYWORD
    END
    # compute full page size and devicePixelRatio to avoid cropped top/scale issues
    ${vals}=    Execute Javascript    return {w: Math.max(document.documentElement.clientWidth, window.innerWidth || 0, document.documentElement.scrollWidth), h: Math.max(document.body.scrollHeight, document.documentElement.scrollHeight, document.documentElement.clientHeight), dpr: (window.devicePixelRatio||1)};
    ${width}=    Set Variable    ${vals['w']}
    ${height}=    Set Variable    ${vals['h']}
    ${dpr}=    Set Variable    ${vals['dpr']}
    ${target_w}=    Evaluate    int(math.ceil(${width} * ${dpr}))    math
    ${target_h}=    Evaluate    int(math.ceil(${height} * ${dpr}))    math
    # add a small bottom padding to avoid off-by-a-few-pixels cropping
    ${pad}=    Set Variable    200
    ${target_h_padded}=    Evaluate    ${target_h} + ${pad}
    Run Keyword And Ignore Error    Set Window Position    0    0
    Run Keyword And Ignore Error    Set Window Size    ${target_w}    ${target_h_padded}
    Execute Javascript    window.scrollTo(0,0);
    Sleep    0.5s
    Run Keyword And Ignore Error    Capture Page Screenshot    ${path}
