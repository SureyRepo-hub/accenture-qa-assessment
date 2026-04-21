*** Settings ***
Documentation       Robot Framework API test suite for JSONPlaceholder.
...                 This suite validates GET and POST operations, filtering,
...                 nested JSON validation, and documents the behavior of
...                 POST followed by GET on a fake REST API.
Library             RequestsLibrary
Library             Collections
Variables           ../variables.py

Suite Setup         Create API Session
Suite Teardown      Cleanup Session


*** Variables ***
${POSTS_ENDPOINT}       /posts
${USERS_ENDPOINT}       /users


*** Test Cases ***
Fetch Single Post Returns Expected Fields
    [Documentation]    Verify GET /posts/1 returns HTTP 200 and contains required fields.
    ${response}=    GET On Session    jsonplaceholder    ${POSTS_ENDPOINT}/1
    Status Should Be    200    ${response}
    ${body}=    Set Variable    ${response.json()}

    Dictionary Should Contain Key    ${body}    userId
    Dictionary Should Contain Key    ${body}    id
    Dictionary Should Contain Key    ${body}    title
    Dictionary Should Contain Key    ${body}    body
    Should Be Equal As Integers    ${body}[id]    1

Create Post Using Dictionary Returns Created Payload
    [Documentation]    Verify POST /posts accepts dictionary payload and returns HTTP 201 with matching values.
    ${payload}=    Create Dictionary
    ...    title=${POST_TITLE}
    ...    body=${POST_BODY}
    ...    userId=${POST_USER_ID}

    ${headers}=    Create Dictionary    Content-Type=application/json
    ${response}=    POST On Session    jsonplaceholder    ${POSTS_ENDPOINT}    json=${payload}    headers=${headers}
    Status Should Be    201    ${response}

    ${body}=    Set Variable    ${response.json()}
    Should Be Equal    ${body}[title]    ${payload}[title]
    Should Be Equal    ${body}[body]     ${payload}[body]
    Should Be Equal As Integers    ${body}[userId]    ${payload}[userId]
    Dictionary Should Contain Key    ${body}    id

Filter Posts By User Id Returns Only Matching Items
    [Documentation]    Verify GET /posts?userId=1 returns HTTP 200 and every returned item has userId equal to 1.
    ${params}=    Create Dictionary    userId=1
    ${response}=    GET On Session    jsonplaceholder    ${POSTS_ENDPOINT}    params=${params}
    Status Should Be    200    ${response}

    ${body}=    Set Variable    ${response.json()}
    Should Not Be Empty    ${body}

    FOR    ${item}    IN    @{body}
        Dictionary Should Contain Key    ${item}    userId
        Should Be Equal As Integers    ${item}[userId]    1
    END

Fetch User Returns Expected Nested Json Fields
    [Documentation]    Verify GET /users/1 returns HTTP 200 and expected nested fields are present.
    ${response}=    GET On Session    jsonplaceholder    ${USERS_ENDPOINT}/1
    Status Should Be    200    ${response}

    ${body}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${body}    address
    Dictionary Should Contain Key    ${body}    company

    ${address}=    Set Variable    ${body}[address]
    ${geo}=        Set Variable    ${address}[geo]
    ${company}=    Set Variable    ${body}[company]

    Dictionary Should Contain Key    ${address}    city
    Dictionary Should Contain Key    ${geo}        lat
    Dictionary Should Contain Key    ${company}    name

    Should Not Be Empty    ${address}[city]
    Should Not Be Empty    ${geo}[lat]
    Should Not Be Empty    ${company}[name]

Create Post Then Retrieve By Returned Id
    [Documentation]    Create a post using POST /posts, extract returned id, then attempt GET /posts/{id}.
    ...                Document actual API behavior: JSONPlaceholder does not persist created records.
    ${payload}=    Create Dictionary
    ...    title=integration test title
    ...    body=integration test body
    ...    userId=99

    ${headers}=    Create Dictionary    Content-Type=application/json
    ${post_response}=    POST On Session    jsonplaceholder    ${POSTS_ENDPOINT}    json=${payload}    headers=${headers}
    Status Should Be    201    ${post_response}

    ${created}=    Set Variable    ${post_response.json()}
    Dictionary Should Contain Key    ${created}    id
    ${created_id}=    Set Variable    ${created}[id]

    ${get_response}=    GET On Session    jsonplaceholder    ${POSTS_ENDPOINT}/${created_id}
    ${status_code}=    Convert To String    ${get_response.status_code}

    Log    Returned ID from POST: ${created_id}
    Log    GET /posts/${created_id} response code: ${status_code}
    Log    JSONPlaceholder is a fake API. POST response is simulated and created data is not persisted.

    IF    '${status_code}' == '200'
        ${retrieved}=    Set Variable    ${get_response.json()}
        Dictionary Should Contain Key    ${retrieved}    id
        Log    GET returned an existing resource for id ${created_id}. This does not guarantee persistence of the POSTed payload.
    ELSE
        Should Be Equal    ${status_code}    404
    END


*** Keywords ***
Create API Session
    [Documentation]    Create reusable HTTP session for JSONPlaceholder API.
    Create Session    jsonplaceholder    ${BASE_URL}    verify=${VERIFY_SSL}

Cleanup Session
    [Documentation]    Cleanup placeholder suite teardown step.
    Log    Test suite execution completed. No explicit API cleanup required for JSONPlaceholder.
