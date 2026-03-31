import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/screens/register_screen.dart';
import 'package:app/screens/home_screen.dart';

/// 登录屏幕类
class LoginScreen extends StatefulWidget {
  /// 构造函数
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

/// 登录屏幕状态类
class _LoginScreenState extends State<LoginScreen> {
  /// 表单键，用于表单验证
  final _formKey = GlobalKey<FormState>();
  /// 邮箱输入控制器，默认值为测试邮箱
  final _emailController = TextEditingController(text: "123@example.com");
  /// 密码输入控制器，默认值为测试密码
  final _passwordController = TextEditingController(text: "123456");
  /// 是否隐藏密码
  bool _obscurePassword = true;

  @override
  void dispose() {
    // 释放控制器资源
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 登录方法
  /// 验证表单并调用AuthProvider的login方法进行登录
  void _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (success) {
        // 登录成功，跳转到主页
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // 登录失败，显示错误信息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.errorMessage ?? '登录失败')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('登录'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              const Text(
                '登录',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
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
              const SizedBox(height: 24),
              // 登录按钮
              ElevatedButton(
                onPressed: authProvider.isLoading ? null : _login,
                child: authProvider.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('登录'),
              ),
              const SizedBox(height: 16),
              // 注册按钮
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                child: const Text('没有账号？去注册'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
