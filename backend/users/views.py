from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.core.mail import send_mail
from django_otp.plugins.otp_totp.models import TOTPDevice
from .serializers import RegisterSerializer, AccountSerializer
from .models import Account

class RegisterView(APIView):
    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        
        if serializer.is_valid():
            user = serializer.save()
            user.is_active = False
            user.save()

            device = TOTPDevice.objects.create(user=user, name="default", confirmed=False)
            otp_code = device.generate_challenge()

            try:
                send_mail(
                    'Kode Verifikasi Kusaku',
                    f'Halo {user.username}, kode OTP kamu adalah: {otp_code}',
                    'admin@kusaku.com',
                    [user.email],
                    fail_silently=False,
                )
                return Response({
                    "message": "User berhasil dibuat. Silahkan cek email untuk kode OTP."
                }, status=status.HTTP_201_CREATED)
            except Exception as e:
                return Response({
                    "message": "User dibuat tapi email gagal dikirim.",
                    "error": str(e)
                }, status=status.HTTP_201_CREATED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class AccountView(APIView):
    def get(self, request):
        users = Account.objects.all()
        serializer = AccountSerializer(users, many=True)
        return Response(serializer.data)