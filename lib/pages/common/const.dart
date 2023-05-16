// event

import 'package:flutter/material.dart';
import 'package:span_mobile/common/util.dart';

const kSpendrPosAcceptPaymentStep = "spendr_pos_accept_payment_step";
const kSpendrPosManualPushPaymentStep = "spendr_pos_manual_push_payment_step";
const kSpendrPosManuallyAcceptPaymentConfirmationStep =
    "spendr_pos_manually_accept_payment_confirmation_step";
const kSpendrPosAcceptPaymentEvent = "spendr_pos_accept_payment_event";
const kCreatePinEvent = 'create_pin_event';
const kBiometricsKey = 'biometrics_login';
const kConsumerPinEnableKey = 'consumer_pin_enable';
double kSafeAreaBottomInset = MediaQuery.of(Util.context).padding.bottom;
double kSafeAreaTopInset = MediaQuery.of(Util.context).padding.top;
double kScreenW = MediaQuery.of(Util.context).size.width;
double kScreenH = MediaQuery.of(Util.context).size.height;
String kAppType = 'appType';
const kTransactionStatusCompleted = 'Completed';
const kTransactionStatusPending = 'Pending';
const kTransactionStatusCancelled = 'Cancelled';
const kLoadAccountTypePassport = 'Passport';
const kLoadAccountTypeDriverLicense = 'Driver\'s License';
const kDepositErrorStatus = 'error';
const kStartCheckLatestPendingTransactionForConsumerEvent =
    'start_check_latest_pending_transaction_for_consumer_event';
const kStartCheckTransactionStatusForMerchantEvent =
    'start_check_transaction_status_for_merchant_event';
const kEndCheckLatestPendingTransactionForConsumerEvent =
    'end_check_latest_pending_transaction_for_consumer_event';
const kEndCheckTransactionStatusForMerchantEvent =
    'end_check_transaction_status_for_merchant_event';
const kChooseLocationCompleteEvent = 'choose_location_complete_event';
const kRefreshSkuxProfileEvent = 'refresh_skux_profile_event';
const kAcceptTermEvent = 'accept_term_event';
const kDefaultUserName = 'SKUx User';
const kRecentViewedKey = 'recent_viewed_key';
const kOpenCardEvent = 'open_card_event';
const kShowOpenPageEvent = 'show_open_page_event';
const kRefreshTokenAfterSocialLoginEvent =
    'refresh_token_after_social_login_event';
const kClaimOfferSuccessEvent = 'claim_offer_success_event';
