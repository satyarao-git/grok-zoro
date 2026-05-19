// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProjectSchemaCollection on Isar {
  IsarCollection<ProjectSchema> get projectSchemas => this.collection();
}

const ProjectSchemaSchema = CollectionSchema(
  name: r'ProjectSchema',
  id: 5854779809336245556,
  properties: {
    r'areaOfFocus': PropertySchema(
      id: 0,
      name: r'areaOfFocus',
      type: IsarType.string,
    ),
    r'completedStepCount': PropertySchema(
      id: 1,
      name: r'completedStepCount',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currentNextActionId': PropertySchema(
      id: 3,
      name: r'currentNextActionId',
      type: IsarType.string,
    ),
    r'desiredOutcome': PropertySchema(
      id: 4,
      name: r'desiredOutcome',
      type: IsarType.string,
    ),
    r'isCompleted': PropertySchema(
      id: 5,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'projectStepsJson': PropertySchema(
      id: 6,
      name: r'projectStepsJson',
      type: IsarType.stringList,
    ),
    r'stepIds': PropertySchema(
      id: 7,
      name: r'stepIds',
      type: IsarType.stringList,
    ),
    r'tags': PropertySchema(
      id: 8,
      name: r'tags',
      type: IsarType.stringList,
    ),
    r'targetCompletionDate': PropertySchema(
      id: 9,
      name: r'targetCompletionDate',
      type: IsarType.dateTime,
    ),
    r'title': PropertySchema(
      id: 10,
      name: r'title',
      type: IsarType.string,
    ),
    r'uuid': PropertySchema(
      id: 11,
      name: r'uuid',
      type: IsarType.string,
    )
  },
  estimateSize: _projectSchemaEstimateSize,
  serialize: _projectSchemaSerialize,
  deserialize: _projectSchemaDeserialize,
  deserializeProp: _projectSchemaDeserializeProp,
  idName: r'id',
  indexes: {
    r'uuid': IndexSchema(
      id: 2134397340427724972,
      name: r'uuid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'uuid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _projectSchemaGetId,
  getLinks: _projectSchemaGetLinks,
  attach: _projectSchemaAttach,
  version: '3.1.0+1',
);

int _projectSchemaEstimateSize(
  ProjectSchema object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.areaOfFocus;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.currentNextActionId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.desiredOutcome.length * 3;
  bytesCount += 3 + object.projectStepsJson.length * 3;
  {
    for (var i = 0; i < object.projectStepsJson.length; i++) {
      final value = object.projectStepsJson[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.stepIds.length * 3;
  {
    for (var i = 0; i < object.stepIds.length; i++) {
      final value = object.stepIds[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.tags.length * 3;
  {
    for (var i = 0; i < object.tags.length; i++) {
      final value = object.tags[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  {
    final value = object.uuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _projectSchemaSerialize(
  ProjectSchema object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.areaOfFocus);
  writer.writeLong(offsets[1], object.completedStepCount);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.currentNextActionId);
  writer.writeString(offsets[4], object.desiredOutcome);
  writer.writeBool(offsets[5], object.isCompleted);
  writer.writeStringList(offsets[6], object.projectStepsJson);
  writer.writeStringList(offsets[7], object.stepIds);
  writer.writeStringList(offsets[8], object.tags);
  writer.writeDateTime(offsets[9], object.targetCompletionDate);
  writer.writeString(offsets[10], object.title);
  writer.writeString(offsets[11], object.uuid);
}

ProjectSchema _projectSchemaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProjectSchema();
  object.areaOfFocus = reader.readStringOrNull(offsets[0]);
  object.completedStepCount = reader.readLong(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.currentNextActionId = reader.readStringOrNull(offsets[3]);
  object.desiredOutcome = reader.readString(offsets[4]);
  object.id = id;
  object.isCompleted = reader.readBool(offsets[5]);
  object.projectStepsJson = reader.readStringList(offsets[6]) ?? [];
  object.stepIds = reader.readStringList(offsets[7]) ?? [];
  object.tags = reader.readStringList(offsets[8]) ?? [];
  object.targetCompletionDate = reader.readDateTimeOrNull(offsets[9]);
  object.title = reader.readString(offsets[10]);
  object.uuid = reader.readStringOrNull(offsets[11]);
  return object;
}

P _projectSchemaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readStringList(offset) ?? []) as P;
    case 7:
      return (reader.readStringList(offset) ?? []) as P;
    case 8:
      return (reader.readStringList(offset) ?? []) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _projectSchemaGetId(ProjectSchema object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _projectSchemaGetLinks(ProjectSchema object) {
  return [];
}

void _projectSchemaAttach(
    IsarCollection<dynamic> col, Id id, ProjectSchema object) {
  object.id = id;
}

extension ProjectSchemaQueryWhereSort
    on QueryBuilder<ProjectSchema, ProjectSchema, QWhere> {
  QueryBuilder<ProjectSchema, ProjectSchema, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ProjectSchemaQueryWhere
    on QueryBuilder<ProjectSchema, ProjectSchema, QWhereClause> {
  QueryBuilder<ProjectSchema, ProjectSchema, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterWhereClause> idBetween(
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

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterWhereClause> uuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uuid',
        value: [null],
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterWhereClause>
      uuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'uuid',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterWhereClause> uuidEqualTo(
      String? uuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uuid',
        value: [uuid],
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterWhereClause> uuidNotEqualTo(
      String? uuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [],
              upper: [uuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [uuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [uuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [],
              upper: [uuid],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ProjectSchemaQueryFilter
    on QueryBuilder<ProjectSchema, ProjectSchema, QFilterCondition> {
  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      areaOfFocusIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'areaOfFocus',
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      areaOfFocusIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'areaOfFocus',
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      areaOfFocusEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'areaOfFocus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      areaOfFocusGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'areaOfFocus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      areaOfFocusLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'areaOfFocus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      areaOfFocusBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'areaOfFocus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      areaOfFocusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'areaOfFocus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      areaOfFocusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'areaOfFocus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      areaOfFocusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'areaOfFocus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      areaOfFocusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'areaOfFocus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      areaOfFocusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'areaOfFocus',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      areaOfFocusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'areaOfFocus',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      completedStepCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedStepCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      completedStepCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedStepCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      completedStepCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedStepCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      completedStepCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedStepCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      currentNextActionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'currentNextActionId',
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      currentNextActionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'currentNextActionId',
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      currentNextActionIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentNextActionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      currentNextActionIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentNextActionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      currentNextActionIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentNextActionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      currentNextActionIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentNextActionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      currentNextActionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'currentNextActionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      currentNextActionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'currentNextActionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      currentNextActionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currentNextActionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      currentNextActionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currentNextActionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      currentNextActionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentNextActionId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      currentNextActionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currentNextActionId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      desiredOutcomeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'desiredOutcome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      desiredOutcomeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'desiredOutcome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      desiredOutcomeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'desiredOutcome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      desiredOutcomeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'desiredOutcome',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      desiredOutcomeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'desiredOutcome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      desiredOutcomeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'desiredOutcome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      desiredOutcomeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'desiredOutcome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      desiredOutcomeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'desiredOutcome',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      desiredOutcomeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'desiredOutcome',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      desiredOutcomeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'desiredOutcome',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
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

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      isCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      projectStepsJsonElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'projectStepsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      projectStepsJsonElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'projectStepsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      projectStepsJsonElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'projectStepsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      projectStepsJsonElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'projectStepsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      projectStepsJsonElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'projectStepsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      projectStepsJsonElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'projectStepsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      projectStepsJsonElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'projectStepsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      projectStepsJsonElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'projectStepsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      projectStepsJsonElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'projectStepsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      projectStepsJsonElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'projectStepsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      projectStepsJsonLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'projectStepsJson',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      projectStepsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'projectStepsJson',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      projectStepsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'projectStepsJson',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      projectStepsJsonLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'projectStepsJson',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      projectStepsJsonLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'projectStepsJson',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      projectStepsJsonLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'projectStepsJson',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      stepIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stepIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      stepIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stepIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      stepIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stepIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      stepIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stepIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      stepIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stepIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      stepIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stepIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      stepIdsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stepIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      stepIdsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stepIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      stepIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stepIds',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      stepIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stepIds',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      stepIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'stepIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      stepIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'stepIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      stepIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'stepIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      stepIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'stepIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      stepIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'stepIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      stepIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'stepIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      tagsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      tagsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      tagsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      tagsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tags',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      tagsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      tagsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      tagsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      tagsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tags',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      tagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      tagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      tagsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      tagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      tagsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      tagsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      tagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      targetCompletionDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'targetCompletionDate',
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      targetCompletionDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'targetCompletionDate',
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      targetCompletionDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetCompletionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      targetCompletionDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetCompletionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      targetCompletionDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetCompletionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      targetCompletionDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetCompletionDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
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

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
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

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
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

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
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

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
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

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
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

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      uuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'uuid',
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      uuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'uuid',
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition> uuidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      uuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      uuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition> uuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      uuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      uuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      uuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition> uuidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterFilterCondition>
      uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uuid',
        value: '',
      ));
    });
  }
}

extension ProjectSchemaQueryObject
    on QueryBuilder<ProjectSchema, ProjectSchema, QFilterCondition> {}

extension ProjectSchemaQueryLinks
    on QueryBuilder<ProjectSchema, ProjectSchema, QFilterCondition> {}

extension ProjectSchemaQuerySortBy
    on QueryBuilder<ProjectSchema, ProjectSchema, QSortBy> {
  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy> sortByAreaOfFocus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'areaOfFocus', Sort.asc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy>
      sortByAreaOfFocusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'areaOfFocus', Sort.desc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy>
      sortByCompletedStepCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedStepCount', Sort.asc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy>
      sortByCompletedStepCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedStepCount', Sort.desc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy>
      sortByCurrentNextActionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentNextActionId', Sort.asc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy>
      sortByCurrentNextActionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentNextActionId', Sort.desc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy>
      sortByDesiredOutcome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'desiredOutcome', Sort.asc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy>
      sortByDesiredOutcomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'desiredOutcome', Sort.desc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy> sortByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy>
      sortByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy>
      sortByTargetCompletionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetCompletionDate', Sort.asc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy>
      sortByTargetCompletionDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetCompletionDate', Sort.desc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy> sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy> sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension ProjectSchemaQuerySortThenBy
    on QueryBuilder<ProjectSchema, ProjectSchema, QSortThenBy> {
  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy> thenByAreaOfFocus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'areaOfFocus', Sort.asc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy>
      thenByAreaOfFocusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'areaOfFocus', Sort.desc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy>
      thenByCompletedStepCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedStepCount', Sort.asc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy>
      thenByCompletedStepCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedStepCount', Sort.desc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy>
      thenByCurrentNextActionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentNextActionId', Sort.asc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy>
      thenByCurrentNextActionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentNextActionId', Sort.desc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy>
      thenByDesiredOutcome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'desiredOutcome', Sort.asc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy>
      thenByDesiredOutcomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'desiredOutcome', Sort.desc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy> thenByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy>
      thenByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy>
      thenByTargetCompletionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetCompletionDate', Sort.asc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy>
      thenByTargetCompletionDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetCompletionDate', Sort.desc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy> thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QAfterSortBy> thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension ProjectSchemaQueryWhereDistinct
    on QueryBuilder<ProjectSchema, ProjectSchema, QDistinct> {
  QueryBuilder<ProjectSchema, ProjectSchema, QDistinct> distinctByAreaOfFocus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'areaOfFocus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QDistinct>
      distinctByCompletedStepCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedStepCount');
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QDistinct>
      distinctByCurrentNextActionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentNextActionId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QDistinct>
      distinctByDesiredOutcome({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'desiredOutcome',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QDistinct>
      distinctByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCompleted');
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QDistinct>
      distinctByProjectStepsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'projectStepsJson');
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QDistinct> distinctByStepIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stepIds');
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QDistinct> distinctByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tags');
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QDistinct>
      distinctByTargetCompletionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetCompletionDate');
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProjectSchema, ProjectSchema, QDistinct> distinctByUuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }
}

extension ProjectSchemaQueryProperty
    on QueryBuilder<ProjectSchema, ProjectSchema, QQueryProperty> {
  QueryBuilder<ProjectSchema, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ProjectSchema, String?, QQueryOperations> areaOfFocusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'areaOfFocus');
    });
  }

  QueryBuilder<ProjectSchema, int, QQueryOperations>
      completedStepCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedStepCount');
    });
  }

  QueryBuilder<ProjectSchema, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ProjectSchema, String?, QQueryOperations>
      currentNextActionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentNextActionId');
    });
  }

  QueryBuilder<ProjectSchema, String, QQueryOperations>
      desiredOutcomeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'desiredOutcome');
    });
  }

  QueryBuilder<ProjectSchema, bool, QQueryOperations> isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCompleted');
    });
  }

  QueryBuilder<ProjectSchema, List<String>, QQueryOperations>
      projectStepsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'projectStepsJson');
    });
  }

  QueryBuilder<ProjectSchema, List<String>, QQueryOperations>
      stepIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stepIds');
    });
  }

  QueryBuilder<ProjectSchema, List<String>, QQueryOperations> tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tags');
    });
  }

  QueryBuilder<ProjectSchema, DateTime?, QQueryOperations>
      targetCompletionDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetCompletionDate');
    });
  }

  QueryBuilder<ProjectSchema, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<ProjectSchema, String?, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }
}
