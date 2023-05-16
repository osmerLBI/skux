import 'package:mobx/mobx.dart';
import 'package:span_mobile/models/Skux/user.dart';

part 'skux_user_store.g.dart';

class SkuxUserStore = _SkuxUserStore with _$SkuxUserStore;

final SkuxUserStore userStore = SkuxUserStore();

abstract class _SkuxUserStore with Store {
  @observable
  SkuxUser user = SkuxUser();

  @action
  void setUser(SkuxUser user) {
    this.user = user;
  }

  // @action
  // refreshUser({bool loading = false, bool silent = true}) async {
  //   DioResponse resp = await Util.dioRequest(
  //       url: SKUxAPI.profileUrl,
  //       method: 'get',
  //       loading: loading,
  //       silent: silent);
  //   if (resp.success) {
  //     user = SkuxUser.fromJson(resp.data);

  //     if (SkuxInfo.hasClaimedOfferSuccess == false &&
  //         resp.data['everClaimedOffer'] == true) {
  //       SkuxInfo.hasClaimedOfferSuccess = resp.data['everClaimedOffer'];
  //       Util.eventHub.fire(kShowOpenPageEvent);
  //     }
  //   }
  // }
}
