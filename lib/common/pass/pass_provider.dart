import 'dart:typed_data';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path_provider/path_provider.dart';

const SAMPLE_PASS_PATH = 'assets/passes/health_id_card_sample.pkpass';

final dio = Dio();

Future<bool> request() async {
  Response response;
  response = await dio.post(
      'https://us-central1-pass-d96f3.cloudfunctions.net/pass',
      data: {'backgroundColor': 'FFFFFF'});
  print("*******************************************************************");
  print(response.data.toString());

  return response.data['result'] == 'SUCCESS' ? true : false;
}

Future<File> download() async {
  final firebase_storage.Reference ref = firebase_storage
      .FirebaseStorage.instance
      .ref()
      .child('pass/custom.pkpass');
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
    print(appDir);
    print('Pass downloaded and saved successfully');
    if (await file.exists()) {
      print('Pass file fetched successfully');
      return file;
    } else {
      print('Pass file does not exist');
      return null;
    }
  } catch (e) {
    print('Error occurred during pass download: $e');
    return null;
  }
}

final Future<Uint8List> Function() passProvider = () async {
  File pkpassFile = null;
  bool result = await request();
  if (result) {
    pkpassFile = await download();
  }
  print(result);
  // ByteData pass = await rootBundle.load(SAMPLE_PASS_PATH);
  // return pass.buffer.asUint8List();

  final bytes = await pkpassFile.readAsBytes();
  final pass = Uint8List.fromList(bytes);
  print(pass.toString());
  print("*******************************************************************");
  return pass;
};
