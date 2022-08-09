*** Settings ***
Library     RequestsLibrary
Library     Collections
Variables    ../Resources/variables.py



*** Variables ***
${course1_id}=      ${0}
${course2_id}=      ${0}
${course3_id}=      ${0}




*** Test Cases ***
POST New Course (POST)
    [Tags]    post
    # course 1
    ${body}=    Create Dictionary    name=${course1}[name]
    ${resp}=    POST    ${base_url}/courses/create    json=${body}

    ${course1_id}=    Set Variable    ${resp.json()}[id]
    Set Global Variable    ${course1_id}

    Set To Dictionary    ${course1}    id=${course1_id}  
    # Validations
    Status Should Be    OK    ${resp}
    Dictionaries Should Be Equal    ${resp.json()}    ${course1}

    # course 2
    ${body}=    Create Dictionary    name=${course2}[name]
    ${resp}=    POST    ${base_url}/courses/create    json=${body}

    ${course2_id}=    Set Variable    ${resp.json()}[id]
    Set Global Variable    ${course2_id}
    Set To Dictionary    ${course2}    id=${course2_id}  
    # Validations
    Status Should Be    OK    ${resp}
    Dictionaries Should Be Equal    ${resp.json()}    ${course2}

    # course 3
    ${body}=    Create Dictionary    name=${course3}[name]
    ${resp}=    POST    ${base_url}/courses/create    json=${body}

    ${course3_id}=    Set Variable    ${resp.json()}[id]
    Set Global Variable    ${course3_id}
    Set To Dictionary    ${course3}    id=${course3_id}  

    # Validations
    Status Should Be    OK    ${resp}
    Dictionaries Should Be Equal    ${resp.json()}    ${course3}

POST New Course (POST) Expect an error (without name)
    [Tags]    post
    ${body}=    Create Dictionary    name=
    ${resp}=    POST    ${base_url}/courses/create    json=${body}    expected_status=400

    # Validations
    Status Should Be    BAD REQUEST    ${resp}
    Should Be Equal As Strings    Bad Request    ${resp.json()}[error]

POST New Course (POST) Expect an error (without body)
    [Tags]    post
    ${body}=    Create Dictionary
    ${resp}=    POST    ${base_url}/courses/create    json=${body}    expected_status=400

    # Validations
    Status Should Be    BAD REQUEST    ${resp}
    Should Be Equal As Strings    Bad Request    ${resp.json()}[error]

Get All Courses(GET)
    [Tags]    get
    ${resp}=    GET    ${base_url}/courses
    Log To Console    ${resp.status_code}
    Log To Console    ${resp.content}

    #Validation
    Status Should Be    OK    ${resp}

Get Course By Id (GET)
    [Tags]    get
    ${resp}=    GET    ${base_url}/courses/${course1_id}

    ${res_body}=    Create Dictionary
    ...    id=${resp.json()}[id]
    ...    name=${resp.json()}[name]
    ...    numOfStudent=${resp.json()}[numOfStudent]

    #validations
    Status Should Be    OK    ${resp}
    Should Be Equal As Strings    ${res_body}    ${course1}

@Get Course By Id (GET) InValid ID
    [Tags]    get
    ${resp}=    Get    ${base_url}/courses/invalidId    expected_status=400

    # Validations
    Status Should Be    BAD REQUEST    ${resp}
    Should Be Equal As Strings    Bad Request    ${resp.json()}[error]

@Get Course By Id (GET) wrongId
    [Tags]    get
    ${resp}=    Get    ${base_url}/courses/-1    expected_status=400

    ${res_str}=    Convert To String    ${resp.content}
    ${expected_str}=    Convert To String    Course does not exist!

    # Validations
    Status Should Be    BAD REQUEST    ${resp}
    Should Be Equal    ${expected_str}    ${res_str}

DELETE Course (delete)
    [Tags]    delete
    # Course 2 #
    ${resp}=    DELETE    ${base_url}/courses/${course2_id}

    # Validations
    Status Should Be    OK    ${resp}
    Dictionaries Should Be Equal    ${course2}    ${resp.json()}

    # Course 2 #
    ${resp}=    DELETE    ${base_url}/courses/${course3_id}

    # Validations
    Status Should Be    OK    ${resp}
    Dictionaries Should Be Equal    ${course3}    ${resp.json()}

DELETE Course Already deleted (delete)
    [Tags]    delete
    # Course 2 #
    ${resp}=    DELETE    ${base_url}/courses/${course2_id}    expected_status=400

    # Validations
    Status Should Be    BAD REQUEST    ${resp}
    Should Be Equal As Strings    ${resp.content}    course not exists!

    # Course 3 #
    ${resp}=    DELETE    ${base_url}/courses/${course3_id}    expected_status=400

    # Validations
    Status Should Be    BAD REQUEST    ${resp}
    Should Be Equal As Strings    ${resp.content}    course not exists!

DELETE Course (delete) wrong id
    [Tags]    delete
    ${resp}=    DELETE    ${base_url}/courses/-1    expected_status=400

    # Validations
    Status Should Be    BAD REQUEST    ${resp}
    Should Be Equal As Strings    ${resp.content}    course not exists!

DELETE Course (delete) Invalid ID
    ${resp}=    DELETE    ${base_url}/courses/inavlid_Id    expected_status=400

    # Validations
    Status Should Be    BAD REQUEST    ${resp}
    Should Be Equal As Strings    Bad Request    ${resp.json()}[error]
