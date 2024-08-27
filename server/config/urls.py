from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('api/v1/', include("accounts.urls")),
    path('api/v1/', include("schools.urls")),
    path('api/v1/', include("announcements.urls")),
    path('admin/', admin.site.urls),
]
