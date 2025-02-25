import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:new_sharemedia/view_models/theme/theme_view_model.dart';
import 'package:new_sharemedia/screens/edit_profile.dart'; // Import needed screens
import 'package:new_sharemedia/utils/firebase.dart';
import 'package:new_sharemedia/models/user.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  bool pushNotifications = true;
  bool emailNotifications = false;
  UserModel? user;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    DocumentSnapshot doc = await usersRef.doc(firebaseAuth.currentUser!.uid).get();
    setState(() {
      user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
    });
  }

  // Account settings functions
  void navigateToEditProfile() {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => EditProfile(user: user))
    );
  }

  void changePassword() async {
    try {
      await firebaseAuth.sendPasswordResetEmail(
        email: firebaseAuth.currentUser!.email!
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent'))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'))
      );
    }
  }

  // Privacy settings functions 
  void updateAccountPrivacy(bool isPrivate) async {
    try {
      await usersRef.doc(firebaseAuth.currentUser!.uid).update({
        'isPrivate': isPrivate
      });
      setState(() {
        user?.isPrivate = isPrivate;
      });
    } catch (e) {
      print(e);
    }
  }

  void manageBlockedUsers() {
    // Navigate to blocked users screen
    // TODO: Create and navigate to BlockedUsers screen
  }

  // Notification settings functions
  void togglePushNotifications(bool value) {
    setState(() {
      pushNotifications = value;
    });
    // TODO: Update push notification settings in backend
  }

  void toggleEmailNotifications(bool value) {
    setState(() {
      emailNotifications = value;  
    });
    // TODO: Update email notification settings in backend
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.keyboard_backspace),
        ),
        backgroundColor: Theme.of(context).canvasColor,
        elevation: 0.0,
        title: Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Theme.of(context).canvasColor,
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            _buildSectionHeader('Display'),
            _buildThemeSettings(),
            
            _buildSectionHeader('Account'),
            _buildAccountSettings(),
            
            _buildSectionHeader('Privacy'),
            _buildPrivacySettings(),
            
            _buildSectionHeader('Notifications'),
            _buildNotificationSettings(),
            
            _buildSectionHeader('About'),
            _buildAboutSettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }

  Widget _buildThemeSettings() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: Text("Light Theme"),
                  subtitle: Text("Default light theme"),
                  value: ThemeMode.light,
                  groupValue: themeProvider.themeMode,
                  onChanged: (ThemeMode? value) {
                    if (value != null) themeProvider.setThemeMode(value);
                  },
                  secondary: Icon(Icons.brightness_high),
                ),
                RadioListTile<ThemeMode>(
                  title: Text("Dark Theme"),
                  subtitle: Text("Switch to dark theme"),
                  value: ThemeMode.dark,
                  groupValue: themeProvider.themeMode,
                  onChanged: (ThemeMode? value) {
                    if (value != null) themeProvider.setThemeMode(value);
                  },
                  secondary: Icon(Icons.brightness_4),
                ),
                RadioListTile<ThemeMode>(
                  title: Text("System Theme"),
                  subtitle: Text("Follow system settings"),
                  value: ThemeMode.system,
                  groupValue: themeProvider.themeMode,
                  onChanged: (ThemeMode? value) {
                    if (value != null) themeProvider.setThemeMode(value);
                  },
                  secondary: Icon(Icons.brightness_auto),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          ListTile(
            title: Text("Edit Profile"),
            leading: Icon(Icons.person_outline),
            trailing: Icon(Icons.chevron_right),
            onTap: navigateToEditProfile,
          ),
          Divider(height: 0),
          ListTile(
            title: Text("Change Password"),
            leading: Icon(Icons.lock_outline),
            trailing: Icon(Icons.chevron_right),
            onTap: changePassword,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySettings() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          ListTile(
            title: Text("Account Privacy"),
            leading: Icon(Icons.security),
            trailing: CupertinoSwitch(
              value: user?.isPrivate ?? false,
              onChanged: updateAccountPrivacy,
              activeColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
          Divider(height: 0),
          ListTile(
            title: Text("Blocked Users"),
            leading: Icon(Icons.block),
            trailing: Icon(Icons.chevron_right),
            onTap: manageBlockedUsers,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          ListTile(
            title: Text("Push Notifications"),
            leading: Icon(Icons.notifications_none),
            trailing: CupertinoSwitch(
              value: pushNotifications,
              onChanged: togglePushNotifications,
              activeColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
          Divider(height: 0),
          ListTile(
            title: Text("Email Notifications"), 
            leading: Icon(Icons.mail_outline),
            trailing: CupertinoSwitch(
              value: emailNotifications,
              onChanged: toggleEmailNotifications,
              activeColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSettings() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          ListTile(
            title: Text("App Version"),
            leading: Icon(Icons.info_outline),
            trailing: Text("1.0.0"),
          ),
          Divider(height: 0),
          ListTile(
            title: Text("Terms of Service"),
            leading: Icon(Icons.description_outlined),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to terms of service
            },
          ),
          Divider(height: 0),
          ListTile(
            title: Text("Privacy Policy"),
            leading: Icon(Icons.privacy_tip_outlined),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to privacy policy
            },
          ),
        ],
      ),
    );
  }
}
