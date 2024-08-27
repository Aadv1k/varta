from rest_framework import viewsets
from rest_framework.decorators import action

from .models import Announcement
from accounts.permissions import IsJWTAuthenticated

from common.response_builder import ErrorResponseBuilder, SuccessResponseBuilder

class AnnouncementViewSet(viewsets.ViewSet):
    permission_classes = ( IsJWTAuthenticated, )

    def list(self, request):
        all_announcements = Announcement.objects.filter(
            author__school=request.user.school,
        ).exclude(author__id=request.user.id)

        return ErrorResponseBuilder().set_message("Lmao you failed bro").build()

    @action(detail=True, methods=['get'])
    def list_mine(self, request):
        all_announcements = Announcement.objects.filter(author__id=request.user.id,)

        return ErrorResponseBuilder().set_message("Lmao you failed bro").build()