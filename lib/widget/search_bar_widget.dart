import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SearchBarWiget extends StatefulWidget {
  const SearchBarWiget({
    super.key,
    this.onClicked,
    this.onClickedMic,
    this.query,
    this.hint,
    this.onChanged,
  });

  final Function(String)? onClicked;
  final Function(String)? onChanged;
  final Function? onClickedMic;
  final String? query;
  final String? hint;

  @override
  State<SearchBarWiget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWiget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.query ?? '';
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Theme(
          data: ThemeData(
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              filled: true,
              fillColor: isDarkMode ? Colors.grey[900] : Colors.grey[200], // Background color
              hintText: widget.hint ?? 'أدخل كلمة لبدء البحث',
              hintStyle: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600], // Hint color
              ),
              prefixIcon: IconButton(
                icon: SvgPicture.asset(
                  'assets/icon/search.svg',
                  color: isDarkMode ? Colors.white : Colors.grey[600], // Icon color
                  width: 20,
                  height: 20,
                ),
                onPressed: () {
                  if (_searchController.text.isNotEmpty) {
                    widget.onClicked?.call(_searchController.text);
                  }
                },
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: isDarkMode ? Colors.white : Colors.grey[600],
                  size: 18,
                ),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    widget.onChanged?.call('');
                  });
                },
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            ),
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black), // Text color
            onChanged: (value) {
              setState(() {});
              widget.onChanged?.call(value);
            },
            onSubmitted: (value) {
              widget.onClicked?.call(value);
            },
          ),
        ),
      ),
    );
  }
}
