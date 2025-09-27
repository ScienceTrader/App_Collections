class SearchFilters {
  final String? category;
  final String? username;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isPromoted;
  final String sortBy;

  SearchFilters({
    this.category,
    this.username,
    this.startDate,
    this.endDate,
    this.isPromoted,
    this.sortBy = 'recent',
  });

  SearchFilters copyWith({
    String? category,
    String? username,
    DateTime? startDate,
    DateTime? endDate,
    bool? isPromoted,
    String? sortBy,
  }) {
    return SearchFilters(
      category: category ?? this.category,
      username: username ?? this.username,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isPromoted: isPromoted ?? this.isPromoted,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  bool get hasActiveFilters {
    return category != null ||
           username != null ||
           startDate != null ||
           endDate != null ||
           isPromoted != null ||
           sortBy != 'recent';
  }

  Map<String, dynamic> toJson() {
    return {
      if (category != null) 'category': category,
      if (username != null) 'username': username,
      if (startDate != null) 'start_date': startDate!.toIso8601String(),
      if (endDate != null) 'end_date': endDate!.toIso8601String(),
      if (isPromoted != null) 'is_promoted': isPromoted,
      'sort_by': sortBy,
    };
  }
}