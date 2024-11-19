from django.contrib import admin
from django.utils.html import format_html
from .models import Attachment


class AttachmentAdmin(admin.ModelAdmin):
    list_display = (
        'id',
        'file_name',
        'file_type',
        'user',
        'announcement',
        'file_size_display',
        'created_at',
    )
    search_fields = ('file_name', 'user__username', 'announcement__title')
    list_filter = ('file_type', 'announcement')
    readonly_fields = ('id', 'created_at')

    def file_size_display(self, obj):
        """Display file size in a human-readable format."""
        size = obj.file_size_in_bytes
        if size < 1024:
            return f"{size} B"
        elif size < 1024 ** 2:
            return f"{size / 1024:.2f} KB"
        elif size < 1024 ** 3:
            return f"{size / (1024 ** 2):.2f} MB"
        else:
            return f"{size / (1024 ** 3):.2f} GB"

    file_size_display.short_description = "File Size"

admin.site.register(Attachment, AttachmentAdmin)
