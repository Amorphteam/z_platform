import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:zahra/model/hekam.dart';

class TranslationBottomSheet extends StatelessWidget {
  final Hekam hekam;

  const TranslationBottomSheet({
    super.key,
    required this.hekam,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ترجمه',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (hekam.english1 != null) ...[
                      Card(
                        elevation: 0,
                        color: CupertinoColors.lightBackgroundGray,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'English',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Html(
                                data: hekam.english1!,
                                style: {
                                  "body": Style(
                                    fontSize: FontSize(16),
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                    textAlign: TextAlign.right,
                                    direction: TextDirection.rtl,
                                  ),
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (hekam.farsi1 != null) ...[
                      Card(
                        elevation: 0,
                        color: CupertinoColors.lightBackgroundGray,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'فارسی ۱',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Html(
                                data: hekam.farsi1!,
                                style: {
                                  "body": Style(
                                    fontSize: FontSize(16),
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                    textAlign: TextAlign.right,
                                    direction: TextDirection.rtl,
                                  ),
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (hekam.farsi2 != null) ...[
                      Card(
                        elevation: 0,
                        color: CupertinoColors.lightBackgroundGray,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'فارسی ۲',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Html(
                                data: hekam.farsi2!,
                                style: {
                                  "body": Style(
                                    fontSize: FontSize(16),
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                    textAlign: TextAlign.right,
                                    direction: TextDirection.rtl,
                                  ),
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (hekam.farsi3 != null) ...[
                      Card(
                        elevation: 0,
                        color: CupertinoColors.lightBackgroundGray,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'فارسی ۳',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Html(
                                data: hekam.farsi3!,
                                style: {
                                  "body": Style(
                                    fontSize: FontSize(16),
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                    textAlign: TextAlign.right,
                                    direction: TextDirection.rtl,
                                  ),
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (hekam.farsi4 != null) ...[
                      Card(
                        elevation: 0,
                        color: CupertinoColors.lightBackgroundGray,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'فارسی ۴',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Html(
                                data: hekam.farsi4!,
                                style: {
                                  "body": Style(
                                    fontSize: FontSize(16),
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                    textAlign: TextAlign.right,
                                    direction: TextDirection.rtl,
                                  ),
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 