from django.db import models
from django.contrib.auth.models import AbstractUser
import secrets


class User(AbstractUser):
    email = models.EmailField(unique=True, verbose_name='邮箱')
    phone = models.CharField(max_length=20, blank=True, null=True, verbose_name='手机号')
    avatar = models.ImageField(upload_to='avatars/', blank=True, null=True, verbose_name='头像')
    is_verified = models.BooleanField(default=False, verbose_name='邮箱已验证')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='创建时间')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='更新时间')

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']

    class Meta:
        db_table = 'users'
        verbose_name = '用户'
        verbose_name_plural = '用户'
        ordering = ['-created_at']

    def __str__(self):
        return self.username


class Family(models.Model):
    name = models.CharField(max_length=100, verbose_name='家庭名称')
    invite_code = models.CharField(max_length=20, unique=True, verbose_name='邀请码')
    created_by = models.ForeignKey(User, on_delete=models.CASCADE, related_name='created_families', verbose_name='创建者')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='创建时间')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='更新时间')

    class Meta:
        db_table = 'families'
        verbose_name = '家庭'
        verbose_name_plural = '家庭'
        ordering = ['-created_at']

    def __str__(self):
        return self.name

    def save(self, *args, **kwargs):
        if not self.invite_code:
            self.invite_code = self._generate_invite_code()
        super().save(*args, **kwargs)

    def _generate_invite_code(self):
        while True:
            code = secrets.token_urlsafe(12)[:10]
            if not Family.objects.filter(invite_code=code).exists():
                return code


class FamilyMember(models.Model):
    ROLE_CHOICES = [
        ('admin', '管理员'),
        ('member', '成员'),
    ]

    family = models.ForeignKey(Family, on_delete=models.CASCADE, related_name='members', verbose_name='家庭')
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='family_memberships', verbose_name='用户')
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='member', verbose_name='角色')
    is_selected = models.BooleanField(default=False, verbose_name='是否选中')
    joined_at = models.DateTimeField(auto_now_add=True, verbose_name='加入时间')

    class Meta:
        db_table = 'family_members'
        verbose_name = '家庭成员'
        verbose_name_plural = '家庭成员'
        unique_together = ('family', 'user')
        ordering = ['-joined_at']

    def __str__(self):
        return f'{self.user.username} - {self.family.name} ({self.role})'
