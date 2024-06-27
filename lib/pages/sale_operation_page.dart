import 'package:easy_pos/helper/sql_helper.dart';
import 'package:easy_pos/models/order_items_model.dart';
import 'package:easy_pos/models/order_model.dart';
import 'package:easy_pos/models/products_model.dart';
import 'package:easy_pos/pages/all_sale.dart';
import 'package:easy_pos/widgets/app_elevated_button.dart';
import 'package:easy_pos/widgets/app_form_field.dart';

import 'package:easy_pos/widgets/client_drop_down.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SaleOperationPage extends StatefulWidget {
  final OrderModel? orderModel;
  const SaleOperationPage({this.orderModel, super.key});

  @override
  State<SaleOperationPage> createState() => _SaleOperationPageState();
}

class _SaleOperationPageState extends State<SaleOperationPage> {
  String? orderLabel;
  List<ProductModel>? products;
  List<OrderItemModel> selectOrderItem = [];
  int? selectedClientId;
  TextEditingController? discountController;
  double? totalAfterDiscount;

  double? discount = 0.0;
  @override
  void initState() {
    initPage();
    super.initState();
  }

  void initPage() {
    orderLabel = widget.orderModel == null
        ? '#OR ${DateTime.now().millisecondsSinceEpoch}'
        : widget.orderModel?.id.toString();

    selectedClientId = widget.orderModel?.clientId;

    discountController = TextEditingController(
        text: widget.orderModel == null
            ? ""
            : "${widget.orderModel!.discount! * 100}");
    getProducts();
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
        products = [];
        for (var item in data) {
          products!.add(ProductModel.fromJson(item));
        }
      } else {
        products = [];
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Failed to get products :  $e'),
      ));
      products = [];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.orderModel != null ? 'Update Sale' : 'Add New Sale'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: const Color(0xffF5F5F5),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: const BoxDecoration(
                              color: Color(0xffFFF2CD),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          width: double.maxFinite,
                          // padding: inputPadding,

                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              'Label :$orderLabel',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ClientDropDown(
                            selectedValue: selectedClientId,
                            onChanged: (cliientId) {
                              setState(() {
                                selectedClientId = cliientId;
                              });
                            }),
                      ),
                      Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                onAddProductClicked();
                              },
                              icon: const Icon(Icons.add)),
                          const Text(
                            'Add Product',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Card(
                color: const Color(0xffF5F5F5),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const Text(
                        'Order Items',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      for (var orderItem in selectOrderItem)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            leading: Image.network(
                                orderItem.productModel?.image ?? ''),
                            title: Text(
                                '${orderItem.productModel?.name ?? ''},${orderItem.productCount}X'),
                            trailing: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    width: 1,
                                    color: const Color(0xffF5F5F5),
                                  ),
                                ),
                                child: Text(
                                    '${(orderItem.productCount ?? 0) * (orderItem.productModel?.price ?? 0)}')),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: AppFormField(
                                Controller: discountController ??
                                    TextEditingController(),
                                label: 'discount',
                                texInputType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  var discountValue;
                                  if ((discountController?.text.isNotEmpty ??
                                      false)) {
                                    discountValue =
                                        (discountController?.text ?? '');
                                    discount =
                                        double.parse(discountValue) / 100;

                                    totalAfterDiscount = calculateTotalPrice -
                                        (calculateTotalPrice * discount!);
                                  } else {
                                    discount = 0.0;
                                  }
                                  setState(() {});
                                },
                                child: const Text('Apply'))
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total : ",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "${totalAfterDiscount ?? calculateTotalPrice} Egp ",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppElevatedButton(
                  onPressed: () {
                    insertOrder();
                  },
                  label:
                      widget.orderModel != null ? 'Update Order' : 'Add Order')
            ],
          ),
        ),
      ),
    );
  }

  Future<void> insertOrder() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      if (widget.orderModel != null) {
        await sqlHelper.db!.update(
            'orders',
            {
              'label': orderLabel,
              'totalPrice': calculateTotalPrice,
              'discount': discount,
              'clientId': selectedClientId,
              'createdAt': DateTime.now().toIso8601String(),
            },
            where: 'id =?',
            whereArgs: [widget.orderModel?.id]);

        Navigator.pop(context);
      } else {
        var orderId = await sqlHelper.db!.insert('orders', {
          'label': orderLabel,
          'totalPrice': calculateTotalPrice,
          'discount': discount,
          'clientId': selectedClientId,
          'createdAt': DateTime.now().toIso8601String(),
        });

        var batch = sqlHelper.db!.batch();
        for (var orderItem in selectOrderItem) {
          batch.insert('orderProductItems', {
            'orderId': orderItem.orderId,
            'productCount': orderItem.productId,
            'productId': orderItem.productCount ?? 0,
          });
        }
        var result = await batch.commit();

        print('>>>>>> selected order items ids $result');
      }
      setState(() {});
      Navigator.push(
          context, MaterialPageRoute(builder: (ctx) => const AllSales()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Order Set successfully')));
      Navigator.pop(context, true);
    }
  }

  double get calculateTotalPrice {
    double total = 0;
    for (var orderitem in selectOrderItem) {
      total = total +
          ((orderitem.productCount ?? 0) *
              (orderitem.productModel?.price ?? 0));
    }
    return total;
  }

  void onAddProductClicked() async {
    await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setStateEx) {
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: (products?.isEmpty ?? false)
                    ? const Center(
                        child: Text('No Items'),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ignore: prefer_const_constructors
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Text(
                              'Products',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Expanded(
                            flex: 5,
                            child: ListView(
                              children: [
                                for (var product in products!)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: ListTile(
                                      leading: Image.network(
                                          product.image ?? 'No image'),
                                      title: Text(product.name ?? 'No Name'),
                                      subtitle: getOrdetItem(product.id!) ==
                                              null
                                          ? null
                                          : Row(
                                              children: [
                                                IconButton(
                                                  icon:
                                                      const Icon(Icons.remove),
                                                  onPressed: getOrdetItem(
                                                                  product
                                                                      .id!) !=
                                                              null &&
                                                          getOrdetItem(product
                                                                      .id!)
                                                                  ?.productCount ==
                                                              1
                                                      ? null
                                                      : () {
                                                          var orderItem =
                                                              getOrdetItem(
                                                                  product.id!);

                                                          orderItem
                                                                  ?.productCount =
                                                              (orderItem.productCount ??
                                                                      0) -
                                                                  1;
                                                          setStateEx(() {});
                                                        },
                                                ),
                                                Text(getOrdetItem(product.id!)!
                                                    .productCount
                                                    .toString()),
                                                IconButton(
                                                  icon: const Icon(Icons.add),
                                                  onPressed: () {
                                                    var orderItem =
                                                        getOrdetItem(
                                                            product.id!);

                                                    if ((orderItem
                                                                ?.productCount ??
                                                            0) <
                                                        (product.stock ?? 0)) {
                                                      orderItem?.productCount =
                                                          (orderItem.productCount ??
                                                                  0) +
                                                              1;
                                                    }

                                                    setStateEx(() {});
                                                  },
                                                ),
                                              ],
                                            ),
                                      trailing: getOrdetItem(product.id!) ==
                                              null
                                          ? IconButton(
                                              icon: const Icon(Icons.add),
                                              onPressed: () {
                                                onAddItem(product);
                                                setStateEx(() {});
                                              },
                                            )
                                          : IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () {
                                                onDeleteItem(product.id!);
                                                setStateEx(() {});
                                              },
                                            ),
                                    ),
                                  ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: AppElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              label: 'Back',
                            ),
                          ),
                        ],
                      ),
              ),
            );
          });
        });

    setState(() {});
  }

  OrderItemModel? getOrdetItem(int productId) {
    for (var item in selectOrderItem) {
      if (item.productId == productId) {
        return item;
      }
    }
    return null;
  }

  void onAddItem(ProductModel product) {
    selectOrderItem.add(OrderItemModel(
      productId: product.id,
      productCount: 1,
      productModel: product,
    ));
  }

  void onDeleteItem(int productId) {
    for (var i = 0; i < selectOrderItem.length; i++) {
      if (selectOrderItem[i].productId == productId) {
        selectOrderItem.removeAt(i);
        break;
      }
    }
  }
}
