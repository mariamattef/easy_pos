import 'package:easy_pos/helper/sql_helper.dart';
import 'package:easy_pos/models/category_model.dart';
import 'package:easy_pos/models/clients_model.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ClientDropDown extends StatefulWidget {
  final int? selectedValue;
  final void Function(int?)? onChanged;
  const ClientDropDown(
      {required this.onChanged, this.selectedValue, super.key});

  @override
  State<ClientDropDown> createState() => _CategoriesDropDownState();
}

class _CategoriesDropDownState extends State<ClientDropDown> {
  List<ClientModel>? clients;
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
    var onValidator;
    return clients == null
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : (clients?.isEmpty ?? false)
            ? const Center(
                child: Text('No Data Found'),
              )
            : Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.black)),
                child: DropdownButton(
                    underline: const SizedBox(),
                    isExpanded: true,
                    // underline: const SizedBox(),
                    // ignore: prefer_const_constructors
                    hint: Text(
                      'select client',
                      style: const TextStyle(
                          fontWeight: FontWeight.w400, fontSize: 18),
                    ),
                    value: widget.selectedValue,
                    items: [
                      for (var category in clients!)
                        DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name ?? 'No name'),
                        )
                    ],
                    onChanged: widget.onChanged),
              );
  }
}
