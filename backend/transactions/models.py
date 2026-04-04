from django.db import models
from django.conf import settings
from django.utils import timezone
import math

User = settings.AUTH_USER_MODEL


class Category(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='categories')
    name = models.CharField(max_length=100)
    is_active = models.BooleanField(default=True)

    class Meta:
        unique_together = ('user', 'name')

    def __str__(self):
        return self.name


class CategoryBudget(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='budgets')
    category = models.ForeignKey(Category, on_delete=models.CASCADE, related_name='budgets')
    percentage = models.FloatField(default=0)

    class Meta:
        unique_together = ('user', 'category')

    def __str__(self):
        return f"{self.category.name} - {self.percentage}%"


class Expense(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='expenses')
    category = models.ForeignKey(
        Category,
        on_delete=models.PROTECT
    )

    total_payment = models.DecimalField(max_digits=10, decimal_places=2)
    transaction_fee = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    kusaku_points = models.IntegerField(default=0)  # auto-calculated on save

    date = models.DateTimeField(default=timezone.now)
    notes = models.TextField(blank=True)

    class Meta:
        ordering = ['-date']

    def save(self, *args, **kwargs):
        self.kusaku_points = math.floor(self.total_payment / 10000) * 10
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.total_payment} - {self.user}"


class Income(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='incomes')

    amount = models.DecimalField(max_digits=10, decimal_places=2)
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)

    date = models.DateTimeField(default=timezone.now)

    class Meta:
        ordering = ['-date']

    def __str__(self):
        return self.title