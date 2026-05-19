// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_review_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWeeklyReviewSchemaCollection on Isar {
  IsarCollection<WeeklyReviewSchema> get weeklyReviewSchemas =>
      this.collection();
}

const WeeklyReviewSchemaSchema = CollectionSchema(
  name: r'WeeklyReviewSchema',
  id: 6209743483388695326,
  properties: {
    r'completedAt': PropertySchema(
      id: 0,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'reviewedStepIds': PropertySchema(
      id: 1,
      name: r'reviewedStepIds',
      type: IsarType.stringList,
    )
  },
  estimateSize: _weeklyReviewSchemaEstimateSize,
  serialize: _weeklyReviewSchemaSerialize,
  deserialize: _weeklyReviewSchemaDeserialize,
  deserializeProp: _weeklyReviewSchemaDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _weeklyReviewSchemaGetId,
  getLinks: _weeklyReviewSchemaGetLinks,
  attach: _weeklyReviewSchemaAttach,
  version: '3.1.0+1',
);

int _weeklyReviewSchemaEstimateSize(
  WeeklyReviewSchema object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.reviewedStepIds.length * 3;
  {
    for (var i = 0; i < object.reviewedStepIds.length; i++) {
      final value = object.reviewedStepIds[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _weeklyReviewSchemaSerialize(
  WeeklyReviewSchema object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.completedAt);
  writer.writeStringList(offsets[1], object.reviewedStepIds);
}

WeeklyReviewSchema _weeklyReviewSchemaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WeeklyReviewSchema();
  object.completedAt = reader.readDateTimeOrNull(offsets[0]);
  object.id = id;
  object.reviewedStepIds = reader.readStringList(offsets[1]) ?? [];
  return object;
}

P _weeklyReviewSchemaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _weeklyReviewSchemaGetId(WeeklyReviewSchema object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _weeklyReviewSchemaGetLinks(
    WeeklyReviewSchema object) {
  return [];
}

void _weeklyReviewSchemaAttach(
    IsarCollection<dynamic> col, Id id, WeeklyReviewSchema object) {
  object.id = id;
}

extension WeeklyReviewSchemaQueryWhereSort
    on QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QWhere> {
  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension WeeklyReviewSchemaQueryWhere
    on QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QWhereClause> {
  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterWhereClause>
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

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterWhereClause>
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

extension WeeklyReviewSchemaQueryFilter
    on QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QFilterCondition> {
  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterFilterCondition>
      completedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterFilterCondition>
      completedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterFilterCondition>
      completedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterFilterCondition>
      completedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterFilterCondition>
      completedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterFilterCondition>
      completedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterFilterCondition>
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

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterFilterCondition>
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

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterFilterCondition>
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

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterFilterCondition>
      reviewedStepIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reviewedStepIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterFilterCondition>
      reviewedStepIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reviewedStepIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterFilterCondition>
      reviewedStepIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reviewedStepIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterFilterCondition>
      reviewedStepIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reviewedStepIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterFilterCondition>
      reviewedStepIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reviewedStepIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterFilterCondition>
      reviewedStepIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reviewedStepIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterFilterCondition>
      reviewedStepIdsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reviewedStepIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterFilterCondition>
      reviewedStepIdsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reviewedStepIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterFilterCondition>
      reviewedStepIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reviewedStepIds',
        value: '',
      ));
    });
  }

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterFilterCondition>
      reviewedStepIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reviewedStepIds',
        value: '',
      ));
    });
  }

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterFilterCondition>
      reviewedStepIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reviewedStepIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterFilterCondition>
      reviewedStepIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reviewedStepIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterFilterCondition>
      reviewedStepIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reviewedStepIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterFilterCondition>
      reviewedStepIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reviewedStepIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterFilterCondition>
      reviewedStepIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reviewedStepIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterFilterCondition>
      reviewedStepIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reviewedStepIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension WeeklyReviewSchemaQueryObject
    on QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QFilterCondition> {}

extension WeeklyReviewSchemaQueryLinks
    on QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QFilterCondition> {}

extension WeeklyReviewSchemaQuerySortBy
    on QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QSortBy> {
  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterSortBy>
      sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterSortBy>
      sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }
}

extension WeeklyReviewSchemaQuerySortThenBy
    on QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QSortThenBy> {
  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterSortBy>
      thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterSortBy>
      thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension WeeklyReviewSchemaQueryWhereDistinct
    on QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QDistinct> {
  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QDistinct>
      distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAt');
    });
  }

  QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QDistinct>
      distinctByReviewedStepIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reviewedStepIds');
    });
  }
}

extension WeeklyReviewSchemaQueryProperty
    on QueryBuilder<WeeklyReviewSchema, WeeklyReviewSchema, QQueryProperty> {
  QueryBuilder<WeeklyReviewSchema, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WeeklyReviewSchema, DateTime?, QQueryOperations>
      completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAt');
    });
  }

  QueryBuilder<WeeklyReviewSchema, List<String>, QQueryOperations>
      reviewedStepIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reviewedStepIds');
    });
  }
}
