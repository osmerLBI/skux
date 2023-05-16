// ignore_for_file: must_be_immutable, prefer_typing_uninitialized_variables, non_constant_identifier_names

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:span_mobile/common/skux/skux_style.dart';
import 'package:span_mobile/common/style.dart';
import 'package:span_mobile/common/util.dart';
import 'package:span_mobile/pages/common/const.dart';
import 'package:span_mobile/pages/common/jh_button.dart';
import 'package:span_mobile/pages/skux/auth/terms.dart';

class ClaimOfferButtonMutation extends HookWidget {
  ClaimOfferButtonMutation({
    Key key,
    this.offerUuid,
    this.buttonText,
    this.isClaimButton,
    this.isDisabled,
  }) : super(key: key);

  String offerUuid = '';
  String buttonText = '';
  bool isClaimButton = true;
  bool isDisabled = false;

  var client;

  final String ClaimOfferMutation = r'''mutation ClaimOffer($offerUuid: UUID!, $deviceId: String) {
    claimOffer(offerUUID: $offerUuid, deviceId: $deviceId) {
      ... on UserCard {
        uuid
        maskedCardNumber
        cardName
        cardImage
        status
        termsAndConditionsUrl
        accountNumber
        userPurses {
          totalItems
        }
      }
      ... on ExternalError {
        errorCode
        message
      }
      ... on ClaimPurseTask {
        uuid
        status
      }
      ... on OfferNotExistsError {
        errorCode
        message
      }
    }
  }''';

  @override
  Widget build(BuildContext context) {
    client = useGraphQLClient();

    var isClaiming = useState(false);

    return JhButton(
        onPressed: (isClaiming.value || isDisabled == true)
            ? null
            : () async {
                if (isClaimButton == false) {
                  Util.eventHub.fire(kOpenCardEvent, {'uuid': offerUuid});
                  Navigator.pop(context);
                } else {
                  isClaiming.value = true;
                  EasyLoading.show(dismissOnTap: false);

                  final QueryOptions queryOptions = QueryOptions(document: gql(r'''query NeedsTermsAndConditions($offerUuid: UUID!) {
                      needsTermsAndConditions(offerUUID: $offerUuid) {
                        ... on NeedsTermsAndConditions {
                          needsTermsAndConditions
                          termsAndConditionsUrl
                        }
                        ... on OfferNotFoundError {
                          errorCode
                          message
                        }
                        ... on OfferNotExistsError {
                          errorCode
                          message
                        }
                      }
                    }'''), variables: {
                    "offerUuid": offerUuid,
                  });

                  await client.query(queryOptions).then((value) async {
                    if (value.data['needsTermsAndConditions']['needsTermsAndConditions']) {
                      showCupertinoModalBottomSheet(
                        context: context,
                        isDismissible: false,
                        enableDrag: false,
                        expand: false,
                        backgroundColor: SkuxStyle.bgColor,
                        duration: const Duration(milliseconds: 300),
                        builder: (context) => TermsPage(
                          url: value.data['needsTermsAndConditions']['termsAndConditionsUrl'],
                          didFinishLoading: EasyLoading.dismiss,
                          onAcceptClicked: () async {
                            EasyLoading.show(dismissOnTap: false);
                            final MutationOptions mutationOptions = MutationOptions(
                              document: gql(ClaimOfferMutation),
                              variables: {
                                'offerUuid': offerUuid,
                                'deviceId': 'ImpossibleTestID',
                              },
                              onError: (error) {
                                EasyLoading.dismiss();
                              },
                            );
                            await client.mutate(mutationOptions).then((value) async {
                              if (value.hasException) {
                                EasyLoading.dismiss();
                                // @TODO: Show ERRORS and handle exception
                              } else {
                                Navigator.pop(context);
                                Util.eventHub.fire(kOpenCardEvent, {'uuid': offerUuid, 'newCard': true});
                                Util.toast('Claim Success');
                                EasyLoading.dismiss();
                              }
                              isClaiming.value = false;
                            });
                          },
                          onDeclinePressed: () {
                            Util.toast(
                              tr('Accepting the Terms & Conditions is required to claim the offer'),
                              position: EasyLoadingToastPosition.center,
                              seconds: 1.5,
                            );
                            isClaiming.value = false;
                          },
                        ),
                      );
                    }
                  });
                }
              },
        borderRadius: BorderRadius.circular(8),
        width: 182,
        height: 40,
        text: isClaiming.value ? 'Loading...' : tr(buttonText),
        fontSize: 15,
        weight: FontWeight.w600,
        color: style.primaryColor);
  }
}


                    // child: Query(
                    //   options: QueryOptions(
                    //     document: gql(r'''query NeedsTermsAndConditions($offerUuid: UUID!) {
                    //             needsTermsAndConditions(offerUUID: $offerUuid) {
                    //               ... on NeedsTermsAndConditions {
                    //                 needsTermsAndConditions
                    //                 termsAndConditionsUrl
                    //               }
                    //               ... on OfferNotFoundError {
                    //                 errorCode
                    //                 message
                    //               }
                    //               ... on OfferNotExistsError {
                    //                 errorCode
                    //                 message
                    //               }
                    //             }
                    //           }'''),
                    //     variables: {
                    //       "offerUuid": widget.offer['uuid'],
                    //     },
                    //     onComplete: (data) {
                    //       EasyLoading.dismiss();
                    //       }
                    //     },
                    //   ),
                    //   builder: (QueryResult result, {fetchMore, refetch}) {
                    //     if (result.isLoading || widget.hideButton) {
                    //       return Container();
                    //     } else {
                    //       String buttonText = (widget.offer['userCard']['__typename'] == 'UserCard') ? 'Show Card' : 'Claim Offer';
                    //       return ClaimOfferButtonMutation(
                    //         offerUuid: widget.offer['uuid'],
                    //         buttonText: buttonText,
                    //         isClaimButton: widget.offer['userCard']['__typename'] != 'UserCard',
                    //         // buttonClicked: _showCardButtonClicked,
                    //         isDisabled: _claimButtonIsDisabled,
                    //       );
                    //     }
                    //   },
                    // )),
