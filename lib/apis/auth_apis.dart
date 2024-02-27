import 'package:carol/apis/utils.dart';
import 'package:carol/params/backend.dart' as backend_params;

Future<void> deleteAccount({
  required String userId,
}) async {
  final url = Uri.https(
    backend_params.appGateway,
    '${backend_params.authUserPath}/$userId',
  );
  await httpDelete(url);
  return;
}
