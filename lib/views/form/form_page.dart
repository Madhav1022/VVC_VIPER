import 'package:flutter/material.dart';
import '../../entities/contact_entity.dart';
import '../../presenters/form_presenter.dart';
import '../../utils/constants.dart';
import '../../utils/helper_functions.dart';
import 'form_view.dart';

class FormPage extends StatefulWidget {
  static const String routeName = 'form';
  final ContactEntity contactEntity;

  const FormPage({
    super.key,
    required this.contactEntity,
  });

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> implements FormView {
  final _formKey = GlobalKey<FormState>();
  final FormPresenter _presenter = FormPresenter();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final companyController = TextEditingController();
  final designationController = TextEditingController();
  final webController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    nameController.text = widget.contactEntity.name;
    mobileController.text = widget.contactEntity.mobile;
    emailController.text = widget.contactEntity.email;
    addressController.text = widget.contactEntity.address;
    companyController.text = widget.contactEntity.company;
    designationController.text = widget.contactEntity.designation;
    webController.text = widget.contactEntity.website;
  }

  @override
  void showMessage(String message) {
    showMsg(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Page'),
        backgroundColor: Color(0xFF6200EE),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 24),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildTextField(nameController, 'Contact Name', isRequired: true),
            const SizedBox(height: 16),
            _buildTextField(mobileController, 'Mobile Number',
                keyboardType: TextInputType.phone, isRequired: true),
            const SizedBox(height: 16),
            _buildTextField(emailController, 'Email',
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildTextField(addressController, 'Street Address'),
            const SizedBox(height: 16),
            _buildTextField(companyController, 'Company Name'),
            const SizedBox(height: 16),
            _buildTextField(designationController, 'Designation'),
            const SizedBox(height: 16),
            _buildTextField(webController, 'Website'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveContact,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)
                ),
              ),
              child: const Text('Save', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        TextInputType keyboardType = TextInputType.text,
        bool isRequired = false
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.deepPurple),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return emptyFieldErrMsg;
        }
        return null;
      },
    );
  }

  void _saveContact() async {
    final contact = ContactEntity(
      id: widget.contactEntity.id,
      name: nameController.text,
      mobile: mobileController.text,
      email: emailController.text,
      address: addressController.text,
      company: companyController.text,
      designation: designationController.text,
      website: webController.text,
      image: widget.contactEntity.image,
      favorite: widget.contactEntity.favorite,
    );

    await _presenter.saveContact(context, contact, _formKey);
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    addressController.dispose();
    companyController.dispose();
    designationController.dispose();
    webController.dispose();
    super.dispose();
  }
}
