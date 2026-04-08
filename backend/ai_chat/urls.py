from django.urls import path
from .views import ChatSessionView, ChatMessageView

urlpatterns = [
    path('session/<int:user_id>/', ChatSessionView.as_view()),
    path('message/<int:user_id>/', ChatMessageView.as_view()),
]