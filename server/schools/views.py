from django.shortcuts import render

from rest_framework.views import APIView 

from .models import School

from common.response_builder import SuccessResponseBuilder

from .serializers import SchoolSerializer

class SchoolList(APIView):
    def get(self, request, format=None):
        print(School.objects.all())
        serializer = SchoolSerializer(data=School.objects.all(), many=True)
        serializer.is_valid()

        return SuccessResponseBuilder() \
                    .set_message("Successfully fetched the schools") \
                    .set_data(serializer.data) \
                    .set_metadata({ "total_schools": len(serializer.data) }) \
                    .build()
