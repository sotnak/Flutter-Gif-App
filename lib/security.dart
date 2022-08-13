import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:crypto/crypto.dart';

String? secret = dotenv.env['SECRET'];

String getAuth(){

  var now = DateTime.now().toUtc();

  int time = now.minute + 60 * (now.hour + 12 * now.day);

  var bytes = utf8.encode('$secret.$time');

  Digest sha256Result = sha256.convert(bytes);

  return sha256Result.toString();
}