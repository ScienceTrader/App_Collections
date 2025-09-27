import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/collection_controller.dart';
import '../../../shared/models/category_model.dart';

class AddCategoryScreen extends StatefulWidget {
  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedIcon;
  Color? _selectedColor;

  final List<String> _iconOptions = [
    'folder',
    'favorite',
    'star',
    'book',
    'movie',
    'music_note',
    'sports_soccer',
    'directions_car',
    'home',
    'work',
    'school',
    'restaurant',
    'shopping_bag',
    'flight',
    'camera',
    'palette',
  ];

  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.amber,
    Colors.indigo,
    Colors.brown,
    Colors.grey,
    Colors.cyan,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nova Categoria'),
        actions: [
          TextButton(
            onPressed: _saveCategory,
            child: Text('Salvar'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Preview Card
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Pré-visualização',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _selectedColor ?? Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getIconData(_selectedIcon),
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _nameController.text.isEmpty ? 'Nome da categoria' : _nameController.text,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_descriptionController.text.isNotEmpty)
                        Text(
                          _descriptionController.text,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome da categoria *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira o nome da categoria';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {}),
              ),
              SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Descreva sua categoria...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) => setState(() {}),
              ),
              SizedBox(height: 24),

              // Icon Selection
              Text(
                'Ícone',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Container(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _iconOptions.length,
                  itemBuilder: (context, index) {
                    final icon = _iconOptions[index];
                    final isSelected = _selectedIcon == icon;
                    
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = icon),
                      child: Container(
                        width: 60,
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected ? Border.all(color: Theme.of(context).primaryColor, width: 2) : null,
                        ),
                        child: Icon(
                          _getIconData(icon),
                          color: isSelected ? Colors.white : Colors.grey.shade600,
                          size: 28,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 24),

              // Color Selection
              Text(
                'Cor',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _colorOptions.map((color) {
                  final isSelected = _selectedColor == color;
                  
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
                      ),
                      child: isSelected ? Icon(Icons.check, color: Colors.white) : null,
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 32),

              // Save Button
              Obx(() => ElevatedButton(
                onPressed: CollectionController.to.isLoading.value ? null : _saveCategory,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: CollectionController.to.isLoading.value
                    ? CircularProgressIndicator()
                    : Text('Criar Categoria'),
              )),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'folder': return Icons.folder;
      case 'favorite': return Icons.favorite;
      case 'star': return Icons.star;
      case 'book': return Icons.book;
      case 'movie': return Icons.movie;
      case 'music_note': return Icons.music_note;
      case 'sports_soccer': return Icons.sports_soccer;
      case 'directions_car': return Icons.directions_car;
      case 'home': return Icons.home;
      case 'work': return Icons.work;
      case 'school': return Icons.school;
      case 'restaurant': return Icons.restaurant;
      case 'shopping_bag': return Icons.shopping_bag;
      case 'flight': return Icons.flight;
      case 'camera': return Icons.camera;
      case 'palette': return Icons.palette;
      default: return Icons.folder;
    }
  }

  
  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final category = CategoryModel(
        userId: '', // Will be set in controller
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        icon: _selectedIcon,
        color: _selectedColor?.value.toRadixString(16),
      );

      CollectionController.to.addCategory(category);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}