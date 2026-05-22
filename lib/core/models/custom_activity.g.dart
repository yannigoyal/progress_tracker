// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_activity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCustomActivityCollection on Isar {
  IsarCollection<CustomActivity> get customActivitys => this.collection();
}

const CustomActivitySchema = CollectionSchema(
  name: r'CustomActivity',
  id: -8259564944563054362,
  properties: {
    r'colorValue': PropertySchema(
      id: 0,
      name: r'colorValue',
      type: IsarType.long,
    ),
    r'customIconPath': PropertySchema(
      id: 1,
      name: r'customIconPath',
      type: IsarType.string,
    ),
    r'enabledFields': PropertySchema(
      id: 2,
      name: r'enabledFields',
      type: IsarType.stringList,
    ),
    r'fieldLabelsJson': PropertySchema(
      id: 3,
      name: r'fieldLabelsJson',
      type: IsarType.string,
    ),
    r'iconCodePoint': PropertySchema(
      id: 4,
      name: r'iconCodePoint',
      type: IsarType.long,
    ),
    r'name': PropertySchema(
      id: 5,
      name: r'name',
      type: IsarType.string,
    ),
    r'sortOrder': PropertySchema(
      id: 6,
      name: r'sortOrder',
      type: IsarType.long,
    )
  },
  estimateSize: _customActivityEstimateSize,
  serialize: _customActivitySerialize,
  deserialize: _customActivityDeserialize,
  deserializeProp: _customActivityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _customActivityGetId,
  getLinks: _customActivityGetLinks,
  attach: _customActivityAttach,
  version: '3.1.0+1',
);

