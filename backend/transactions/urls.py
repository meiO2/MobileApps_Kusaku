from django.urls import path
from .views import (
    CategoryListView,
    CategoryUpdateView,
    BudgetView,
    BalanceView,
    ExpenseView,
    IncomeView
)

urlpatterns = [
    path('categories/', CategoryListView.as_view()),
    path('categories/<int:pk>/', CategoryUpdateView.as_view()),

    path('budget/', BudgetView.as_view()),
    path('balance/', BalanceView.as_view()),

    path('expenses/', ExpenseView.as_view()),
    path('incomes/', IncomeView.as_view()),
]