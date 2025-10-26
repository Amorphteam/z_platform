import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../util/theme_helper.dart';

class ThemeModeToggle extends StatelessWidget {
  final bool showLabels;
  final bool isCompact;
  
  const ThemeModeToggle({
    super.key,
    this.showLabels = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Consumer<ThemeHelper>(
        builder: (context, themeHelper, child) {
          final currentMode = themeHelper.themeMode;
          
          if (isCompact) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    currentMode == ThemeMode.light 
                        ? Icons.light_mode 
                        : currentMode == ThemeMode.dark 
                            ? Icons.dark_mode 
                            : Icons.brightness_auto,
                  ),
                  onPressed: () => _cycleThemeMode(themeHelper),
                  tooltip: _getTooltip(currentMode),
                ),
                if (showLabels) ...[
                  const SizedBox(width: 8),
                  Text(_getLabel(currentMode)),
                ],
              ],
            );
          }
          
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'وضع العرض',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildThemeOption(
                          context,
                          themeHelper,
                          AppTheme.light,
                          Icons.light_mode,
                          'الوضع الفاتح',
                          'ألوان فاتحة',
                          currentMode == ThemeMode.light,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildThemeOption(
                          context,
                          themeHelper,
                          AppTheme.dark,
                          Icons.dark_mode,
                          'الوضع الداكن',
                          'ألوان داكنة',
                          currentMode == ThemeMode.dark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildThemeOption(
                          context,
                          themeHelper,
                          AppTheme.system,
                          Icons.brightness_auto,
                          'النظام',
                          'تلقائي',
                          currentMode == ThemeMode.system,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeHelper themeHelper,
    AppTheme theme,
    IconData icon,
    String title,
    String subtitle,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => themeHelper.setTheme(theme),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _cycleThemeMode(ThemeHelper themeHelper) {
    switch (themeHelper.themeMode) {
      case ThemeMode.light:
        themeHelper.setTheme(AppTheme.dark);
        break;
      case ThemeMode.dark:
        themeHelper.setTheme(AppTheme.system);
        break;
      case ThemeMode.system:
        themeHelper.setTheme(AppTheme.light);
        break;
    }
  }

  String _getLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'فاتح';
      case ThemeMode.dark:
        return 'داكن';
      case ThemeMode.system:
        return 'تلقائي';
    }
  }

  String _getTooltip(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'الوضع الفاتح';
      case ThemeMode.dark:
        return 'الوضع الداكن';
      case ThemeMode.system:
        return 'وضع النظام';
    }
  }
}