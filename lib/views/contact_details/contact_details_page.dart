import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../entities/contact_entity.dart';
import '../../presenters/contact_details_presenter.dart';
import 'contact_details_view.dart';

class ContactDetailsPage extends StatefulWidget {
  static const String routeName = 'details';
  final int id;
  const ContactDetailsPage({super.key, required this.id});

  @override
  State<ContactDetailsPage> createState() => _ContactDetailsPageState();
}

class _ContactDetailsPageState extends State<ContactDetailsPage>
    implements ContactDetailsView {
  final ContactDetailsPresenter _presenter = ContactDetailsPresenter();
  ContactEntity? _contact;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContact();
  }

  Future<void> _loadContact() async {
    final contact = await _presenter.getContactById(widget.id);
    if (mounted) {
      setState(() {
        _contact = contact;
        _isLoading = false;
      });
    }
  }

  @override
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void refreshUI() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Details'),
        backgroundColor: const Color(0xFF6200EE),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contact == null
          ? const Center(child: Text('Contact not found'))
          : FutureBuilder<Directory>(
        future: getApplicationDocumentsDirectory(),
        builder: (context, dirSnapshot) {
          if (!dirSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final dir = dirSnapshot.data!;
          final localImageFile =
          File('${dir.path}/${_contact!.image}');
          final hasLocalImage = localImageFile.existsSync();
          final imageUrl = _contact!.image;

          Widget imageWidget;
          if (imageUrl.startsWith('http')) {
            imageWidget = Image.network(
              imageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            );
          } else if (hasLocalImage) {
            imageWidget = Image.file(
              localImageFile,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            );
          } else {
            imageWidget = const Icon(
              Icons.person,
              size: 100,
              color: Colors.grey,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              // Card image or placeholder
              imageWidget,
              const SizedBox(height: 16),

              // Name
              if (_contact!.name.isNotEmpty)
                _buildDetailRow(
                  label: _contact!.name,
                  icon: Icons.person,
                  color: Colors.purple,
                ),

              // Mobile
              if (_contact!.mobile.isNotEmpty)
                _buildDetailRow(
                  label: _contact!.mobile,
                  icon: Icons.phone,
                  color: Colors.green,
                  onTap: () =>
                      _presenter.callContact(_contact!.mobile, showError),
                ),

              // Email
              if (_contact!.email.isNotEmpty)
                _buildDetailRow(
                  label: _contact!.email,
                  icon: Icons.email,
                  color: Colors.red,
                  onTap: () =>
                      _presenter.emailContact(_contact!.email, showError),
                ),

              // Address
              if (_contact!.address.isNotEmpty)
                _buildDetailRow(
                  label: _contact!.address,
                  icon: Icons.location_on,
                  color: Colors.purple,
                  onTap: () =>
                      _presenter.openMap(_contact!.address, showError),
                ),

              // Website
              if (_contact!.website.isNotEmpty)
                _buildDetailRow(
                  label: _contact!.website,
                  icon: Icons.web,
                  color: Colors.blue,
                  onTap: () =>
                      _presenter.openWebsite(_contact!.website, showError),
                ),

              // Company
              if (_contact!.company.isNotEmpty)
                _buildDetailRow(
                  label: _contact!.company,
                  icon: Icons.business,
                  color: Colors.teal,
                ),

              // Designation
              if (_contact!.designation.isNotEmpty)
                _buildDetailRow(
                  label: _contact!.designation,
                  icon: Icons.work,
                  color: Colors.orange,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: color),
        ),
      ],
    );
  }
}
