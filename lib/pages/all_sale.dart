import 'package:easy_pos/helper/sql_helper.dart';
import 'package:easy_pos/models/order_items_model.dart';
import 'package:easy_pos/models/order_model.dart';
import 'package:easy_pos/models/products_model.dart';
import 'package:easy_pos/pages/sale_operation_page.dart';
import 'package:easy_pos/widgets/app_elevated_button.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AllSales extends StatefulWidget {
  const AllSales({super.key});

  @override
  State<AllSales> createState() => _AllSalesState();
}

class _AllSalesState extends State<AllSales> {
  List<OrderModel>? orders;

  List<OrderItemModel> selectedOrderItem = [];

  @override
  void initState() {
    getOrders();
    super.initState();
  }

  void getOrders() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.rawQuery("""
      select O.* ,C.name as clientName,C.phone as clientPhone,C.address as clientAddress
      from orders O
      inner join clients C
      where O.clientId = C.id
      """);

      if (data.isNotEmpty) {
        orders = [];
        for (var item in data) {
          orders!.add(OrderModel.freomJson(item));
        }
      } else {
        orders = [];
      }
    } catch (e) {
      print('Error In get data from orders $e');
      orders = [];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(title: const Text("All Sales")),
      body: orders == null
          ? const Center(child: CircularProgressIndicator())
          : (orders?.isEmpty ?? false)
              ? const Center(child: Text("No Data Found"))
              : ListView(
                  children: orders?.map((OrderModel order) {
                        print(order);
                        return Column(
                          children: [
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Card(
                                    color: Colors.white,
                                    surfaceTintColor: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: double.maxFinite,
                                            padding: const EdgeInsets.all(10),
                                            color: const Color(0xffFFF2CD),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Date: ${DateTime.now().day - 1}/${DateTime.now().month}/${DateTime.now().year} ",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xffF27D10),
                                                  ),
                                                ),
                                                Text(
                                                  "${order.totalPrice} EGP",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  "Receipt Name : \n ${order.label}  "),
                                              IconButton(
                                                  onPressed: () {},
                                                  icon: const Icon(
                                                      Icons.more_vert_rounded)),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(right: 5),
                                                child: CircleAvatar(
                                                  radius: 16,
                                                  child: Icon(Icons.person),
                                                ),
                                              ),
                                              Text("${order.clientName}"),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                          const SizedBox(height: 20),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text("${order.clientPhone}"),
                                              //todo: remove the static text
                                              Text("${order.clientAddress}"),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                      "Subtotal : ${order.totalPrice} EGP"),
                                                  Text(
                                                      "Discount : ${order.discount! * 100} %"),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                          // const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                      "Total: ${calculateProductPriceAfterDiscount(discount: order.discount!, total: order.totalPrice!)}"),
                                                ],
                                              ),
                                              const Text("Paid"),
                                            ],
                                          ),
                                          const SizedBox(height: 20),

                                          Row(
                                            children: [
                                              TextButton(
                                                  onPressed: () async {
                                                    var result =
                                                        await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (ctx) =>
                                                              SaleOperationPage(
                                                                  orderModel:
                                                                      order)),
                                                    );
                                                    if (result ?? false) {
                                                      getOrders();
                                                    }
                                                  },
                                                  child: const Text('Edit',
                                                      style: TextStyle(
                                                          fontSize: 16))),
                                              IconButton(
                                                onPressed: () {
                                                  onDeleteorder(order.id ?? 0);
                                                },
                                                icon: const Icon(Icons.delete),
                                                color: Colors.red,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList() ??
                      [],
                ),
    );
  }

  double calculateProductPriceAfterDiscount(
      {required double discount, required double total}) {
    return (total - (total * discount));
  }

  Future<void> onDeleteorder(int id) async {
    try {
      var dialogResult = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Delete Receipt",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            content:
                const Text("Are you sure you want to delete this receipt?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('OK')),
            ],
          );
        },
      );
      if (dialogResult ?? false) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        var result = await sqlHelper.db!.delete(
          "Orders",
          where: "id = ?",
          whereArgs: [id],
        );

        if (result > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Order deleted successfully")),
          );
          getOrders();
        }
        print(">>> selected order & orderItem are deleted : $result");
      }
    } catch (e) {
      print('Error in delete Receipt: $e');
    }
  }
}
