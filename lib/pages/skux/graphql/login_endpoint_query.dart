// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:span_mobile/pages/common/vlog.dart';

class LoginEndpointGraphQL {
  LoginEndpointGraphQL({
    Key key,
    @required this.client,
  });
  final GraphQLClient client;
  final String LoginEndpointQuery = r'''query {
        getLoginEndpoint {
          __typename,
          ... on LoginEndpointResponse {
            URL
          }
        }
      }
  ''';

  Future<QueryResult> query() async {
    EasyLoading.show();
    final QueryOptions options = QueryOptions(
      document: gql(LoginEndpointQuery),
      onError: (error) {
        VLog(error, tag: 'Query Login Endpoint Error');
        EasyLoading.dismiss();
      },
    );
    final value = await client.query(options);
    EasyLoading.dismiss();
    VLog(value, tag: 'Query Login Endpoint Complete');
    return value;
  }
}
