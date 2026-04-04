from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from rest_framework import status
from django.db.models import Sum
from django.db import transaction
from rest_framework import status

from .models import Category, Expense, Income, CategoryBudget
from .serializers import (
    CategorySerializer,
    ExpenseSerializer,
    IncomeSerializer,
    CategoryBudgetSerializer,
)

class CategoryListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        categories = Category.objects.filter(user=request.user)
        return Response(CategorySerializer(categories, many=True).data)

class CategoryUpdateView(APIView):
    permission_classes = [IsAuthenticated]

    def put(self, request, pk):
        category = get_object_or_404(Category, pk=pk, user=request.user)

        category.name = request.data.get("name", category.name)
        category.is_active = request.data.get("is_active", category.is_active)
        category.save()

        return Response(CategorySerializer(category).data)

class BudgetView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        budgets = CategoryBudget.objects.filter(user=request.user)
        return Response(CategoryBudgetSerializer(budgets, many=True).data)

    def put(self, request):
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

        with transaction.atomic():
            for item in data:
                category_id = item.get('category_id')

                if not category_id:
                    return Response(
                        {"error": "category_id is required"},
                        status=status.HTTP_400_BAD_REQUEST
                    )

                category = get_object_or_404(
                    Category,
                    id=category_id,
                    user=request.user
                )

                if "name" in item:
                    category.name = item["name"]

                if "is_active" in item:
                    category.is_active = item["is_active"]

                category.save()

                budget = get_object_or_404(
                    CategoryBudget,
                    user=request.user,
                    category=category
                )

                if "percentage" in item:
                    budget.percentage = item["percentage"]

                budget.save()

        return Response(
            {"message": "Budget updated successfully"},
            status=status.HTTP_200_OK
        )

class BalanceView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        total_income = Income.objects.filter(user=request.user).aggregate(
            total=Sum('amount')
        )['total'] or 0

        expenses = Expense.objects.filter(user=request.user)
        total_expense = sum(
            e.total_payment + e.transaction_fee
            for e in expenses
        )

        balance = total_income - total_expense

        points_earned = Expense.objects.filter(user=request.user).aggregate(
            total=Sum('kusaku_points')
        )['total'] or 0

        points_spent = Stamp.objects.filter(user=request.user).aggregate(
            total=Sum('points_used')
        )['total'] or 0

        kusaku_points = points_earned - points_spent

        return Response({
            "total_income": total_income,
            "total_expense": total_expense,
            "balance": balance,
            "kusaku_points": kusaku_points,
        })
    
class ExpenseView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        expenses = Expense.objects.filter(user=request.user)
        return Response(ExpenseSerializer(expenses, many=True).data)

    def post(self, request):
        serializer = ExpenseSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user=request.user)
            return Response(serializer.data, status=201)
        return Response(serializer.errors, status=400)

class IncomeView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        incomes = Income.objects.filter(user=request.user)
        return Response(IncomeSerializer(incomes, many=True).data)

    def post(self, request):
        serializer = IncomeSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user=request.user)
            return Response(serializer.data, status=201)
        return Response(serializer.errors, status=400)


