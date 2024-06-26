import 'package:data_table_2/data_table_2.dart';
import 'package:easy_pos/helper/sql_helper.dart';
import 'package:easy_pos/models/clients_model.dart';
import 'package:easy_pos/pages/Clients_ope_page.dart';
import 'package:easy_pos/widgets/app_table.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  List<ClientModel>? clients;
  bool sortAscending = true;
  @override
  void initState() {
    getClients();
    super.initState();
  }

  void getClients() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.query('clients');

      if (data.isNotEmpty) {
        clients = [];
        for (var item in data) {
          clients!.add(ClientModel.freomJson(item));
        }
      } else {
        clients = [];
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Failed to get clients :  $e'),
      ));
      clients = [];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Clients'),
          actions: [
            IconButton(
                onPressed: () async {
                  var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ClientsOpePage()));
                  if (result ?? false) {
                    getClients();
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
                       SELECT * FROM clients
                       WHERE email LIKE '%$value%' OR phone LIKE '%$value%';
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
                sortAscending: sortAscending,
                sortColumnIndex: 5,
                minWidth: 800,
                columns: [
                  const DataColumn2(label: Text('Id')),
                  const DataColumn2(label: Text('Name')),
                  const DataColumn2(label: Text('Email')),
                  const DataColumn2(label: Text('Phone')),
                  const DataColumn2(label: Text('Address')),
                  DataColumn2(
                    label: const Center(
                      child: Text('Actions'),
                    ),
                    onSort: (columnIndex, ascending) {
                      sortAscending = ascending;
                      clients!.sort((a, b) {
                        if (sortAscending) {
                          return a.phone!.compareTo(b.phone!);
                        } else {
                          return b.phone!.compareTo(a.phone!);
                        }
                      });
                      setState(() {});
                    },
                  ),
                ],
                source: ClientsTableSourse(
                  clientEx: clients,
                  onUpdate: (clientsModel) async {
                    var result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ClientsOpePage(
                                  clientModel: clientsModel,
                                )));
                    if (result ?? false) {
                      getClients();
                    }
                  },
                  onDelete: (clientsModel) {
                    onDeleteRow(clientsModel.id!);
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
              title: const Text('Delete client'),
              content:
                  const Text('Are you sure you want to delete this client ?'),
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
            .delete('clients', where: 'id = ?', whereArgs: [id]);
        if (result > 0) {
          getClients();
        }
      }
    } catch (e) {
      print('Failed to delete clients : $e');
    }
  }
}

class ClientsTableSourse extends DataTableSource {
  List<ClientModel>? clientEx;
  void Function(ClientModel) onUpdate;
  void Function(ClientModel) onDelete;
  ClientsTableSourse(
      {this.clientEx, required this.onDelete, required this.onUpdate});
  @override
  DataRow? getRow(int index) {
    return DataRow2(cells: [
      DataCell(Text('${clientEx?[index].id}')),
      DataCell(Text('${clientEx?[index].name}')),
      DataCell(Text('${clientEx?[index].email}')),
      DataCell(Text('${clientEx?[index].phone}')),
      DataCell(Text('${clientEx?[index].address}')),
      DataCell(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              onUpdate.call(clientEx![index]);
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () {
              onDelete.call(clientEx![index]);
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
  int get rowCount => clientEx?.length ?? 0;

  @override
  int get selectedRowCount => 0;
}
