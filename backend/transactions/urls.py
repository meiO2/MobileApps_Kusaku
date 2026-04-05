from django.urls import path
from .views import (
    CategoryListView,
    CategoryUpdateView,
    BudgetView,
    BalanceView,
    ExpenseView,
    IncomeView,
    TransferView
)

urlpatterns = [
    path('categories/', CategoryListView.as_view()),
    path('categories/<int:pk>/', CategoryUpdateView.as_view()),

    path('budget/', BudgetView.as_view()),
    path('balance/<int:user_id>/', BalanceView.as_view()),

    path('expenses/<int:user_id>/', ExpenseView.as_view()),
    path('incomes/<int:user_id>/', IncomeView.as_view()),
    path('transfer/<int:user_id>/', TransferView.as_view()),
]