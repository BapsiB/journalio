import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSettingItem(context, Icons.account_circle_outlined, 'Account'),
          _buildSettingItem(context, Icons.notifications_none, 'Notifications'),
          _buildSettingItem(context, Icons.backup_outlined, 'Backup'),
          _buildSettingItem(context, Icons.restore, 'Restore'),
          _buildSettingItem(context, Icons.bug_report_outlined, 'Debug'),
        ],
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(icon, color: AppColors.primaryPeach),
          title: Text(label),
          trailing: Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {
            // Handle tap
            print('Tapped on $label');
          },
        ),
      ),
    );
  }
}
