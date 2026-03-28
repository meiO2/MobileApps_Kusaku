import random
from django.core.mail import send_mail
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.conf import settings
from django.contrib.auth import authenticate
from django.shortcuts import get_object_or_404
from django.contrib.auth import authenticate
from rest_framework.permissions import AllowAny

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


class LoginView(APIView):
    permission_classes = [AllowAny]
    # We use POST to securely send the username/password to be checked
    def post(self, request):
        username = request.data.get('username')
        password = request.data.get('password')

        # This SEARCHES the database for a match
        user = authenticate(username=username, password=password)

        if user is not None:
            return Response({"user_id": user.id, "username": user.username}, status=status.HTTP_200_OK)
        
        # If it gets here, the search failed (Unauthorized)
        return Response({"error": "Invalid credentials"}, status=status.HTTP_401_UNAUTHORIZED)

class ProfileDetailView(APIView):
    def get(self, request, user_id):
        # This will search for the user by ID or return a 404 error if not found
        user = get_object_or_404(Account, id=user_id)
        
        # Using your existing serializer to format the data
        serializer = RegisterSerializer(user) 
        return Response(serializer.data, status=status.HTTP_200_OK)

