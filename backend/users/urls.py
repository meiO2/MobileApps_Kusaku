from django.urls import path
from .views import SendOTPView, RegisterView

urlpatterns = [
    path('send-otp/', SendOTPView.as_view()),
    path('register/', RegisterView.as_view()),
]