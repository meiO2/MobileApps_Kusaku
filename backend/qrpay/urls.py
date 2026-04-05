from django.urls import path
from .views import GenerateQRView, ResolveQRView

urlpatterns = [
    path('generate/', GenerateQRView.as_view()),
    path('resolve/<int:user_id>/', ResolveQRView.as_view()),
]