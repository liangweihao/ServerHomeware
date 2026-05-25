import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShoppingListPage extends ConsumerWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: Center(
        child: Text('购物清单'),
      ),
    );
  }
}