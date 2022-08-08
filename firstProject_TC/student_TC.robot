*** Settings ***
Library     RequestsLibrary
Library     Collections
Library     RPA.Windows


*** Variables ***
${base_url}=        http://localhost:8080/firstProject/api
${student_id}=      ${2}
${course_id}=       ${1}


*** Test Cases ***
Get All Students(GET)
    [Tags]    get
    ${response}=    GET    ${base_url}/students/
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    #Validation
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}    200

Get Student By ID(GET)
    [Tags]    get
    Log To Console    ${student_id}
    ${resp}=    GET    ${base_url}/students/${student_id}
    ${res_body}=    Create Dictionary
    ...    id=${resp.json()}[id]
    ...    name=${resp.json()}[name]
    ...    role=${resp.json()}[role]

    @{reCourse_list}=    Create List
    ${expected_data}=    Create Dictionary
    ...    id=${student_id}
    ...    name=Robot-framework student
    ...    role=student

    #validations
    Status Should Be    OK    ${resp}
    Should Be Equal As Strings    ${res_body}    ${expected_data}

@Get Student By Id (GET) wrongId
    [Tags]    get
    ${resp}=    Get    ${base_url}/students/-1    expected_status=400

    ${res_str}=    Convert To String    ${resp.content}
    ${expected_str}=    Set Variable    something wrong Student dose not exists try again later

    Status Should Be    BAD REQUEST    ${resp}
    Should Be Equal    ${res_str}    ${expected_str}

    Log To Console    ${student_id}

@Get Student By Id (GET) InValid ID
    [Tags]    get
    ${resp}=    Get    ${base_url}/students/invalidId    expected_status=400

    Status Should Be    BAD REQUEST    ${resp}
    Should Be Equal As Strings    Bad Request    ${resp.json()}[error]

POST New Student (POST)
    [Tags]    post
    ${body}=    Create Dictionary    name=Robot-framework student
    ${resp}=    POST    ${base_url}/students/create    json=${body}
    @{reCourse_list}=    Create List
    ${res_data}=    Create Dictionary
    ...    id=${resp.json()}[id]
    ...    name=${resp.json()}[name]
    ...    regCourses=${resp.json()}[regCourses]
    ${expected_data}=    Create Dictionary
    ...    id=${resp.json()}[id]
    ...    name=Robot-framework student
    ...    regCourses=@{reCourse_list}

    ${student_id}=    Set Variable    ${resp.json()}[id]
    Log To Console    ${student_id}
    Status Should Be    OK    ${resp}
    Dictionaries Should Be Equal    ${res_data}    ${expected_data}

POST New Student (POST) Expect an error (without name)
    [Tags]    post
    ${body}=    Create Dictionary    name=
    ${resp}=    POST    ${base_url}/students/create    json=${body}    expected_status=400

    Status Should Be    BAD REQUEST    ${resp}
    Should Be Equal As Strings    Bad Request    ${resp.json()}[error]

Register student to course
    [Tags]    post
    ${resp}=    POST    ${base_url}/students/${student_id}/courses/${course_id}

    ${registredCourse}=    Create Dictionary
    ...    id=${course_id}
    ...    name=Automation from zero to hero
    ...    numOfStudent=${resp.json()}[regCourses][0][numOfStudent]
    @{reCourse_list}=    Create List    ${registredCourse}
    ${res_data}=    Create Dictionary
    ...    id=${resp.json()}[id]
    ...    name=${resp.json()}[name]
    ...    regCourses=${resp.json()}[regCourses]
    ${expected_data}=    Create Dictionary
    ...    id=${resp.json()}[id]
    ...    name=Robot-framework student
    ...    regCourses=@{reCourse_list}

    Status Should Be    OK    ${resp}
    Dictionaries Should Be Equal    ${res_data}    ${expected_data}

Register student to course wrong student id
    [Tags]    post
    ${resp}=    POST    ${base_url}/students/-1/courses/1    expected_status=400

    ${res_str}=    Convert To String    ${resp.content}
    ${expected_str}=    Set Variable    something wrong Student dose not exists! try again later

    Status Should Be    BAD REQUEST    ${resp}
    Should Be Equal    ${res_str}    ${expected_str}

Register student to course wrong course id
    [Tags]    post
    ${resp}=    POST    ${base_url}/students/1/courses/-1    expected_status=400

    ${res_str}=    Convert To String    ${resp.content}
    ${expected_str}=    Set Variable    something wrong Course dose not exists! try again later

    Status Should Be    BAD REQUEST    ${resp}
    Should Be Equal    ${res_str}    ${expected_str}

UnRegister student from course
    [Tags]    delete
    ${resp}=    DELETE    ${base_url}/students/${student_id}/courses/${course_id}

    @{reCourse_list}=    Create List
    ${res_data}=    Create Dictionary
    ...    id=${resp.json()}[id]
    ...    name=${resp.json()}[name]    role=student
    ...    regCourses=${resp.json()}[regCourses]
    ${expected_data}=    Create Dictionary
    ...    id=${resp.json()}[id]
    ...    name=Robot-framework student
    ...    role=student
    ...    regCourses=@{reCourse_list}

    Status Should Be    OK    ${resp}
    Dictionaries Should Be Equal    ${res_data}    ${expected_data}
