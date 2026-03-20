from django.urls import path
from .views import RegisterView, AccountView

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('accounts/', AccountView.as_view(), name='accounts'),
]