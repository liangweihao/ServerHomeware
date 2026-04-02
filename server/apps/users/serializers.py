from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import Family, FamilyMember


User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'phone', 'avatar', 'is_verified', 'created_at']
        read_only_fields = ['id', 'is_verified', 'created_at']
        extra_kwargs = {
            'phone': {'allow_null': True, 'required': False},
            'avatar': {'allow_null': True, 'required': False},
        }


class UserRegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)
    password_confirm = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ['username', 'email', 'password', 'password_confirm', 'phone']

    def validate(self, attrs):
        if attrs['password'] != attrs['password_confirm']:
            raise serializers.ValidationError({'password_confirm': '两次密码不一致'})
        return attrs

    def create(self, validated_data):
        validated_data.pop('password_confirm')
        password = validated_data.pop('password')
        user = User.objects.create_user(**validated_data)
        user.set_password(password)
        user.save()
        return user


class UserLoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)


class FamilyMemberSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='user.username', read_only=True)
    email = serializers.EmailField(source='user.email', read_only=True)

    class Meta:
        model = FamilyMember
        fields = ['id', 'username', 'email', 'role', 'joined_at']
        read_only_fields = ['id', 'joined_at']


class FamilySerializer(serializers.ModelSerializer):
    members = FamilyMemberSerializer(many=True, read_only=True)
    created_by_username = serializers.CharField(source='created_by.username', read_only=True)
    is_selected = serializers.SerializerMethodField()

    class Meta:
        model = Family
        fields = ['id', 'name', 'invite_code', 'created_by', 'created_by_username', 'is_selected', 'members', 'created_at']
        read_only_fields = ['id', 'invite_code', 'created_by', 'created_by_username', 'is_selected', 'created_at']

    def get_is_selected(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            try:
                member = FamilyMember.objects.get(family=obj, user=request.user)
                return member.is_selected
            except FamilyMember.DoesNotExist:
                return False
        return False


class FamilyCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Family
        fields = ['name']

    def create(self, validated_data):
        user = self.context['request'].user
        family = Family.objects.create(name=validated_data['name'], created_by=user)
        FamilyMember.objects.create(family=family, user=user, role='admin')
        return family


class FamilyJoinSerializer(serializers.Serializer):
    invite_code = serializers.CharField(max_length=20)

    def validate_invite_code(self, value):
        try:
            family = Family.objects.get(invite_code=value)
        except Family.DoesNotExist:
            raise serializers.ValidationError('邀请码无效')
        return value

    def save(self):
        user = self.context['request'].user
        invite_code = self.validated_data['invite_code']
        family = Family.objects.get(invite_code=invite_code)
        
        if FamilyMember.objects.filter(family=family, user=user).exists():
            raise serializers.ValidationError('您已经是该家庭的成员')
        
        member = FamilyMember.objects.create(family=family, user=user, role='member')
        return member
