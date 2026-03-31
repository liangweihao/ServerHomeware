import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/screens/login_screen.dart';
import 'package:app/screens/home_screen.dart';

/// 注册屏幕类
class RegisterScreen extends StatefulWidget {
  /// 构造函数
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

/// 注册屏幕状态类
class _RegisterScreenState extends State<RegisterScreen> {
  /// 表单键，用于表单验证
  final _formKey = GlobalKey<FormState>();
  /// 用户名输入控制器
  final _usernameController = TextEditingController();
  /// 邮箱输入控制器
  final _emailController = TextEditingController();
  /// 密码输入控制器
  final _passwordController = TextEditingController();
  /// 确认密码输入控制器
  final _confirmPasswordController = TextEditingController();
  /// 是否隐藏密码
  bool _obscurePassword = true;
  /// 是否隐藏确认密码
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    // 释放控制器资源
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// 注册方法
  /// 验证表单并调用AuthProvider的register方法进行注册
  void _register() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.register(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (success) {
        // 注册成功，跳转到主页
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // 注册失败，显示错误信息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.errorMessage ?? '注册失败')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('注册'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Text(
                '创建新账号',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // 用户名输入框
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: '用户名',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入用户名';
                  }
                  if (value.length < 3) {
                    return '用户名长度至少为3位';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // 邮箱输入框
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: '邮箱',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入邮箱';
                  }
                  if (!value.contains('@')) {
                    return '请输入有效的邮箱地址';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // 密码输入框
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: '密码',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入密码';
                  }
                  if (value.length < 6) {
                    return '密码长度至少为6位';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // 确认密码输入框
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: '确认密码',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscureConfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请确认密码';
                  }
                  if (value != _passwordController.text) {
                    return '两次输入的密码不一致';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // 注册按钮
              ElevatedButton(
                onPressed: authProvider.isLoading ? null : _register,
                child: authProvider.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('注册'),
              ),
              const SizedBox(height: 16),
              // 登录按钮
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text('已有账号？去登录'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
