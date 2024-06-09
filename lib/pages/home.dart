import 'package:easy_pos/helper/sql_helper.dart';
import 'package:easy_pos/pages/categories.dart';
import 'package:easy_pos/pages/products.dart';
import 'package:easy_pos/widgets/grid_view_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLooding = true;
  bool isTableInitialize = false;
  @override
  void initState() {
    initilizeTable();
    super.initState();
  }

  void initilizeTable() async {
    var sqlHelper = GetIt.I.get<SqlHelper>();
    isTableInitialize = await sqlHelper.createTables();
    isLooding = false;
    setState(() {});
  }

  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Container(),
      appBar: AppBar(),
      body: Column(
        children: [
          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                color: Theme.of(context).primaryColor,
                height: MediaQuery.of(context).size.height / 3.3,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Easy Pos',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w800),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: isLooding
                                ? Transform.scale(
                                    scale: .6,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : CircleAvatar(
                                    radius: 9,
                                    backgroundColor: isTableInitialize
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      HeaderItem('Exchanged Rate ', '1 USD = 50 EGP'),
                      HeaderItem('Today\'s Sales ', '1000 EGP'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              color: Color(0xfffafafa),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  GridViewItem(
                    label: 'All Sales',
                    color: Colors.orange,
                    icon: Icons.calculate,
                    onPrresed: () {},
                  ),
                  GridViewItem(
                    label: 'Products',
                    color: Colors.pink,
                    icon: Icons.inventory_2,
                    onPrresed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (ctx) => ProductsPage()));
                    },
                  ),
                  GridViewItem(
                    label: 'Clients',
                    color: Colors.blue,
                    icon: Icons.groups,
                    onPrresed: () {},
                  ),
                  GridViewItem(
                    label: 'New Sale',
                    color: Colors.green,
                    icon: Icons.point_of_sale,
                    onPrresed: () {},
                  ),
                  GridViewItem(
                    label: 'Categories',
                    color: Colors.yellow,
                    icon: Icons.category,
                    onPrresed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (ctx) => CategoriesPage()));
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
