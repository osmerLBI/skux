import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:span_mobile/common/util.dart';
import 'package:span_mobile/pages/common/vlog.dart';
import 'package:widget_loading/widget_loading.dart';

class PDFViewPage extends StatefulWidget {
  const PDFViewPage({
    Key key,
    this.url,
    this.onLoadFinished,
    this.onError,
  }) : super(key: key);
  final String url;
  final Function onLoadFinished;
  final Function onError;

  @override
  _PDFViewPageState createState() => _PDFViewPageState();
}

class _PDFViewPageState extends State<PDFViewPage> {
  PDFDocument _doc;

  @override
  void initState() {
    Util.postFrame((p0) async {
      try {
        _doc = await PDFDocument.fromURL(widget.url);
        setState(() {});
        if (widget.onLoadFinished != null) {
          widget.onLoadFinished();
        }
      } catch (e) {
        VLog('pdf error');
        VLog(e, mode: VLogMode.error);
        if (widget.onError != null) {
          widget.onError(e);
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularWidgetLoading(
        child: _doc == null
            ? Container()
            : PDFViewer(
                document: _doc,
                showNavigation: true,
                showPicker: false,
              ),
        loading: _doc == null,
      ),
    );
  }
}
