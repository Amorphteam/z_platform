import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cupertino_native/cupertino_native.dart';

class EpubPageSlider extends StatelessWidget {
  final double currentPage;
  final double maxPages;
  final String bookTitle;
  final bool isAboutUsBook;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangedEnd;
  final VoidCallback? onPageJump;

  const EpubPageSlider({
    super.key,
    required this.currentPage,
    required this.maxPages,
    required this.bookTitle,
    required this.isAboutUsBook,
    this.onChanged,
    this.onChangedEnd,
    this.onPageJump,
  });

  @override
  Widget build(BuildContext context) {
    if (isAboutUsBook || maxPages <= 1.0) {
      return const SizedBox.shrink();
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          _buildSlider(),
          _buildPageInfo(context),
        ],
      ),
    );
  }

  Widget _buildSlider() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Transform.flip(
          flipX: true,
          child: CNSlider(
            value: currentPage,
            min: 0,
            max: maxPages,
            onChanged: onChanged ?? (_) {},
          ),
        ),
      );
    } else {
      return Slider(
        value: currentPage,
        min: 0,
        max: maxPages,
        onChanged: onChanged ?? (_) {},
        onChangeEnd: onChangedEnd ?? (_) {},
      );
    }
  }

  Widget _buildPageInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          right: 16.0, left: 16.0, bottom: 20.0, top: 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                bookTitle,
                style: Theme.of(context).textTheme.labelLarge,
                maxLines: 1,
              ),
            ),
          ),
          TextButton(
            onPressed: onPageJump,
            child: Text(
              '${maxPages.toInt()}/${currentPage.toInt() + 1}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}

