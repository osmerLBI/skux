import 'dart:typed_data';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path_provider/path_provider.dart';
import 'package:span_mobile/pages/common/vlog.dart';

const SAMPLE_PASS_PATH = 'assets/passes/testPass.pkpass';
const SAMPLE_PASS_PATH2 = 'assets/passes/health_id_card_sample.pkpass';

Future<bool> request(description, expires, offerUUID, userCard) async {
  Response response;
  final dio = Dio();
  response = await dio
      .post('https://us-central1-pass-d96f3.cloudfunctions.net/pass', data: {
    'backgroundColor': '0000FF',
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
  ByteData pass = await rootBundle.load(SAMPLE_PASS_PATH2);
  VLog(pass.toString());
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
