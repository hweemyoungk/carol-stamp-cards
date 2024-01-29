import 'dart:io';

class Unauthenticated extends HttpException {
  Unauthenticated(super.message, {Uri? uri}) : super(uri: uri);
}
