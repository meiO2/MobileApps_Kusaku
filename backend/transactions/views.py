from rest_framework.views import APIView
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from rest_framework import status
from django.db.models import Sum
from django.db import transaction

from .models import Category, Expense, Income, CategoryBudget, Transfer
from .serializers import (
    CategorySerializer,
    ExpenseSerializer,
    IncomeSerializer,
    CategoryBudgetSerializer,
)
from kusakustamp.models import UserStamp
from users.models import Account

class CategoryListView(APIView):

    def get(self, request):
        categories = Category.objects.filter(user=request.user)
        return Response(CategorySerializer(categories, many=True).data)

from .models import Category, CategoryBudget

class CategoryUpdateView(APIView):

    def post(self, request, pk):
        print("REQUEST DATA:", request.data)

        user = get_object_or_404(Account, pk=pk)
        categories = request.data.get("categories", [])

        from django.db.models import Sum
        total_income = Income.objects.filter(user=user).aggregate(
            total=Sum('amount')
        )['total'] or 0

        updated = []

        for cat_data in categories:
            cat_id = cat_data.get("id")

            category = get_object_or_404(Category, pk=cat_id, user=user)

            category.is_active = cat_data.get("enabled", category.is_active)
            category.save()

            budget, _ = CategoryBudget.objects.get_or_create(
                user=user,
                category=category
            )

            percentage = cat_data.get("percentage", budget.percentage)
            budget.percentage = percentage
            budget.allocated_amount = (percentage / 100) * float(total_income)  # ← add float()
            budget.save()

            updated.append({
                "id": category.id,
                "name": category.name,
                "percentage": budget.percentage,
                "enabled": category.is_active,
            })

        return Response(updated)

class BudgetView(APIView):

    def get(self, request, user_id):
        from django.db.models import Sum

        total_income = Income.objects.filter(user_id=user_id).aggregate(
            total=Sum('amount')
        )['total'] or 0

        budgets = CategoryBudget.objects.filter(
            user_id=user_id,
            category__is_active=True,
            percentage__gt=0
        ).select_related('category')

        result = []
        for budget in budgets:
            allocated = (budget.percentage / 100) * float(total_income)  # ← float()
            remaining = allocated - float(budget.used_amount)             # ← float()
            result.append({
                "category": {
                    "name": budget.category.name,
                },
                "percentage": budget.percentage,
                "allocated_amount": allocated,
                "used_amount": float(budget.used_amount),                 # ← float()
                "remaining_amount": max(remaining, 0),
            })

        return Response(result)

    def put(self, request, user_id):
        data = request.data

        if not isinstance(data, list):
            return Response(
                {"error": "Invalid data format, expected a list"},
                status=status.HTTP_400_BAD_REQUEST
            )

        total = sum(item.get('percentage', 0) for item in data)
        if total > 100 or total < 0:
            return Response(
                {"error": "Total percentage must be between 0 and 100"},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        total_income = Income.objects.filter(user_id=user_id).aggregate(
                    total=Sum('amount')
                )['total'] or 0

        with transaction.atomic():
            budgets = []

            for item in data:
                category = get_object_or_404(Category, id=item['category_id'], user_id=user_id)
                budget = get_object_or_404(CategoryBudget, user_id=user_id, category=category)

                percentage = item.get("percentage", budget.percentage)
                budget.percentage = percentage

                budget.allocated_amount = (percentage / 100) * total_income

                budgets.append(budget)

            total_allocated = sum(b.allocated_amount for b in budgets)
            leftover = total_income - total_allocated

            if leftover > 0:
                extra_per_budget = leftover / len(budgets)
                for b in budgets:
                    b.allocated_amount += extra_per_budget

            for b in budgets:
                b.save()

        return Response(
            {"message": "Budget updated successfully"},
            status=status.HTTP_200_OK
        )

class BalanceView(APIView):
    def get(self, request, user_id):
        total_income = Income.objects.filter(user_id=user_id).aggregate(
            total=Sum('amount')
        )['total'] or 0

        expenses = Expense.objects.filter(user_id=user_id)
        total_expense = sum(e.total_payment + e.transaction_fee for e in expenses)

        sent_transfers = Transfer.objects.filter(sender_id=user_id).aggregate(
            total=Sum('amount')
        )['total'] or 0

        received_transfers = Transfer.objects.filter(recipient_id=user_id).aggregate(
            total=Sum('amount')
        )['total'] or 0

        points_earned = Expense.objects.filter(user_id=user_id).aggregate(
            total=Sum('kusaku_points')
        )['total'] or 0

        points_spent = UserStamp.objects.filter(user_id=user_id).aggregate(
            total=Sum('points_used')
        )['total'] or 0

        balance = total_income - total_expense - sent_transfers + received_transfers

        return Response({
            "total_income": total_income,
            "total_expense": total_expense,
            "balance": balance,
            "kusaku_points": points_earned - points_spent,
        })

class ExpenseView(APIView):
    def get(self, request, user_id):
        expenses = Expense.objects.filter(user_id=user_id)
        return Response(ExpenseSerializer(expenses, many=True).data)

    def post(self, request, user_id):
        serializer = ExpenseSerializer(data=request.data)
        if serializer.is_valid():
            expense = serializer.save(user_id=user_id)

            budget = CategoryBudget.objects.get(
                user_id=user_id,
                category=expense.category
            )

            total_spent = expense.total_payment + expense.transaction_fee
            budget.used_amount += total_spent
            budget.save()

            return Response(serializer.data, status=201)

        return Response(serializer.errors, status=400)

class IncomeView(APIView):

    def get(self, request, user_id):
        incomes = Income.objects.filter(user_id=user_id)
        return Response(IncomeSerializer(incomes, many=True).data)

    def post(self, request, user_id):
        serializer = IncomeSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user_id=user_id)
            return Response(serializer.data, status=201)
        return Response(serializer.errors, status=400)

