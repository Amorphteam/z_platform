import 'package:flutter/material.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final IconData leftIcon;
  final IconData rightIcon;
  final VoidCallback onLeftTap;
  final VoidCallback onRightTap;
  final Function(String)? onSearch; // Now optional
  final bool showSearchBar; // Toggle for search bar

  const CustomAppBar({
    Key? key,
    required this.title,
    required this.leftIcon,
    required this.rightIcon,
    required this.onLeftTap,
    required this.onRightTap,
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
  Widget build(BuildContext context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0,
          leading: IconButton(
            icon: Icon(widget.leftIcon, color: Colors.black),
            onPressed: widget.onLeftTap,
          ),
          title: Text(
            widget.title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(widget.rightIcon, color: Colors.black),
              onPressed: widget.onRightTap,
            ),
          ],
        ),
        if (widget.showSearchBar) // Conditionally show search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              onChanged: widget.onSearch, // Will be null-safe
              decoration: InputDecoration(
                hintText: "أدخل كلمة لبدء البحث",
                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                filled: true,
                fillColor: Colors.grey[200], // Background color
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
      ],
    );
}
