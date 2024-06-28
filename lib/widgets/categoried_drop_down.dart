import 'package:easy_pos/helper/sql_helper.dart';
import 'package:easy_pos/models/category_model.dart';
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
            : Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.black)),
                child: DropdownButton(
                    isExpanded: true,
                    underline: const SizedBox(),
                    // ignore: prefer_const_constructors
                    hint: Text(
                      'select category',
                      style: const TextStyle(
                          fontWeight: FontWeight.w400, fontSize: 18),
                    ),
                    value: widget.selectedValue,
                    items: [
                      for (var category in categories!)
                        DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name ?? 'No name'),
                        )
                    ],
                    onChanged: widget.onChanged),
              );
  }
}




// Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(5),
//           border: Border.all(color: Colors.black)),
//       child: DropdownButton(
//           isExpanded: true,
//           underline: const SizedBox(),
//           // ignore: prefer_const_constructors
//           hint: Text(
//             'select category',
//             style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
//           ),
//           value: widget.selectedValue,
//           items: [
//             for (var category in categories!)
//               DropdownMenuItem(
//                 value: category.id,
//                 child: Text(category.name ?? 'No name'),
//               )
//           ],
//           onChanged: widget.onChanged),
//     );
//   }
// }
