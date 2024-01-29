import 'dart:io';

class Unauthorized extends HttpException {
  Unauthorized(super.message, {Uri? uri}) : super(uri: uri);
}
