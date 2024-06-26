import 'package:easy_pos/helper/sql_helper.dart';
import 'package:easy_pos/models/clients_model.dart';
import 'package:easy_pos/widgets/app_elevated_button.dart';
import 'package:easy_pos/widgets/app_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ClientsOpePage extends StatefulWidget {
  final ClientModel? clientModel;
  const ClientsOpePage({this.clientModel, super.key});

  @override
  State<ClientsOpePage> createState() => _ClientsOpePageState();
}

class _ClientsOpePageState extends State<ClientsOpePage> {
  var formKey = GlobalKey<FormState>();
  TextEditingController? nameController;
  TextEditingController? emailController;
  TextEditingController? phoneController;
  TextEditingController? addressController;
  @override
  void initState() {
    nameController = TextEditingController(text: widget.clientModel?.name);
    emailController = TextEditingController(text: widget.clientModel?.email);
    phoneController = TextEditingController(text: widget.clientModel?.phone);
    addressController =
        TextEditingController(text: widget.clientModel?.address);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clientModel != null ? 'Update' : 'Add New Client'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
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
                  texInputType: TextInputType.emailAddress,
                  Controller: emailController!,
                  label: 'Email',
                ),
                const SizedBox(
                  height: 20,
                ),
                AppFormField(
                  texInputType: TextInputType.number,
                  Controller: phoneController!,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'phone is required';
                    }
                    return null;
                  },
                  label: 'Phone',
                ),
                const SizedBox(
                  height: 20,
                ),
                AppFormField(
                  Controller: addressController!,
                  label: 'Address',
                ),
                const SizedBox(
                  height: 20,
                ),
                AppElevatedButton(
                    onPressed: () async {
                      await onSubmit();
                    },
                    label: widget.clientModel != null ? 'Update' : 'Add ')
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> onSubmit() async {
    try {
      if (formKey.currentState!.validate()) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        if (widget.clientModel != null) {
          // Update
          await sqlHelper.db!.update(
              'clients',
              {
                'name': nameController?.text,
                'phone': phoneController?.text,
                'email': emailController?.text,
                'address': addressController?.text
              },
              where: 'id =?',
              whereArgs: [widget.clientModel?.id]);
        } else {
          await sqlHelper.db!.insert('clients', {
            'name': nameController?.text,
            'phone': phoneController?.text,
            'email': emailController?.text,
            'address': addressController?.text
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Client added successfully')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Failed to add client :  $e'),
      ));
    }
  }
}
