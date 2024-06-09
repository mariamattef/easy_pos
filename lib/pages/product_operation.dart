import 'package:easy_pos/models/products_model.dart';
import 'package:easy_pos/widgets/app_elevated_button.dart';
import 'package:easy_pos/widgets/app_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class ProductOperationPage extends StatefulWidget {
  final ProductModel? productModel;
  const ProductOperationPage({this.productModel, super.key});

  @override
  State<ProductOperationPage> createState() => _ProductsOperationPageState();
}

class _ProductsOperationPageState extends State<ProductOperationPage> {
  var formKey = GlobalKey<FormState>();
  TextEditingController? nameController;
  TextEditingController? descriptionController;
  TextEditingController? priceController;
  TextEditingController? stockController;
  TextEditingController? imageController;
  bool isAvailable = false;

  @override
  void initState() {
    nameController = TextEditingController(text: widget.productModel?.name);
    descriptionController =
        TextEditingController(text: widget.productModel?.description);
    priceController =
        TextEditingController(text: '${widget.productModel?.price ?? ''}');
    stockController =
        TextEditingController(text: '${widget.productModel?.stock ?? ''}');
    isAvailable = widget.productModel?.isAvaliable ?? false;
    imageController = TextEditingController(text: widget.productModel?.image);
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productModel != null ? 'Update' : 'Add New'),
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
              Row(
                children: [
                  Expanded(
                    child: AppFormField(
                      texInputType: TextInputType.number,
                      formater: [FilteringTextInputFormatter.digitsOnly],
                      Controller: priceController!,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Price is required';
                        }
                        return null;
                      },
                      label: 'Price',
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: AppFormField(
                      texInputType: TextInputType.number,
                      formater: [FilteringTextInputFormatter.digitsOnly],
                      Controller: stockController!,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Stock is required';
                        }
                        return null;
                      },
                      label: 'Stock',
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              AppFormField(
                // texInputType: TextInputType.number,
                // formater: [FilteringTextInputFormatter.digitsOnly],
                Controller: imageController!,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Image Url is required';
                  }
                  return null;
                },
                label: 'Image Url',
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Switch(
                      value: isAvailable,
                      onChanged: (value) {
                        setState(() {
                          isAvailable = value;
                        });
                      }),
                  const SizedBox(
                    width: 20,
                  ),
                  const Text(
                    'Is Active',
                    style: TextStyle(fontSize: 17),
                  ),
                ],
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
}

Future<void> onSubmit() async {
  // try {
  //   if (formKey.currentState!.validate()) {
  //     var sqlHelper = GetIt.I.get<SqlHelper>();
  //     if (widget.categoryModel != null) {
  //       // Update
  //       await sqlHelper.db!.update(
  //           'categories',
  //           {
  //             'name': nameController?.text,
  //             'description': descriptionController?.text
  //           },
  //           where: 'id =?',
  //           whereArgs: [widget.categoryModel?.id]);
  //     } else {
  //       await sqlHelper.db!.insert('categories', {
  //         'name': nameController?.text,
  //         'description': descriptionController?.text
  //       });
  //     }

  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //         backgroundColor: Colors.green,
  //         content: Text('Category added successfully')));
  //     Navigator.pop(context, true);
  //   }
  // } catch (e) {
  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //     backgroundColor: Colors.red,
  //     content: Text('Failed to add category :  $e'),
  //   ));
  // }
}
