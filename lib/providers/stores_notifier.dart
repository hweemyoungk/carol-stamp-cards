import 'package:carol/models/store.dart';
import 'package:carol/providers/list_notifier.dart';

class StoresNotifier extends ListNotifier<Store> {
  StoresNotifier(super.state);

  @override
  void sort() {}
}
