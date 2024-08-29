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
import re

class AcademicYearField(serializers.CharField):
    academic_year_reg = r"^(\d{4})-(\d{4})$"

    def to_internal_value(self, data):
        match = re.match(self.academic_year_reg, data)
        if not match:
            raise serializers.ValidationError("Expected academic year to be provided in the format yyyy-yyyy")

        start_year, end_year = match.groups()

        try:
            start_year = int(start_year)
            end_year = int(end_year)
        except ValueError:
            raise serializers.ValidationError("Years must be integers")

        if start_year >= end_year:
            raise serializers.ValidationError("End year must be greater than start year")

        start_date = datetime.datetime(year=start_year, month=4, day=1)
        end_date = datetime.datetime(year=end_year, month=3, day=31)

        if not AcademicYear.objects.filter(start_date=start_date, end_date=end_date).exists():
            raise serializers.ValidationError("Invalid academic year")

        return data

    def to_representation(self, value):
        return f"{ value.start_date.year }-{ value.end_date.year }"


class AnnouncementViewSet(viewsets.ViewSet):
    permission_classes = ( IsJWTAuthenticated, )

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
