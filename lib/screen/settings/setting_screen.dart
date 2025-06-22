import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widget/custom_appbar.dart';
import '../../model/style_model.dart';
import 'cubit/setting_cubit.dart';


class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: CustomAppBar(
          showSearchBar: false,
          backgroundImage: 'assets/image/back_tazhib_light.jpg',
          title: "الإعدادات",
        ),
        body: Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: BlocBuilder<SettingCubit, SettingState>(
            builder: (context, state) {
              return state.map(
                loaded: (loadedState) {
                  return ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      _buildTextSection(context, loadedState),
                      const SizedBox(height: 24),
                      // _buildFontFamilySection(context, loadedState),
                      // const SizedBox(height: 24),
                      _buildTranslationSection(context, loadedState),
                      const SizedBox(height: 24),
                      _buildThemeSection(context, loadedState),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child}) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: child,
      ),
    );
  }

  Widget _buildTextSection(BuildContext context, Loaded loadedState) {
    final cubit = context.read<SettingCubit>();
    
    // Convert enum values to slider values
    double fontSizeToSliderValue(FontSizeCustom fontSize) {
      return fontSize.index / (FontSizeCustom.values.length - 1);
    }

    double lineHeightToSliderValue(LineHeightCustom lineHeight) {
      return lineHeight.index / (LineHeightCustom.values.length - 1);
    }

    void handleFontSizeSliderChange(double newValue) {
      final fontSize = FontSizeCustom.values[(newValue * (FontSizeCustom.values.length - 1)).round()];
      cubit.updateFontSize(fontSize);
    }

    void handleLineHeightSliderChange(double newValue) {
      final lineHeight = LineHeightCustom.values[(newValue * (LineHeightCustom.values.length - 1)).round()];
      cubit.updateLineHeight(lineHeight);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'النص'),
        _buildCard(
          context,
          child: Container(
            child: Column(
              children: [
                Row(
                  children: [
                     SizedBox(
                        width: 100,
                         child: Text('حجم الخط:', style: Theme.of(context).textTheme.bodyLarge)),
                    Expanded(
                      child: Slider(
                        thumbColor: Theme.of(context).colorScheme.onSurface,
                        activeColor: Theme.of(context).colorScheme.onSurface,
                        value: fontSizeToSliderValue(loadedState.fontSize),
                        min: 0.0,
                        max: 1.0,
                        divisions: FontSizeCustom.values.length - 1,
                        label: loadedState.fontSize.size.round().toString(),
                        onChanged: handleFontSizeSliderChange,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                        width: 100,
                        child: Text('فاصلة الأسطر:', style: Theme.of(context).textTheme.bodyLarge)),
                    Expanded(
                      child: Slider(
                        thumbColor: Theme.of(context).colorScheme.onSurface,
                        activeColor: Theme.of(context).colorScheme.onSurface,
                        value: lineHeightToSliderValue(loadedState.lineHeight),
                        min: 0.0,
                        max: 1.0,
                        divisions: LineHeightCustom.values.length - 1,
                        label: loadedState.lineHeight.size.toStringAsFixed(1),
                        onChanged: handleLineHeightSliderChange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'لَا قُرْبَةَ بِالنَّوَافِلِ إِذَا أَضَرَّتْ بِالْفَرَائِضِ.',
                    style: TextStyle(
                      fontSize: loadedState.fontSize.size,
                      height: loadedState.lineHeight.size,
                      fontFamily: 'Lotus Qazi Light',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFontFamilySection(BuildContext context, Loaded loadedState) {
    final cubit = context.read<SettingCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'مجموعة الخط'),
        _buildCard(
          context,
          child: Column(
            children: [
              _buildFontFamilyTile(context, 'خط ١', FontFamily.font1, loadedState.fontFamily,
                  () => cubit.updateFontFamily(FontFamily.font1)),
              const Divider(height: 1),
              _buildFontFamilyTile(context, 'خط ٢', FontFamily.font2, loadedState.fontFamily,
                  () => cubit.updateFontFamily(FontFamily.font2)),
              const Divider(height: 1),
              _buildFontFamilyTile(context, 'خط ٣', FontFamily.font3, loadedState.fontFamily,
                  () => cubit.updateFontFamily(FontFamily.font3)),
              const Divider(height: 1),
              _buildFontFamilyTile(context, 'خط ٤', FontFamily.font4, loadedState.fontFamily,
                  () => cubit.updateFontFamily(FontFamily.font4)),
              const Divider(height: 1),
              _buildFontFamilyTile(context, 'خط ٥', FontFamily.font5, loadedState.fontFamily,
                  () => cubit.updateFontFamily(FontFamily.font5)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFontFamilyTile(BuildContext context, String title, FontFamily value,
      FontFamily groupValue, VoidCallback onTap) {
    return ListTile(
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge,),
      onTap: onTap,
      trailing: groupValue == value
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.onSurface)
          : null,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildTranslationSection(BuildContext context, Loaded loadedState) {
    final cubit = context.read<SettingCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'الترجمة'),
        _buildCard(
          context,
          child: Column(
            children: [
              _buildSwitchTile(
                context,
                title: 'English',
                value: loadedState.english,
                onChanged: (val) => cubit.toggleEnglish(val),
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                context,
                title: 'فارسی - فیض الإسلام',
                value: loadedState.farsiFaidh,
                onChanged: (val) => cubit.toggleFarsiFaidh(val),
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                context,
                title: 'فارسی - انصاریان',
                value: loadedState.farsiAnsarian,
                onChanged: (val) => cubit.toggleFarsiAnsarian(val),
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                context,
                title: 'فارسی - جعفری',
                value: loadedState.farsiJafari,
                onChanged: (val) => cubit.toggleFarsiJafari(val),
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                context,
                title: 'فارسی - شهیدی',
                value: loadedState.farsiShahidi,
                onChanged: (val) => cubit.toggleFarsiShahidi(val),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(BuildContext context,
      {required String title,
      required bool value,
      required ValueChanged<bool> onChanged}) {
    return SwitchListTile(
      activeColor: Theme.of(context).colorScheme.onSurface,
      inactiveThumbColor: Colors.grey,
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      value: value,
      onChanged: onChanged,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildThemeSection(BuildContext context, Loaded loadedState) {
    final cubit = context.read<SettingCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'مظهر التطبيق'),
        _buildCard(
          context,
          child: Column(
            children: [
              _buildThemeTile(context, 'افتراضي', 'system', loadedState.theme,
                  () async => await cubit.setTheme('system', context)),
              const Divider(height: 1),
              _buildThemeTile(context, 'فاتح', 'light', loadedState.theme,
                  () async => await cubit.setTheme('light', context)),
              const Divider(height: 1),
              _buildThemeTile(context, 'داكن', 'dark', loadedState.theme,
                  () async => await cubit.setTheme('dark', context)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeTile(BuildContext context, String title, String value,
      String groupValue, Future<void> Function() onTap) {
    return ListTile(
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge,),
      onTap: () => onTap(),
      trailing: groupValue == value
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.onSurface)
          : null,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}
