from rest_framework import viewsets
from rest_framework.decorators import action

from django.core.paginator import Paginator
import datetime

from .models import Announcement
from accounts.permissions import IsJWTAuthenticated

from rest_framework import serializers

from .serializers import AnnouncementOutputSerializer


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
        assert False, "Not implemented"

    @action(detail=True, methods=['get'])
    def list_mine(self, request):
        return self._paginate_announcements(request, Announcement.objects.filter(author__id=request.user.id))
