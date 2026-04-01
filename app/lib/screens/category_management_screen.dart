import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/item_provider.dart';

/// 添加分类对话框
class AddCategoryDialog extends StatefulWidget {
  final int familyId;
  
  const AddCategoryDialog({
    Key? key,
    required this.familyId,
  }) : super(key: key);

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _iconController = TextEditingController();
  final _colorController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final itemProvider = Provider.of<ItemProvider>(context, listen: false);
      final success = await itemProvider.addCategory(
        _nameController.text.trim(),
        widget.familyId,
        icon: _iconController.text.trim().isEmpty ? null : _iconController.text.trim(),
        color: _colorController.text.trim().isEmpty ? null : _colorController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('分类添加成功')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(itemProvider.errorMessage ?? '添加分类失败')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加分类'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '分类名称',
                hintText: '请输入分类名称',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入分类名称';
                }
                return null;
              },
              maxLength: 50,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _iconController,
              decoration: const InputDecoration(
                labelText: '分类图标（可选）',
                hintText: '例如：🍎',
                border: OutlineInputBorder(),
              ),
              maxLength: 10,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _colorController,
              decoration: const InputDecoration(
                labelText: '分类颜色（可选）',
                hintText: '例如：#FF6B6B',
                border: OutlineInputBorder(),
              ),
              maxLength: 20,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('添加'),
        ),
      ],
    );
  }
}

/// 分类管理页面
class CategoryManagementScreen extends StatefulWidget {
  final int familyId;
  
  const CategoryManagementScreen({
    Key? key,
    required this.familyId,
  }) : super(key: key);

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  @override
  void initState() {
    super.initState();
    // 加载分类列表，使用 addPostFrameCallback 确保在构建完成后再调用
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final itemProvider = Provider.of<ItemProvider>(context, listen: false);
      itemProvider.getCategories(widget.familyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('分类管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddCategoryDialog(familyId: widget.familyId),
              );
            },
            tooltip: '添加分类',
          ),
        ],
      ),
      body: itemProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : itemProvider.categories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.category, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('暂无分类', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 8),
                      const Text('点击右上角添加按钮创建分类', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: itemProvider.categories.length,
                  itemBuilder: (context, index) {
                    final category = itemProvider.categories[index];
                    return ListTile(
                      leading: category.icon != null
                          ? Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: category.color != null
                                    ? Color(int.parse(category.color!.replaceFirst('#', '0xFF')))
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  category.icon!,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            )
                          : Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: category.color != null
                                    ? Color(int.parse(category.color!.replaceFirst('#', '0xFF')))
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.category),
                            ),
                      title: Text(category.name),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // 可以添加编辑分类的功能
                      },
                    );
                  },
                ),
    );
  }
}
