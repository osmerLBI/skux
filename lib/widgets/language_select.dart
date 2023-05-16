import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:span_mobile/common/platform.dart';
import 'package:span_mobile/common/skux/skux_style.dart';
import 'package:span_mobile/common/util.dart';
import 'package:span_mobile/i18n/locale_data.dart';

class LanguageSelect extends StatefulWidget {
  final bool arrow;
  final Function(LocaleData) onSelected;

  const LanguageSelect({Key key, this.arrow = true, this.onSelected})
      : super(key: key);

  @override
  _LanguageSelectState createState() {
    return _LanguageSelectState();
  }
}

class _LanguageSelectState extends State<LanguageSelect> {
  LocaleData selected;
  List<LocaleData> options;

  @override
  void initState() {
    super.initState();

    options = platform.localeData();
  }

  @override
  Widget build(BuildContext context) {
    Locale locale = EasyLocalization.of(context).locale;
    if (selected == null) {
      for (LocaleData ld in options) {
        if (ld.isLocale(locale)) {
          selected = ld;
          break;
        }
      }
    }

    return PopupMenuButton<LocaleData>(
      initialValue: selected,
      tooltip: tr('Change Language'),
      offset: Offset(0, locale.languageCode != 'en' ? 100 : 0),
      onSelected: (LocaleData v) async {
        selected = v;
        await Util.updateSystemLocale(v);
        setState(() {});

        if (widget.onSelected != null) {
          widget.onSelected(v);
        }
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: Util.radius(3),
            child: Image.asset(
              'packages/intl_phone_number_input/assets/flags/${selected.iso}.png',
              width: 36,
            ),
          ),
          if (widget.arrow)
            const Icon(
              Icons.keyboard_arrow_down,
              color: SkuxStyle.lightColor,
            ),
        ],
      ),
      itemBuilder: (_) {
        return options.map((LocaleData e) {
          return PopupMenuItem<LocaleData>(
            value: e,
            child: Row(
              children: [
                if (selected == e) const Icon(Icons.check),
                if (selected != e) const SizedBox(width: 24),
                const SizedBox(width: 10),
                ClipRRect(
                  borderRadius: Util.radius(3),
                  child: Image.asset(
                    'packages/intl_phone_number_input/assets/flags/${e.iso}.png',
                    width: 36,
                  ),
                ),
                const SizedBox(width: 10),
                Text(e.name),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