int _customActivityEstimateSize(
  CustomActivity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.customIconPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.enabledFields.length * 3;
  {
    for (var i = 0; i < object.enabledFields.length; i++) {
      final value = object.enabledFields[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.fieldLabelsJson.length * 3;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _customActivitySerialize(
  CustomActivity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.colorValue);
  writer.writeString(offsets[1], object.customIconPath);
  writer.writeStringList(offsets[2], object.enabledFields);
  writer.writeString(offsets[3], object.fieldLabelsJson);
  writer.writeLong(offsets[4], object.iconCodePoint);
  writer.writeString(offsets[5], object.name);
  writer.writeLong(offsets[6], object.sortOrder);
}

CustomActivity _customActivityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CustomActivity();
  object.colorValue = reader.readLong(offsets[0]);
  object.customIconPath = reader.readStringOrNull(offsets[1]);
  object.enabledFields = reader.readStringList(offsets[2]) ?? [];
  object.fieldLabelsJson = reader.readString(offsets[3]);
  object.iconCodePoint = reader.readLong(offsets[4]);
  object.id = id;
  object.name = reader.readString(offsets[5]);
  object.sortOrder = reader.readLong(offsets[6]);
  return object;
}

P _customActivityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _customActivityGetId(CustomActivity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _customActivityGetLinks(CustomActivity object) {
  return [];
}

void _customActivityAttach(
    IsarCollection<dynamic> col, Id id, CustomActivity object) {
  object.id = id;
}

extension CustomActivityQueryWhereSort
    on QueryBuilder<CustomActivity, CustomActivity, QWhere> {
  QueryBuilder<CustomActivity, CustomActivity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CustomActivityQueryWhere
    on QueryBuilder<CustomActivity, CustomActivity, QWhereClause> {
  QueryBuilder<CustomActivity, CustomActivity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<CustomActivity, CustomActivity, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterWhereClause> idBetween(
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

extension CustomActivityQueryFilter
    on QueryBuilder<CustomActivity, CustomActivity, QFilterCondition> {
  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      colorValueEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'colorValue',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      colorValueGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'colorValue',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      colorValueLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'colorValue',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      colorValueBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'colorValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      customIconPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'customIconPath',
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      customIconPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'customIconPath',
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      customIconPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customIconPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      customIconPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'customIconPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      customIconPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'customIconPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      customIconPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'customIconPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      customIconPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'customIconPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      customIconPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'customIconPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      customIconPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'customIconPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      customIconPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'customIconPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      customIconPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customIconPath',
        value: '',
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      customIconPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'customIconPath',
        value: '',
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      enabledFieldsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enabledFields',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      enabledFieldsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'enabledFields',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      enabledFieldsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'enabledFields',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      enabledFieldsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'enabledFields',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      enabledFieldsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'enabledFields',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      enabledFieldsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'enabledFields',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      enabledFieldsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'enabledFields',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      enabledFieldsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'enabledFields',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      enabledFieldsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enabledFields',
        value: '',
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      enabledFieldsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'enabledFields',
        value: '',
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      enabledFieldsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'enabledFields',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      enabledFieldsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'enabledFields',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      enabledFieldsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'enabledFields',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      enabledFieldsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'enabledFields',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      enabledFieldsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'enabledFields',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      enabledFieldsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'enabledFields',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      fieldLabelsJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fieldLabelsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      fieldLabelsJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fieldLabelsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      fieldLabelsJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fieldLabelsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      fieldLabelsJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fieldLabelsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      fieldLabelsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fieldLabelsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      fieldLabelsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fieldLabelsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      fieldLabelsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fieldLabelsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      fieldLabelsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fieldLabelsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      fieldLabelsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fieldLabelsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      fieldLabelsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fieldLabelsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      iconCodePointEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iconCodePoint',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      iconCodePointGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'iconCodePoint',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      iconCodePointLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'iconCodePoint',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      iconCodePointBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'iconCodePoint',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
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

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
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

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      sortOrderEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      sortOrderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      sortOrderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterFilterCondition>
      sortOrderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sortOrder',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CustomActivityQueryObject
    on QueryBuilder<CustomActivity, CustomActivity, QFilterCondition> {}

extension CustomActivityQueryLinks
    on QueryBuilder<CustomActivity, CustomActivity, QFilterCondition> {}

extension CustomActivityQuerySortBy
    on QueryBuilder<CustomActivity, CustomActivity, QSortBy> {
  QueryBuilder<CustomActivity, CustomActivity, QAfterSortBy>
      sortByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.asc);
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterSortBy>
      sortByColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.desc);
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterSortBy>
      sortByCustomIconPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customIconPath', Sort.asc);
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterSortBy>
      sortByCustomIconPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customIconPath', Sort.desc);
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterSortBy>
      sortByFieldLabelsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fieldLabelsJson', Sort.asc);
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterSortBy>
      sortByFieldLabelsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fieldLabelsJson', Sort.desc);
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterSortBy>
      sortByIconCodePoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCodePoint', Sort.asc);
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterSortBy>
      sortByIconCodePointDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCodePoint', Sort.desc);
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterSortBy> sortBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterSortBy>
      sortBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }
}

extension CustomActivityQuerySortThenBy
    on QueryBuilder<CustomActivity, CustomActivity, QSortThenBy> {
  QueryBuilder<CustomActivity, CustomActivity, QAfterSortBy>
      thenByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.asc);
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterSortBy>
      thenByColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.desc);
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterSortBy>
      thenByCustomIconPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customIconPath', Sort.asc);
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterSortBy>
      thenByCustomIconPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customIconPath', Sort.desc);
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterSortBy>
      thenByFieldLabelsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fieldLabelsJson', Sort.asc);
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterSortBy>
      thenByFieldLabelsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fieldLabelsJson', Sort.desc);
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterSortBy>
      thenByIconCodePoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCodePoint', Sort.asc);
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterSortBy>
      thenByIconCodePointDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCodePoint', Sort.desc);
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterSortBy> thenBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QAfterSortBy>
      thenBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }
}

extension CustomActivityQueryWhereDistinct
    on QueryBuilder<CustomActivity, CustomActivity, QDistinct> {
  QueryBuilder<CustomActivity, CustomActivity, QDistinct>
      distinctByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'colorValue');
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QDistinct>
      distinctByCustomIconPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'customIconPath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QDistinct>
      distinctByEnabledFields() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enabledFields');
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QDistinct>
      distinctByFieldLabelsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fieldLabelsJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QDistinct>
      distinctByIconCodePoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'iconCodePoint');
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CustomActivity, CustomActivity, QDistinct>
      distinctBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortOrder');
    });
  }
}

extension CustomActivityQueryProperty
    on QueryBuilder<CustomActivity, CustomActivity, QQueryProperty> {
  QueryBuilder<CustomActivity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CustomActivity, int, QQueryOperations> colorValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'colorValue');
    });
  }

  QueryBuilder<CustomActivity, String?, QQueryOperations>
      customIconPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'customIconPath');
    });
  }

  QueryBuilder<CustomActivity, List<String>, QQueryOperations>
      enabledFieldsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enabledFields');
    });
  }

  QueryBuilder<CustomActivity, String, QQueryOperations>
      fieldLabelsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fieldLabelsJson');
    });
  }

  QueryBuilder<CustomActivity, int, QQueryOperations> iconCodePointProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'iconCodePoint');
    });
  }

  QueryBuilder<CustomActivity, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<CustomActivity, int, QQueryOperations> sortOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortOrder');
    });
  }
}
