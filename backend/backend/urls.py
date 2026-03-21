from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static


urlpatterns = [
    path('api/users/', include('users.urls')),
    path('api/ads/', include('ads.urls')),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)