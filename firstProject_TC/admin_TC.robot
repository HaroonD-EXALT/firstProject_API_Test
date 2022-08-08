*** Settings ***
Library     RequestsLibrary
Library     Collections


*** Variables ***
${base_url}=    http://localhost:8080/firstProject/api
${admin_id}=    ${1}


*** Test Cases ***
Get All Admins(GET)
    ${response}=    GET    ${base_url}/admins
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    #Validation
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}    200


Get Admin By ID(GET)
    Log To Console    ${admin_id}
    [Tags]    get
    ${resp}=    GET    ${base_url}/admins/${admin_id}
    ${res_body}=    Create Dictionary
    ...    id=${resp.json()}[id]
    ...    name=${resp.json()}[name]
    ...    password=${resp.json()}[password]
    ...    role=${resp.json()}[role]

    ${expected_data}=    Create Dictionary
    ...    id=${admin_id}
    ...    name=Robot-framework
    ...    password=robot.1234
    ...    role=admin
    #validations
    Status Should Be    OK    ${resp}
    Should Be Equal As Strings    ${res_body}    ${expected_data}

    

@Get Admin By Id (GET) wrongId
    [Tags]    get
    ${resp}=    Get    ${base_url}/admins/-1    expected_status=400
    Status Should Be    BAD REQUEST    ${resp}

    ${res_str}=    Convert To String    ${resp.content}
    ${expected_str}=    Set Variable		something wrong admin not found try again later 
    Should Be Equal    ${res_str}    ${expected_str}
        # something wrong admin not found try again later 

@Get Admin By Id (GET) InValid ID
    [Tags]    get
    ${resp}=    Get    ${base_url}/admins/invalidId    expected_status=400

    Status Should Be    BAD REQUEST    ${resp}
    Should Be Equal As Strings    Bad Request    ${resp.json()}[error]

POST New Admin (POST)
    [Tags]    post
    ${body}=    Create Dictionary    name=Robot-framework    password=robot.1234
    ${resp}=    POST    ${base_url}/admins/create    json=${body}
    ${data}=    Create Dictionary    name=${resp.json()}[name]    password=${resp.json()}[password]

    Status Should Be    OK    ${resp}
    Dictionaries Should Be Equal    ${data}    ${body}


POST New Admin (POST) Expect an error (without name)
    [Tags]    post
    ${body}=    Create Dictionary    name=    password=robot.1234
    ${resp}=    POST    ${base_url}/admins/create   json=${body}    expected_status=400

    Status Should Be    BAD REQUEST    ${resp}
    Should Be Equal As Strings    Bad Request    ${resp.json()}[error]

POST New Admin (POST) Expect an error (without password)
    [Tags]    post
    ${body}=    Create Dictionary    name=Test    password=
    ${resp}=    POST    ${base_url}/admins/create    json=${body}    expected_status=400

    Status Should Be    BAD REQUEST    ${resp}

    Should Be Equal As Strings    Bad Request    ${resp.json()}[error]

Login (POST) 
    [Tags]    post
    ${body}=    Create Dictionary    username=Robot-framework    password=robot.1234
    ${resp}=    POST    ${base_url}/admins/login    json=${body}    

    Status Should Be    OK    ${resp}
    # Should Be Equal As Strings    Bad Request    ${resp.json()}[error]



Login (POST) Expect an error (wrong name)
    [Tags]    post
    ${body}=    Create Dictionary    username=Robot-Wrong Name    password=robot.1234
    ${resp}=    POST    ${base_url}/admins/login    json=${body}    expected_status=401

    Status Should Be    UNAUTHORIZED    ${resp}

    # Should Be Equal As Strings    Bad Request    ${resp.json()}[error]


Login (POST) Expect an error (wrong password)
    [Tags]    post
    ${body}=    Create Dictionary    username=Robot-framework    password=wrong password
    ${resp}=    POST    ${base_url}/admins/login    json=${body}    expected_status=401

    Status Should Be    UNAUTHORIZED    ${resp}

    # Should Be Equal As Strings    Bad Request    ${resp.json()}[error]
