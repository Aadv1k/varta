from django.contrib import admin
from .models import Announcement, AnnouncementScope
from django.utils.html import format_html
from attachments.models import Attachment
from django.contrib import messages

class AnnouncementScopeInline(admin.TabularInline):
    model = AnnouncementScope
    extra = 1
    fields = ('filter', 'filter_data')
    show_change_link = True

@admin.action(description="Soft delete selected announcements")
def soft_delete_announcements(modeladmin, request, queryset):
    """Perform soft delete on the selected announcements."""
    for obj in queryset:
        obj.soft_delete()
    modeladmin.message_user(request, "Selected announcements were soft deleted.")

class AnnouncementAdmin(admin.ModelAdmin):
    list_display = ('title', 'author', 'academic_year', 'created_at', 'updated_at', 'deleted_at')
    search_fields = ('title', 'body', 'author__first_name', 'author__last_name')
    list_filter = ('created_at', 'updated_at', 'deleted_at', 'author')
    readonly_fields = ('created_at', 'updated_at', 'deleted_at')

    inlines = [AnnouncementScopeInline]
    actions = [soft_delete_announcements, ]


admin.site.register(Announcement, AnnouncementAdmin)
admin.site.register(AnnouncementScope)