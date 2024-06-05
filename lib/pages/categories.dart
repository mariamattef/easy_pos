import 'package:easy_pos/helper/sql_helper.dart';
import 'package:easy_pos/models/category_model.dart';
import 'package:easy_pos/pages/category_operation.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<CategoryModel>? categories;
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
                    var data = await sqlHelper.db!.rawQuery(
                        'select * from categories where name like ? ',
                        ['%$value%']);
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
                child: PaginatedDataTable2(
                  empty: const Center(
                    child: Text(
                      'No Data found',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  minWidth: 600,
                  wrapInCard: false,
                  fixedColumnsColor: Colors.black,
                  border: TableBorder.all(color: Colors.black),
                  rowsPerPage: 10,
                  renderEmptyRowsInTheEnd: false,
                  headingRowHeight: 50,
                  horizontalMargin: 20,
                  columnSpacing: 20,
                  dataRowHeight: 50,
                  headingRowColor:
                      MaterialStateProperty.all(Theme.of(context).primaryColor),
                  headingTextStyle:
                      const TextStyle(fontSize: 18, color: Colors.white),
                  isHorizontalScrollBarVisible: true,
                  fixedCornerColor: Colors.green,
                  dataTextStyle:
                      const TextStyle(fontSize: 20, color: Colors.black),
                  columns: const [
                    DataColumn2(label: Text('Id')),
                    DataColumn2(label: Text('Name')),
                    DataColumn2(label: Text('Description')),
                    DataColumn2(label: Center(child: Text('Actions'))),
                  ],
                  source: MyDataTableSourse(categories, getCategories),
                ),
              )
            ],
          ),
        ));
  }
}

class MyDataTableSourse extends DataTableSource {
  List<CategoryModel>? categoriesEx;
  void Function() getCategories;
  MyDataTableSourse(this.categoriesEx, this.getCategories);
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
            onPressed: () {},
            icon: Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () async {
              await onDeleteRow(categoriesEx![index].id!);
            },
            icon: Icon(
              Icons.delete,
              color: Colors.red,
            ),
          )
        ],
      )),
    ]);
  }

  Future<void> onDeleteRow(int id) async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var result = await sqlHelper.db!
          .delete('categories', where: 'id = ?', whereArgs: [id]);
      if (result > 0) {
        getCategories();
      }
    } catch (e) {
      print('Failed to delete category : $e');
    }
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => categoriesEx?.length ?? 0;

  @override
  int get selectedRowCount => 0;
}
