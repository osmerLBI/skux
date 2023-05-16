import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:span_mobile/common/skux/skux_style.dart';

class LoadingDataTip extends StatelessWidget {
  final Widget icon;
  final String emoji;
  final bool search;
  final bool refresh;

  const LoadingDataTip({
    Key key,
    this.icon,
    this.refresh = true,
    this.search = false,
    this.emoji,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Semantics(
        child: Column(
          children: [
            if (icon != null) icon,
            if (icon == null)
              ExcludeSemantics(
                child: Text(
                  emoji ?? '😐',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            const SizedBox(height: 8),
            Semantics(
              child: Text(
                tr(search ? 'No matched result' : 'No data yet.') +
                    (!search && refresh
                        ? (' ' + tr('Pull to refresh...'))
                        : ''),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium.copyWith(
                      color: SkuxStyle.contrastGreyColor,
                    ),
              ),
            ),
          ],
        ),
        explicitChildNodes: true,
      ),
    );
  }
}
