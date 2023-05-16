import 'dart:io';

import 'package:dio_log/http_log_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:logger_flutter/logger_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:span_mobile/common/platform.dart';
import 'package:span_mobile/common/style.dart';
import 'package:span_mobile/common/util.dart';
import 'package:span_mobile/widgets/line_separator.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key key}) : super(key: key);

  @override
  _TestPageState createState() {
    return _TestPageState();
  }
}

class _TestPageState extends State<TestPage> {
  void setServerUrl(String url) {
    Util.serverUrl = url;
    Util.pref.setString('serverUrl', url);
    Util.log('Updated server URL to: ' + url);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
            child: const Text('Debugging Page'),
            onTap: () {
              // todo UME debug
              // context.read<UMESwitch>().trigger();
            }),
      ),
      body: SafeArea(
        child: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              ListTile(
                title: const Text('App version'),
                trailing: Text(Util.getVersion()),
              ),
              const LineSeparator(high: true),
              PopupMenuButton<String>(
                onSelected: (String url) async {
                  if (url.isEmpty) {
                    url = await Util.showPromptDialog(
                      context: context,
                      title: 'Server URL',
                      value: Util.serverUrl,
                    );
                  }
                  if (url != null && url.isNotEmpty) {
                    setServerUrl(url);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: platform.productionUrl(),
                      child: const Text('Production Server'),
                    ),
                    PopupMenuItem<String>(
                      value: platform.stagingUrl(),
                      child: const Text('Staging Server'),
                    ),
                    PopupMenuItem<String>(
                      value: 'http://' + platform.key() + '.span.hans',
                      child: const Text('Local Server'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'http://192.168.31.172',
                      child: Text('Home - 192.168.31.172'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'http://10.10.3.117',
                      child: Text('Office - 10.10.3.117'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'http://192.168.43.83',
                      child: Text('Mobile - 192.168.43.83'),
                    ),
                    const PopupMenuItem<String>(
                      value: '',
                      child: Text('Custom'),
                    ),
                  ];
                },
                child: ListTile(
                  title: const Text('Server URL'),
                  subtitle: Text(Util.serverUrl),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
              const LineSeparator(high: true),
              PopupMenuButton(
                onSelected: (user) async {
                  Util.eventHub.fire('common_login_as', user);
                  Util.navigator(context: context).pop();
                },
                itemBuilder: (BuildContext context) {
                  List<PopupMenuEntry> items = [];
                  List<Map> users = platform.testUsers();
                  for (Map user in users) {
                    PopupMenuItem item = PopupMenuItem(
                      value: user,
                      child: Column(
                        children: [
                          Text(
                            user['name'],
                            style: const TextStyle(
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            user['email'],
                            style: TextStyle(
                              color: Colors.black38,
                              fontFamily: style.fontFamily3,
                              fontSize: 14,
                            ),
                          ),
                        ],
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                    );
                    items.add(item);
                    items.add(const PopupMenuDivider());
                  }
                  return items.sublist(0, items.length - 1);
                },
                child: const ListTile(
                  title: Text('Login As'),
                  subtitle: Text('Works only on login screen'),
                  trailing: Icon(Icons.chevron_right),
                ),
              ),
              const LineSeparator(high: true),
              ListTile(
                title: const Text('Show all logs'),
                subtitle:
                    const Text('All the logs that triggered by Util.logger'),
                onTap: () {
                  Util.push(builder: () {
                    return LogConsole(
                      showCloseButton: true,
                    );
                  });
                },
                trailing: const Icon(Icons.chevron_right),
              ),
              ListTile(
                title: const Text('Show API request/response logs'),
                subtitle: const Text('Dio builtin log screen'),
                onTap: () {
                  Util.push(builder: () {
                    return HttpLogListWidget();
                  });
                },
                trailing: const Icon(Icons.chevron_right),
              ),
              const LineSeparator(high: true),
              ListTile(
                title: const Text('Clear cache'),
                onTap: () async {
                  PaintingBinding.instance.imageCache.clear();

                  final Directory tempDir = await getTemporaryDirectory();
                  final Directory libCacheDir =
                      Directory("${tempDir.path}/libCachedImageData");

                  if (libCacheDir.existsSync()) {
                    await libCacheDir.delete(recursive: true);
                  }

                  await DefaultCacheManager().emptyCache();

                  Util.toastSuccess();
                },
                trailing: const Icon(Icons.chevron_right),
              ),
              ListTile(
                title: const Text('Temporary test'),
                onTap: () {},
                trailing: const Icon(Icons.chevron_right),
              ),
              const LineSeparator(high: true),
            ],
          ).toList(),
        ),
      ),
    );
  }
}
