from rest_framework import serializers
from .models import Account, EmailOTP
from django.contrib.auth.hashers import make_password
from django.utils import timezone
from datetime import timedelta


class SendOTPSerializer(serializers.Serializer):
    email = serializers.EmailField()


class RegisterSerializer(serializers.ModelSerializer):
    otp = serializers.CharField(write_only=True)

    class Meta:
        model = Account
        fields = [
            'email',
            'username',
            'phone_number',
            'transaction_password',
            'password',
            'otp'
        ]
        extra_kwargs = {
            'password': {'write_only': True}
        }

    def validate(self, data):
        email = data.get('email')
        otp = data.get('otp')

        otp_obj = EmailOTP.objects.filter(email=email, otp=otp).first()

        if not otp_obj:
            raise serializers.ValidationError("OTP salah")

        if otp_obj.created_at < timezone.now() - timedelta(minutes=5):
            raise serializers.ValidationError("OTP sudah kadaluarsa")

        return data

    def create(self, validated_data):
        validated_data.pop('otp')

        validated_data['password'] = make_password(validated_data['password'])
        validated_data['transaction_password'] = make_password(validated_data['transaction_password'])

        user = Account.objects.create(**validated_data)

        EmailOTP.objects.filter(email=user.email).delete()

        return user


class AccountSerializer(serializers.ModelSerializer):
    class Meta:
        model = Account
        fields = '__all__'