import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/discovery_controller.dart';
import '../../../shared/models/search_models.dart';

class SearchFiltersBottomSheet extends StatefulWidget {
  @override
  _SearchFiltersBottomSheetState createState() => _SearchFiltersBottomSheetState();
}

class _SearchFiltersBottomSheetState extends State<SearchFiltersBottomSheet> {
  late SearchFilters _filters;
  final _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filters = DiscoveryController.to.currentFilters.value;
    _usernameController.text = _filters.username ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Text(
                  'Filtros de Busca',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                TextButton(
                  onPressed: _clearAllFilters,
                  child: Text('Limpar Tudo'),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildSortBySection(),
                SizedBox(height: 24),
                _buildCategorySection(),
                SizedBox(height: 24),
                _buildUsernameSection(),
                SizedBox(height: 24),
                _buildDateRangeSection(),
                SizedBox(height: 24),
                _buildAdvancedSection(),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                child: Text('Aplicar Filtros'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortBySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ordenar Por',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        
        Wrap(
          spacing: 8,
          children: [
            _buildSortChip('recent', 'Mais Recentes'),
            _buildSortChip('popular', 'Mais Populares'),
            _buildSortChip('trending', 'Em Alta'),
          ],
        ),
      ],
    );
  }

  Widget _buildSortChip(String value, String label) {
    final isSelected = _filters.sortBy == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filters = _filters.copyWith(sortBy: value);
        });
      },
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoria',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        
        Obx(() {
          final categories = DiscoveryController.to.popularCategories;
          return Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              FilterChip(
                label: Text('Todas'),
                selected: _filters.category == null,
                onSelected: (selected) {
                  setState(() {
                    _filters = _filters.copyWith(category: null);
                  });
                },
              ),
              
              ...categories.take(6).map((category) => FilterChip(
                label: Text(category.name),
                selected: _filters.category == category.name,
                onSelected: (selected) {
                  setState(() {
                    _filters = _filters.copyWith(
                      category: selected ? category.name : null,
                    );
                  });
                },
              )).toList(),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildUsernameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Usuário Específico',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        
        TextField(
          controller: _usernameController,
          decoration: InputDecoration(
            hintText: 'Digite o nome do usuário',
            border: OutlineInputBorder(),
            suffixIcon: _usernameController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _usernameController.clear();
                      setState(() {
                        _filters = _filters.copyWith(username: null);
                      });
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            setState(() {
              _filters = _filters.copyWith(
                username: value.isEmpty ? null : value,
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildDateRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Período',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _selectStartDate(),
                child: Text(
                  _filters.startDate != null
                      ? '${_filters.startDate!.day}/${_filters.startDate!.month}/${_filters.startDate!.year}'
                      : 'Data inicial',
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _selectEndDate(),
                child: Text(
                  _filters.endDate != null
                      ? '${_filters.endDate!.day}/${_filters.endDate!.month}/${_filters.endDate!.year}'
                      : 'Data final',
                ),
              ),
            ),
          ],
        ),
        
        if (_filters.startDate != null || _filters.endDate != null)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: TextButton(
              onPressed: () {
                setState(() {
                  _filters = _filters.copyWith(
                    startDate: null,
                    endDate: null,
                  );
                });
              },
              child: Text('Limpar período'),
            ),
          ),
      ],
    );
  }

  Widget _buildAdvancedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtros Avançados',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        
        CheckboxListTile(
          title: Text('Apenas itens promovidos'),
          subtitle: Text('Itens que estão sendo promovidos pelos usuários'),
          value: _filters.isPromoted ?? false,
          contentPadding: EdgeInsets.zero,
          onChanged: (value) {
            setState(() {
              _filters = _filters.copyWith(isPromoted: value);
            });
          },
        ),
      ],
    );
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _filters.startDate ?? DateTime.now().subtract(Duration(days: 30)),
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        _filters = _filters.copyWith(startDate: date);
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _filters.endDate ?? DateTime.now(),
      firstDate: _filters.startDate ?? DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        _filters = _filters.copyWith(endDate: date);
      });
    }
  }

  void _clearAllFilters() {
    setState(() {
      _filters = SearchFilters();
      _usernameController.clear();
    });
  }

  void _applyFilters() {
    DiscoveryController.to.applyFilters(_filters);
    Get.back();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
}