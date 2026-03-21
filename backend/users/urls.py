from django.urls import path
from .views import SendOTPView, RegisterView, AccountListView

urlpatterns = [
    path('send-otp/', SendOTPView.as_view(), name='send-otp'),
    path('register/', RegisterView.as_view(), name='register'),
    path('accounts/', AccountListView.as_view(), name='account-list'),
]