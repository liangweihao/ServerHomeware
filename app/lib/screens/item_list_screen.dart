import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/family_provider.dart';
import 'package:app/providers/item_provider.dart';
import 'package:app/screens/add_item_screen.dart';
import 'package:app/screens/item_detail_screen.dart';

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({Key? key}) : super(key: key);

  @override
  _ItemListScreenState createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadItems();
    });
  }

  void _loadItems() {
    final familyProvider = Provider.of<FamilyProvider>(context, listen: false);
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    if (familyProvider.selectedFamily != null) {
      itemProvider.getItems(familyProvider.selectedFamily!.id);
      itemProvider.getCategories(familyProvider.selectedFamily!.id);
      itemProvider.getLocations(familyProvider.selectedFamily!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final familyProvider = Provider.of<FamilyProvider>(context);
    final itemProvider = Provider.of<ItemProvider>(context);

    if (familyProvider.selectedFamily == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('请先选择一个家庭'),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/family');
              },
              child: const Text('去选择家庭'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddItemScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: itemProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: itemProvider.items.length,
              itemBuilder: (context, index) {
                final item = itemProvider.items[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('数量: ${item.quantity} ${item.unit}'),
                  trailing: item.expiryDate != null
                      ? Text('过期: ${item.expiryDate!.toString().split(' ')[0]}')
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemDetailScreen(itemId: item.id),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
