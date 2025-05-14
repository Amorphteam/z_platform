import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zahra/screen/hekam/cubit/hekam_cubit.dart';
import 'package:zahra/screen/hekam/widgets/translation_bottom_sheet.dart';

class HekamScreen extends StatelessWidget {
  const HekamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HekamCubit()..fetchHekam(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.outlineVariant,
        appBar: AppBar(
          title: const Text('الحكم والمواعظ'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: BlocBuilder<HekamCubit, HekamState>(
          builder: (context, state) {
            return state.when(
              initial: () => const Center(child: CircularProgressIndicator()),
              loading: () => const Center(child: CircularProgressIndicator()),
              loaded: (hekam) => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: hekam.length,
                itemBuilder: (context, index) {
                  final item = hekam[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Html(
                            data: item.asl,
                            style: {
                              "body": Style(
                                textAlign: TextAlign.center,
                                fontSize: FontSize(18),
                                fontWeight: FontWeight.bold,
                              ),
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.share),
                                onPressed: () {
                                  Share.share(item.asl);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.translate),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => TranslationBottomSheet(hekam: item),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  item.isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: item.isFavorite ? Colors.red : null,
                                ),
                                onPressed: () {
                                  context.read<HekamCubit>().toggleFavorite(item.id);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              error: (message) => Center(child: Text(message)),
            );
          },
        ),
      ),
    );
  }
} 