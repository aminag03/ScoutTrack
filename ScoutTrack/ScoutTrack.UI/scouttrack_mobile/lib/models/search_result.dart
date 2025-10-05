class SearchResult<T> {
  int? totalCount;
  List<T>? items;

  SearchResult({this.totalCount, this.items});

  factory SearchResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return SearchResult<T>(
      totalCount: json['totalCount'],
      items: json['items'] != null
          ? (json['items'] as List).map((item) => fromJsonT(item)).toList()
          : null,
    );
  }
}
