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
  final String? backgroundImage; // New parameter for background image


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
    this.backgroundImage, // Add to constructor
  }) : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize =>
      Size.fromHeight(showSearchBar ? 140 : kToolbarHeight); // Adjust height based on search bar visibility
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
          backgroundColor: widget.backgroundImage != null ? Colors.transparent : null,
          flexibleSpace: widget.backgroundImage != null
              ? Container(
            height: kToolbarHeight + MediaQuery.of(context).padding.top,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(widget.backgroundImage!),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3),
                  BlendMode.darken,
                ),
              ),
            ),
          )
              : null,
          leading: widget.leftIcon != null
              ? IconButton(
                  icon: Icon(widget.leftIcon,
                      color: Colors.white),
                  onPressed: widget.onLeftTap ?? _showAboutUs,
                )
              : widget.leftWidget ?? IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.title,
              style: TextStyle(
                color: widget.backgroundImage != null ? Colors.white : Theme.of(context).colorScheme.secondary,
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          centerTitle: true,
          actions: widget.rightIcon != null
              ? [
                  IconButton(
                    icon: Icon(widget.rightIcon,
                        color: widget.backgroundImage != null ? Colors.white : (isDarkMode ? Colors.white : Colors.black)),
                    onPressed: widget.onRightTap ?? () => _showThemeDialog(context),
                  ),
                ]
              : [],
        ),
        if (widget.showSearchBar)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Theme(
                data: ThemeData(
                  textSelectionTheme: TextSelectionThemeData(
                    cursorColor: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {});
                    if (widget.onSearch != null) widget.onSearch!(value);
                  },
                  onSubmitted: widget.onSubmitted,
                  decoration: InputDecoration(
                    hintText: "بحث...",
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    prefixIcon: Icon(Icons.search,
                        color: isDarkMode ? Colors.white : Colors.black54),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: isDarkMode ? Colors.white : Colors.black54),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                              if (widget.onSearch != null) widget.onSearch!('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey[900] : Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
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
