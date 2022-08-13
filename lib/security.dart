import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dotenv/dotenv.dart';

var env = DotEnv(includePlatformEnvironment: true)..load();
String? secret = env['SECRET'];

String getAuth(){

  var now = DateTime.now();

  int time = now.minute + 60 * (now.hour + 12 * now.day);

  var bytes = utf8.encode('$secret.$time');

  Digest sha256Result = sha256.convert(bytes);

  return sha256Result.toString();
}