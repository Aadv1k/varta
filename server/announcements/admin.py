from django.contrib import admin
from .models import Announcement, AnnouncementScope


class AnnouncementScopeInline(admin.TabularInline):
    model = AnnouncementScope
    extra = 1 
    fields = ('filter', 'filter_data')
    show_change_link = True


class AnnouncementAdmin(admin.ModelAdmin):
    list_display = ('title', 'author', 'academic_year', 'created_at', 'updated_at', 'deleted_at', 'is_deleted')
    search_fields = ('title', 'body', 'author__first_name', 'author__last_name')
    list_filter = ('academic_year', 'author', 'created_at', 'updated_at', 'deleted_at')
    readonly_fields = ('created_at', 'updated_at', 'deleted_at')
    inlines = [AnnouncementScopeInline]

    def is_deleted(self, obj):
        return obj.deleted_at is not None

class AnnouncementScopeAdmin(admin.ModelAdmin):
    list_display = ('announcement', 'filter', 'filter_data')
    search_fields = ('announcement__title', 'filter', 'filter_data')
    list_filter = ('filter',)


admin.site.register(Announcement, AnnouncementAdmin)
admin.site.register(AnnouncementScope, AnnouncementScopeAdmin)
