import 'package:easy_pos/helper/sql_helper.dart';
import 'package:easy_pos/models/products_model.dart';
import 'package:easy_pos/widgets/app_elevated_button.dart';
import 'package:easy_pos/widgets/app_form_field.dart';
import 'package:easy_pos/widgets/categoried_drop_down.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get_it/get_it.dart';

class ProductOperationPage extends StatefulWidget {
  final ProductModel? productMod;
  const ProductOperationPage({this.productMod, super.key});

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
  bool isAvaliable = false;
  int? selectedCategoryId;

  @override
  void initState() {
    setInitiData();
    super.initState();
  }

  void setInitiData() {
    nameController = TextEditingController(text: widget.productMod?.name);
    descriptionController =
        TextEditingController(text: widget.productMod?.description);
    priceController =
        TextEditingController(text: '${widget.productMod?.price ?? ''}');
    stockController =
        TextEditingController(text: '${widget.productMod?.stock ?? ''}');
    imageController = TextEditingController(text: widget.productMod?.image);
    isAvaliable = widget.productMod?.isAvaliable ?? false;
    selectedCategoryId = widget.productMod?.categoryId;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productMod != null ? 'Update' : 'Add New Sale'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
            key: formKey,
            child: ListView(
              children: [
                Column(
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
                            value: isAvaliable,
                            onChanged: (value) {
                              setState(() {
                                isAvaliable = value;
                              });
                            }),
                        const SizedBox(
                          width: 20,
                        ),
                        const Text(
                          'Is Available',
                          style: TextStyle(fontSize: 17),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CategoriesDropDown(
                        selectedValue: selectedCategoryId,
                        onChanged: (categoryId) {
                          setState(() {
                            selectedCategoryId = categoryId;
                          });
                        }),
                    const SizedBox(
                      height: 20,
                    ),
                    AppElevatedButton(
                        onPressed: () async {
                          await onSubmit();
                        },
                        label: widget.productMod != null ? 'Update' : 'Add ')
                  ],
                ),
              ],
            )),
      ),
    );
  }

  Future<void> onSubmit() async {
    try {
      if (formKey.currentState!.validate()) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        if (widget.productMod != null) {
          // Update
          await sqlHelper.db!.update(
              'products',
              {
                'name': nameController?.text,
                'description': descriptionController?.text,
                'price': priceController?.text,
                'stock': stockController?.text,
                'image': imageController?.text,
                'isAvaliable': isAvaliable,
                'categoryId': selectedCategoryId,
              },
              where: 'id =?',
              whereArgs: [widget.productMod?.id]);
        } else {
          await sqlHelper.db!.insert('products', {
            'name': nameController?.text,
            'description': descriptionController?.text,
            'price': priceController?.text,
            'stock': stockController?.text,
            'image': imageController?.text,
            'isAvaliable': isAvaliable,
            'categoryId': selectedCategoryId,
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Product added successfully')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Failed to add product :  $e'),
      ));
    }
  }
}
