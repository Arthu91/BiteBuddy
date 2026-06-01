import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import '../../providers/meal_provider.dart';
import '../../services/meal_service.dart';
import '../../widgets/app_button.dart';

class NewRecipeScreen extends ConsumerStatefulWidget {
  const NewRecipeScreen({super.key});

  @override
  ConsumerState<NewRecipeScreen> createState() => _NewRecipeScreenState();
}

class _NewRecipeScreenState extends ConsumerState<NewRecipeScreen> {
  final _nameCtrl    = TextEditingController();
  final _descCtrl    = TextEditingController();
  final _tagsCtrl    = TextEditingController();
  int _servings = 1, _prepTime = 0, _cookTime = 0;
  bool _saving = false;

  final List<Map<String, TextEditingController>> _ingredients = [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _tagsCtrl.dispose();
    for (final i in _ingredients) {
      i['name']!.dispose();
      i['amount']!.dispose();
      i['unit']!.dispose();
    }
    super.dispose();
  }

  void _addIngredient() {
    setState(() => _ingredients.add({
      'name':   TextEditingController(),
      'amount': TextEditingController(),
      'unit':   TextEditingController(),
    }));
  }

  void _removeIngredient(int i) {
    _ingredients[i]['name']!.dispose();
    _ingredients[i]['amount']!.dispose();
    _ingredients[i]['unit']!.dispose();
    setState(() => _ingredients.removeAt(i));
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      await MealService.instance.createRecipe(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        servings: _servings,
        prepTime: _prepTime,
        cookTime: _cookTime,
        tags: _tagsCtrl.text.trim(),
        ingredients: _ingredients.map((i) => (
          name:   i['name']!.text.trim(),
          amount: i['amount']!.text.trim(),
          unit:   i['unit']!.text.trim(),
        )).where((i) => i.name.isNotEmpty).toList(),
      );
      ref.invalidate(recipesProvider);
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('New Recipe')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _field('Recipe Name *', _nameCtrl, hint: 'e.g. Avocado Toast'),
            const SizedBox(height: 12),
            _field('Description', _descCtrl, hint: 'Optional...', maxLines: 3),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _numField('Servings', _servings, (v) => setState(() => _servings = v))),
              const SizedBox(width: 10),
              Expanded(child: _numField('Prep (min)', _prepTime, (v) => setState(() => _prepTime = v))),
              const SizedBox(width: 10),
              Expanded(child: _numField('Cook (min)', _cookTime, (v) => setState(() => _cookTime = v))),
            ]),
            const SizedBox(height: 12),
            _field('Tags', _tagsCtrl, hint: 'healthy, vegan, quick'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ingredients', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textDark)),
                TextButton.icon(
                  onPressed: _addIngredient,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add'),
                ),
              ],
            ),
            ..._ingredients.indexed.map((e) {
              final (i, ing) = e;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: TextField(
                      controller: ing['name'],
                      decoration: const InputDecoration(hintText: 'Ingredient', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                    )),
                    const SizedBox(width: 6),
                    Expanded(flex: 2, child: TextField(
                      controller: ing['amount'],
                      decoration: const InputDecoration(hintText: 'Amount', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                    )),
                    const SizedBox(width: 6),
                    Expanded(flex: 2, child: TextField(
                      controller: ing['unit'],
                      decoration: const InputDecoration(hintText: 'Unit', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                    )),
                    IconButton(
                      onPressed: () => _removeIngredient(i),
                      icon: const Icon(Icons.remove_circle_outline, color: AppColors.textMuted, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
            AppButton(
              label: 'Save Recipe',
              onPressed: _nameCtrl.text.trim().isEmpty ? null : _save,
              loading: _saving,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {String? hint, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textDark)),
        const SizedBox(height: 6),
        TextField(controller: ctrl, maxLines: maxLines, decoration: InputDecoration(hintText: hint)),
      ],
    );
  }

  Widget _numField(String label, int value, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textDark)),
        const SizedBox(height: 6),
        Row(
          children: [
            GestureDetector(
              onTap: () { if (value > 0) onChanged(value - 1); },
              child: const Icon(Icons.remove_circle_outline, color: AppColors.textMuted),
            ),
            Expanded(child: Text('$value', textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
            GestureDetector(
              onTap: () => onChanged(value + 1),
              child: const Icon(Icons.add_circle_outline, color: AppColors.forestGreen),
            ),
          ],
        ),
      ],
    );
  }
}
