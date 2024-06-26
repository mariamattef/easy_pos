import 'package:data_table_2/data_table_2.dart';
import 'package:easy_pos/helper/sql_helper.dart';
import 'package:easy_pos/models/products_model.dart';
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
  List<ProductModel>? product;
  bool sortAscending = true;
  @override
  void initState() {
    getProducts();
    super.initState();
  }

  void getProducts() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.rawQuery('''
      select P.* ,C.name as categoryName,C.description as categoryDes from products P
      inner join categories C 
      where P.categoryId = C.id
      ''');

      if (data.isNotEmpty) {
        product = [];
        for (var item in data) {
          product!.add(ProductModel.fromJson(item));
        }
      } else {
        product = [];
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Failed to get products :  $e'),
      ));
      product = [];
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
                    var result = await sqlHelper.db!.rawQuery("""
                    SELECT * FROM products
                    WHERE name LIKE '%$value%' OR description LIKE '%$value%' OR price LIKE '%$value%'
                  """);
                    print('Search >>> $result');
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
                sortColumnIndex: 10,
                sortAscending: sortAscending,
                minWidth: 1400,
                columns: [
                  const DataColumn2(label: Text('Id')),
                  const DataColumn2(label: Text('Name')),
                  const DataColumn2(label: Text('Description')),
                  const DataColumn2(label: Text('Price')),
                  const DataColumn2(label: Text('Stock')),
                  const DataColumn2(label: Text('isAvaliable')),
                  const DataColumn2(label: Center(child: Text('Image'))),
                  const DataColumn2(label: Text('CategoryId')),
                  const DataColumn2(label: Text('CategoryName')),
                  const DataColumn2(label: Text('CategoryDes')),
                  DataColumn2(
                    label: const Center(child: Text('Actions')),
                    onSort: (columnIndex, ascending) {
                      sortAscending = ascending;
                      product!.sort((a, b) {
                        if (sortAscending) {
                          return a.price!.compareTo(b.price!);
                        } else {
                          return b.price!.compareTo(a.price!);
                        }
                      });
                      setState(() {});
                    },
                  ),
                ],
                source: ProductsSourse(
                  productEx: product,
                  onUpdate: (productmodel) async {
                    var result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProductOperationPage(
                                  productMod: productmodel,
                                )));
                    if (result ?? false) {
                      getProducts();
                    }
                  },
                  onDelete: (productmodel) {
                    onDeleteRow(productmodel.id!);
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
  List<ProductModel>? productEx;
  void Function(ProductModel) onUpdate;
  void Function(ProductModel) onDelete;
  ProductsSourse(
      {required this.productEx,
      required this.onDelete,
      required this.onUpdate});
  @override
  DataRow? getRow(int index) {
    return DataRow2(cells: [
      DataCell(Text('${productEx?[index].id}')),
      DataCell(Text('${productEx?[index].name}')),
      DataCell(Text('${productEx?[index].description}')),
      DataCell(Text('${productEx?[index].price}')),
      DataCell(Text('${productEx?[index].stock}')),
      DataCell(Text('${productEx?[index].isAvaliable}')),
      DataCell(Center(
        child: Image.network(
          '${productEx?[index].image}',
          fit: BoxFit.contain,
        ),
      )),
      DataCell(Text('${productEx?[index].categoryId}')),
      DataCell(Text('${productEx?[index].categoryName}')),
      DataCell(Text('${productEx?[index].categoryDes}')),
      DataCell(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              onUpdate.call(productEx![index]);
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () {
              onDelete.call(productEx![index]);
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
  int get rowCount => productEx?.length ?? 0;

  @override
  int get selectedRowCount => 0;
}
