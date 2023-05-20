import 'dart:typed_data';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path_provider/path_provider.dart';
import 'package:span_mobile/pages/common/vlog.dart';
import 'package:encrypt/encrypt.dart';
import 'dart:convert';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/export.dart';
import 'package:crypto/crypto.dart';

const SAMPLE_PASS_PATH = 'assets/passes/testPass.pkpass';

Future<bool> request(description, expires, offerUUID, userCard) async {
  Response response;
  final dio = Dio();
  response = await dio
      .post('https://us-central1-pass-d96f3.cloudfunctions.net/pass', data: {
    'backgroundColor': 'FFFFFF',
    'description': description,
    'expires': expires,
    'offerUUID': offerUUID,
    'userCard': userCard
  });
  print("*******************************************************************");
  print(response.data.toString());

  return response.data['result'] == 'SUCCESS' ? true : false;
}

Future<File> download() async {
  final firebase_storage.Reference ref = firebase_storage
      .FirebaseStorage.instance
      .ref()
      .child('passes/custom.pkpass');
  final String downloadURL = await ref.getDownloadURL();
  print('Download URL: $downloadURL');
  return await downloadPass(downloadURL);
}

Future<File> downloadPass(String passUrl) async {
  final dio = Dio();
  try {
    final response = await dio.get(passUrl,
        options: Options(responseType: ResponseType.bytes));
    final bytes = response.data as List<int>;

    final appDir = await getApplicationDocumentsDirectory();
    final file = File('${appDir.path}/pass.pkpass');
    await file.writeAsBytes(bytes);
    if (await file.exists()) {
      return file;
    } else {
      return null;
    }
  } catch (e) {
    print('Error occurred during pass download: $e');
    return null;
  }
}

Future<Uint8List> passProvider() async {
  ByteData pass = await rootBundle.load(SAMPLE_PASS_PATH);
  VLog(pass.toString());
  await decryptPass();
  return pass.buffer.asUint8List();
}

Future<Uint8List> passProviderDynamic(
    description, expires, offerUUID, userCard) async {
  File pkpassFile = null;
  bool result = await request(description, expires, offerUUID, userCard);
  if (result) {
    pkpassFile = await download();
  }
  await getCardPerson();
  final bytes = await pkpassFile.readAsBytes();
  final pass = Uint8List.fromList(bytes);
  print(pass.toString());
  print("*******************************************************************");
  return pass;
}

String extractPayload() {
  String payload = 'YrpKXylWkYscI6GhM9x/mw==';
  var iv = 'vEAt8JeRDiYecWUj0TLgQw==';
  var key = 'idu2OFc5yEfxagBj4Ef4g+bw7tjrjw9ndglJzlst+xM=';
  final encrypted = Encrypted.fromBase64(payload);
  final keyBytes = base64.decode(key);
  final ivBytes = base64.decode(iv);
  final aesKey = Key(keyBytes);
  final aesIV = IV(ivBytes);
  final encrypter = Encrypter(AES(aesKey, mode: AESMode.cbc));
  final decrypted = encrypter.decrypt(encrypted, iv: aesIV);
  VLog(decrypted);
  print("*******************************************************************");
  return decrypted;
}

Future<void> getCardPerson() async {
  final dio = Dio();
  Response response;
  var requestBody = {
    'person': '1097497569',
  };
  dio.options.headers['x-api-key'] =
      'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOjUwMDAxNzU1MCwidCI6MTYyMzg1Nzk1NywiciI6InlzYzVmeDJpc2MifQ.blyqRgLRKeOZ1Tvm4Z7UBv1wx2kHBNQAJvTArYOWCqo';
  dio.options.headers['x-platform'] = '233';
  response = await dio.post(
      'https://skux-test.virtualcards.us/api/skux/card/getPersonAndCard',
      data: requestBody);
  VLog(response.data.toString());
  print("*******************************************************************");
}

void decryptPass() async {
  final appDir = await getApplicationDocumentsDirectory();
  final file = File('${appDir.path}/pass.pkpass');
  final bytes = await file.readAsBytes();
  // await pkpassFile.readAsBytes()
  //final encryptedPass = await rootBundle.load(SAMPLE_PASS_PATH);

  var encryptionKey =
      'm2IaJqeTF4N2GELX1xRug4rXKoy5dRw2lJiikq5Ax4Y='; // Assuming it's a base64-encoded string
  var iv = 'dGVKRPG+Of4X9ySpB5D4qg=='; // Assuming it's a base64-encoded string

  final key = Key.fromBase64(encryptionKey);
  final ivData = IV.fromBase64(iv);
  final cipher = Encrypter(AES(key, mode: AESMode.cbc));
  final macValue = bytes.buffer.asUint8List();
  // final decryptedPass = cipher.decrypt(toData, iv: ivData);
  final decryptedPass = cipher.decryptBytes(Encrypted(macValue), iv: ivData);

  File('decryptedPass.pkpass').writeAsBytesSync(decryptedPass);
  File decFile = await location();
  final testBytes = await decFile.readAsBytes();
  final pass = Uint8List.fromList(testBytes);
  VLog(pass.toString());
}

Future<File> location() async {
  final appDir = await getApplicationDocumentsDirectory();
  final file = File('${appDir.path}/decryptedPass.pkpass');
  if (await file.exists()) {
    return file;
  } else {
    return null;
  }
}

Uint8List decryptPsdass(
    Uint8List encryptedPass, String encryptionKeyBase64, String ivBase64) {
  final encryptionKeyData = base64.decode(encryptionKeyBase64);
  final ivData = base64.decode(ivBase64);

  final cbcBlockCipher = CBCBlockCipher(AESFastEngine());
  final cbcParameters =
      ParametersWithIV(KeyParameter(encryptionKeyData), ivData);
  cbcBlockCipher.init(false, cbcParameters);

  final decryptedPass = cbcBlockCipher.process(encryptedPass);

  return decryptedPass;
}
