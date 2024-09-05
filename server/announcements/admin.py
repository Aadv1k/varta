from django.contrib import admin

from .models import Announcement, AnnouncementScope

admin.site.register(Announcement)
admin.site.register(AnnouncementScope)
