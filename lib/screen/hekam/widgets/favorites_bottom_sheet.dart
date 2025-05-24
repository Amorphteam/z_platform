import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:zahra/model/hekam.dart';
import 'package:zahra/screen/hekam/cubit/hekam_cubit.dart';

import '../../../util/style_helper.dart';

class FavoritesBottomSheet extends StatelessWidget {
  const FavoritesBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
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
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'المفضلة',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: BlocBuilder<HekamCubit, HekamState>(
                    builder: (context, state) {
                      return state.when(
                        initial: () => const Center(child: CircularProgressIndicator()),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        loaded: (hekam) {
                          final favorites = hekam.where((item) => item.isFavorite).toList();
                          if (favorites.isEmpty) {
                            return Center(
                              child: Text(
                                'لا توجد عناصر في المفضلة',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            );
                          }
                          return ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: favorites.length,
                            itemBuilder: (context, index) {
                              final item = favorites[index];
                              return Card(
                                elevation: 0,
                                color: Theme.of(context).colorScheme.primaryContainer,
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Html(
                                        data: item.asl,
                                        style: StyleHelper.getStyles(context),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon:  Icon(Icons.star_rate, color: Theme.of(context).colorScheme.secondaryContainer),
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
                          );
                        },
                        error: (message) => Center(child: Text(message)),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 