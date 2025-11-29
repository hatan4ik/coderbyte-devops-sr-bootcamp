# This file contains the Python code for a simple HTTP Cloud Function.
# It can be triggered by an HTTP request.

import functions_framework

# Register this function to respond to HTTP requests
@functions_framework.http
def hello_http(request):
    """
    HTTP Cloud Function that greets a user.
    Args:
        request (flask.Request): The request object.
        <https://flask.palletsprojects.com/en/1.1.x/api/#incoming-request-data>
    Returns:
        The response text, or any set of values that can be turned into a
        Response object using `make_response`
        <https://flask.palletsprojects.com/en/1.1.x/api/#flask.make_response>.
    """
    # Try to get the 'name' from the query parameters
    name = request.args.get('name')

    # If not in query, try to get it from the JSON body
    if not name:
        request_json = request.get_json(silent=True)
        if request_json and 'name' in request_json:
            name = request_json['name']

    # If a name was found, return a personalized greeting.
    # Otherwise, return a generic greeting.
    if name:
        return f"Hello, {name}!"
    else:
        return "Hello, World!"
