import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditItemPage extends ConsumerWidget {
  final int id;
  
  const EditItemPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('编辑物品')),
      body: Center(
        child: Text('编辑物品 ID: $id'),
      ),
    );
  }
}