import 'package:flutter/material.dart';
import 'userlistpage.dart';
import 'manageservice.dart';
import 'reportspage.dart';

class AdminPanelPage extends StatelessWidget {
  final Map<String, dynamic> adminData;

  const AdminPanelPage({Key? key, required this.adminData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF558B2F),
      ),
      body: Container(
        color: const Color(0xFF8BC34A),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Welcome, ${adminData['name']}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLeftAlignedButton(
                      context,
                      'View All Users',
                      Icons.people,
                      () {
                        _navigateToUserList(context);
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildLeftAlignedButton(
                      context,
                      'Manage Services',
                      Icons.manage_accounts,
                      () {
                        _navigateToManageServices(context);
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildLeftAlignedButton(
                      context,
                      'View Reports',
                      Icons.report,
                      () {
                        _navigateToReports(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftAlignedButton(
      BuildContext context, String label, IconData icon, VoidCallback onPressed,
      {Color backgroundColor = const Color(0xFF558B2F)}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 10.0),
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  void _navigateToUserList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserListPage()),
    );
  }

  void _navigateToManageServices(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ManageServicesPage()),
    );
  }

  void _navigateToReports(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReportsPage()),
    );
  }
}
