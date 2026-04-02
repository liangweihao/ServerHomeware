import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/item_provider.dart';
import 'package:app/models/item.dart';

/// 添加位置对话框
class AddLocationDialog extends StatefulWidget {
  final int familyId;
  
  const AddLocationDialog({
    Key? key,
    required this.familyId,
  }) : super(key: key);

  @override
  State<AddLocationDialog> createState() => _AddLocationDialogState();
}

class _AddLocationDialogState extends State<AddLocationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  int? _selectedParentId;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final itemProvider = Provider.of<ItemProvider>(context, listen: false);
      final success = await itemProvider.addLocation(
        _nameController.text.trim(),
        widget.familyId,
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        parent: _selectedParentId,
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('位置添加成功')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(itemProvider.errorMessage ?? '添加位置失败')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    final locations = itemProvider.locations;
    
    return AlertDialog(
      title: const Text('添加位置'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '位置名称',
                hintText: '请输入位置名称',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入位置名称';
                }
                return null;
              },
              maxLength: 50,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '位置描述（可选）',
                hintText: '请输入位置描述',
                border: OutlineInputBorder(),
              ),
              maxLength: 200,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              value: _selectedParentId,
              hint: const Text('选择父位置（可选）'),
              decoration: const InputDecoration(
                labelText: '父位置',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('无父位置'),
                ),
                ...locations.map((location) => DropdownMenuItem<int?>(
                  value: location.id,
                  child: Text(location.name),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedParentId = value;
                });
              },
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

/// 位置管理页面
class LocationManagementScreen extends StatefulWidget {
  final int familyId;
  
  const LocationManagementScreen({
    Key? key,
    required this.familyId,
  }) : super(key: key);

  @override
  State<LocationManagementScreen> createState() => _LocationManagementScreenState();
}

class _LocationManagementScreenState extends State<LocationManagementScreen> {
  @override
  void initState() {
    super.initState();
    // 加载位置列表
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final itemProvider = Provider.of<ItemProvider>(context, listen: false);
      itemProvider.getLocations(widget.familyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('位置管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddLocationDialog(familyId: widget.familyId),
              );
            },
            tooltip: '添加位置',
          ),
        ],
      ),
      body: itemProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : itemProvider.locations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('暂无位置', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 8),
                      const Text('点击右上角添加按钮创建位置', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: itemProvider.locations.length,
                  itemBuilder: (context, index) {
                    final location = itemProvider.locations[index];
                    return Dismissible(
                      key: Key(location.id.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        final confirmed = await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('确认删除'),
                              content: Text('确定要删除位置 "${location.name}" 吗？'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('取消'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('删除', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            );
                          },
                        );
                        
                        if (confirmed == true) {
                          final success = await itemProvider.deleteLocation(location.id);
                          if (success) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(content: Text('位置 "${location.name}" 已删除')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('删除位置失败')),
                            );
                          }
                          return true;
                        }
                        return false;
                      },
                      onDismissed: (direction) {
                        // 删除动画完成后的回调，不需要在这里执行删除操作
                      },
                      child: ListTile(
                        leading: const Icon(Icons.location_on, color: Colors.blue),
                        title: Text(location.name),
                        subtitle: location.description != null && location.description!.isNotEmpty
                            ? Text(location.description!)
                            : null,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // 可以添加编辑位置的功能
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
