import 'dart:convert';
import 'dart:typed_data';

import 'package:epub_parser/epub_parser.dart';
import 'package:flutter/services.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

class HtmlFileInfo {
  HtmlFileInfo(this.fileName, this.modifiedHtmlContent, this.pageIndex);
  final String fileName;
  final String modifiedHtmlContent;
  final int pageIndex;
}

Future<EpubBook> loadEpubFromAsset(String assetPath) async {
  final ByteData data = await rootBundle.load(assetPath);
  final List<int> bytes = data.buffer.asUint8List();
  final EpubBook epubBook = await EpubReader.readBook(Uint8List.fromList(bytes));
  return epubBook;
}

String convertLatinNumbersToArabic(String input) {
  const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  final document = html_parser.parse(input);

  void traverseAndReplace(dom.Node node) {
    if (node is dom.Text) {
      node.text = node.text.replaceAllMapped(RegExp(r'[0-9]'), (match) {
        final latinDigit = int.parse(match[0]!);
        return arabicDigits[latinDigit];
      });
    } else if (node.hasChildNodes()) {
      node.nodes.forEach(traverseAndReplace);
    }
  }

  traverseAndReplace(document.body!);
  return document.outerHtml;
}

Future<List<HtmlFileInfo>> extractHtmlContentWithEmbeddedImages(EpubBook epubBook) async {
  final EpubContent? bookContent = epubBook.Content;
  final Map<String, EpubByteContentFile>? images = bookContent?.Images;
  final Map<String, EpubTextContentFile>? htmlFiles = bookContent?.Html;

  final List<HtmlFileInfo> htmlContentList = [];
  if (htmlFiles != null) {
    int index = 0;
    for (final entry in htmlFiles.entries) {
      final String htmlContent = embedImagesInHtmlContent(entry.value, images);
      htmlContentList.add(HtmlFileInfo(entry.key, htmlContent, index++));
    }
  }

  return htmlContentList;
}

String embedImagesInHtmlContent(EpubTextContentFile htmlFile, Map<String, EpubByteContentFile>? images) {
  String htmlContent = htmlFile.Content!;
  final imgRegExp = RegExp(r'<img[^>]*>');
  final Iterable<RegExpMatch> imgTags = imgRegExp.allMatches(htmlContent);

  for (final imgMatch in imgTags) {
    final String imgTag = imgMatch.group(0)!;
    final String imageName = extractImageNameFromTag(imgTag);
    final String? base64Image = convertImageToBase64(images?['Images/$imageName']);

    if (base64Image != null) {
      final String replacement = '<img src="data:image/jpg;base64,$base64Image" alt="$imageName" />';
      htmlContent = htmlContent.replaceFirst(imgTag, replacement);
    }
  }

  return htmlContent;
}

List<HtmlFileInfo> reorderHtmlFilesBasedOnSpine(List<HtmlFileInfo> htmlFiles, List<String>? spineItems) {
  if (spineItems == null || spineItems.isEmpty) return htmlFiles;

  final Map<String, HtmlFileInfo> htmlFilesMap = {
    for (final file in htmlFiles) file.fileName.replaceAll('Text/', ''): file,
  };

  final List<HtmlFileInfo> orderedFiles = [];
  for (final spineItem in spineItems) {
    final HtmlFileInfo? file = htmlFilesMap[spineItem.replaceFirst('x', '')];
    if (file != null) {
      orderedFiles.add(file);
    }
  }
  return orderedFiles;
}

String? convertImageToBase64(EpubByteContentFile? imageFile) {
  if (imageFile == null) return null;
  return base64Encode(imageFile.Content!);
}

Future<int> findPageIndexInEpub(
  EpubBook epubBook,
  String fileName, {
  bool useSpineOrder = false,
}) async {
  final String targetBase = fileName.split('/').last;

  if (useSpineOrder) {
    try {
      final List<HtmlFileInfo> rawFiles = await extractHtmlContentWithEmbeddedImages(epubBook);
      final spineItems = epubBook.Schema?.Package?.Spine?.Items;
      final List<String> idRefs = [];
      if (spineItems != null) {
        for (final item in spineItems) {
          if (item.IdRef != null) {
            idRefs.add(item.IdRef!);
          }
        }
      }
      final List<HtmlFileInfo> ordered = reorderHtmlFilesBasedOnSpine(rawFiles, idRefs);
      for (int i = 0; i < ordered.length; i++) {
        final String name = ordered[i].fileName;
        if (name == fileName || name.split('/').last == targetBase) {
          return i;
        }
      }
    } catch (_) {}
  }

  final EpubContent? bookContent = epubBook.Content;
  final Map<String, EpubTextContentFile>? htmlFiles = bookContent?.Html;
  if (htmlFiles != null) {
    int index = 0;
    for (final String key in htmlFiles.keys) {
      if (key == fileName || key.split('/').last == targetBase) {
        return index;
      }
      index++;
    }
  }
  return -1;
}

String extractImageNameFromTag(String imageTag) {
  final RegExp imgSrcRegex = RegExp(r'src="([^"]+)"');
  final Match? match = imgSrcRegex.firstMatch(imageTag);
  String imageName = '';
  if (match != null && match.groupCount >= 1) {
    imageName = match.group(1)!;
    final List<String> pathSegments = imageName.split('/');
    if (pathSegments.isNotEmpty) {
      imageName = pathSegments.last;
    }
  }
  return imageName;
}

