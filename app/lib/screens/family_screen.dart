import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/family_provider.dart';

/// 家庭管理屏幕类，用于管理家庭相关功能
class FamilyScreen extends StatefulWidget {
  /// 构造函数
  const FamilyScreen({Key? key}) : super(key: key);

  @override
  _FamilyScreenState createState() => _FamilyScreenState();
}

/// FamilyScreen的状态类
class _FamilyScreenState extends State<FamilyScreen> {
  /// 表单键，用于表单验证
  final _formKey = GlobalKey<FormState>();
  /// 家庭名称输入控制器
  final _familyNameController = TextEditingController();
  /// 是否显示创建家庭表单
  bool _showCreateForm = false;

  /// 释放资源
  @override
  void dispose() {
    _familyNameController.dispose();
    super.dispose();
  }

  /// 创建家庭方法
  /// 验证表单并调用familyProvider创建家庭
  void _createFamily() async {
    if (_formKey.currentState!.validate()) {
      final familyProvider = Provider.of<FamilyProvider>(context, listen: false);
      final success = await familyProvider.createFamily(_familyNameController.text.trim());
      if (success) {
        setState(() {
          _showCreateForm = false;
          _familyNameController.clear();
        });
        // 显示创建成功提示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('家庭创建成功')),
        );
      } else {
        // 显示创建失败提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(familyProvider.errorMessage ?? '创建家庭失败')),
        );
      }
    }
  }

  /// 构建UI界面
  @override
  Widget build(BuildContext context) {
    final familyProvider = Provider.of<FamilyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('家庭管理'),
        centerTitle: true,
      ),
      body: familyProvider.isLoading
          ? const Center(child: CircularProgressIndicator()) // 显示加载指示器
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 创建家庭表单
                  if (_showCreateForm)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // 家庭名称输入框
                              TextFormField(
                                controller: _familyNameController,
                                decoration: const InputDecoration(
                                  labelText: '家庭名称',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '请输入家庭名称';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              // 操作按钮
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: familyProvider.isLoading ? null : _createFamily,
                                      child: familyProvider.isLoading
                                          ? const CircularProgressIndicator()
                                          : const Text('创建'),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          _showCreateForm = false;
                                          _familyNameController.clear();
                                        });
                                      },
                                      child: const Text('取消'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // 创建家庭按钮
                  if (!_showCreateForm)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showCreateForm = true;
                        });
                      },
                      child: const Text('创建家庭'),
                    ),
                  const SizedBox(height: 24),
                  // 家庭列表标题
                  const Text(
                    '我的家庭',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // 家庭列表
                  Expanded(
                    child: ListView.builder(
                      itemCount: familyProvider.families.length,
                      itemBuilder: (context, index) {
                        final family = familyProvider.families[index];
                        final isSelected = familyProvider.selectedFamily?.id == family.id;
                        return Card(
                          elevation: isSelected ? 4 : 2,
                          color: isSelected ? Colors.blue[50] : null,
                          child: ListTile(
                            title: Text(family.name),
                            trailing: isSelected ? const Icon(Icons.check) : null,
                            onTap: () {
                              // 选择家庭
                              familyProvider.selectFamily(family);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('已选择家庭: ${family.name}')),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
