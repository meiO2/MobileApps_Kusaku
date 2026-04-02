from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404

from .models import Category, Expense, Income, CategoryBudget, UserBalance
from .serializers import (
    CategorySerializer,
    ExpenseSerializer,
    IncomeSerializer,
    CategoryBudgetSerializer,
    UserBalanceSerializer
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
        data = request.data  # list of {category_id, percentage}

        total = sum(item['percentage'] for item in data)
        if total > 100:
            return Response({"error": "Total percentage cannot exceed 100%"}, status=400)

        for item in data:
            budget = CategoryBudget.objects.get(
                user=request.user,
                category_id=item['category_id']
            )
            budget.percentage = item['percentage']
            budget.save()

        return Response({"message": "Budget updated"})

class BalanceView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        balance = get_object_or_404(UserBalance, user=request.user)
        return Response(UserBalanceSerializer(balance).data)

    def put(self, request):
        balance = get_object_or_404(UserBalance, user=request.user)
        balance.total_balance = request.data.get("total_balance", balance.total_balance)
        balance.save()

        return Response(UserBalanceSerializer(balance).data)
    
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


