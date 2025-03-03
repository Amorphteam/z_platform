import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../util/theme_helper.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final VoidCallback? onLeftTap;
  final Function(String)? onSearch; // Optional
  final bool showSearchBar; // Toggle for search bar

  const CustomAppBar({
    Key? key,
    required this.title,
    this.leftIcon, // Made optional
    this.rightIcon, // Made optional
    this.onLeftTap, // Made optional
    this.onSearch, // Optional
    this.showSearchBar = true, // Default: show search bar
  }) : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(showSearchBar ? 140 : kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0,
          leading: widget.leftIcon != null
              ? IconButton(
            icon: Icon(widget.leftIcon, color: isDarkMode ? Colors.white : Colors.black),
            onPressed: widget.onLeftTap,
          )
              : null, // Hide if leftIcon is null
          title: Text(
            widget.title,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: widget.rightIcon != null
              ? [
            IconButton(
              icon: Icon(widget.rightIcon, color: isDarkMode ? Colors.white : Colors.black),
              onPressed: () => _showThemeDialog(context),
            ),
          ]
              : [], // Hide if rightIcon is null
        ),
        if (widget.showSearchBar) // Conditionally show search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Theme(
                data: ThemeData(
                  textSelectionTheme: TextSelectionThemeData(
                    cursorColor: isDarkMode ? Colors.white : Colors.black, // Cursor color
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: widget.onSearch, // Will be null-safe
                  decoration: InputDecoration(
                    hintText: "البحث في الفهرست",
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600], // Hint color
                    ),
                    prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.white : Colors.black54),
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey[900] : Colors.grey[200], // Background color
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black), // Text color
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("اختر سمة التطبيق"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("الوضع الفاتح"),
                leading: const Icon(Icons.light_mode),
                onTap: () {
                  Provider.of<ThemeHelper>(context, listen: false)
                      .setTheme(AppTheme.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("الوضع الداكن"),
                leading: const Icon(Icons.dark_mode),
                onTap: () {
                  Provider.of<ThemeHelper>(context, listen: false)
                      .setTheme(AppTheme.dark);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("النظام الافتراضي"),
                leading: const Icon(Icons.settings),
                onTap: () {
                  Provider.of<ThemeHelper>(context, listen: false)
                      .setTheme(AppTheme.system);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
