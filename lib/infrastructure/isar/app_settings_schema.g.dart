// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAppSettingsSchemaCollection on Isar {
  IsarCollection<AppSettingsSchema> get appSettingsSchemas => this.collection();
}

const AppSettingsSchemaSchema = CollectionSchema(
  name: r'AppSettingsSchema',
  id: 8456715016247925552,
  properties: {
    r'aiApiKey': PropertySchema(
      id: 0,
      name: r'aiApiKey',
      type: IsarType.string,
    ),
    r'aiBaseUrl': PropertySchema(
      id: 1,
      name: r'aiBaseUrl',
      type: IsarType.string,
    ),
    r'aiEnabled': PropertySchema(
      id: 2,
      name: r'aiEnabled',
      type: IsarType.bool,
    ),
    r'aiModel': PropertySchema(
      id: 3,
      name: r'aiModel',
      type: IsarType.string,
    ),
    r'defaultContextName': PropertySchema(
      id: 4,
      name: r'defaultContextName',
      type: IsarType.string,
    ),
    r'voiceCaptureEnabled': PropertySchema(
      id: 5,
      name: r'voiceCaptureEnabled',
      type: IsarType.bool,
    ),
    r'voiceLocaleId': PropertySchema(
      id: 6,
      name: r'voiceLocaleId',
      type: IsarType.string,
    ),
    r'weeklyReviewWeekday': PropertySchema(
      id: 7,
      name: r'weeklyReviewWeekday',
      type: IsarType.long,
    )
  },
  estimateSize: _appSettingsSchemaEstimateSize,
  serialize: _appSettingsSchemaSerialize,
  deserialize: _appSettingsSchemaDeserialize,
  deserializeProp: _appSettingsSchemaDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _appSettingsSchemaGetId,
  getLinks: _appSettingsSchemaGetLinks,
  attach: _appSettingsSchemaAttach,
  version: '3.1.0+1',
);

int _appSettingsSchemaEstimateSize(
  AppSettingsSchema object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.aiApiKey;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.aiBaseUrl.length * 3;
  bytesCount += 3 + object.aiModel.length * 3;
  bytesCount += 3 + object.defaultContextName.length * 3;
  {
    final value = object.voiceLocaleId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _appSettingsSchemaSerialize(
  AppSettingsSchema object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.aiApiKey);
  writer.writeString(offsets[1], object.aiBaseUrl);
  writer.writeBool(offsets[2], object.aiEnabled);
  writer.writeString(offsets[3], object.aiModel);
  writer.writeString(offsets[4], object.defaultContextName);
  writer.writeBool(offsets[5], object.voiceCaptureEnabled);
  writer.writeString(offsets[6], object.voiceLocaleId);
  writer.writeLong(offsets[7], object.weeklyReviewWeekday);
}

AppSettingsSchema _appSettingsSchemaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppSettingsSchema();
  object.aiApiKey = reader.readStringOrNull(offsets[0]);
  object.aiBaseUrl = reader.readString(offsets[1]);
  object.aiEnabled = reader.readBool(offsets[2]);
  object.aiModel = reader.readString(offsets[3]);
  object.defaultContextName = reader.readString(offsets[4]);
  object.id = id;
  object.voiceCaptureEnabled = reader.readBool(offsets[5]);
  object.voiceLocaleId = reader.readStringOrNull(offsets[6]);
  object.weeklyReviewWeekday = reader.readLong(offsets[7]);
  return object;
}

