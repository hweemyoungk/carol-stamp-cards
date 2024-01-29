import 'dart:io';

class ServerError extends HttpException {
  ServerError(super.message, {Uri? uri}) : super(uri: uri);
}
