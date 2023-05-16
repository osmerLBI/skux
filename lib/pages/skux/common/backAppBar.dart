// ignore_for_file: non_constant_identifier_names, file_names

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_svg/svg.dart';
import 'package:span_mobile/pages/common/base_appbar.dart';
import 'package:span_mobile/pages/common/debug_widget.dart';

SkuBackAppBar(BuildContext context, {String title = '', Widget titleItem}) {
  return baseAppBar(
    context,
    title: title,
    titleItem: titleItem ??
        DebugWidget(
          child: Semantics(
            sortKey: const OrdinalSortKey(1),
            header: true,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              ),
            ),
          ),
        ),
    leftItem: Semantics(
      sortKey: const OrdinalSortKey(2),
      button: true,
      label: 'Back',
      excludeSemantics: true,
      child: IconButton(
        icon: SvgPicture.asset('assets/image/skux/arrow_left.svg'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ),
  );
}
