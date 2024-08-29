from rest_framework import serializers
from schools.models import AcademicYear

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
