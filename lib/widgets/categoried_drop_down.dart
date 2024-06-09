import 'package:easy_pos/helper/sql_helper.dart';
import 'package:easy_pos/models/category_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CategoriesDropDown extends StatefulWidget {
  final int? selectedValue;
  final void Function(int?)? onChanged;

  const CategoriesDropDown(
      {required this.onChanged, this.selectedValue, super.key});

  @override
  State<CategoriesDropDown> createState() => _CategoriesDropDownState();
}

class _CategoriesDropDownState extends State<CategoriesDropDown> {
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
    return categories == null
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : (categories?.isEmpty ?? false)
            ? const Center(
                child: Text('No Data Found'),
              )
            : DropdownButton(
                hint: Text('select category'),
                value: widget.selectedValue,
                items: [
                  for (var category in categories!)
                    DropdownMenuItem(
                      child: Text(category.name ?? 'No name'),
                      value: category.id,
                    )
                ],
                onChanged: widget.onChanged);
  }
}
