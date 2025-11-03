import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:zahra/model/hekam.dart';
import 'package:zahra/model/ibn_hadid.dart';
import 'package:zahra/repository/database_repository.dart';
import 'package:zahra/util/style_helper.dart';

import '../../../model/style_model.dart';

class IbnHadidBottomSheet extends StatefulWidget {
  final Hekam hekam;

  const IbnHadidBottomSheet({
    super.key,
    required this.hekam,
  });

  @override
  State<IbnHadidBottomSheet> createState() => _IbnHadidBottomSheetState();
}

class _IbnHadidBottomSheetState extends State<IbnHadidBottomSheet> {
  String selectedDescription = 'الكل';
  late FontSizeCustom _fontSize;
  late LineHeightCustom _lineHeight;
  late FontFamily _fontFamily;
  IbnHadid? _ibnHadid;
  bool _isLoading = true;
  final DatabaseRepository _databaseRepository = DatabaseRepository();

  @override
  void initState() {
    super.initState();
    _loadFontPreferences();
    _loadIbnHadid();
  }

  Future<void> _loadFontPreferences() async {
    final styleHelper = await StyleHelper.loadFromPrefs();
    setState(() {
      _fontSize = styleHelper.fontSize;
      _lineHeight = styleHelper.lineSpace;
      _fontFamily = styleHelper.fontFamily;
    });
  }

  Future<void> _loadIbnHadid() async {
    try {
      final ibnHadid = await _databaseRepository.getIbnHadidById(widget.hekam.id);
      setState(() {
        _ibnHadid = ibnHadid;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<String> _getAvailableDescriptions() {
    if (_ibnHadid == null) return [];
    
    List<String> descriptions = ['الكل'];
    // Currently only 'det' is available, but structure supports future additions
    if (_ibnHadid!.det.isNotEmpty) {
      descriptions.add('det');
    }
    // Future descriptions can be added here like:
    // if (_ibnHadid!.det2 != null && _ibnHadid!.det2!.isNotEmpty) descriptions.add('det2');
    
    return descriptions;
  }

  String? _getDescriptionContent(String descriptionKey) {
    if (_ibnHadid == null) return null;
    
    switch (descriptionKey) {
      case 'det':
        return _ibnHadid!.det;
      // Future descriptions can be added here:
      // case 'det2': return _ibnHadid!.det2;
      default:
        return null;
    }
  }

  String _getDescriptionLabel(String descriptionKey) {
    // You can customize labels here
    switch (descriptionKey) {
      case 'الكل':
        return 'الكل';
      case 'det':
        return 'الشرح الأول';
      // Future labels:
      // case 'det2': return 'الشرح الثاني';
      default:
        return descriptionKey;
    }
  }

  bool shouldShowDescription(String descriptionKey) {
    if (selectedDescription == 'الكل') {
      // When "الكل" is selected, show all available descriptions
      return descriptionKey != 'الكل';
    }
    return descriptionKey == selectedDescription;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final availableDescriptions = _getAvailableDescriptions();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.5,
        maxChildSize: 1.0,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 48.0),
                            child: Center(
                              child: Text(
                                'شرح ابن ابی الحدید',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_ibnHadid == null || availableDescriptions.isEmpty)
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'لا يوجد شرح متاح',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  )
                else ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: availableDescriptions.map((description) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: FilterChip(
                            backgroundColor: isDarkMode
                                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.4)
                                : Colors.transparent,
                            side: BorderSide.none,
                            labelStyle: TextStyle(
                              color: selectedDescription == description
                                  ? Theme.of(context).colorScheme.surface
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                            checkmarkColor: Theme.of(context).colorScheme.surface,
                            label: Text(_getDescriptionLabel(description)),
                            selected: selectedDescription == description,
                            selectedColor: Theme.of(context).colorScheme.onSurface,
                            onSelected: (selected) {
                              setState(() {
                                selectedDescription = description;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      children: _buildDescriptionContent(),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildDescriptionContent() {
    List<Widget> content = [];
    final availableDescriptions = _getAvailableDescriptions();
    
    if (selectedDescription == 'الكل') {
      // Show all available descriptions
      for (String desc in availableDescriptions) {
        if (desc == 'الكل') continue;
        final descriptionContent = _getDescriptionContent(desc);
        if (descriptionContent != null && descriptionContent.isNotEmpty) {
          content.add(Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Html(
                    data: descriptionContent,
                    style: {
                      ...StyleHelper.getStyles(context),
                      'html': Style(
                        fontSize: FontSize(_fontSize.size),
                        lineHeight: LineHeight(_lineHeight.size),
                        textAlign: TextAlign.justify,
                        fontFamily: _fontFamily.name,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      'p': Style(
                        textAlign: TextAlign.justify,
                        fontFamily: _fontFamily.name,
                      ),
                    },
                  ),
                ],
              ),
            ),
          ));
          content.add(const SizedBox(height: 16));
        }
      }
    } else {
      // Show only the selected description
      final descriptionContent = _getDescriptionContent(selectedDescription);
      if (descriptionContent != null && descriptionContent.isNotEmpty) {
        content.add(Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Html(
                  data: descriptionContent,
                  style: {
                    ...StyleHelper.getStyles(context),
                    'html': Style(
                      fontSize: FontSize(_fontSize.size),
                      lineHeight: LineHeight(_lineHeight.size),
                      textAlign: TextAlign.justify,
                      fontFamily: _fontFamily.name,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    'p': Style(
                      textAlign: TextAlign.justify,
                      fontFamily: _fontFamily.name,
                    ),
                  },
                ),
              ],
            ),
          ),
        ));
      }
    }
    
    return content;
  }
}

