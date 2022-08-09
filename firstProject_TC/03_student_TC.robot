*** Settings ***
Library     RequestsLibrary
Library     Collections
Variables    ../Resources/variables.py


*** Variables ***
${student1_id}=    ${0}
${student2_id}=    ${0}



*** Test Cases ***

POST New Student (POST)
    [Tags]    post
    # Student 1
    ${body}=    Create Dictionary    name=${student1}[name] 
    ${resp}=    POST    ${base_url}/students/create    json=${body}
    
    ${student1_id}=    Set Variable    ${resp.json()}[id]
    Set Global Variable    ${student1_id}
    Set To Dictionary    ${student1}    id=${resp.json()}[id]  
  
    Status Should Be    OK    ${resp}
    Dictionaries Should Be Equal    ${resp.json()}    ${student1}

    # Student 2
    ${body}=    Create Dictionary    name=${student2}[name] 
    ${resp}=    POST    ${base_url}/students/create    json=${body}
    
    ${student2_id}=    Set Variable    ${resp.json()}[id]
    Set Global Variable    ${student2_id}
    Set To Dictionary    ${student2}    id=${resp.json()}[id]  
    
  
    Status Should Be    OK    ${resp}
    Dictionaries Should Be Equal    ${resp.json()}    ${student2}

POST New Student (POST) Expect an error (without name)
    [Tags]    post
    ${body}=    Create Dictionary    name=
    ${resp}=    POST    ${base_url}/students/create    json=${body}    expected_status=400

    Status Should Be    BAD REQUEST    ${resp}
    Should Be Equal As Strings    Bad Request    ${resp.json()}[error]


Get All Students(GET)
    [Tags]    get
    ${response}=    GET    ${base_url}/students/


    #Validation
    Status Should Be    OK    ${response}

    @{expected_list}=    Create List    ${student1}    ${student2}

    List Should Contain Sub List    ${response.json()}    ${expected_list}

Get Student By ID(GET)
    [Tags]    get
   
    ${resp}=    GET    ${base_url}/students/${student1_id}
   

    

    #validations
    Status Should Be    OK    ${resp}
    Dictionaries Should Be Equal    ${student1}    ${resp.json()}

@Get Student By Id (GET) wrongId
    [Tags]    get
    ${resp}=    Get    ${base_url}/students/-1    expected_status=400

    ${res_str}=    Convert To String    ${resp.content}
    ${expected_str}=    Set Variable    something wrong Student dose not exists try again later

    Status Should Be    BAD REQUEST    ${resp}
    Should Be Equal    ${res_str}    ${expected_str}



@Get Student By Id (GET) InValid ID
    [Tags]    get
    ${resp}=    Get    ${base_url}/students/invalidId    expected_status=400

    Status Should Be    BAD REQUEST    ${resp}
    Should Be Equal As Strings    Bad Request    ${resp.json()}[error]


Register student to course
    [Tags]    post

    # get course data to check numOfStudent if it is increment or not 
    ${resp_course}=    GET    ${base_url}/courses/${course1}[id]
    ${resp}=    POST    ${base_url}/students/${student1_id}/courses/${course1}[id]


    Set To Dictionary    ${course1}    numOfStudent=${${resp_course.json()}[numOfStudent]+1}
    @{reCourse_list}=    Create List    ${course1}
    Set To Dictionary    ${student1}    regCourses=@{reCourse_list}
    
    # Validations 
    Status Should Be    OK    ${resp}
    Dictionaries Should Be Equal    ${resp.json()}    ${student1}

Register student to course that already is registred 
    [Tags]    post
    ${resp}=    POST    ${base_url}/students/${student1_id}/courses/${course1}[id]    expected_status=400

    # Validations 
    Status Should Be    BAD REQUEST    ${resp}
    Should Be Equal As Strings    ${resp.content}    the course is already registered


Register student to course wrong student id
    [Tags]    post
    ${resp}=    POST    ${base_url}/students/-1/courses/1    expected_status=400

    ${res_str}=    Convert To String    ${resp.content}
    ${expected_str}=    Set Variable    Student dose not exists!

    Status Should Be    BAD REQUEST    ${resp}
    Should Be Equal    ${res_str}    ${expected_str}

Register student to course wrong course id
    [Tags]    post
    ${resp}=    POST    ${base_url}/students/1/courses/-1    expected_status=400

    ${res_str}=    Convert To String    ${resp.content}
    ${expected_str}=    Set Variable    Course dose not exists!

    Status Should Be    BAD REQUEST    ${resp}
    Should Be Equal    ${res_str}    ${expected_str}

UnRegister student from course

    [Tags]    delete

    # get course data to check numOfStudent if it is decrement or not
    ${resp_course}=    GET    ${base_url}/courses/${course1}[id]
    ${resp}=    DELETE    ${base_url}/students/${student1_id}/courses/${course1}[id]


    ${res_body}=    Create Dictionary
    ...    id=${resp_course.json()}[id]
    ...    name=${resp_course.json()}[name]
    ...    numOfStudent=${resp_course.json()}[numOfStudent]

    Set To Dictionary    ${course1}    numOfStudent=${${res_body}[numOfStudent]-1}
    @{reCourse_list}=    Create List    
    Set To Dictionary    ${student1}    regCourses=@{reCourse_list}
    
    # Validations 
    Status Should Be    OK    ${resp}
    Dictionaries Should Be Equal    ${resp.json()}    ${student1}

Unregister student to course that already is unregistred 
    [Tags]    post
    ${resp}=    DELETE    ${base_url}/students/${student1_id}/courses/${course1}[id]    expected_status=400

    # Validations 
    Status Should Be    BAD REQUEST    ${resp}
    Should Be Equal As Strings    ${resp.content}    the course is already unregistered


Unregister student to course wrong student id
    [Tags]    delete
    ${resp}=    DELETE    ${base_url}/students/-1/courses/1    expected_status=400

    ${res_str}=    Convert To String    ${resp.content}
    ${expected_str}=    Set Variable    Student dose not exists!

    Status Should Be    BAD REQUEST    ${resp}
    Should Be Equal    ${res_str}    ${expected_str}

Unregister student to course wrong course id
    [Tags]    delete
    ${resp}=    DELETE    ${base_url}/students/1/courses/-1    expected_status=400

    ${res_str}=    Convert To String    ${resp.content}
    ${expected_str}=    Set Variable    Course dose not exists!

    Status Should Be    BAD REQUEST    ${resp}
    Should Be Equal    ${res_str}    ${expected_str}


