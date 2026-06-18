// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_blob.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetVaultBlobCollection on Isar {
  IsarCollection<VaultBlob> get vaultBlobs => this.collection();
}

const VaultBlobSchema = CollectionSchema(
  name: r'VaultBlob',
  id: 5898254163327596898,
  properties: {
    r'ciphertextBase64': PropertySchema(
      id: 0,
      name: r'ciphertextBase64',
      type: IsarType.string,
    ),
    r'encryptionSalt': PropertySchema(
      id: 1,
      name: r'encryptionSalt',
      type: IsarType.string,
    ),
    r'schemaVersion': PropertySchema(
      id: 2,
      name: r'schemaVersion',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 3,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _vaultBlobEstimateSize,
  serialize: _vaultBlobSerialize,
  deserialize: _vaultBlobDeserialize,
  deserializeProp: _vaultBlobDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _vaultBlobGetId,
  getLinks: _vaultBlobGetLinks,
  attach: _vaultBlobAttach,
  version: '3.1.0+1',
);

int _vaultBlobEstimateSize(
  VaultBlob object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.ciphertextBase64.length * 3;
  bytesCount += 3 + object.encryptionSalt.length * 3;
  return bytesCount;
}

void _vaultBlobSerialize(
  VaultBlob object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.ciphertextBase64);
  writer.writeString(offsets[1], object.encryptionSalt);
  writer.writeLong(offsets[2], object.schemaVersion);
  writer.writeDateTime(offsets[3], object.updatedAt);
}

VaultBlob _vaultBlobDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VaultBlob();
  object.ciphertextBase64 = reader.readString(offsets[0]);
  object.encryptionSalt = reader.readString(offsets[1]);
  object.id = id;
  object.schemaVersion = reader.readLong(offsets[2]);
  object.updatedAt = reader.readDateTime(offsets[3]);
  return object;
}

P _vaultBlobDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _vaultBlobGetId(VaultBlob object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _vaultBlobGetLinks(VaultBlob object) {
  return [];
}

void _vaultBlobAttach(IsarCollection<dynamic> col, Id id, VaultBlob object) {
  object.id = id;
}

extension VaultBlobQueryWhereSort
    on QueryBuilder<VaultBlob, VaultBlob, QWhere> {
  QueryBuilder<VaultBlob, VaultBlob, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension VaultBlobQueryWhere
    on QueryBuilder<VaultBlob, VaultBlob, QWhereClause> {
  QueryBuilder<VaultBlob, VaultBlob, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<VaultBlob, VaultBlob, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterWhereClause> idBetween(
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

extension VaultBlobQueryFilter
    on QueryBuilder<VaultBlob, VaultBlob, QFilterCondition> {
  QueryBuilder<VaultBlob, VaultBlob, QAfterFilterCondition>
      ciphertextBase64EqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ciphertextBase64',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterFilterCondition>
      ciphertextBase64GreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ciphertextBase64',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterFilterCondition>
      ciphertextBase64LessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ciphertextBase64',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterFilterCondition>
      ciphertextBase64Between(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ciphertextBase64',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterFilterCondition>
      ciphertextBase64StartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ciphertextBase64',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterFilterCondition>
      ciphertextBase64EndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ciphertextBase64',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterFilterCondition>
      ciphertextBase64Contains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ciphertextBase64',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterFilterCondition>
      ciphertextBase64Matches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ciphertextBase64',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterFilterCondition>
      ciphertextBase64IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ciphertextBase64',
        value: '',
      ));
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterFilterCondition>
      ciphertextBase64IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ciphertextBase64',
        value: '',
      ));
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterFilterCondition>
      encryptionSaltEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'encryptionSalt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterFilterCondition>
      encryptionSaltGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'encryptionSalt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterFilterCondition>
      encryptionSaltLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'encryptionSalt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterFilterCondition>
      encryptionSaltBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'encryptionSalt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterFilterCondition>
      encryptionSaltStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'encryptionSalt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterFilterCondition>
      encryptionSaltEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'encryptionSalt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterFilterCondition>
      encryptionSaltContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'encryptionSalt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterFilterCondition>
      encryptionSaltMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'encryptionSalt',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterFilterCondition>
      encryptionSaltIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'encryptionSalt',
        value: '',
      ));
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterFilterCondition>
      encryptionSaltIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'encryptionSalt',
        value: '',
      ));
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<VaultBlob, VaultBlob, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<VaultBlob, VaultBlob, QAfterFilterCondition> idBetween(
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

  QueryBuilder<VaultBlob, VaultBlob, QAfterFilterCondition>
      schemaVersionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schemaVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterFilterCondition>
      schemaVersionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'schemaVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterFilterCondition>
      schemaVersionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'schemaVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterFilterCondition>
      schemaVersionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'schemaVersion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterFilterCondition> updatedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension VaultBlobQueryObject
    on QueryBuilder<VaultBlob, VaultBlob, QFilterCondition> {}

extension VaultBlobQueryLinks
    on QueryBuilder<VaultBlob, VaultBlob, QFilterCondition> {}

extension VaultBlobQuerySortBy on QueryBuilder<VaultBlob, VaultBlob, QSortBy> {
  QueryBuilder<VaultBlob, VaultBlob, QAfterSortBy> sortByCiphertextBase64() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ciphertextBase64', Sort.asc);
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterSortBy>
      sortByCiphertextBase64Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ciphertextBase64', Sort.desc);
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterSortBy> sortByEncryptionSalt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptionSalt', Sort.asc);
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterSortBy> sortByEncryptionSaltDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptionSalt', Sort.desc);
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterSortBy> sortBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterSortBy> sortBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension VaultBlobQuerySortThenBy
    on QueryBuilder<VaultBlob, VaultBlob, QSortThenBy> {
  QueryBuilder<VaultBlob, VaultBlob, QAfterSortBy> thenByCiphertextBase64() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ciphertextBase64', Sort.asc);
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterSortBy>
      thenByCiphertextBase64Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ciphertextBase64', Sort.desc);
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterSortBy> thenByEncryptionSalt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptionSalt', Sort.asc);
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterSortBy> thenByEncryptionSaltDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptionSalt', Sort.desc);
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterSortBy> thenBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterSortBy> thenBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension VaultBlobQueryWhereDistinct
    on QueryBuilder<VaultBlob, VaultBlob, QDistinct> {
  QueryBuilder<VaultBlob, VaultBlob, QDistinct> distinctByCiphertextBase64(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ciphertextBase64',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QDistinct> distinctByEncryptionSalt(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'encryptionSalt',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QDistinct> distinctBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schemaVersion');
    });
  }

  QueryBuilder<VaultBlob, VaultBlob, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension VaultBlobQueryProperty
    on QueryBuilder<VaultBlob, VaultBlob, QQueryProperty> {
  QueryBuilder<VaultBlob, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<VaultBlob, String, QQueryOperations> ciphertextBase64Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ciphertextBase64');
    });
  }

  QueryBuilder<VaultBlob, String, QQueryOperations> encryptionSaltProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'encryptionSalt');
    });
  }

  QueryBuilder<VaultBlob, int, QQueryOperations> schemaVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schemaVersion');
    });
  }

  QueryBuilder<VaultBlob, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
