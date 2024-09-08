from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.request import Request

from django.core.paginator import Paginator
import datetime

from django.core.exceptions import ValidationError as DjangoValidationError

from .models import Announcement
from accounts.permissions import IsJWTAuthenticated
from accounts.models import User

from rest_framework import serializers

from rest_framework.exceptions import ValidationError


from .serializers import AnnouncementOutputSerializer, AnnouncementSerializer


from schools.models import AcademicYear

from common.response_builder import ErrorResponseBuilder, SuccessResponseBuilder
from common.fields.AcademicYearField import AcademicYearField
import re

from accounts.permissions import IsTeacher

class AnnouncementViewSet(viewsets.ViewSet):
    permission_classes = [ IsJWTAuthenticated, ]

    def get_permissions(self):
        if self.action == "list_mine":
            permission_classes = [IsJWTAuthenticated, IsTeacher]
        else:
            permission_classes = [IsJWTAuthenticated]

        return [perm() for perm in permission_classes]

    class PaginationSerializer(serializers.Serializer):
        page = serializers.IntegerField(required=False, min_value=1)
        per_page = serializers.IntegerField(max_value=100, min_value=10, required=False)
        academic_year = AcademicYearField(required=False, allow_null=True)

    def _paginate_announcements(self, request, base_query):
        try:
            serializer = self.PaginationSerializer(
                data=dict(
                    per_page=request.GET.get("per_page", 20),
                    page=request.GET.get("page", 1),
                    academic_year=request.GET.get("academic_year")
                )
            )
        except ValueError:
            return ErrorResponseBuilder() \
                    .set_message("Invalid pagination parameters. Please provide valid integers.") \
                    .build()

        if not serializer.is_valid():
            return ErrorResponseBuilder() \
                    .set_code(400) \
                    .set_message("Invalid pagination parameters.") \
                    .set_details([{"field": key, "error": str(value[0])} for key, value in serializer.errors.items()]) \
                    .build()

        page_number = serializer.validated_data.get("page", 1)
        per_page = serializer.validated_data.get("per_page", 20)
        academic_year = serializer.validated_data.get("academic_year")

        if academic_year:
            current_academic_year_query = base_query.filter(academic_year=academic_year)
        else:
            current_academic_year_query = base_query.filter(academic_year__current=True)

        sorted_announcement_query = current_academic_year_query.order_by("-created_at")
        sorted_announcements_for_user = [ann for ann in sorted_announcement_query if ann.for_user(request.user)]

        serializer = AnnouncementOutputSerializer(data=sorted_announcements_for_user, many=True)
        serializer.is_valid()

        paginator = Paginator(serializer.data, per_page)
        try:
            current_page = paginator.page(page_number)
        except Paginator.EmptyPage:
            return ErrorResponseBuilder() \
                    .set_message(f"Page {page_number} does not exist. There are only {paginator.num_pages} pages available.") \
                    .build()

        return SuccessResponseBuilder() \
                .set_message("Announcements retrieved successfully.") \
                .set_data(current_page.object_list) \
                .set_metadata({
                    "page_length": len(current_page),
                    "page_number": page_number,
                    "total_pages": paginator.num_pages,
                }) \
                .build()


    def list(self, request):
        return self._paginate_announcements(request, Announcement.objects.all().exclude(author__id=request.user.id))

    def create(self, request):
        serializer = AnnouncementSerializer(data=request.data)

        if not serializer.is_valid():
            return ErrorResponseBuilder() \
                .set_code(400) \
                .set_message("Could not create announcement due to error") \
                .set_details([{"field": key, "error": str(value[0])} for key, value in serializer.errors.items()]) \
                .build()

        serializer.save()

        return SuccessResponseBuilder() \
            .set_code(201) \
            .set_message("Created announcement successfully") \
            .set_data(serializer.data) \
            .build()
        

    @action(detail=True, methods=['get'])
    def list_mine(self, request):
        return self._paginate_announcements(request, Announcement.objects.filter(author__id=request.user.id))

    class SearchSerializer(serializers.Serializer):
        query = serializers.CharField(max_length=256, required=False, allow_blank=True)
        posted_by = serializers.ListField(required=False, child=serializers.UUIDField(), allow_empty=True)
        date_from = serializers.DateField(required=False, allow_null=True, input_formats=["iso-8601"])
        date_to = serializers.DateField(required=False, allow_null=True, input_formats=["iso-8601"])

    @action(detail=True, methods=['get'])
    def search(self, request: Request):
        # posted_by_query_param = request.query_params.get("posted_by"),
        search_serializer = self.SearchSerializer(data={
            "query": request.query_params.get("query", ""),
            "posted_by": request.GET.getlist('posted_by'), #[puid for puid in posted_by_query_param if puid != None],
            "date_from": request.query_params.get("date_from"),
            "date_to": request.query_params.get("date_to"),
        })

        if not search_serializer.is_valid():
            return ErrorResponseBuilder() \
                .set_code(400) \
                .set_message("Invalid search parameters.") \
                .set_details([{"field": key, "error": str(value[0])} for key, value in search_serializer.errors.items()]) \
                .build()

        validated_data = search_serializer.validated_data
        
        if len(validated_data["posted_by"]) >= 1:
            base_query = Announcement.objects.filter(author__school__id=request.user.school.id, author__public_id__in=validated_data["posted_by"])
        else:
            base_query = Announcement.objects.filter(author__school__id=request.user.school.id)


        if validated_data.get("query"):
            base_query = base_query.filter(title__icontains=validated_data["query"])

        if validated_data.get("date_from"):
            base_query = base_query.filter(created_at__gte=validated_data["date_from"])

        if validated_data.get("date_to"):
            base_query = base_query.filter(created_at__lte=validated_data["date_to"])

        results = base_query

        output_serializer = AnnouncementOutputSerializer(data=results, many=True)
        assert not output_serializer.is_valid(), search_serializer.errors

        return SuccessResponseBuilder() \
            .set_message("Search query complete") \
            .set_data(output_serializer.data) \
            .set_metadata({
                "results": len(output_serializer.data),
            }) \
            .build()
