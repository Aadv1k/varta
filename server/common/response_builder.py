from rest_framework.response import Response

class SuccessResponseBuilder:
    def __init__(self):
        self.success = {
            "status": "success",
            "code": 200,
            "message": "Request processed successfully",
            "data": {},
            "metadata": {}
        }
    
    def set_code(self, status_code):
        self.success["code"] = status_code
        return self

    def set_message(self, message):
        self.success["message"] = message
        return self

    def set_data(self, data):
        self.success["data"] = data
        return self

    def set_metadata(self, metadata):
        self.success["metadata"] = metadata
        return self

    def build(self):
        return Response(data=self.success, status=self.success["code"])

class ErrorResponseBuilder:
    def __init__(self):
        self.error = {
            "status": "error",
            "code": 400,
            "message": "Something went wrong while trying to process your request",
            "errors": []
        }
    
    def set_code(self, status_code):
        self.error["code"] = status_code
        return self

    def set_message(self, message):
        self.error["message"] = message
        return self

    def set_details(self, errors):
        self.error["errors"] = errors
        return self

    def build(self):
        return Response(data=self.error, status=self.error["code"])
