import 'package:easy_pos/helper/sql_helper.dart';
import 'package:easy_pos/models/category_model.dart';
import 'package:easy_pos/pages/category_operation.dart';
import 'package:easy_pos/widgets/app_table.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:get_it/get_it.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<CategoryModel>? categories;
  bool sortAscending = true;
  @override
  void initState() {
    getCategories();
    super.initState();
  }

  void getCategories() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.query('categories');

      if (data.isNotEmpty) {
        categories = [];
        for (var item in data) {
          categories!.add(CategoryModel.freomJson(item));
        }
      } else {
        categories = [];
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Failed to get categories :  $e'),
      ));
      categories = [];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Categories'),
          actions: [
            IconButton(
                onPressed: () async {
                  var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CategoriesOpePage()));
                  if (result ?? false) {
                    getCategories();
                  }
                },
                icon: const Icon(Icons.add))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  onChanged: (value) async {
                    var sqlHelper = GetIt.I.get<SqlHelper>();
                    var data = await sqlHelper.db!.rawQuery("""
                       SELECT * FROM categories
                       WHERE name LIKE '%$value%' OR description LIKE '%$value%';
                      """);
                    print('data >>> $data');
                  },
                  decoration: InputDecoration(
                      labelText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5))),
                ),
              ),
              Expanded(
                  child: AppTable(
                sortColumnIndex: 3,
                sortAscending: sortAscending,
                minWidth: 700,
                columns: [
                  const DataColumn2(label: Text('Id')),
                  const DataColumn2(
                    label: Text('Name'),
                  ),
                  const DataColumn2(label: Text('Description')),
                  DataColumn2(
                    label: const Center(
                      child: Text('Actions'),
                    ),
                    onSort: (columnIndex, ascending) {
                      sortAscending = ascending;
                      categories!.sort((a, b) {
                        if (sortAscending) {
                          return a.name!.compareTo(b.name!);
                        } else {
                          return b.name!.compareTo(a.name!);
                        }
                      });
                      setState(() {});
                    },
                  ),
                ],
                source: CategoriesTableSourse(
                  categoriesEx: categories,
                  onUpdate: (categoryModel) async {
                    var result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CategoriesOpePage(
                                  categoryModel: categoryModel,
                                )));
                    if (result ?? false) {
                      getCategories();
                    }
                  },
                  onDelete: (categoryModel) {
                    onDeleteRow(categoryModel.id!);
                  },
                ),
              )),
            ],
          ),
        ));
  }

  Future<void> onDeleteRow(int id) async {
    try {
      var dialogResult = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete Category'),
              content:
                  const Text('Are you sure you want to delete this category?'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text('Delete'))
              ],
            );
          });
      if (dialogResult ?? false) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        var result = await sqlHelper.db!
            .delete('categories', where: 'id = ?', whereArgs: [id]);
        if (result > 0) {
          getCategories();
        }
      }
    } catch (e) {
      print('Failed to delete category : $e');
    }
  }
}

class CategoriesTableSourse extends DataTableSource {
  List<CategoryModel>? categoriesEx;
  void Function(CategoryModel) onUpdate;
  void Function(CategoryModel) onDelete;
  CategoriesTableSourse(
      {this.categoriesEx, required this.onDelete, required this.onUpdate});
  @override
  DataRow? getRow(int index) {
    return DataRow2(cells: [
      DataCell(Text('${categoriesEx?[index].id}')),
      DataCell(Text('${categoriesEx?[index].name}')),
      DataCell(Text('${categoriesEx?[index].description}')),
      DataCell(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              onUpdate.call(categoriesEx![index]);
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () {
              onDelete.call(categoriesEx![index]);
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          )
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => categoriesEx?.length ?? 0;

  @override
  int get selectedRowCount => 0;
}
