from rest_framework.views import APIView
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from .models import ChatSession, ChatMessage
from .serializers import ChatSessionSerializer
from users.models import Account
from .services.openrouter_service import send_to_ai

import requests


class ChatSessionView(APIView):
    def get(self, request, user_id):
        session, _ = ChatSession.objects.get_or_create(user_id=user_id)
        serializer = ChatSessionSerializer(session)
        return Response(serializer.data)


class ChatMessageView(APIView):
    def post(self, request, user_id):
        session, _ = ChatSession.objects.get_or_create(user_id=user_id)

        user_message = request.data.get("message")

        ChatMessage.objects.create(
            session=session,
            is_user=True,
            text=user_message
        )

        messages = ChatMessage.objects.filter(session=session).order_by('created_at')
        messages = messages.order_by('-created_at')[:10][::-1]

        conversation = []

        conversation.append({
            "role": "system",
            "content": (
                "You are a financial assistant. Help users manage budgeting, "
                "expenses, and give suggestions.\n\n"
                "If user asks for budget allocation, respond ONLY in JSON format like:\n"
                "{ \"Makan & Minum\": 30, \"Transportasi\": 10 }\n\n"
                "Keep answers short and helpful."
            )
        })

        for m in messages:
            conversation.append({
                "role": "user" if m.is_user else "assistant",
                "content": m.text
            })

        ai_reply = send_to_ai(conversation)

        ChatMessage.objects.create(
            session=session,
            is_user=False,
            text=ai_reply
        )

        import json
        try:
            parsed = json.loads(ai_reply)
            return Response({
                "reply": ai_reply,
                "type": "budget_suggestion",
                "data": parsed
            })
        except:
            print("OPENROUTER RESPONSE:", ai_reply)
            return Response({
                "reply": ai_reply,
                "type": "text"
            })