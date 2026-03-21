from django.contrib.auth.hashers import make_password
from rest_framework import serializers
from .models import Account, EmailOTP

class RegisterSerializer(serializers.ModelSerializer):
    otp = serializers.CharField(write_only=True)

    class Meta:
        model = Account
        fields = ['email', 'username', 'phone_number', 'password', 'transaction_password', 'otp']
        extra_kwargs = {
            'password': {'write_only': True},
            'transaction_password': {'write_only': True}
        }

    
    def create(self, validated_data):
        otp_input = validated_data.pop('otp')
        email = validated_data.get('email')

        try:
            otp_obj = EmailOTP.objects.filter(email=email).latest('created_at')
        except EmailOTP.DoesNotExist:
            raise serializers.ValidationError("OTP tidak ditemukan")

        if otp_obj.is_expired():
            raise serializers.ValidationError("OTP sudah expired")

        if otp_obj.otp != otp_input:
            raise serializers.ValidationError("OTP salah")

        validated_data['transaction_password'] = make_password(
            validated_data.get('transaction_password')
        )

        user = Account.objects.create_user(**validated_data)
        user.is_active = True
        user.save()

        otp_obj.delete()

        return user
    
    def validate_email(self, value):
        if Account.objects.filter(email=value).exists():
            raise serializers.ValidationError("Email sudah digunakan")
        return value

class AccountSerializer(serializers.ModelSerializer):
    class Meta:
        model = Account
        fields = ['id', 'email', 'username', 'phone_number', 'is_active']

class SendOTPSerializer(serializers.Serializer):
    email = serializers.EmailField()