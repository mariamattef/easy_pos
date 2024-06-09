import 'package:easy_pos/helper/sql_helper.dart';
import 'package:easy_pos/models/category_model.dart';
import 'package:easy_pos/widgets/app_elevated_button.dart';
import 'package:easy_pos/widgets/app_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CategoriesOpePage extends StatefulWidget {
  final CategoryModel? categoryModel;
  const CategoriesOpePage({this.categoryModel, super.key});

  @override
  State<CategoriesOpePage> createState() => _CategoriesOpePageState();
}

class _CategoriesOpePageState extends State<CategoriesOpePage> {
  @override
  var formKey = GlobalKey<FormState>();
  TextEditingController? nameController;
  TextEditingController? descriptionController;
  @override
  void initState() {
    nameController = TextEditingController(text: widget.categoryModel?.name);
    descriptionController =
        TextEditingController(text: widget.categoryModel?.description);
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryModel != null ? 'Update' : 'Add New'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              AppFormField(
                  Controller: nameController!,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                  label: 'Name'),
              const SizedBox(
                height: 20,
              ),
              AppFormField(
                Controller: descriptionController!,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
                label: 'Description',
              ),
              const SizedBox(
                height: 20,
              ),
              AppElevatedButton(
                  onPressed: () async {
                    await onSubmit();
                  },
                  label: 'Submit')
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onSubmit() async {
    try {
      if (formKey.currentState!.validate()) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        if (widget.categoryModel != null) {
          // Update
          await sqlHelper.db!.update(
              'categories',
              {
                'name': nameController?.text,
                'description': descriptionController?.text
              },
              where: 'id =?',
              whereArgs: [widget.categoryModel?.id]);
        } else {
          await sqlHelper.db!.insert('categories', {
            'name': nameController?.text,
            'description': descriptionController?.text
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Category added successfully')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Failed to add category :  $e'),
      ));
    }
  }
}
