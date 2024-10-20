from django.contrib import admin
from .models import School, AcademicYear

class SchoolAdmin(admin.ModelAdmin):
    list_display = ('name', 'address', 'phone_number', 'email', 'website')
    search_fields = ('name', )
    list_filter = ('name',)

class AcademicYearAdmin(admin.ModelAdmin):
    list_display = ('start_date', 'end_date', 'current')
    search_fields = ('start_date', 'end_date')
    list_filter = ('current',)

admin.site.register(School, SchoolAdmin)
admin.site.register(AcademicYear, AcademicYearAdmin)