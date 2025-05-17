import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../util/theme_helper.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final IconData? leftIcon;
  final Widget? leftWidget;
  final IconData? rightIcon;
  final VoidCallback? onLeftTap;
  final VoidCallback? onRightTap; // New callback for right icon
  final Function(String)? onSearch; // Optional
  final Function(String)? onSubmitted; // Optional
  final bool showSearchBar; // Toggle for search bar

  const CustomAppBar({
    Key? key,
    required this.title,
    this.leftIcon, // Made optional
    this.rightIcon, // Made optional
    this.onLeftTap, // Made optional
    this.onRightTap, // New optional callback
    this.onSearch, // Optional
    this.showSearchBar = true,
    this.leftWidget,
    this.onSubmitted, // Default: show search bar
  }) : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize =>
      Size.fromHeight(showSearchBar ? 140 : kToolbarHeight);
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
          elevation: 0,
          leading: widget.leftIcon != null
              ? IconButton(
            icon: Icon(widget.leftIcon,
                color: isDarkMode ? Colors.white : Colors.black),
            onPressed: widget.onLeftTap ?? _showAboutUs,
          )
              : widget.leftWidget,
          title: Text(
            widget.title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontFamily: 'kuffi',
              fontSize: 18,
              fontWeight: FontWeight.normal,
            ),
          ),
          centerTitle: true,
          actions: widget.rightIcon != null
              ? [
            IconButton(
              icon: Icon(widget.rightIcon,
                  color: isDarkMode ? Colors.white : Colors.black),
              onPressed: widget.onRightTap ?? () => _showThemeDialog(context),
            ),
          ]
              : [], // Hide if rightIcon is null
        ),
        if (widget.showSearchBar) // Conditionally show search bar
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Theme(
                data: ThemeData(
                  textSelectionTheme: TextSelectionThemeData(
                    cursorColor: isDarkMode
                        ? Colors.white
                        : Colors.black, // Cursor color
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {}); // Refresh UI when text changes
                    if (widget.onSearch != null) widget.onSearch!(value);
                  },
                  onSubmitted: widget.onSubmitted,
                  decoration: InputDecoration(
                    hintText: "اكتب شيئاً...",
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600], // Hint color
                    ),
                    prefixIcon: Icon(Icons.search,
                        color: isDarkMode ? Colors.white : Colors.black54),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear, color: isDarkMode ? Colors.white : Colors.black54),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {}); // Refresh UI to hide the clear button
                        if (widget.onSearch != null) widget.onSearch!(''); // Clear search callback
                      },
                    )
                        : null, // Hide clear button if no text
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
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
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
          ),
        );
      },
    );
  }

  void _showAboutUs() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Placeholder(),
    );
  }
}
