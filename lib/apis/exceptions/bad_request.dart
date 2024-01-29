import 'dart:io';

class BadRequest extends HttpException {
  BadRequest(super.message, {Uri? uri}) : super(uri: uri);
}
