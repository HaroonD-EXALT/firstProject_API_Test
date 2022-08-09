*** Settings ***
Library     RequestsLibrary
Library     Collections


*** Variables ***
${base_url}=    http://localhost:8080/firstProject/api
${admin1_id}=    ${0}    
${admin2_id}=    ${0}




*** Test Cases ***

POST New Admin (POST)
    [Tags]    post
    # Admin 1
    ${body}=    Create Dictionary    name=admin 1    password=admin1.1234
    ${resp}=    POST    ${base_url}/admins/create    json=${body}
    ${resp_data}=    Create Dictionary    id=${resp.json()}[id]    name=${resp.json()}[name]    password=${resp.json()}[password]    role=${resp.json()}[role]
    
    ${admin1_id}=    Set Variable    ${resp.json()}[id]
    Set Global Variable    ${admin1_id}
    
    Log To Console    ${admin1_id}
    ${exp_data}=    Create Dictionary    id=${admin1_id}    name=admin 1    password=admin1.1234    role=admin

    # Validations
    Status Should Be    OK    ${resp}
    Dictionaries Should Be Equal    ${resp_data}    ${exp_data}


    # Admin 2
    ${body}=    Create Dictionary    name=admin 2    password=admin2.1234
    ${resp}=    POST    ${base_url}/admins/create    json=${body}
    ${resp_data}=    Create Dictionary    id=${resp.json()}[id]    name=${resp.json()}[name]    password=${resp.json()}[password]    role=${resp.json()}[role]
    
    ${admin2_id}=    Set Variable     ${resp.json()}[id]
    Set Global Variable    ${admin2_id}

    Log To Console    ${admin2_id}
    ${exp_data}=    Create Dictionary    id=${admin2_id}    name=admin 2    password=admin2.1234    role=admin

    # Validation
    Status Should Be    OK    ${resp}
    Dictionaries Should Be Equal    ${resp_data}    ${exp_data}


Get All Admins(GET)
    ${response}=    GET    ${base_url}/admins
    # Log To Console    ${response.status_code}
    # Log To Console    ${response.content}

    ${exp_data_admin1}=    Create Dictionary    id=${admin1_id}    name=admin 1    password=admin1.1234    role=admin
    ${exp_data_admin2}=    Create Dictionary    id=${admin2_id}    name=admin 2    password=admin2.1234    role=admin

    @{expected_admin_list}=    Create List    ${exp_data_admin1}    ${exp_data_admin2}    
    @{resp_list}=    Create List    ${response.content}

    Log To Console    ${resp_list} 
    #Validation
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}    200

    Lists Should Be Equal    @{expected_admin_list}    @{resp_list}


Get Admin By ID(GET)
    Log To Console    admin1_i
    Log To Console    ${admin1_id}
    [Tags]    get
    ${resp}=    GET    ${base_url}/admins/${admin1_id}
    ${res_body}=    Create Dictionary
    ...    id=${resp.json()}[id]
    ...    name=${resp.json()}[name]
    ...    password=${resp.json()}[password]
    ...    role=${resp.json()}[role]

    ${expected_data}=    Create Dictionary
    ...    id=${admin1_id}
    ...    name=admin 1
    ...    password=admin1.1234
    ...    role=admin
    #validations
    Status Should Be    OK    ${resp}
    Dictionaries Should Be Equal    ${res_body}    ${expected_data}




@Get Admin By Id (GET) wrongId
    [Tags]    get
    ${resp}=    Get    ${base_url}/admins/-1    expected_status=400
    Status Should Be    BAD REQUEST    ${resp}

    ${res_str}=    Convert To String    ${resp.content}
    ${expected_str}=    Set Variable		something wrong admin not found try again later 
    Should Be Equal    ${res_str}    ${expected_str}

@Get Admin By Id (GET) InValid ID
    [Tags]    get
    ${resp}=    Get    ${base_url}/admins/invalidId    expected_status=400

    Status Should Be    BAD REQUEST    ${resp}
    Should Be Equal As Strings    Bad Request    ${resp.json()}[error]




POST New Admin (POST) Expect an error (without name)
    [Tags]    post
    ${body}=    Create Dictionary    name=    password=admin1.1234
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
    ${body}=    Create Dictionary    username=admin 1    password=admin1.1234
    ${resp}=    POST    ${base_url}/admins/login    json=${body}    

    Status Should Be    OK    ${resp}
    Should Be Equal As Strings    successful login    ${resp.content}


Login (POST) Expect an error (wrong name)
    [Tags]    post
    ${body}=    Create Dictionary    username=Robot-Wrong Name    password=robot.1234
    ${resp}=    POST    ${base_url}/admins/login    json=${body}    expected_status=401

    Status Should Be    UNAUTHORIZED    ${resp}
    Should Be Equal As Strings    username or password is incorrect.    ${resp.content}


Login (POST) Expect an error (wrong password)
    [Tags]    post
    ${body}=    Create Dictionary    username=Robot-framework    password=wrong password
    ${resp}=    POST    ${base_url}/admins/login    json=${body}    expected_status=401

    Status Should Be    UNAUTHORIZED    ${resp}
    Should Be Equal As Strings    username or password is incorrect.    ${resp.content}

Delete Admin 1 (Delete)
    [Tags]    delete
    ${resp}=    DELETE    ${base_url}/admins/${admin1_id}   
    
    ${exp_data_admin1}=    Create Dictionary    id=${admin1_id}    name=admin 1    password=admin1.1234    role=admin

    # Validations
    Status Should Be    OK    ${resp}
    Dictionaries Should Be Equal    ${resp.json()}    ${exp_data_admin1}


Delete Admin 1 already deleted (Delete)  
    ${resp}=    DELETE    ${base_url}/admins/${admin1_id}    expected_status=400 
    
    # Validations
    Status Should Be    BAD REQUEST    ${resp}
    Should Be Equal As Strings    Admin not exists!    ${resp.content}

Delete Admin 2 (Delete)
    [Tags]    delete
    ${resp}=    DELETE    ${base_url}/admins/${admin2_id}   
    
    ${exp_data_admin1}=    Create Dictionary    id=${admin2_id}    name=admin 2    password=admin2.1234    role=admin

    # Validations
    Status Should Be    OK    ${resp}
    Dictionaries Should Be Equal    ${resp.json()}    ${exp_data_admin1}


Delete Admin 2 already deleted (Delete)  
    ${resp}=    DELETE    ${base_url}/admins/${admin1_id}    expected_status=400 
    
    # Validations
    Status Should Be    BAD REQUEST    ${resp}
    Should Be Equal As Strings    Admin not exists!    ${resp.content}

