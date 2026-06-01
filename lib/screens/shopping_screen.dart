import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/app_colors.dart';
import '../core/database.dart';
import '../models/enums.dart';
import '../providers/meal_provider.dart';
import '../services/shopping_service.dart';
import '../widgets/app_card.dart';
import '../widgets/app_header.dart';

class ShoppingScreen extends ConsumerStatefulWidget {
  const ShoppingScreen({super.key});

  @override
  ConsumerState<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends ConsumerState<ShoppingScreen> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String? _selectedCategory;
  String _filterCategory = 'All';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    await ShoppingService.instance.addItem(
      name: name,
      amount: _amountCtrl.text.trim(),
      category: _selectedCategory ?? kShoppingCategories.first,
    );
    _nameCtrl.clear();
    _amountCtrl.clear();
    ref.invalidate(shoppingItemsProvider);
  }

  Future<void> _toggle(ShoppingItem item) async {
    await ShoppingService.instance.toggle(item.id, !item.checked);
    ref.invalidate(shoppingItemsProvider);
  }

  Future<void> _delete(int id) async {
    await ShoppingService.instance.deleteItem(id);
    ref.invalidate(shoppingItemsProvider);
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Item', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textDark)),
              const SizedBox(height: 16),
              TextField(
                controller: _nameCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Item name (e.g. Chicken Breast)',
                  filled: true,
                  fillColor: AppColors.cream,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _amountCtrl,
                      decoration: InputDecoration(
                        hintText: 'Amount (e.g. 200g)',
                        filled: true,
                        fillColor: AppColors.cream,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedCategory ?? kShoppingCategories.first,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.cream,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      items: kShoppingCategories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: (v) => setModal(() => _selectedCategory = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    _add();
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.forestGreen,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text('Add to List',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(shoppingItemsProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppHeader(
        actions: [
          GestureDetector(
            onTap: () => _showAddSheet(context),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.forestGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.plus, size: 14, color: AppColors.white),
                  SizedBox(width: 4),
                  Text('Add Item', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Shopping List',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                const SizedBox(height: 2),
                const Text('Check off as you shop',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Category filter bar
          itemsAsync.when(
            loading: () => const SizedBox(),
            error: (_, _) => const SizedBox(),
            data: (items) {
              final usedCats = <String>{'All'};
              for (final item in items) {
                if (item.category.isNotEmpty) usedCats.add(item.category);
              }
              final cats = usedCats.toList();
              return SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: cats.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final cat = cats[i];
                    final isSelected = _filterCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _filterCategory = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.forestGreen : AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? AppColors.forestGreen : AppColors.border),
                        ),
                        child: Text(cat,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? AppColors.white : AppColors.textDark,
                            )),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          Expanded(
            child: itemsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (items) {
                final filtered = _filterCategory == 'All'
                    ? items
                    : items.where((i) => i.category == _filterCategory).toList();

                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🛒', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        const Text('Your list is empty',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.textDark)),
                        const SizedBox(height: 4),
                        const Text('Add items or generate from your meal plan',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () => _showAddSheet(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.forestGreen,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('Add Item',
                                style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final grouped = <String, List<ShoppingItem>>{};
                for (final cat in kShoppingCategories) {
                  final catItems = filtered.where((i) => i.category == cat).toList();
                  if (catItems.isNotEmpty) grouped[cat] = catItems;
                }
                final other = filtered.where((i) => !kShoppingCategories.contains(i.category)).toList();
                if (other.isNotEmpty) grouped['Other'] = other;

                final checkedCount = items.where((i) => i.checked).length;
                final total = items.length;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  children: [
                    // Progress summary
                    AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$checkedCount of $total items checked',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark)),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: total > 0 ? checkedCount / total : 0,
                                    minHeight: 6,
                                    backgroundColor: AppColors.greenLight,
                                    valueColor: const AlwaysStoppedAnimation(AppColors.forestGreen),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (checkedCount > 0) ...[
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () async {
                                await ShoppingService.instance.clearChecked();
                                ref.invalidate(shoppingItemsProvider);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.cream,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: const Text('Clear done',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...grouped.entries.map((e) => _CategorySection(
                      category: e.key,
                      items: e.value,
                      onToggle: _toggle,
                      onDelete: _delete,
                      onAddToCategory: () {
                        setState(() => _selectedCategory = e.key);
                        _showAddSheet(context);
                      },
                    )),

                    const SizedBox(height: 12),

                    // Meal plan banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.calendarDays, color: AppColors.orange, size: 20),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Generate from meal plan',
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textDark)),
                                Text('Auto-fill from this week\'s planned recipes',
                                    style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final now = DateTime.now();
                              final weekStart = now.subtract(Duration(days: now.weekday - 1));
                              final start = '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';
                              final endDate = weekStart.add(const Duration(days: 6));
                              final end = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
                              await ShoppingService.instance.generateFromMealPlan(start, end);
                              ref.invalidate(shoppingItemsProvider);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: AppColors.orange,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('Generate',
                                  style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatefulWidget {
  final String category;
  final List<ShoppingItem> items;
  final Future<void> Function(ShoppingItem) onToggle;
  final Future<void> Function(int) onDelete;
  final VoidCallback onAddToCategory;

  const _CategorySection({
    required this.category,
    required this.items,
    required this.onToggle,
    required this.onDelete,
    required this.onAddToCategory,
  });

  @override
  State<_CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<_CategorySection> {
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    final checkedInCat = widget.items.where((i) => i.checked).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _collapsed = !_collapsed),
          child: Row(
            children: [
              Text(widget.category,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: AppColors.greenLight, borderRadius: BorderRadius.circular(10)),
                child: Text('${widget.items.length}',
                    style: const TextStyle(fontSize: 11, color: AppColors.forestGreen, fontWeight: FontWeight.w600)),
              ),
              if (checkedInCat > 0) ...[
                const SizedBox(width: 4),
                Text('· $checkedInCat done',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
              const Spacer(),
              GestureDetector(
                onTap: widget.onAddToCategory,
                child: const Icon(LucideIcons.plus, size: 16, color: AppColors.forestGreen),
              ),
              const SizedBox(width: 8),
              Icon(
                _collapsed ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                color: AppColors.textMuted, size: 18,
              ),
            ],
          ),
        ),
        if (!_collapsed) ...[
          const SizedBox(height: 6),
          ...widget.items.map((item) => _ItemRow(
            item: item,
            onToggle: widget.onToggle,
            onDelete: widget.onDelete,
          )),
        ],
        const SizedBox(height: 14),
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  final ShoppingItem item;
  final Future<void> Function(ShoppingItem) onToggle;
  final Future<void> Function(int) onDelete;

  const _ItemRow({required this.item, required this.onToggle, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onToggle(item),
            child: Icon(
              item.checked ? Icons.check_circle : Icons.radio_button_unchecked,
              color: item.checked ? AppColors.forestGreen : AppColors.textMuted,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.name,
              style: TextStyle(
                fontSize: 14,
                color: item.checked ? AppColors.textMuted : AppColors.textDark,
                decoration: item.checked ? TextDecoration.lineThrough : null,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (item.amount.isNotEmpty)
            Text(
              '${item.amount} ${item.unit}'.trim(),
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
            ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onDelete(item.id),
            child: const Icon(LucideIcons.trash2, size: 14, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
