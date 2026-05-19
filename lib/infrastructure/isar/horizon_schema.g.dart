// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'horizon_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetHorizonSchemaCollection on Isar {
  IsarCollection<HorizonSchema> get horizonSchemas => this.collection();
}

const HorizonSchemaSchema = CollectionSchema(
  name: r'HorizonSchema',
  id: -2488930966482321670,
  properties: {
    r'alignmentScore': PropertySchema(
      id: 0,
      name: r'alignmentScore',
      type: IsarType.double,
    ),
    r'description': PropertySchema(
      id: 1,
      name: r'description',
      type: IsarType.string,
    ),
    r'levelName': PropertySchema(
      id: 2,
      name: r'levelName',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 3,
      name: r'title',
      type: IsarType.string,
    )
  },
  estimateSize: _horizonSchemaEstimateSize,
  serialize: _horizonSchemaSerialize,
  deserialize: _horizonSchemaDeserialize,
  deserializeProp: _horizonSchemaDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _horizonSchemaGetId,
  getLinks: _horizonSchemaGetLinks,
  attach: _horizonSchemaAttach,
  version: '3.1.0+1',
);

int _horizonSchemaEstimateSize(
  HorizonSchema object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.description.length * 3;
  bytesCount += 3 + object.levelName.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _horizonSchemaSerialize(
  HorizonSchema object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.alignmentScore);
  writer.writeString(offsets[1], object.description);
  writer.writeString(offsets[2], object.levelName);
  writer.writeString(offsets[3], object.title);
}

HorizonSchema _horizonSchemaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = HorizonSchema();
  object.alignmentScore = reader.readDoubleOrNull(offsets[0]);
  object.description = reader.readString(offsets[1]);
  object.id = id;
  object.levelName = reader.readString(offsets[2]);
  object.title = reader.readString(offsets[3]);
  return object;
}

P _horizonSchemaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _horizonSchemaGetId(HorizonSchema object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _horizonSchemaGetLinks(HorizonSchema object) {
  return [];
}

void _horizonSchemaAttach(
    IsarCollection<dynamic> col, Id id, HorizonSchema object) {
  object.id = id;
}

extension HorizonSchemaQueryWhereSort
    on QueryBuilder<HorizonSchema, HorizonSchema, QWhere> {
  QueryBuilder<HorizonSchema, HorizonSchema, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension HorizonSchemaQueryWhere
    on QueryBuilder<HorizonSchema, HorizonSchema, QWhereClause> {
  QueryBuilder<HorizonSchema, HorizonSchema, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterWhereClause> idBetween(
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

extension HorizonSchemaQueryFilter
    on QueryBuilder<HorizonSchema, HorizonSchema, QFilterCondition> {
  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      alignmentScoreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'alignmentScore',
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      alignmentScoreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'alignmentScore',
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      alignmentScoreEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'alignmentScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      alignmentScoreGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'alignmentScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      alignmentScoreLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'alignmentScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      alignmentScoreBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'alignmentScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      descriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
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

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition> idBetween(
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

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      levelNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'levelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      levelNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'levelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      levelNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'levelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      levelNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'levelName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      levelNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'levelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      levelNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'levelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      levelNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'levelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      levelNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'levelName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      levelNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'levelName',
        value: '',
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      levelNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'levelName',
        value: '',
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }
}

extension HorizonSchemaQueryObject
    on QueryBuilder<HorizonSchema, HorizonSchema, QFilterCondition> {}

extension HorizonSchemaQueryLinks
    on QueryBuilder<HorizonSchema, HorizonSchema, QFilterCondition> {}

extension HorizonSchemaQuerySortBy
    on QueryBuilder<HorizonSchema, HorizonSchema, QSortBy> {
  QueryBuilder<HorizonSchema, HorizonSchema, QAfterSortBy>
      sortByAlignmentScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alignmentScore', Sort.asc);
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterSortBy>
      sortByAlignmentScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alignmentScore', Sort.desc);
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterSortBy> sortByLevelName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'levelName', Sort.asc);
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterSortBy>
      sortByLevelNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'levelName', Sort.desc);
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension HorizonSchemaQuerySortThenBy
    on QueryBuilder<HorizonSchema, HorizonSchema, QSortThenBy> {
  QueryBuilder<HorizonSchema, HorizonSchema, QAfterSortBy>
      thenByAlignmentScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alignmentScore', Sort.asc);
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterSortBy>
      thenByAlignmentScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alignmentScore', Sort.desc);
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterSortBy> thenByLevelName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'levelName', Sort.asc);
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterSortBy>
      thenByLevelNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'levelName', Sort.desc);
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension HorizonSchemaQueryWhereDistinct
    on QueryBuilder<HorizonSchema, HorizonSchema, QDistinct> {
  QueryBuilder<HorizonSchema, HorizonSchema, QDistinct>
      distinctByAlignmentScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'alignmentScore');
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QDistinct> distinctByLevelName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'levelName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HorizonSchema, HorizonSchema, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension HorizonSchemaQueryProperty
    on QueryBuilder<HorizonSchema, HorizonSchema, QQueryProperty> {
  QueryBuilder<HorizonSchema, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<HorizonSchema, double?, QQueryOperations>
      alignmentScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'alignmentScore');
    });
  }

  QueryBuilder<HorizonSchema, String, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<HorizonSchema, String, QQueryOperations> levelNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'levelName');
    });
  }

  QueryBuilder<HorizonSchema, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}
