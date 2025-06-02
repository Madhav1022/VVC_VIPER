import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../entities/contact_entity.dart';
import '../../presenters/home_presenter.dart';
import '../../routers/app_router.dart';
import '../../utils/helper_functions.dart';
import '../profile/profile_page.dart';

abstract class HomeView {
  void showMessage(String message);
}

class HomePage extends StatefulWidget {
  static const String routeName = '/';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> implements HomeView {
  final HomePresenter _presenter = HomePresenter();
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _presenter.loadContacts();
  }

  @override
  void dispose() {
    _presenter.dispose();
    super.dispose();
  }

  @override
  void showMessage(String message) {
    showMsg(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact List'),
        backgroundColor: const Color(0xFF6200EE),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () async {
              final result = await GoRouter.of(context).pushNamed<bool>(
                ProfilePage.routeName,
              );
              if (result == true) {
                setState(() {});
              }
            },
            tooltip: 'Profile',
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _presenter.navigateToAddContact(context),
        backgroundColor: const Color(0xFF6200EE),
        elevation: 8,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: BottomAppBar(
          clipBehavior: Clip.antiAlias,
          shape: const CircularNotchedRectangle(),
          notchMargin: 10,
          padding: EdgeInsets.zero,
          child: SizedBox(
            height: 70,
            child: BottomNavigationBar(
              backgroundColor: Colors.grey[100],
              currentIndex: selectedIndex,
              selectedItemColor: const Color(0xFF6200EE),
              onTap: (index) {
                setState(() {
                  selectedIndex = index;
                });
                _presenter.loadContacts(favorites: index == 1);
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'All',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: 'Favorites',
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Welcome, ${_presenter.displayName}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6200EE),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ContactEntity>>(
              stream: _presenter.contactStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.contacts_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No contacts found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap the + button to add a contact',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final contacts = snapshot.data!;
                return ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return Dismissible(
                      key: ValueKey(contact.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        padding: const EdgeInsets.only(right: 20),
                        alignment: Alignment.centerRight,
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: _showConfirmationDialog,
                      onDismissed: (_) async {
                        await _presenter.deleteContact(contact.id);
                        showMessage('Deleted Successfully');
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 4,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            contact.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            contact.mobile,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: () async {
                              await _presenter.toggleFavorite(contact);
                            },
                            icon: Icon(
                              contact.favorite ? Icons.favorite : Icons.favorite_border,
                              color: Colors.pink,
                            ),
                          ),
                          onTap: () => AppRouter().navigateToDetails(context, contact.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmationDialog(DismissDirection direction) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: const Text('Are you sure you want to delete this contact?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('NO'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('YES'),
          ),
        ],
      ),
    );
  }
}


























