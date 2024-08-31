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
        page = serializers.IntegerField(required=False)
        per_page = serializers.IntegerField(max_value=100, min_value=20, required=False)
        academic_year = AcademicYearField(required=False)

    def _paginate_announcements(self, request, base_query):
        serializer = self.PaginationSerializer(
            data=dict(request.GET)
        )

        if not serializer.is_valid():
            return ErrorResponseBuilder() \
                    .set_code(400)        \
                    .set_message("Invalid data provicded") \
                    .set_details([{"field": key, "error": str(value.pop())} for key, value in serializer.errors.items()]) \
                    .build()

        page_number = serializer.validated_data.get("page") or 1
        page_length = serializer.validated_data.get("page_length") or 20
        academic_year = serializer.validated_data.get("acadmic_year") 

        current_academic_year_query = base_query.filter(academic_year__current=True) if not academic_year else base_query.filter(academic_year=academic_year)

        sorted_announcement_query = current_academic_year_query.order_by("created_at")
        sorted_announcements_for_user = filter(lambda ann: ann.for_user(request.user), sorted_announcement_query.all())

        serializer = AnnouncementOutputSerializer(data=sorted_announcements_for_user, many=True)

        serializer.is_valid()

        pages = Paginator(serializer.data, page_length)
        current_page = pages.page(page_number)

        return SuccessResponseBuilder() \
                .set_message("Something did happen actually come to think of it") \
                .set_data(current_page.object_list) \
                .set_metadata(dict(page_length=len(current_page), page_number=page_number, page_count=pages.num_pages)) \
                .build()


    def list(self, request):
        return self._paginate_announcements(request, Announcement.objects.all().exclude(author__id=request.user.id))

    @action(detail=True, methods=['get'])
    def list_mine(self, request):
        return self._paginate_announcements(request, Announcement.objects.filter(author__id=request.user.id))
