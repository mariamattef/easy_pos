import 'package:data_table_2/data_table_2.dart';
import 'package:easy_pos/helper/sql_helper.dart';
import 'package:easy_pos/models/order_model.dart';
import 'package:easy_pos/pages/sale_operation_page.dart';
import 'package:easy_pos/widgets/app_table.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AllSalesPage extends StatefulWidget {
  final OrderModel? orderModel;
  const AllSalesPage({this.orderModel, super.key});

  @override
  State<AllSalesPage> createState() => _AllSalesPageState();
}

class _AllSalesPageState extends State<AllSalesPage> {
  List<OrderModel>? orders;
  @override
  void initState() {
    getOrdres();
    super.initState();
  }

  void getOrdres() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.rawQuery('''
    select O.* ,C.name as clientName,C.phone as clientPhone,C.address as clientAddress
      from Orders O
      inner join Clients C
      where O.clientId = C.id
      ''');

      if (data.isNotEmpty) {
        orders = [];
        for (var item in data) {
          orders!.add(OrderModel.freomJson(item));
        }
      } else {
        orders = [];
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Failed to get orders :  $e'),
      ));
      orders = [];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('All Salles'),
          actions: [
            IconButton(
                onPressed: () async {
                  var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SaleOperationPage()));
                  if (result ?? false) {
                    getOrdres();
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
                    SELECT * FROM orders
                    WHERE label LIKE '%$value%' 
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
                minWidth: 1200,
                columns: const [
                  DataColumn2(label: Text('Id')),
                  DataColumn2(label: Text('Label')),
                  DataColumn2(label: Text('totalPrice')),
                  DataColumn2(label: Text('clientId')),
                  DataColumn2(label: Text('discount')),
                  DataColumn2(label: Text('clientName')),
                  DataColumn2(label: Text('clientPhone')),
                  DataColumn2(label: Text('clientAddress')),
                  DataColumn2(label: Center(child: Text('Actions'))),
                ],
                source: OrdersSourse(
                  ordersEx: orders,
                  onShow: (order) async {
                    var result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SaleOperationPage(
                                  orderModel: order,
                                )));
                    if (result ?? false) {
                      getOrdres();
                    }
                  },
                  onDelete: (OrderModel) {
                    onDeleteRow(OrderModel.id!);
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
              title: const Text('Delete order'),
              content:
                  const Text('Are you sure you want to delete this order?'),
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
            .delete('orders', where: 'id = ?', whereArgs: [id]);
        if (result > 0) {
          getOrdres();
        }
      }
    } catch (e) {
      print('Failed to delete order : $e');
    }
  }
}

class OrdersSourse extends DataTableSource {
  List<OrderModel>? ordersEx;
  void Function(OrderModel) onShow;
  void Function(OrderModel) onDelete;
  OrdersSourse(
      {required this.ordersEx, required this.onDelete, required this.onShow});
  @override
  DataRow? getRow(int index) {
    return DataRow2(cells: [
      DataCell(Text('${ordersEx?[index].id}')),
      DataCell(Text('${ordersEx?[index].label}')),
      DataCell(Text('${ordersEx?[index].totalPrice}')),
      DataCell(Text('${ordersEx?[index].clientId}')),
      DataCell(Text('${ordersEx?[index].discount}')),
      DataCell(Text('${ordersEx?[index].clientName}')),
      DataCell(Text('${ordersEx?[index].clientPhone}')),
      DataCell(Text('${ordersEx?[index].clientAddress}')),
      DataCell(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              onShow.call(ordersEx![index]);
            },
            icon: const Icon(Icons.visibility),
          ),
          IconButton(
            onPressed: () {
              onDelete.call(ordersEx![index]);
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
  int get rowCount => ordersEx?.length ?? 0;

  @override
  int get selectedRowCount => 0;
}
