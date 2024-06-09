import 'package:data_table_2/data_table_2.dart';
import 'package:easy_pos/helper/sql_helper.dart';
import 'package:easy_pos/models/products_model.dart';
import 'package:easy_pos/pages/categories.dart';
import 'package:easy_pos/pages/product_operation.dart';
import 'package:easy_pos/widgets/app_table.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<ProductModel>? products;
  @override
  void initState() {
    getProducts();
    super.initState();
  }

  void getProducts() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.rawQuery('''
      select P.* C.name as CategoryName,C.description as CategoryDes from products P
      inner join categories C 
      where P.categoryId = C.id
      ''');

      if (data.isNotEmpty) {
        products = [];
        for (var item in data) {
          products!.add(ProductModel.freomJson(item));
        }
      } else {
        products = [];
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Failed to get categories :  $e'),
      ));
      products = [];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Products'),
          actions: [
            IconButton(
                onPressed: () async {
                  var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProductOperationPage()));
                  if (result ?? false) {
                    getProducts();
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
                    await sqlHelper.db!.rawQuery(
                        'select * from products where name like ? ',
                        ['%$value%']);
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
                minWidth: 1200,
                columns: const [
                  DataColumn2(label: Text('Id')),
                  DataColumn2(label: Text('Name')),
                  DataColumn2(label: Text('Description')),
                  DataColumn2(label: Text('Price')),
                  DataColumn2(label: Text('Stock')),
                  DataColumn2(label: Text('Image')),
                  DataColumn2(label: Text('CategoryId')),
                  DataColumn2(label: Text('CategoryName')),
                  DataColumn2(label: Text('CategoryDes')),
                  DataColumn2(label: Center(child: Text('Actions'))),
                ],
                source: ProductsSourse(
                  productsEx: products,
                  onUpdate: (ProductModel) async {
                    // var result = await Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => CategoriesOpePage(
                    //               proProductModel: ProductModel,
                    //             )));
                    // if (result ?? false) {
                    //   getProducts();
                    // }
                  },
                  onDelete: (ProductModel) {
                    onDeleteRow(ProductModel.id!);
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
              title: const Text('Delete Product'),
              content:
                  const Text('Are you sure you want to delete this Product ?'),
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
            .delete('products', where: 'id = ?', whereArgs: [id]);
        if (result > 0) {
          getProducts();
        }
      }
    } catch (e) {
      print('Failed to delete category : $e');
    }
  }
}

class ProductsSourse extends DataTableSource {
  List<ProductModel>? productsEx;
  void Function(ProductModel) onUpdate;
  void Function(ProductModel) onDelete;
  ProductsSourse(
      {this.productsEx, required this.onDelete, required this.onUpdate});
  @override
  DataRow? getRow(int index) {
    return DataRow2(cells: [
      DataCell(Text('${productsEx?[index].id}')),
      DataCell(Text('${productsEx?[index].name}')),
      DataCell(Text('${productsEx?[index].description}')),
      DataCell(Text('${productsEx?[index].price}')),
      DataCell(Text('${productsEx?[index].stock}')),
      DataCell(Text('${productsEx?[index].isAvaliable}')),
      DataCell(Text('${productsEx?[index].image}')),
      DataCell(Text('${productsEx?[index].categoryId}')),
      DataCell(Text('${productsEx?[index].categoryName}')),
      DataCell(Text('${productsEx?[index].categoryDes}')),
      DataCell(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              onUpdate.call(productsEx![index]);
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () {
              onDelete.call(productsEx![index]);
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
  int get rowCount => productsEx?.length ?? 0;

  @override
  int get selectedRowCount => 0;
}
