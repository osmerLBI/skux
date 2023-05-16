// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skux_user_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SkuxUserStore on _SkuxUserStore, Store {
  final _$userAtom = Atom(name: '_SkuxUserStore.user');

  @override
  SkuxUser get user {
    _$userAtom.reportRead();
    return super.user;
  }

  @override
  set user(SkuxUser value) {
    _$userAtom.reportWrite(value, super.user, () {
      super.user = value;
    });
  }

  // final _$refreshUserAsyncAction = AsyncAction('_SkuxUserStore.refreshUser');

  // @override
  // Future refreshUser({bool loading = false, bool silent = true}) {
  //   return _$refreshUserAsyncAction
  //       .run(() => super.refreshUser(loading: loading, silent: silent));
  // }

  final _$_SkuxUserStoreActionController =
      ActionController(name: '_SkuxUserStore');

  @override
  void setUser(SkuxUser user) {
    final _$actionInfo = _$_SkuxUserStoreActionController.startAction(
        name: '_SkuxUserStore.setUser');
    try {
      return super.setUser(user);
    } finally {
      _$_SkuxUserStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
user: ${user}
    ''';
  }
}
