from rest_framework.views import APIView
from rest_framework.response import Response
from django.contrib.auth import get_user_model
from django.shortcuts import get_object_or_404

User = get_user_model()


class GenerateQRView(APIView):
    def get(self, request):
        return Response({
            "qr_data": str(request.user.id)
        })


class ResolveQRView(APIView):
    def get(self, request, user_id):
        user = get_object_or_404(User, id=user_id)

        return Response({
            "user_id": user.id,
            "username": user.username,
            "phone_number": user.phone_number,
        })