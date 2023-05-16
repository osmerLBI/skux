import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class FbValidators extends FormBuilderValidators {
  static FormFieldValidator<T> compose<T>(
      List<FormFieldValidator<T>> validators) {
    return FormBuilderValidators.compose(validators);
  }

  static FormFieldValidator required(
    BuildContext context, {
    String errorText = 'This field cannot be empty.',
  }) {
    return FormBuilderValidators.required(context, errorText: tr(errorText));
  }

  static FormFieldValidator min(
    BuildContext context,
    num min, {
    String errorText,
  }) {
    return FormBuilderValidators.min(
      context,
      min,
      errorText: tr('Value must be greater than or equal to {n}', namedArgs: {
        'n': min.toString(),
      }),
    );
  }

  static FormFieldValidator max(
    BuildContext context,
    num max, {
    String errorText,
  }) {
    return FormBuilderValidators.max(
      context,
      max,
      errorText: tr('Value must be less than or equal to {n}', namedArgs: {
        'n': max.toString(),
      }),
    );
  }

  static FormFieldValidator<String> minLength(
    BuildContext context,
    num minLength, {
    bool allowEmpty = false,
    String errorText,
  }) {
    return FormBuilderValidators.minLength(
      context,
      minLength,
      allowEmpty: allowEmpty,
      errorText: tr(
        'Value must have a length greater than or equal to {n}',
        namedArgs: {
          'n': minLength.toString(),
        },
      ),
    );
  }

  static FormFieldValidator<String> maxLength(
    BuildContext context,
    num maxLength, {
    String errorText,
  }) {
    return FormBuilderValidators.maxLength(
      context,
      maxLength,
      errorText: tr(
        'Value must have a length less than or equal to {n}',
        namedArgs: {
          'n': maxLength.toString(),
        },
      ),
    );
  }

  static FormFieldValidator<String> email(
    BuildContext context, {
    String errorText = 'This field requires a valid email address.',
  }) {
    return FormBuilderValidators.email(context, errorText: tr(errorText));
  }

  static FormFieldValidator<String> url(
    BuildContext context, {
    String errorText = 'This field requires a valid URL address.',
    List<String> protocols = const ['http', 'https', 'ftp'],
    bool requireTld = true,
    bool requireProtocol = false,
    bool allowUnderscore = false,
    List<String> hostWhitelist = const [],
    List<String> hostBlacklist = const [],
  }) {
    return FormBuilderValidators.url(
      context,
      errorText: tr(errorText),
      protocols: protocols,
      requireTld: requireTld,
      requireProtocol: requireProtocol,
      allowUnderscore: allowUnderscore,
      hostWhitelist: hostWhitelist,
      hostBlacklist: hostBlacklist,
    );
  }

  static FormFieldValidator<String> match(
    BuildContext context,
    Pattern pattern, {
    String errorText = 'Value does not match pattern.',
  }) {
    return FormBuilderValidators.match(
      context,
      pattern,
      errorText: tr(errorText),
    );
  }

  static FormFieldValidator<String> numeric(
    BuildContext context, {
    String errorText = 'Value must be numeric.',
  }) {
    return FormBuilderValidators.numeric(context, errorText: tr(errorText));
  }

  static FormFieldValidator<String> creditCard(
    BuildContext context, {
    String errorText = 'This field requires a valid credit card number.',
  }) {
    return FormBuilderValidators.creditCard(context, errorText: tr(errorText));
  }

  static FormFieldValidator<String> ip(
    BuildContext context, {
    dynamic version,
    String errorText = 'This field requires a valid IP.',
  }) {
    return FormBuilderValidators.ip(
      context,
      version: version,
      errorText: tr(errorText),
    );
  }

  static FormFieldValidator<String> dateString(
    BuildContext context, {
    String errorText = 'This field requires a valid date string.',
  }) {
    return FormBuilderValidators.dateString(context, errorText: tr(errorText));
  }
}
