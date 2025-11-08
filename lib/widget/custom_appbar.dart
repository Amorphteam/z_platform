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
  final VoidCallback? onSearchTap;
  final List<String> recentSearches;
  final ValueChanged<String>? onRecentSelected;
  final ValueChanged<String>? onRecentDelete;
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
    this.onSearchTap,
    this.recentSearches = const [],
    this.onRecentSelected,
    this.onRecentDelete,
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
  final GlobalKey _searchFieldKey = GlobalKey();
  OverlayEntry? _recentOverlay;

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
                key: _searchFieldKey,
                controller: _searchController,
                onTap: _handleSearchTap,
                onChanged: (value) {
                  setState(() {});
                  _removeRecentOverlay();
                  if (widget.onSearch != null) widget.onSearch!(value);
                },
                onSubmitted: (query) {
                  _removeRecentOverlay();
                  if (widget.onSubmitted != null) {
                    widget.onSubmitted!(query);
                  }
                },
                decoration: InputDecoration(
                  hintText: "بحث...",
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                      _removeRecentOverlay();
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

  @override
  void didUpdateWidget(covariant CustomAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_recentOverlay != null && !listEquals(oldWidget.recentSearches, widget.recentSearches)) {
      _removeRecentOverlay();
      if (widget.recentSearches.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showRecentOverlay();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _removeRecentOverlay();
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchTap() {
    widget.onSearchTap?.call();

    if (widget.recentSearches.isEmpty) {
      _removeRecentOverlay();
      return;
    }

    _showRecentOverlay();
  }

  void _showRecentOverlay() {
    _removeRecentOverlay();

    final RenderBox? searchBox = _searchFieldKey.currentContext?.findRenderObject() as RenderBox?;
    final OverlayState? overlayState = Overlay.of(context);

    if (searchBox == null || overlayState == null) {
      return;
    }

    final Offset position = searchBox.localToGlobal(Offset.zero);
    final double top = position.dy + searchBox.size.height;

    _recentOverlay = OverlayEntry(
      builder: (context) {
        final theme = Theme.of(context);
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _removeRecentOverlay,
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              top: top,
              left: 0,
              right: 0,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Material(
                    color: Colors.transparent,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 320),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: widget.recentSearches.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: theme.dividerColor.withOpacity(0.2),
                          ),
                          itemBuilder: (context, index) {
                            final term = widget.recentSearches[index];
                            return ListTile(
                              leading: const Icon(Icons.history),
                              title: Text(term),
                              trailing: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  widget.onRecentDelete?.call(term);
                                },
                              ),
                              onTap: () {
                                _removeRecentOverlay();
                                _searchController..text = term
                                ..selection =
                                    TextSelection.fromPosition(TextPosition(offset: term.length));
                                widget.onSearch?.call(term);
                                widget.onRecentSelected?.call(term);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlayState.insert(_recentOverlay!);
  }

  void _removeRecentOverlay() {
    _recentOverlay?.remove();
    _recentOverlay = null;
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
