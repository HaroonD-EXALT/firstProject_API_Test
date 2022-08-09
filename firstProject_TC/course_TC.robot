*** Settings ***
Library     RequestsLibrary
Library     Collections


*** Variables ***
${base_url}=        http://localhost:8080/firstProject/api
${course_id}=       ${2}


*** Test Cases ***
Get All Courses(GET)
    [Tags]    get
    ${resp}=    GET    ${base_url}/courses
    Log To Console    ${resp.status_code}
    Log To Console    ${resp.content}

    #Validation
    Status Should Be    OK    ${resp}

Get Course By Id (GET)
    [Tags]    get
    ${resp}=    GET    ${base_url}/courses/${course_id}

    ${res_body}=    Create Dictionary
    ...    id=${resp.json()}[id]
    ...    name=${resp.json()}[name]
    ...    numOfStudent=${resp.json()}[numOfStudent]

    ${expected_data}=    Create Dictionary
    ...    id=${course_id}
    ...    name=Robot-framework zero to hero
    ...    numOfStudent=${resp.json()}[numOfStudent]

    #validations
    Status Should Be    OK    ${resp}
    Should Be Equal As Strings    ${res_body}    ${expected_data}

@Get Course By Id (GET) InValid ID
    [Tags]    get
    ${resp}=    Get    ${base_url}/courses/invalidId    expected_status=400

    Status Should Be    BAD REQUEST    ${resp}
    Should Be Equal As Strings    Bad Request    ${resp.json()}[error]

@Get Course By Id (GET) wrongId
    [Tags]    get
    ${resp}=    Get    ${base_url}/courses/-1    expected_status=400
    Status Should Be    BAD REQUEST    ${resp}

    ${res_str}=    Convert To String    ${resp.content}
    ${expected_str}=    Convert To String    Course does not exist!
    Should Be Equal    ${expected_str}    ${res_str}

POST New Course (POST)
    [Tags]    post
    ${body}=    Create Dictionary    name=Robot-framework zero to hero
    ${resp}=    POST    ${base_url}/courses/create    json=${body}
    ${data}=    Create Dictionary    name=${resp.json()}[id]    name=${resp.json()}[name]    numOfStudent=${0}

    Status Should Be    OK    ${resp}
    Should Be Equal    ${data}[name]    ${body}[name]

POST New Course (POST) Expect an error (without name)
    [Tags]    post
    ${body}=    Create Dictionary    name=
    ${resp}=    POST    ${base_url}/courses/create    json=${body}    expected_status=400

    Status Should Be    BAD REQUEST    ${resp}
    Should Be Equal As Strings    Bad Request    ${resp.json()}[error]

POST New Course (POST) Expect an error (without body)
    [Tags]    post
    ${body}=    Create Dictionary
    ${resp}=    POST    ${base_url}/courses/create    json=${body}    expected_status=400

    Status Should Be    BAD REQUEST    ${resp}

    Should Be Equal As Strings    Bad Request    ${resp.json()}[error]

DELETE Course By ID (delete)
    [Tags]    delete
    ${resp}=    DELETE    ${base_url}/courses/${course_id}

    Status Should Be    OK    ${resp}
    Dictionary Should Contain Key    ${resp.json()}    id

DELETE Course By ID (delete) wrong id
    [Tags]    delete
    ${resp}=    DELETE    ${base_url}/courses/-1    expected_status=400

    Status Should Be    BAD REQUEST    ${resp}
    Should Be Equal As Strings    ${resp.content}    something wrong course dose not exists! try again later

DELETE Course By ID (delete) Invalid ID
    ${resp}=    DELETE    ${base_url}/courses/inavlid_Id    expected_status=400

    Status Should Be    BAD REQUEST    ${resp}
    Should Be Equal As Strings    Bad Request    ${resp.json()}[error]
 