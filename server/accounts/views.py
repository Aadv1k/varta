from rest_framework.decorators import api_view
from rest_framework.response import Response

@api_view(["POST"])
def user_login(request):
    return Response({"foo": "hello world"})
