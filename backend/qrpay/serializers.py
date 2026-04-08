from rest_framework import serializers

from .models import Qris


class QrisSerializer(serializers.ModelSerializer):
    class Meta:
        model = Qris
        fields = [
            'id',
            'qris_number',
            'merchant_name',
            'merchant_PT',
            'transaction_date',
            'transaction_time',
            'amount',
        ]
        read_only_fields = ['id']
