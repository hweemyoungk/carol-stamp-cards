import 'package:carol/widgets/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActiveLocaleNotifier extends StateNotifier<Locale> {
  ActiveLocaleNotifier()
      : super(
          Locale.fromSubtags(languageCode: SupportedLanguage.en.name),
        );

  void set(SupportedLanguage languageCode) {
    state = Locale.fromSubtags(languageCode: languageCode.name);
  }
}
