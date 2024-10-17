from django.shortcuts import render

from rest_framework.views import APIView 

from .models import School

from common.response_builder import SuccessResponseBuilder

from .serializers import SchoolSerializer

from accounts.permissions import IsJWTAuthenticated
from accounts.serializers import ConstrainedUserSerializer, UserSerializer
from accounts.models import User

class TeacherList(APIView):
    permission_classes = [IsJWTAuthenticated]

    def get(self, request, format=None):
        serializer = ConstrainedUserSerializer(User.objects.filter(
                    school__id=request.user.school.id,
                    user_type=User.UserType.TEACHER, 
                ).order_by("first_name"), many=True)

        return SuccessResponseBuilder() \
                    .set_code(200) \
                    .set_data(serializer.data) \
                    .set_message("Successfully fetched all the teachers") \
                    .build()

        

class SchoolList(APIView):
    def get(self, request, format=None):
        serializer = SchoolSerializer(data=School.objects.all(), many=True)
        serializer.is_valid()

        return SuccessResponseBuilder() \
                    .set_message("Successfully fetched the schools") \
                    .set_data(serializer.data) \
                    .set_metadata({ "total_schools": len(serializer.data) }) \
                    .build()
