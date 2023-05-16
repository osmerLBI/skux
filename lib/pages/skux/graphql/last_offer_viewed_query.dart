// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:span_mobile/pages/common/vlog.dart';

class LastOfferViewedQueryGraphQL {
  LastOfferViewedQueryGraphQL({
    Key key,
    @required this.client,
    this.firstTime = false,
  });

  final GraphQLClient client;
  final bool firstTime;

  final String LastOfferViewedQuery = r'''
    query {
        lastOfferViewed {
          ... on Offer {
            uuid
          }
          ... on OfferNotFoundError {
            errorCode
            message
          }
          ... on OfferNotExistsError {
            errorCode
            message
          }
          __typename
        }
    }
  ''';

  Future<QueryResult> query() async {
    EasyLoading.show();
    final QueryOptions options = QueryOptions(
      document: gql(LastOfferViewedQuery),
      variables: {
        'firstTime': firstTime,
      },
      onError: (error) {
        VLog(error, tag: 'Query Last Offer Viewed Error');
        EasyLoading.dismiss();
      },
    );
    QueryResult value = await client.query(options);
    EasyLoading.dismiss();
    return value;
  }
}
