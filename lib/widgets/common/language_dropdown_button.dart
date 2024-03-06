import 'package:carol/params/shared_preferences.dart' as prefs_params;
import 'package:carol/widgets/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageDropdownButton extends ConsumerWidget {
  const LanguageDropdownButton({
    super.key,
    required this.textColor,
  });
  final Color textColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(activeLocaleProvider);
    final localeNotifier = ref.watch(activeLocaleProvider.notifier);
    const supportedLanguages = SupportedLanguage.values;
    final targetLanguage = supportedLanguages.firstWhere(
        (element) => element.languageCode == currentLocale.languageCode);
    return DropdownButton(
      value: targetLanguage,
      selectedItemBuilder: (context) {
        return supportedLanguages.map(
          (e) {
            return Center(
              child: Text(
                e.language,
                style: TextStyle(
                  color: textColor,
                ),
              ),
            );
          },
        ).toList();
      },
      icon: Icon(
        Icons.language,
        color: textColor,
      ),
      items: supportedLanguages.map((e) => LocaleDropdownMenuItem(e)).toList(),
      onChanged: (value) async {
        if (value == null) {
          return;
        }
        if (value is! SupportedLanguage) {
          return;
        }
        localeNotifier.set(value);

        final prefs = await SharedPreferences.getInstance();
        prefs.setString(prefs_params.languageCodeKey, value.languageCode);
      },
    );
  }
}
