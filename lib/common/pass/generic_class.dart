import 'package:uuid/uuid.dart';

class GenericClass {
  static String _passId = const Uuid().v4();
  static const String _passClass = 'skux';
  static const String _issuerId = '3388000000022226545';
  static const String _issuerEmail =
      'osmer-services@decoded-nebula-385812.iam.gserviceaccount.com';
  String imageFooter = '';
  String description = '';
  String expires = '';
  String offerUUID = '';
  Map userCard;
  GenericClass(this.description, this.expires, this.imageFooter, this.offerUUID,
      this.userCard);

  String getPass() {
    String accountNumber = userCard['accountNumber'];
    String _examplePass = """ 
    {
        "iss": "$_issuerEmail",
        "aud": "google",
        "typ": "savetowallet",
        "origins": [],
        "payload": {
          "genericObjects": [
            {
              "id": "$_issuerId.$accountNumber.$_passId",
              "classId": "$_issuerId.$_passClass",
              "logo": {
                "sourceUri": {
                  "uri": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTq7Un_FXwWPhLTaDovpYxvrUHTTNawLWE-tm3Aj_yOL_nn9KYNf2SSD8Y4h9uiPA2VIQM&usqp=CAU"
                },
                "contentDescription": {
                  "defaultValue": {
                    "language": "en",
                    "value": "LOGO_IMAGE_DESCRIPTION"
                  }
                }
              },
              "cardTitle": {
                "defaultValue": {
                  "language": "en",
                  "value": "Walmart NFC"
                }
              },
              "subheader": {
                "defaultValue": {
                  "language": "en",
                  "value": "Card Number"
                }
              },
              "header": {
                "defaultValue": {
                  "language": "en",
                  "value": "$accountNumber"
                }
              },
              "textModulesData": [
                {
                  "id": "balance",
                  "header": "Balance",
                  "body": "\$899.18"
                },
                {
                  "id": "powerd_by_",
                  "header": "Powerd by ",
                  "body": "SKUx"
                },
                {
                  "id": "offer",
                  "header": "Offer",
                  "body": "$description"
                },
                {
                  "id": "valid_till",
                  "header": "Valid till",
                  "body": "$expires"
                }
              ],
              "barcode": {
                "type": "QR_CODE",
                "value": "$offerUUID",
                "alternateText": ""
              },
              "hexBackgroundColor": "#4285f4",
              "heroImage": {
                "sourceUri": {
                  "uri": "$imageFooter"
                },
                "contentDescription": {
                  "defaultValue": {
                    "language": "en",
                    "value": "HERO_IMAGE_DESCRIPTION"
                  }
                }
              }
            }
          ]
        }
      }
""";
    return _examplePass;
  }
}
