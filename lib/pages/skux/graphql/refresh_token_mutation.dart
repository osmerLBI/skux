// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:span_mobile/pages/common/vlog.dart';

class RefreshTokenGraphQL {
  RefreshTokenGraphQL({
    Key key,
    @required this.client,
  });
  final GraphQLClient client;
  final String RefreshTokenMutation = r'''mutation RefreshToken($refreshToken: String!) {
          refreshToken(refreshToken: $refreshToken) {
            ... on RefreshTokenSuccess {
              success
            }
            ... on RefreshTokenExpired {
              errorCode
              message
            }
            ... on RefreshTokenInvalid {
              errorCode
              message
            }
          }
        }
      ''';

  Future<QueryResult> mutation(refreshToken) async {
    final MutationOptions options = MutationOptions(
      document: gql(RefreshTokenMutation),
      variables: {
        "refreshToken": refreshToken,
      },
      onError: (error) {
        VLog(error, tag: 'Mutation RefreshToken Error');
        EasyLoading.dismiss();
      },
    );
    QueryResult value = await client.mutate(options);
    return value;
  }
}
