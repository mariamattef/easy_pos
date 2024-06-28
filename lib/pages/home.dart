import 'package:easy_pos/helper/sql_helper.dart';
import 'package:easy_pos/models/exchange_rate.dart';
import 'package:easy_pos/models/order_model.dart';
import 'package:easy_pos/pages/categories.dart';
import 'package:easy_pos/pages/clients.dart';
import 'package:easy_pos/pages/sale_operation_page.dart';
import 'package:easy_pos/pages/products.dart';
import 'package:easy_pos/pages/all_sale.dart';
import 'package:easy_pos/widgets/grid_view_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ExchangeRateModel>? exchangeRate;
  bool isLoading = true;
  bool isTableIntilized = false;
  @override
  void initState() {
    intilizeTables();
    getRate();
    getExchangeRate();
    getOrders();
    super.initState();
  }

  List<OrderModel>? orders;
  double todaySales = 0;

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
    calcTodaysSales(orders!);
    setState(() {});
  }

  void calcTodaysSales(List<OrderModel> orders) {
    todaySales = 0;
    for (var order in orders) {
      // if createdAt is the same as DateTime.now() day
      DateTime orderDate = DateTime.parse(order.createdAt!);
      if (orderDate.day == DateTime.now().day) {
        todaySales = todaySales + order.totalPrice!;
      }
    }
    setState(() {});
  }

  void intilizeTables() async {
    var sqlHelper = GetIt.I.get<SqlHelper>();
    isTableIntilized = await sqlHelper.createTables();
    isLoading = false;
    setState(() {});
  }

  void initializeBackUpDb() async {
    var sqlHelper = GetIt.I.get<SqlHelper>();
    await sqlHelper.createBackup();
    setState(() {});
  }

  Future<void> getExchangeRate() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.query('exchangerate');

      if (data.isNotEmpty) {
        exchangeRate = [];
        for (var item in data) {
          exchangeRate!.add(ExchangeRateModel.fromJson(item));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Failed to get Rate :  $e'),
      ));
      exchangeRate = [];
    }
    setState(() {});
  }

  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Container(),
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              calcTodaysSales(orders!);
            },
            icon: const Icon(Icons.point_of_sale),
          )
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                color: Theme.of(context).primaryColor,
                height:
                    MediaQuery.of(context).size.height / 3 + (kIsWeb ? 40 : 0),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Easy Pos',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w800),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: isLoading
                                ? Transform.scale(
                                    scale: .6,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : CircleAvatar(
                                    radius: 9,
                                    backgroundColor: isTableIntilized
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      exchangeRate?.isNotEmpty ?? false
                          ? HeaderItem(
                              'Exchanged Rate ',
                              '${exchangeRate![0].currencyegp} EGP = ${exchangeRate![0].currencyusd} USD',
                            )
                          : HeaderItem('Exchanged Rate ', 'N/A'),
                      HeaderItem('Today\'s Sales ', '$todaySales EGP'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              color: const Color(0xfffafafa),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  GridViewItem(
                    label: 'All Sales',
                    color: Colors.orange,
                    icon: Icons.calculate,
                    onPrresed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (ctx) => const AllSales()));
                    },
                  ),
                  GridViewItem(
                    label: 'Products',
                    color: Colors.pink,
                    icon: Icons.inventory_2,
                    onPrresed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (ctx) => const ProductsPage()));
                    },
                  ),
                  GridViewItem(
                    label: 'Clients',
                    color: Colors.blue,
                    icon: Icons.groups,
                    onPrresed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (ctx) => const ClientsPage()));
                    },
                  ),
                  GridViewItem(
                    label: 'New Sale',
                    color: Colors.green,
                    icon: Icons.point_of_sale,
                    onPrresed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (ctx) => const SaleOperationPage()),
                      );
                    },
                  ),
                  GridViewItem(
                    label: 'Categories',
                    color: Colors.yellow,
                    icon: Icons.category,
                    onPrresed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (ctx) => const CategoriesPage()));
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> getRate() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.insert('exchangerate', {
        'currencyusd': 1,
        'currencyegp': 57.5,
      });
      print('>>>>>> insert $data');

      setState(() {});
    } catch (e) {
      print('Error in get rate $e');
    }
  }
}

Widget HeaderItem(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Card(
      color: const Color(0xff216de1),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 23, horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w800),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