P _appSettingsSchemaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _appSettingsSchemaGetId(AppSettingsSchema object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _appSettingsSchemaGetLinks(
    AppSettingsSchema object) {
  return [];
}

void _appSettingsSchemaAttach(
    IsarCollection<dynamic> col, Id id, AppSettingsSchema object) {
  object.id = id;
}

extension AppSettingsSchemaQueryWhereSort
    on QueryBuilder<AppSettingsSchema, AppSettingsSchema, QWhere> {
  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppSettingsSchemaQueryWhere
    on QueryBuilder<AppSettingsSchema, AppSettingsSchema, QWhereClause> {
  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AppSettingsSchemaQueryFilter
    on QueryBuilder<AppSettingsSchema, AppSettingsSchema, QFilterCondition> {
  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiApiKeyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'aiApiKey',
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiApiKeyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'aiApiKey',
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiApiKeyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiApiKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiApiKeyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiApiKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiApiKeyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiApiKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiApiKeyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiApiKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiApiKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aiApiKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiApiKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aiApiKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiApiKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aiApiKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiApiKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aiApiKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiApiKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiApiKey',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiApiKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aiApiKey',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiBaseUrlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiBaseUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiBaseUrlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiBaseUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiBaseUrlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiBaseUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiBaseUrlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiBaseUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiBaseUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aiBaseUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiBaseUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aiBaseUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiBaseUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aiBaseUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiBaseUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aiBaseUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiBaseUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiBaseUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiBaseUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aiBaseUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiModelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiModelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiModelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiModelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiModel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiModelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aiModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiModelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aiModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiModelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aiModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiModelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aiModel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiModelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiModel',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      aiModelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aiModel',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      defaultContextNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'defaultContextName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      defaultContextNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'defaultContextName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      defaultContextNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'defaultContextName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      defaultContextNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'defaultContextName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      defaultContextNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'defaultContextName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      defaultContextNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'defaultContextName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      defaultContextNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'defaultContextName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      defaultContextNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'defaultContextName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      defaultContextNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'defaultContextName',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      defaultContextNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'defaultContextName',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      voiceCaptureEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'voiceCaptureEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      voiceLocaleIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'voiceLocaleId',
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      voiceLocaleIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'voiceLocaleId',
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      voiceLocaleIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'voiceLocaleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      voiceLocaleIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'voiceLocaleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      voiceLocaleIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'voiceLocaleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      voiceLocaleIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'voiceLocaleId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      voiceLocaleIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'voiceLocaleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      voiceLocaleIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'voiceLocaleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      voiceLocaleIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'voiceLocaleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      voiceLocaleIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'voiceLocaleId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      voiceLocaleIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'voiceLocaleId',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      voiceLocaleIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'voiceLocaleId',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      weeklyReviewWeekdayEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weeklyReviewWeekday',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      weeklyReviewWeekdayGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weeklyReviewWeekday',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      weeklyReviewWeekdayLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weeklyReviewWeekday',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterFilterCondition>
      weeklyReviewWeekdayBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weeklyReviewWeekday',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AppSettingsSchemaQueryObject
    on QueryBuilder<AppSettingsSchema, AppSettingsSchema, QFilterCondition> {}

extension AppSettingsSchemaQueryLinks
    on QueryBuilder<AppSettingsSchema, AppSettingsSchema, QFilterCondition> {}

extension AppSettingsSchemaQuerySortBy
    on QueryBuilder<AppSettingsSchema, AppSettingsSchema, QSortBy> {
  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      sortByAiApiKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiApiKey', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      sortByAiApiKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiApiKey', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      sortByAiBaseUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiBaseUrl', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      sortByAiBaseUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiBaseUrl', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      sortByAiEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      sortByAiEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      sortByAiModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiModel', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      sortByAiModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiModel', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      sortByDefaultContextName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultContextName', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      sortByDefaultContextNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultContextName', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      sortByVoiceCaptureEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voiceCaptureEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      sortByVoiceCaptureEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voiceCaptureEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      sortByVoiceLocaleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voiceLocaleId', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      sortByVoiceLocaleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voiceLocaleId', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      sortByWeeklyReviewWeekday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyReviewWeekday', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      sortByWeeklyReviewWeekdayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyReviewWeekday', Sort.desc);
    });
  }
}

extension AppSettingsSchemaQuerySortThenBy
    on QueryBuilder<AppSettingsSchema, AppSettingsSchema, QSortThenBy> {
  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      thenByAiApiKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiApiKey', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      thenByAiApiKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiApiKey', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      thenByAiBaseUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiBaseUrl', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      thenByAiBaseUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiBaseUrl', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      thenByAiEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      thenByAiEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      thenByAiModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiModel', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      thenByAiModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiModel', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      thenByDefaultContextName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultContextName', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      thenByDefaultContextNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultContextName', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      thenByVoiceCaptureEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voiceCaptureEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      thenByVoiceCaptureEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voiceCaptureEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      thenByVoiceLocaleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voiceLocaleId', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      thenByVoiceLocaleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voiceLocaleId', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      thenByWeeklyReviewWeekday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyReviewWeekday', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QAfterSortBy>
      thenByWeeklyReviewWeekdayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyReviewWeekday', Sort.desc);
    });
  }
}

extension AppSettingsSchemaQueryWhereDistinct
    on QueryBuilder<AppSettingsSchema, AppSettingsSchema, QDistinct> {
  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QDistinct>
      distinctByAiApiKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiApiKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QDistinct>
      distinctByAiBaseUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiBaseUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QDistinct>
      distinctByAiEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiEnabled');
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QDistinct>
      distinctByAiModel({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiModel', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QDistinct>
      distinctByDefaultContextName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'defaultContextName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QDistinct>
      distinctByVoiceCaptureEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'voiceCaptureEnabled');
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QDistinct>
      distinctByVoiceLocaleId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'voiceLocaleId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettingsSchema, AppSettingsSchema, QDistinct>
      distinctByWeeklyReviewWeekday() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weeklyReviewWeekday');
    });
  }
}

extension AppSettingsSchemaQueryProperty
    on QueryBuilder<AppSettingsSchema, AppSettingsSchema, QQueryProperty> {
  QueryBuilder<AppSettingsSchema, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AppSettingsSchema, String?, QQueryOperations>
      aiApiKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiApiKey');
    });
  }

  QueryBuilder<AppSettingsSchema, String, QQueryOperations>
      aiBaseUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiBaseUrl');
    });
  }

  QueryBuilder<AppSettingsSchema, bool, QQueryOperations> aiEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiEnabled');
    });
  }

  QueryBuilder<AppSettingsSchema, String, QQueryOperations> aiModelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiModel');
    });
  }

  QueryBuilder<AppSettingsSchema, String, QQueryOperations>
      defaultContextNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'defaultContextName');
    });
  }

  QueryBuilder<AppSettingsSchema, bool, QQueryOperations>
      voiceCaptureEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'voiceCaptureEnabled');
    });
  }

  QueryBuilder<AppSettingsSchema, String?, QQueryOperations>
      voiceLocaleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'voiceLocaleId');
    });
  }

  QueryBuilder<AppSettingsSchema, int, QQueryOperations>
      weeklyReviewWeekdayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weeklyReviewWeekday');
    });
  }
}
