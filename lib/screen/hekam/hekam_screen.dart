import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zahra/screen/hekam/cubit/hekam_cubit.dart';
import 'package:zahra/screen/hekam/widgets/translation_bottom_sheet.dart';

import '../../widget/custom_appbar.dart';

class HekamScreen extends StatelessWidget {

  HekamScreen({super.key});
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => HekamCubit()..fetchHekam(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: CustomAppBar(
          rightIcon: Icons.star_rate_rounded,
          backgroundImage: 'assets/image/back_tazhib_light.png',
          title: 'الحكم والمواعظ',
          showSearchBar: true,
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
                    color: Theme.of(context).colorScheme.primaryContainer,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Html(
                            data: item.asl,
                            style: {
                              'body': Style(
                                direction: TextDirection.rtl,
                                textAlign: TextAlign.justify,
                                textDecoration: TextDecoration.none,
                              ),
                              'p': Style(
                                color: isDarkMode ? Colors.white : Colors.black,
                                textAlign: TextAlign.justify,
                                margin: Margins.only(bottom: 10),
                                padding: HtmlPaddings.only(right: 7),
                              ),
                              'p.center': Style(
                                color: isDarkMode ? Colors.white : const Color(0xFF996633),
                                textAlign: TextAlign.center,
                                margin: Margins.zero,
                                padding: HtmlPaddings.zero,
                              ),
                              'a': Style(
                                textDecoration: TextDecoration.none,
                              ),
                              'a:link': Style(
                                color: const Color(0xFF2484C6),
                              ),
                              'a:visited': Style(
                                color: Colors.red,
                              ),
                              'h1': Style(
                                color: isDarkMode ? Colors.white : const Color(0xFF00AA00),
                                textAlign: TextAlign.center,
                                margin: Margins.only(bottom: 10),
                                fontWeight: FontWeight.bold,
                              ),
                              'h2': Style(
                                color: isDarkMode ? Colors.white : const Color(0xFF000080),
                                textAlign: TextAlign.center,
                                margin: Margins.only(bottom: 10),
                                fontWeight: FontWeight.bold,
                              ),
                              'h3': Style(
                                color: isDarkMode ? Colors.white : const Color(0xFF006400),
                                textAlign: TextAlign.right,
                                margin: Margins.only(bottom: 10),
                                fontWeight: FontWeight.bold,
                              ),
                              'h3.tit3_1': Style(
                                color: isDarkMode ? Colors.white : const Color(0xFF800000),
                                textAlign: TextAlign.right,
                                margin: Margins.only(bottom: 10),
                                fontWeight: FontWeight.bold,
                              ),
                              'h4.tit4': Style(
                                color: isDarkMode ? Colors.white : Colors.red,
                                textAlign: TextAlign.center,
                                margin: Margins.zero,
                                fontWeight: FontWeight.bold,
                              ),
                              '.pagen': Style(
                                textAlign: TextAlign.center,
                                color: isDarkMode ? Color(0xfff9825e) : Colors.red,
                              ),
                              '.shareef': Style(
                                color: isDarkMode ? Colors.white : const Color(0xFF996633),
                                textAlign: TextAlign.justify,
                                margin: Margins.only(bottom: 5),
                                padding: HtmlPaddings.only(right: 7),
                              ),
                              '.shareef_sher': Style(
                                textAlign: TextAlign.center,
                                color: isDarkMode ? Colors.white : const Color(0xFF996633),
                                margin: Margins.symmetric(vertical: 5),
                                padding: HtmlPaddings.zero,
                              ),
                              '.fnote': Style(
                                color: isDarkMode ? const Color(0xFF8a8afa) : const Color(0xFF000080),
                                margin: Margins.zero,
                                padding: HtmlPaddings.zero,
                              ),
                              '.sher': Style(
                                textAlign: TextAlign.center,
                                color: isDarkMode ? Colors.white : const Color(0xFF990000),
                                margin: Margins.symmetric(vertical: 10),
                                padding: HtmlPaddings.zero,
                              ),
                              '.psm': Style(
                                textAlign: TextAlign.center,
                                color: isDarkMode ? Colors.white : const Color(0xFF990000),
                                margin: Margins.symmetric(vertical: 10),
                                padding: HtmlPaddings.zero,
                              ),
                              '.shareh': Style(
                                color: isDarkMode ? Colors.white : const Color(0xFF996633),
                              ),
                              '.msaleh': Style(
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                              ),
                              '.onwan': Style(
                                color: isDarkMode ? Colors.white : const Color(0xFF088888),
                                fontWeight: FontWeight.bold,
                              ),
                              '.fn': Style(
                                color: isDarkMode ? const Color(0xff8a8afa) : const Color(0xFF000080),
                                fontWeight: FontWeight.normal,
                                textDecoration: TextDecoration.none,
                                verticalAlign: VerticalAlign.top,
                              ),
                              '.fm': Style(
                                color: isDarkMode ? Color(0xffa2e1a2) : Colors.green,
                                fontWeight: FontWeight.bold,
                                textDecoration: TextDecoration.none,
                              ),
                              '.quran': Style(
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Color(0xffa2e1a2) : const Color(0xFF509368),
                              ),
                              '.hadith': Style(
                                color: isDarkMode ? Color(0xffC1C1C1) : Colors.black,
                              ),
                              '.hadith-num': Style(
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Color(0xfff9825e) : Colors.red,
                              ),
                              '.shreah': Style(
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Color(0xffC1C1C1) : Colors.black,
                              ),
                              '.kalema': Style(
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : const Color(0xFFCC0066),
                              ),
                              'mark': Style(
                                backgroundColor: Colors.yellow,
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
                                  item.isFavorite ? Icons.star_rate : Icons.star_border_outlined,
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