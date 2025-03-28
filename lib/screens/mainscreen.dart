import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:new_sharemedia/components/fab_container.dart';
import 'package:new_sharemedia/pages/notification.dart';
import 'package:new_sharemedia/pages/profile.dart';
import 'package:new_sharemedia/pages/search.dart';
import 'package:new_sharemedia/pages/feeds.dart';
import 'package:new_sharemedia/utils/firebase.dart';

class TabScreen extends StatefulWidget {
  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  int _page = 0;

  List pages = [
    {
      'title': 'Home',
      'icon': Ionicons.home,
      'page': Feeds(),
      'index': 0,
    },
    {
      'title': 'Search',
      'icon': Ionicons.search,
      'page': Search(),
      'index': 1,
    },
    {
      'title': 'unsee',
      'icon': Ionicons.add_circle,
      'page': Text('nes'),
      'index': 2,
    },
    {
      'title': 'Notification',
      'icon': CupertinoIcons.bell_solid,
      'page': Activities(),
      'index': 3,
    },
    {
      'title': 'Profile',
      'icon': CupertinoIcons.person_fill,
      'page': Profile(profileId: firebaseAuth.currentUser!.uid),
      'index': 4,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageTransitionSwitcher(
        transitionBuilder: (
          Widget child,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: pages[_page]['page'],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomAppBar(
          elevation: 0,
          child: Container(
            height: 50, // Reduced from 60
            padding: EdgeInsets.symmetric(horizontal: 8), // Reduced horizontal padding
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (Map item in pages)
                  item['index'] == 2
                      ? _buildEnhancedFab()
                      : _buildNavItem(item),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(Map item) {
    bool isSelected = item['index'] == _page;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => navigationTapped(item['index']),
          child: Container(
            height: 45, // Reduced from 62
            padding: EdgeInsets.symmetric(vertical: 4), // Reduced from 8
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item['icon'],
                  color: isSelected
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).brightness == Brightness.dark
                          ? Colors.white54
                          : Colors.black54,
                  size: 20, // Reduced from 24
                ),
                if (isSelected) ...[
                  SizedBox(height: 1), // Reduced from 2
                  Text(
                    item['title'],
                    style: TextStyle(
                      fontSize: 10, // Reduced from 11
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedFab() {
    return Container(
      width: 45, // Reduced from 60
      height: 45, // Reduced from 60
      padding: EdgeInsets.symmetric(vertical: 4), // Reduced from 8
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.secondary,
              Theme.of(context).colorScheme.secondary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10), // Reduced from 12
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
              blurRadius: 6, // Reduced from 8
              offset: Offset(0, 3), // Reduced from 4
            ),
          ],
        ),
        child: FabContainer(
          icon: Ionicons.add_outline,
          mini: true,
        ),
      ),
    );
  }

  void navigationTapped(int page) {
    setState(() {
      _page = page;
    });
  }
}
