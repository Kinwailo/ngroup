// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetServerCollection on Isar {
  IsarCollection<Server> get servers => this.collection();
}

const ServerSchema = CollectionSchema(
  name: r'Server',
  id: -6947657830638655508,
  properties: {
    r'address': PropertySchema(
      id: 0,
      name: r'address',
      type: IsarType.string,
    ),
    r'password': PropertySchema(
      id: 1,
      name: r'password',
      type: IsarType.string,
    ),
    r'port': PropertySchema(
      id: 2,
      name: r'port',
      type: IsarType.long,
    ),
    r'secure': PropertySchema(
      id: 3,
      name: r'secure',
      type: IsarType.bool,
    ),
    r'user': PropertySchema(
      id: 4,
      name: r'user',
      type: IsarType.string,
    )
  },
  estimateSize: _serverEstimateSize,
  serialize: _serverSerialize,
  deserialize: _serverDeserialize,
  deserializeProp: _serverDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _serverGetId,
  getLinks: _serverGetLinks,
  attach: _serverAttach,
  version: '3.1.0+1',
);

int _serverEstimateSize(
  Server object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.address.length * 3;
  {
    final value = object.password;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.user;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _serverSerialize(
  Server object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.address);
  writer.writeString(offsets[1], object.password);
  writer.writeLong(offsets[2], object.port);
  writer.writeBool(offsets[3], object.secure);
  writer.writeString(offsets[4], object.user);
}

Server _serverDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Server();
  object.address = reader.readString(offsets[0]);
  object.id = id;
  object.password = reader.readStringOrNull(offsets[1]);
  object.port = reader.readLong(offsets[2]);
  object.secure = reader.readBool(offsets[3]);
  object.user = reader.readStringOrNull(offsets[4]);
  return object;
}

P _serverDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _serverGetId(Server object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _serverGetLinks(Server object) {
  return [];
}

void _serverAttach(IsarCollection<dynamic> col, Id id, Server object) {
  object.id = id;
}

extension ServerQueryWhereSort on QueryBuilder<Server, Server, QWhere> {
  QueryBuilder<Server, Server, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ServerQueryWhere on QueryBuilder<Server, Server, QWhereClause> {
  QueryBuilder<Server, Server, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Server, Server, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Server, Server, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Server, Server, QAfterWhereClause> idBetween(
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

extension ServerQueryFilter on QueryBuilder<Server, Server, QFilterCondition> {
  QueryBuilder<Server, Server, QAfterFilterCondition> addressEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> addressGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> addressLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> addressBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'address',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> addressStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> addressEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> addressContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> addressMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'address',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> addressIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'address',
        value: '',
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> addressIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'address',
        value: '',
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> idEqualTo(Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> idGreaterThan(
    Id? value, {
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

  QueryBuilder<Server, Server, QAfterFilterCondition> idLessThan(
    Id? value, {
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

  QueryBuilder<Server, Server, QAfterFilterCondition> idBetween(
    Id? lower,
    Id? upper, {
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

  QueryBuilder<Server, Server, QAfterFilterCondition> passwordIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'password',
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> passwordIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'password',
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> passwordEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'password',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> passwordGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'password',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> passwordLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'password',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> passwordBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'password',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> passwordStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'password',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> passwordEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'password',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> passwordContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'password',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> passwordMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'password',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> passwordIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'password',
        value: '',
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> passwordIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'password',
        value: '',
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> portEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'port',
        value: value,
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> portGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'port',
        value: value,
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> portLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'port',
        value: value,
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> portBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'port',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> secureEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'secure',
        value: value,
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> userIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'user',
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> userIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'user',
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> userEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'user',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> userGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'user',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> userLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'user',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> userBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'user',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> userStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'user',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> userEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'user',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> userContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'user',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> userMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'user',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> userIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'user',
        value: '',
      ));
    });
  }

  QueryBuilder<Server, Server, QAfterFilterCondition> userIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'user',
        value: '',
      ));
    });
  }
}

extension ServerQueryObject on QueryBuilder<Server, Server, QFilterCondition> {}

extension ServerQueryLinks on QueryBuilder<Server, Server, QFilterCondition> {}

extension ServerQuerySortBy on QueryBuilder<Server, Server, QSortBy> {
  QueryBuilder<Server, Server, QAfterSortBy> sortByAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'address', Sort.asc);
    });
  }

  QueryBuilder<Server, Server, QAfterSortBy> sortByAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'address', Sort.desc);
    });
  }

  QueryBuilder<Server, Server, QAfterSortBy> sortByPassword() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'password', Sort.asc);
    });
  }

  QueryBuilder<Server, Server, QAfterSortBy> sortByPasswordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'password', Sort.desc);
    });
  }

  QueryBuilder<Server, Server, QAfterSortBy> sortByPort() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'port', Sort.asc);
    });
  }

  QueryBuilder<Server, Server, QAfterSortBy> sortByPortDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'port', Sort.desc);
    });
  }

  QueryBuilder<Server, Server, QAfterSortBy> sortBySecure() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'secure', Sort.asc);
    });
  }

  QueryBuilder<Server, Server, QAfterSortBy> sortBySecureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'secure', Sort.desc);
    });
  }

  QueryBuilder<Server, Server, QAfterSortBy> sortByUser() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'user', Sort.asc);
    });
  }

  QueryBuilder<Server, Server, QAfterSortBy> sortByUserDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'user', Sort.desc);
    });
  }
}

