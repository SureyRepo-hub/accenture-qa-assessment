# QA Automation Engineer Take-Home Assessment

This repository contains:
- Task 1: Sync verification and test plan
- Task 2: Robot Framework API automation for JSONPlaceholder

## Python Version
Python 3.11

## Setup

Create and activate a virtual environment:

```bash
python -m venv .venv
source .venv/bin/activate
```

Install dependencies:

```bash
pip install -r task2/requirements.txt
```

## Configuration

Create a file named `task2/variables.py` based on `task2/variables.py.example`.

Example:

```python
BASE_URL = "https://jsonplaceholder.typicode.com"
VERIFY_SSL = True

POST_TITLE = "my sample title"
POST_BODY = "my sample body"
POST_USER_ID = 1
```

## How to Run the Test Suite

From repository root:

```bash
robot task2/tests/api_tests.robot
```

Or with output directory:

```bash
robot -d results task2/tests/api_tests.robot
```

## Assumptions

- JSONPlaceholder is a fake REST API used for testing and prototyping.
- POST requests return a simulated created response, but created resources are not actually persisted.
- Because of that, the "POST + GET" test documents observed behavior instead of assuming full resource persistence.
- No authentication is required for this API.

## Notes on Design

- Session management is handled with Suite Setup and Suite Teardown.
- Test data and base URL are separated into a variables file.
- High-level tests are written with meaningful names.
- Keywords are used to keep setup readable and maintainable.

## Additional scenarios I would add if I had more time

1. **Fetch Non-Existing Post Returns 404**  
   Verify `GET /posts/999999` returns expected not-found behavior.

2. **Create Post With Partial Payload**  
   Send a partial payload and document how the fake API behaves compared to a real production API.

3. **Validate Response Headers For GET Request**  
   Verify headers like `Content-Type` match the expected JSON response.