class TransferView(APIView):

    def post(self, request, user_id):
        sender_phone = request.data.get('sender_phone')
        recipient_phone = request.data.get('recipient_phone')
        amount = request.data.get('amount')
        notes = request.data.get('notes', '')

        # Validate fields
        if not all([sender_phone, recipient_phone, amount]):
            return Response(
                {"error": "sender_phone, recipient_phone, dan amount wajib diisi"},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Validate sender matches user_id
        try:
            sender = Account.objects.get(id=user_id, phone_number=sender_phone)
        except Account.DoesNotExist:
            return Response(
                {"error": "Nomor pengirim tidak valid"},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Find recipient
        try:
            recipient = Account.objects.get(phone_number=recipient_phone)
        except Account.DoesNotExist:
            return Response(
                {"error": "Nomor penerima tidak ditemukan"},
                status=status.HTTP_404_NOT_FOUND
            )

        if sender == recipient:
            return Response(
                {"error": "Tidak bisa transfer ke diri sendiri"},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Check sender balance
        total_income = Income.objects.filter(user=sender).aggregate(
            total=Sum('amount')
        )['total'] or 0

        expenses = Expense.objects.filter(user=sender)
        total_expense = sum(e.total_payment + e.transaction_fee for e in expenses)

        sent_transfers = Transfer.objects.filter(sender=sender).aggregate(
            total=Sum('amount')
        )['total'] or 0

        received_transfers = Transfer.objects.filter(recipient=sender).aggregate(
            total=Sum('amount')
        )['total'] or 0

        balance = total_income - total_expense - sent_transfers + received_transfers

        if balance < float(amount):
            return Response(
                {
                    "error": "Saldo tidak cukup",
                    "balance": balance,
                },
                status=status.HTTP_400_BAD_REQUEST
            )

        # Create transfer record
        with transaction.atomic():
            transfer = Transfer.objects.create(
                sender=sender,
                recipient=recipient,
                amount=amount,
                notes=notes,
            )

            # Add as income for recipient
            Income.objects.create(
                user=recipient,
                amount=amount,
                title=f"Transfer dari {sender.phone_number}",
                description=notes,
            )

        return Response({
            "message": "Transfer berhasil",
            "transfer_id": transfer.id,
            "amount": amount,
            "recipient": recipient.phone_number,
            "remaining_balance": balance - float(amount),
        }, status=status.HTTP_201_CREATED)

class UserCategoryBudgetView(APIView):

    def get(self, request, user_id):
        user = get_object_or_404(Account, pk=user_id)

        categories = Category.objects.filter(user=user)

        result = []

        for cat in categories:
            budget = CategoryBudget.objects.filter(
                user=user,
                category=cat
            ).first()

            result.append({
                "id": cat.id,
                "name": cat.name,
                "percentage": budget.percentage if budget else 0,
                "enabled": cat.is_active,
            })

        return Response(result)