extension ServerQuerySortThenBy on QueryBuilder<Server, Server, QSortThenBy> {
  QueryBuilder<Server, Server, QAfterSortBy> thenByAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'address', Sort.asc);
    });
  }

  QueryBuilder<Server, Server, QAfterSortBy> thenByAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'address', Sort.desc);
    });
  }

  QueryBuilder<Server, Server, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Server, Server, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Server, Server, QAfterSortBy> thenByPassword() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'password', Sort.asc);
    });
  }

  QueryBuilder<Server, Server, QAfterSortBy> thenByPasswordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'password', Sort.desc);
    });
  }

  QueryBuilder<Server, Server, QAfterSortBy> thenByPort() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'port', Sort.asc);
    });
  }

  QueryBuilder<Server, Server, QAfterSortBy> thenByPortDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'port', Sort.desc);
    });
  }

  QueryBuilder<Server, Server, QAfterSortBy> thenBySecure() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'secure', Sort.asc);
    });
  }

  QueryBuilder<Server, Server, QAfterSortBy> thenBySecureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'secure', Sort.desc);
    });
  }

  QueryBuilder<Server, Server, QAfterSortBy> thenByUser() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'user', Sort.asc);
    });
  }

  QueryBuilder<Server, Server, QAfterSortBy> thenByUserDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'user', Sort.desc);
    });
  }
}

extension ServerQueryWhereDistinct on QueryBuilder<Server, Server, QDistinct> {
  QueryBuilder<Server, Server, QDistinct> distinctByAddress(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'address', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Server, Server, QDistinct> distinctByPassword(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'password', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Server, Server, QDistinct> distinctByPort() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'port');
    });
  }

  QueryBuilder<Server, Server, QDistinct> distinctBySecure() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'secure');
    });
  }

  QueryBuilder<Server, Server, QDistinct> distinctByUser(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'user', caseSensitive: caseSensitive);
    });
  }
}

extension ServerQueryProperty on QueryBuilder<Server, Server, QQueryProperty> {
  QueryBuilder<Server, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Server, String, QQueryOperations> addressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'address');
    });
  }

  QueryBuilder<Server, String?, QQueryOperations> passwordProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'password');
    });
  }

  QueryBuilder<Server, int, QQueryOperations> portProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'port');
    });
  }

  QueryBuilder<Server, bool, QQueryOperations> secureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'secure');
    });
  }

  QueryBuilder<Server, String?, QQueryOperations> userProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'user');
    });
  }
}
