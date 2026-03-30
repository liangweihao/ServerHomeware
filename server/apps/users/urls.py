from django.urls import path
from .views import (
    register,
    login,
    profile,
    update_profile,
    FamilyListCreateView,
    FamilyDetailView,
    join_family
)

urlpatterns = [
    path('register/', register, name='register'),
    path('login/', login, name='login'),
    path('profile/', profile, name='profile'),
    path('profile/update/', update_profile, name='update_profile'),
    path('families/', FamilyListCreateView.as_view(), name='family-list-create'),
    path('families/<int:id>/', FamilyDetailView.as_view(), name='family-detail'),
    path('families/<int:id>/join/', join_family, name='join-family'),
]
