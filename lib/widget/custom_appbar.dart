import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:masaha/widget/theme_mode_toggle.dart';
import 'package:provider/provider.dart';

import '../util/theme_helper.dart';
import '../util/color_helper.dart';
import '../screen/color_picker/color_picker_screen.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  // Helper function to get platform-specific dynamic color description
  static String getDynamicColorDescription() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return "ألوان النظام الافتراضية";
    } else {
      return "ألوان من النظام (Android)";
    }
  }
  final String title;
  final IconData? leftIcon;
  final Widget? leftWidget;
  final Widget? rightWidget;
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
    this.rightWidget,
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
            icon: Icon(widget.leftIcon),
            onPressed: widget.onLeftTap ?? _showAboutUs,
          )
              : widget.leftWidget ?? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.title,
              style: Theme.of(context).textTheme.titleMedium,),
          ),
          centerTitle: true,
          actions: widget.rightIcon != null
              ? [
            IconButton(
              icon: Icon(widget.rightIcon),
              onPressed: widget.onRightTap ?? () => _showThemeDialog(context),
            ),
          ]
              : widget.rightWidget != null
                  ? [
                      widget.rightWidget!,
                    ]
                  : [],
        ),
        if (widget.showSearchBar)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {});
                  if (widget.onSearch != null) widget.onSearch!(value);
                },
                onSubmitted: widget.onSubmitted,
                decoration: InputDecoration(
                  hintText: "بحث...",
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                      if (widget.onSearch != null) widget.onSearch!('');
                    },
                  )
                      : null,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
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
            title: const Text("إعدادات التطبيق"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Theme Mode Section
                const ThemeModeToggle(),
                
                const Divider(),
                
                // Color Mode Section
                Consumer<ColorHelper>(
                  builder: (context, colorHelper, child) {
                    // If color picker is completely hidden, show locked UI
                    if (colorHelper.shouldHideColorPicker) {
                      return Column(
                        children: [
                          const Text(
                            "الألوان",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ListTile(
                            title: const Text("ألوان المطور"),
                            subtitle: const Text("ألوان محددة مسبقاً"),
                            leading: const Icon(Icons.business),
                            trailing: const Icon(Icons.lock),
                          ),
                        ],
                      );
                    }

                    // Normal color mode selection with owner colors option
                    return Column(
                      children: [
                        const Text(
                          "الألوان",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          title: const Text("ألوان المطور"),
                          subtitle: const Text("الألوان الافتراضية للتطبيق"),
                          leading: const Icon(Icons.business),
                          trailing: Radio<ColorMode>(
                            value: ColorMode.owner,
                            groupValue: colorHelper.colorMode,
                            onChanged: (value) {
                              if (value != null) {
                                colorHelper.setColorMode(value);
                              }
                            },
                          ),
                          onTap: () {
                            colorHelper.setColorMode(ColorMode.owner);
                          },
                        ),
                        ListTile(
                          title: const Text("ألوان ديناميكية"),
                          subtitle: Text(CustomAppBar.getDynamicColorDescription()),
                          leading: const Icon(Icons.palette),
                          trailing: Radio<ColorMode>(
                            value: ColorMode.dynamic,
                            groupValue: colorHelper.colorMode,
                            onChanged: (value) {
                              if (value != null) {
                                colorHelper.setColorMode(value);
                              }
                            },
                          ),
                          onTap: () {
                            colorHelper.setColorMode(ColorMode.dynamic);
                          },
                        ),
                        ListTile(
                          title: const Text("ألوان مخصصة"),
                          subtitle: const Text("اختر ألوانك الخاصة"),
                          leading: const Icon(Icons.color_lens),
                          trailing: Radio<ColorMode>(
                            value: ColorMode.custom,
                            groupValue: colorHelper.colorMode,
                            onChanged: (value) {
                              if (value != null) {
                                colorHelper.setColorMode(value);
                              }
                            },
                          ),
                          onTap: () {
                            colorHelper.setColorMode(ColorMode.custom);
                          },
                        ),
                        if (colorHelper.colorMode == ColorMode.custom)
                          ListTile(
                            title: const Text("تخصيص الألوان"),
                            leading: const Icon(Icons.edit),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ColorPickerScreen(),
                                ),
                              );
                            },
                          ),
                      ],
                    );
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
