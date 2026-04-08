from rest_framework.views import APIView
from rest_framework.response import Response
from django.contrib.auth import get_user_model
from django.shortcuts import get_object_or_404
from rest_framework import status
from .models import Qris
from .serializers import QrisSerializer, QrisScanSerializer

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

class QrisListCreateView(APIView):
    def get(self, request):
        qris_records = Qris.objects.all().order_by('-transaction_date', '-transaction_time')
        return Response(QrisSerializer(qris_records, many=True).data)

    def post(self, request):
        serializer = QrisSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class QrisDetailView(APIView):
    def get(self, request, qris_id):
        qris = get_object_or_404(Qris, id=qris_id)
        return Response(QrisSerializer(qris).data)


class QrisScanView(APIView):
    def post(self, request):
        scan_serializer = QrisScanSerializer(data=request.data)
        if not scan_serializer.is_valid():
            return Response(scan_serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        qris_number = scan_serializer.validated_data['qris_number']
        qris = Qris.objects.filter(qris_number=qris_number).first()
        if not qris:
            return Response({'error': 'QRIS tidak valid atau tidak terdaftar'}, status=status.HTTP_404_NOT_FOUND)

        return Response(QrisSerializer(qris).data)