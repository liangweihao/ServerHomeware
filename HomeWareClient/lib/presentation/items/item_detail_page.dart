import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemDetailPage extends ConsumerWidget {
  final int id;
  
  const ItemDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('物品详情')),
      body: Center(
        child: Text('物品 ID: $id'),
      ),
    );
  }
}