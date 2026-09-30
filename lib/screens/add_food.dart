import 'package:flutter/material.dart';
import '../data/food.dart';
import '../models/food.dart';
import '../services/custom_food_service.dart';
import 'food_details.dart';
import 'add_custom_food.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final TextEditingController searchController = TextEditingController();
  List<Food> filteredFoods = foods;
  List<Food> customFoods = [];
  String _selectedCategory = 'All';

  final Map<String, List<Food>> _foodCategories = {
    'All': foods,
    'Staples': foods.where((f) => 
      f.name.contains('Rice') || f.name.contains('Roti') || 
      f.name.contains('Naan') || f.name.contains('Paratha') ||
      f.name.contains('Oats') || f.name.contains('Dalia') ||
      f.name.contains('Quinoa') || f.name.contains('Ragi') ||
      f.name.contains('Jowar') || f.name.contains('Bajra')
    ).toList(),
    'Legumes': foods.where((f) => 
      f.name.contains('Dal') || f.name.contains('Chickpeas') || 
      f.name.contains('Rajma') || f.name.contains('Urad')
    ).toList(),
    'Dairy': foods.where((f) => 
      f.name.contains('Paneer') || f.name.contains('Milk') || 
      f.name.contains('Curd') || f.name.contains('Butter') ||
      f.name.contains('Ghee') || f.name.contains('Cheese')
    ).toList(),
    'Vegetables': foods.where((f) => 
      f.name.contains('Potato') || f.name.contains('Onion') || 
      f.name.contains('Tomato') || f.name.contains('Spinach') ||
      f.name.contains('Cauliflower') || f.name.contains('Broccoli') ||
      f.name.contains('Carrot') || f.name.contains('Cabbage') ||
      f.name.contains('Okra') || f.name.contains('Eggplant') ||
      f.name.contains('Bitter') || f.name.contains('Bottle') ||
      f.name.contains('Peas')
    ).toList(),
    'Fruits': foods.where((f) => 
      f.name.contains('Banana') || f.name.contains('Apple') || 
      f.name.contains('Mango') || f.name.contains('Orange') ||
      f.name.contains('Grapes') || f.name.contains('Papaya') ||
      f.name.contains('Watermelon') || f.name.contains('Guava')
    ).toList(),
    'Proteins': foods.where((f) => 
      f.name.contains('Egg') || f.name.contains('Chicken') || 
      f.name.contains('Fish') || f.name.contains('Tofu') ||
      f.name.contains('Soy')
    ).toList(),
    'Nuts & Seeds': foods.where((f) => 
      f.name.contains('Almond') || f.name.contains('Walnut') || 
      f.name.contains('Cashew') || f.name.contains('Peanut') ||
      f.name.contains('Chia') || f.name.contains('Flax')
    ).toList(),
    'Sweets': foods.where((f) => 
      f.name.contains('Gulab') || f.name.contains('Jalebi') || 
      f.name.contains('Samosa') || f.name.contains('Pakora') ||
      f.name.contains('Chips') || f.name.contains('Chocolate') ||
      f.name.contains('Ice Cream')
    ).toList(),
    'Custom': [], // Will be populated with custom foods
  };

  @override
  void initState() {
    super.initState();
    filteredFoods = foods;
    _loadCustomFoods();
  }

  Future<void> _loadCustomFoods() async {
    final loadedCustomFoods = await CustomFoodService.getCustomFoods();
    setState(() {
      customFoods = loadedCustomFoods;
      _foodCategories['Custom'] = loadedCustomFoods;
    });
  }

  void searchFood(String query) {
    setState(() {
      if (query.isEmpty) {
        if (_selectedCategory == 'All') {
          filteredFoods = [...foods, ...customFoods];
        } else {
          filteredFoods = _foodCategories[_selectedCategory] ?? [];
        }
      } else {
        List<Food> categoryFoods;
        if (_selectedCategory == 'All') {
          categoryFoods = [...foods, ...customFoods];
        } else {
          categoryFoods = _foodCategories[_selectedCategory] ?? [];
        }
        filteredFoods = categoryFoods
            .where((food) => food.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'All') {
        filteredFoods = [...foods, ...customFoods];
      } else {
        filteredFoods = _foodCategories[category] ?? [];
      }
      searchController.clear();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Custom Food',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddCustomFoodScreen(),
                ),
              );
              if (result == true) {
                // Reload custom foods if a new one was added
                await _loadCustomFoods();
                filterByCategory(_selectedCategory);
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade50, Colors.white],
              ),
            ),
            child: TextField(
              controller: searchController,
              onChanged: searchFood,
              decoration: InputDecoration(
                labelText: 'Search food',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          searchFood('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            // Category filter chips
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: _foodCategories.keys.map((category) {
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            filterByCategory(category);
                          }
                        },
                        selectedColor: Colors.green.shade100,
                        checkmarkColor: const Color(0xFF2E7D32),
                        backgroundColor: Colors.grey.shade100,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const Divider(height: 1),
            // Food list
            Expanded(
              child: filteredFoods.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No foods found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try a different search or category',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: filteredFoods.length,
                      itemBuilder: (context, index) {
                        final food = filteredFoods[index];
                        final isCustom = customFoods.any((f) => f.id == food.id);
                        
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isCustom ? Colors.purple.shade100 : Colors.green.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isCustom ? Icons.star : Icons.restaurant,
                                color: isCustom ? Colors.purple : const Color(0xFF2E7D32),
                                size: 24,
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  food.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                if (isCustom) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Custom',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.purple.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '${food.caloriesPer100g} kcal / 100g • ${food.proteinPer100g}g protein',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isCustom)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 20),
                                    color: Colors.red,
                                    onPressed: () {
                                      _showDeleteCustomFoodDialog(food);
                                    },
                                  ),
                                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FoodDetailsScreen(food: food),
                                ),
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

  void _showDeleteCustomFoodDialog(Food food) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Custom Food'),
        content: Text('Are you sure you want to delete "${food.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await CustomFoodService.deleteCustomFood(food.id);
              await _loadCustomFoods();
              filterByCategory(_selectedCategory);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Custom food deleted'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}