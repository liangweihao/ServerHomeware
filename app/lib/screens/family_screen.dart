import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/family_provider.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({Key? key}) : super(key: key);

  @override
  _FamilyScreenState createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _familyNameController = TextEditingController();
  bool _showCreateForm = false;

  @override
  void dispose() {
    _familyNameController.dispose();
    super.dispose();
  }

  void _createFamily() async {
    if (_formKey.currentState!.validate()) {
      final familyProvider = Provider.of<FamilyProvider>(context, listen: false);
      final success = await familyProvider.createFamily(_familyNameController.text.trim());
      if (success) {
        setState(() {
          _showCreateForm = false;
          _familyNameController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('家庭创建成功')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(familyProvider.errorMessage ?? '创建家庭失败')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final familyProvider = Provider.of<FamilyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('家庭管理'),
        centerTitle: true,
      ),
      body: familyProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (_showCreateForm)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
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
                  const Text(
                    '我的家庭',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
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
