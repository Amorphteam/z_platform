import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widget/custom_appbar.dart';
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
                    const Text('حجم الخط:'),
                    Expanded(
                      child: Slider(
                        thumbColor: Theme.of(context).colorScheme.onSurface,
                        activeColor: Theme.of(context).colorScheme.onSurface,
                        value: loadedState.fontSize,
                        min: 10,
                        max: 40,
                        divisions: 30,
                        label: loadedState.fontSize.round().toString(),
                        onChanged: (value) => cubit.updateFontSize(value),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text('فاصلة الأسطر:'),
                    Expanded(
                      child: Slider(
                        thumbColor: Theme.of(context).colorScheme.onSurface,
                        activeColor: Theme.of(context).colorScheme.onSurface,
                        value: loadedState.lineHeight,
                        min: 1.0,
                        max: 3.0,
                        divisions: 20,
                        label: loadedState.lineHeight.toStringAsFixed(1),
                        onChanged: (value) => cubit.updateLineHeight(value),
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
                    'لَا قُرْبَةَ بِالنَّوَافِلِ إِذَا أَضَرَّتْ بِالْفَرَائِضِ.',
                    style: TextStyle(
                      fontSize: loadedState.fontSize,
                      height: loadedState.lineHeight,
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
      title: Text(title),
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
                  () => cubit.setTheme('system')),
              const Divider(height: 1),
              _buildThemeTile(context, 'فاتح', 'light', loadedState.theme,
                  () => cubit.setTheme('light')),
              const Divider(height: 1),
              _buildThemeTile(context, 'داكن', 'dark', loadedState.theme,
                  () => cubit.setTheme('dark')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeTile(BuildContext context, String title, String value,
      String groupValue, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      onTap: onTap,
      trailing: groupValue == value
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.onSurface)
          : null,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}
