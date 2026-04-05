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
    path('balance/<int:user_id>/', BalanceView.as_view()),
    
    path('expenses/<int:user_id>/', ExpenseView.as_view()),
    path('incomes/', IncomeView.as_view()),
]