import random
from django.core.mail import send_mail
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.conf import settings

from .models import EmailOTP, Account
from .serializers import RegisterSerializer, SendOTPSerializer

class SendOTPView(APIView):
    def post(self, request):
        serializer = SendOTPSerializer(data=request.data)

        if serializer.is_valid():
            email = serializer.validated_data['email']

            # 🚫 CHECK IF EMAIL ALREADY EXISTS
            if Account.objects.filter(email=email).exists():
                return Response(
                    {"error": "Email sudah terdaftar"},
                    status=status.HTTP_400_BAD_REQUEST
                )

            otp = str(random.randint(100000, 999999))

            # 🔥 UPDATE OR CREATE (prevent spam)
            EmailOTP.objects.update_or_create(
                email=email,
                defaults={'otp': otp}
            )

            send_mail(
                'Kode OTP Kusaku',
                f'Kode OTP kamu adalah {otp}',
                settings.EMAIL_HOST_USER,
                [email],
                fail_silently=False,
            )

            return Response({"message": "OTP dikirim"}, status=status.HTTP_200_OK)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class RegisterView(APIView):
    def post(self, request):
        serializer = RegisterSerializer(data=request.data)

        if serializer.is_valid():
            serializer.save()
            return Response({"message": "Akun berhasil dibuat"}, status=status.HTTP_201_CREATED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
