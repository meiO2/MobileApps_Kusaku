from django.urls import path
from .views import SendOTPView, RegisterView, LoginView, ProfileDetailView

urlpatterns = [
    path('send-otp/', SendOTPView.as_view(), name='send-otp'),
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('profile/<int:user_id>/', ProfileDetailView.as_view(), name='profile-detail'),
]