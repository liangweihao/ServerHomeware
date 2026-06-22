import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/database/app_database.dart';
import 'app_button.dart';

class LocationPicker extends ConsumerStatefulWidget {
  final Location? selectedLocation;
  final ValueChanged<Location> onSelected;

  const LocationPicker({
    super.key,
    this.selectedLocation,
    required this.onSelected,
  });

  static void show(
    BuildContext context, {
    Location? selectedLocation,
    required ValueChanged<Location> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationPicker(
        selectedLocation: selectedLocation,
        onSelected: onSelected,
      ),
    );
  }

  @override
  ConsumerState<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends ConsumerState<LocationPicker> {
  Location? selectedLevel1;
  Location? selectedLevel2;
  Location? selectedLevel3;

  @override
  void initState() {
    super.initState();
    _initSelection(widget.selectedLocation);
  }

  void _initSelection(Location? location) {
    if (location == null) return;
    // 根据位置的 fullPath 或者 parentId 来初始化选择
    setState(() {
      selectedLevel1 = location;
      selectedLevel2 = null;
      selectedLevel3 = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.5,
      maxChildSize: 0.85,
      builder: (context, scrollController) => Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildContent(context, scrollController),
            ),
            _buildConfirmButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '选择位置',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ScrollController scrollController) {
    return Consumer(
      builder: (context, ref, child) {
        final locationsAsync = ref.watch(topLevelLocationsProvider);
        return locationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('加载失败: $error')),
          data: (locations) => _buildLocationColumns(context, locations, scrollController),
        );
      },
    );
  }

  Widget _buildLocationColumns(BuildContext context, List<Location> level1Locations, ScrollController scrollController) {
    return Row(
      children: [
        Expanded(
          child: _buildLocationList(
            context,
            level1Locations,
            selectedLevel1,
            (loc) => setState(() {
              selectedLevel1 = loc;
              selectedLevel2 = null;
              selectedLevel3 = null;
            }),
          ),
        ),
        if (selectedLevel1 != null)
          Expanded(
            child: FutureBuilder<List<Location>>(
              future: _getChildLocations(ref, selectedLevel1!.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _buildLocationList(
                  context,
                  snapshot.data!,
                  selectedLevel2,
                  (loc) => setState(() {
                    selectedLevel2 = loc;
                    selectedLevel3 = null;
                  }),
                );
              },
            ),
          ),
        if (selectedLevel2 != null)
          Expanded(
            child: FutureBuilder<List<Location>>(
              future: _getChildLocations(ref, selectedLevel2!.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _buildLocationList(
                  context,
                  snapshot.data!,
                  selectedLevel3,
                  (loc) => setState(() => selectedLevel3 = loc),
                );
              },
            ),
          ),
      ],
    );
  }

  Future<List<Location>> _getChildLocations(WidgetRef ref, int parentId) async {
    final db = ref.read(databaseProvider);
    return db.getChildLocations(parentId);
  }

  Widget _buildLocationList(
    BuildContext context,
    List<Location> locations,
    Location? selected,
    ValueChanged<Location> onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: AppColors.border),
        ),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: AppColors.border.withOpacity(0.5),
        ),
        itemCount: locations.length,
        itemBuilder: (context, index) {
          final location = locations[index];
          final isSelected = selected?.id == location.id;
          return _buildLocationItem(context, location, isSelected, () => onTap(location));
        },
      ),
    );
  }

  Widget _buildLocationItem(
    BuildContext context,
    Location location,
    bool isSelected,
    VoidCallback onTap,
  ) {
    // ListTile 的 ink splash 需要最近的 Material 祖先，避免被外层 DecoratedBox 遮挡
    return Material(
      color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: location.icon != null
            ? Text(location.icon!, style: const TextStyle(fontSize: 24))
            : const Icon(Icons.location_on),
        title: Text(
          location.name,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : null,
              ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    final hasSelection = selectedLevel1 != null;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AppButton(
          label: '确定',
          onPressed: hasSelection
              ? () {
                  final selected = selectedLevel3 ?? selectedLevel2 ?? selectedLevel1;
                  if (selected != null) {
                    widget.onSelected(selected);
                    Navigator.pop(context);
                  }
                }
              : null,
          isFullWidth: true,
        ),
      ),
    );
  }
}
