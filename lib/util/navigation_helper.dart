import 'package:flutter/material.dart';
import 'package:zahra/model/item_model.dart';
import 'package:zahra/util/epub_helper.dart';
import '../model/reference_model.dart';

class NavigationHelper {
  static void navigateTo(
      {required String goto,
      ItemModel? item,
      SubItems? subItem,
      String? title,
      required BuildContext context,}) {
    switch (goto) {
      case 'text':
        navigateToEpub(subItem, item, context);
        break;
      case 'jsonGraphic':
        navigateToDetail(subItem, item, context, title);
        break;
      case 'jsonList':
        navigateToToc(subItem, item, context, title);
        break;
    }
  }

  static void navigateToToc(
      SubItems? subItem, ItemModel? item, BuildContext context, String? title,) {
    final int id = subItem?.id ?? item?.linkTo?.id ?? 0;
    Navigator.of(context).pushNamed(
      '/toc',
      arguments: {'id': id, 'item': item, 'title': title},
    );
  }

  static void navigateToTocWithNumber(
     BuildContext context, String? title,) {
    Navigator.of(context).pushNamed(
      '/toc_with_number',
      arguments: {'title': title},
    );
  }

  static void navigateToDetail(
      SubItems? subItem, ItemModel? item, BuildContext context, String? title,) {
    final int id = subItem?.id ?? item?.linkTo?.id ?? 0;
    Navigator.of(context).pushNamed(
      '/detail',
      arguments: {'id': id, 'title': title},
    );
  }

  static void navigateToEpub(SubItems? subItem, ItemModel? item, BuildContext context) {
    final String? bookPath = item?.linkTo?.key?.split('_').first ?? subItem?.key?.split('_').first;
    final String? sectionName = item?.linkTo?.key?.split('_').last ?? subItem?.key?.split('_').last;
    final int sectionNumber = int.parse(sectionName ?? '0');
    final String sectionNumberString = (sectionNumber-1).toString();
    openBook(context, bookPath, sectionNumberString);
  }

  static void openBook(BuildContext context, String? bookPath, String? sectionName) {
      final bookPath0 = '$bookPath.epub';
      openEpub(context: context, reference: ReferenceModel(title: '', bookName: '',bookPath: bookPath0, navIndex: sectionName.toString()));
  }

}
