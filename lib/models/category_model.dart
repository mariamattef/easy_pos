class CategoryModel {
  int? id;
  String? name;
  String? description;

  CategoryModel.freomJson(Map<String, dynamic> data) {
    id = data['id'];
    name = data['name'];
    description = data['description'];
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}
