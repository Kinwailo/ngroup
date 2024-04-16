// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetThreadCollection on Isar {
  IsarCollection<Thread> get threads => this.collection();
}

const ThreadSchema = CollectionSchema(
  name: r'Thread',
  id: 3580143950257234225,
  properties: {
    r'bytes': PropertySchema(
      id: 0,
      name: r'bytes',
      type: IsarType.long,
    ),
    r'dateTime': PropertySchema(
      id: 1,
      name: r'dateTime',
      type: IsarType.dateTime,
    ),
    r'dates': PropertySchema(
      id: 2,
      name: r'dates',
      type: IsarType.dateTimeList,
    ),
    r'from': PropertySchema(
      id: 3,
      name: r'from',
      type: IsarType.string,
    ),
    r'groupId': PropertySchema(
      id: 4,
      name: r'groupId',
      type: IsarType.long,
    ),
    r'isNew': PropertySchema(
      id: 5,
      name: r'isNew',
      type: IsarType.bool,
    ),
    r'isRead': PropertySchema(
      id: 6,
      name: r'isRead',
      type: IsarType.bool,
    ),
    r'messageId': PropertySchema(
      id: 7,
      name: r'messageId',
      type: IsarType.string,
    ),
    r'newCount': PropertySchema(
      id: 8,
      name: r'newCount',
      type: IsarType.long,
    ),
    r'number': PropertySchema(
      id: 9,
      name: r'number',
      type: IsarType.long,
    ),
    r'senders': PropertySchema(
      id: 10,
      name: r'senders',
      type: IsarType.stringList,
    ),
    r'sizes': PropertySchema(
      id: 11,
      name: r'sizes',
      type: IsarType.longList,
    ),
    r'subject': PropertySchema(
      id: 12,
      name: r'subject',
      type: IsarType.string,
    ),
    r'totalCount': PropertySchema(
      id: 13,
      name: r'totalCount',
      type: IsarType.long,
    ),
    r'unreadCount': PropertySchema(
      id: 14,
      name: r'unreadCount',
      type: IsarType.long,
    )
  },
  estimateSize: _threadEstimateSize,
  serialize: _threadSerialize,
  deserialize: _threadDeserialize,
  deserializeProp: _threadDeserializeProp,
  idName: r'id',
  indexes: {
    r'groupId_number': IndexSchema(
      id: -1397923861179946941,
      name: r'groupId_number',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'groupId',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'number',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'groupId_newCount': IndexSchema(
      id: -512119667309507536,
      name: r'groupId_newCount',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'groupId',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'newCount',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'groupId_unreadCount': IndexSchema(
      id: 8405943505768979738,
      name: r'groupId_unreadCount',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'groupId',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'unreadCount',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'messageId': IndexSchema(
      id: -635287409172016016,
      name: r'messageId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'messageId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _threadGetId,
  getLinks: _threadGetLinks,
  attach: _threadAttach,
  version: '3.1.0+1',
);

int _threadEstimateSize(
  Thread object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.dates.length * 8;
  bytesCount += 3 + object.from.length * 3;
  bytesCount += 3 + object.messageId.length * 3;
  bytesCount += 3 + object.senders.length * 3;
  {
    for (var i = 0; i < object.senders.length; i++) {
      final value = object.senders[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.sizes.length * 8;
  bytesCount += 3 + object.subject.length * 3;
  return bytesCount;
}

void _threadSerialize(
  Thread object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.bytes);
  writer.writeDateTime(offsets[1], object.dateTime);
  writer.writeDateTimeList(offsets[2], object.dates);
  writer.writeString(offsets[3], object.from);
  writer.writeLong(offsets[4], object.groupId);
  writer.writeBool(offsets[5], object.isNew);
  writer.writeBool(offsets[6], object.isRead);
  writer.writeString(offsets[7], object.messageId);
  writer.writeLong(offsets[8], object.newCount);
  writer.writeLong(offsets[9], object.number);
  writer.writeStringList(offsets[10], object.senders);
  writer.writeLongList(offsets[11], object.sizes);
  writer.writeString(offsets[12], object.subject);
  writer.writeLong(offsets[13], object.totalCount);
  writer.writeLong(offsets[14], object.unreadCount);
}

Thread _threadDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Thread();
  object.bytes = reader.readLong(offsets[0]);
  object.dateTime = reader.readDateTime(offsets[1]);
  object.dates = reader.readDateTimeList(offsets[2]) ?? [];
  object.from = reader.readString(offsets[3]);
  object.groupId = reader.readLong(offsets[4]);
  object.id = id;
  object.isNew = reader.readBool(offsets[5]);
  object.isRead = reader.readBool(offsets[6]);
  object.messageId = reader.readString(offsets[7]);
  object.newCount = reader.readLong(offsets[8]);
  object.number = reader.readLong(offsets[9]);
  object.senders = reader.readStringList(offsets[10]) ?? [];
  object.sizes = reader.readLongList(offsets[11]) ?? [];
  object.subject = reader.readString(offsets[12]);
  object.totalCount = reader.readLong(offsets[13]);
  object.unreadCount = reader.readLong(offsets[14]);
  return object;
}

P _threadDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDateTimeList(offset) ?? []) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readStringList(offset) ?? []) as P;
    case 11:
      return (reader.readLongList(offset) ?? []) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _threadGetId(Thread object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _threadGetLinks(Thread object) {
  return [];
}

void _threadAttach(IsarCollection<dynamic> col, Id id, Thread object) {
  object.id = id;
}

extension ThreadQueryWhereSort on QueryBuilder<Thread, Thread, QWhere> {
  QueryBuilder<Thread, Thread, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhere> anyGroupIdNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'groupId_number'),
      );
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhere> anyGroupIdNewCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'groupId_newCount'),
      );
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhere> anyGroupIdUnreadCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'groupId_unreadCount'),
      );
    });
  }
}

extension ThreadQueryWhere on QueryBuilder<Thread, Thread, QWhereClause> {
  QueryBuilder<Thread, Thread, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Thread, Thread, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause> idBetween(
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

  QueryBuilder<Thread, Thread, QAfterWhereClause> groupIdEqualToAnyNumber(
      int groupId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'groupId_number',
        value: [groupId],
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause> groupIdNotEqualToAnyNumber(
      int groupId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupId_number',
              lower: [],
              upper: [groupId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupId_number',
              lower: [groupId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupId_number',
              lower: [groupId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupId_number',
              lower: [],
              upper: [groupId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause> groupIdGreaterThanAnyNumber(
    int groupId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'groupId_number',
        lower: [groupId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause> groupIdLessThanAnyNumber(
    int groupId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'groupId_number',
        lower: [],
        upper: [groupId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause> groupIdBetweenAnyNumber(
    int lowerGroupId,
    int upperGroupId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'groupId_number',
        lower: [lowerGroupId],
        includeLower: includeLower,
        upper: [upperGroupId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause> groupIdNumberEqualTo(
      int groupId, int number) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'groupId_number',
        value: [groupId, number],
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause>
      groupIdEqualToNumberNotEqualTo(int groupId, int number) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupId_number',
              lower: [groupId],
              upper: [groupId, number],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupId_number',
              lower: [groupId, number],
              includeLower: false,
              upper: [groupId],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupId_number',
              lower: [groupId, number],
              includeLower: false,
              upper: [groupId],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupId_number',
              lower: [groupId],
              upper: [groupId, number],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause>
      groupIdEqualToNumberGreaterThan(
    int groupId,
    int number, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'groupId_number',
        lower: [groupId, number],
        includeLower: include,
        upper: [groupId],
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause> groupIdEqualToNumberLessThan(
    int groupId,
    int number, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'groupId_number',
        lower: [groupId],
        upper: [groupId, number],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause> groupIdEqualToNumberBetween(
    int groupId,
    int lowerNumber,
    int upperNumber, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'groupId_number',
        lower: [groupId, lowerNumber],
        includeLower: includeLower,
        upper: [groupId, upperNumber],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause> groupIdEqualToAnyNewCount(
      int groupId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'groupId_newCount',
        value: [groupId],
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause> groupIdNotEqualToAnyNewCount(
      int groupId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupId_newCount',
              lower: [],
              upper: [groupId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupId_newCount',
              lower: [groupId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupId_newCount',
              lower: [groupId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupId_newCount',
              lower: [],
              upper: [groupId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause> groupIdGreaterThanAnyNewCount(
    int groupId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'groupId_newCount',
        lower: [groupId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause> groupIdLessThanAnyNewCount(
    int groupId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'groupId_newCount',
        lower: [],
        upper: [groupId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause> groupIdBetweenAnyNewCount(
    int lowerGroupId,
    int upperGroupId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'groupId_newCount',
        lower: [lowerGroupId],
        includeLower: includeLower,
        upper: [upperGroupId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause> groupIdNewCountEqualTo(
      int groupId, int newCount) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'groupId_newCount',
        value: [groupId, newCount],
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause>
      groupIdEqualToNewCountNotEqualTo(int groupId, int newCount) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupId_newCount',
              lower: [groupId],
              upper: [groupId, newCount],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupId_newCount',
              lower: [groupId, newCount],
              includeLower: false,
              upper: [groupId],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupId_newCount',
              lower: [groupId, newCount],
              includeLower: false,
              upper: [groupId],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupId_newCount',
              lower: [groupId],
              upper: [groupId, newCount],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause>
      groupIdEqualToNewCountGreaterThan(
    int groupId,
    int newCount, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'groupId_newCount',
        lower: [groupId, newCount],
        includeLower: include,
        upper: [groupId],
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause>
      groupIdEqualToNewCountLessThan(
    int groupId,
    int newCount, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'groupId_newCount',
        lower: [groupId],
        upper: [groupId, newCount],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause> groupIdEqualToNewCountBetween(
    int groupId,
    int lowerNewCount,
    int upperNewCount, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'groupId_newCount',
        lower: [groupId, lowerNewCount],
        includeLower: includeLower,
        upper: [groupId, upperNewCount],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause> groupIdEqualToAnyUnreadCount(
      int groupId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'groupId_unreadCount',
        value: [groupId],
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause>
      groupIdNotEqualToAnyUnreadCount(int groupId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupId_unreadCount',
              lower: [],
              upper: [groupId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupId_unreadCount',
              lower: [groupId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupId_unreadCount',
              lower: [groupId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupId_unreadCount',
              lower: [],
              upper: [groupId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause>
      groupIdGreaterThanAnyUnreadCount(
    int groupId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'groupId_unreadCount',
        lower: [groupId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause> groupIdLessThanAnyUnreadCount(
    int groupId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'groupId_unreadCount',
        lower: [],
        upper: [groupId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause> groupIdBetweenAnyUnreadCount(
    int lowerGroupId,
    int upperGroupId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'groupId_unreadCount',
        lower: [lowerGroupId],
        includeLower: includeLower,
        upper: [upperGroupId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause> groupIdUnreadCountEqualTo(
      int groupId, int unreadCount) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'groupId_unreadCount',
        value: [groupId, unreadCount],
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause>
      groupIdEqualToUnreadCountNotEqualTo(int groupId, int unreadCount) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupId_unreadCount',
              lower: [groupId],
              upper: [groupId, unreadCount],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupId_unreadCount',
              lower: [groupId, unreadCount],
              includeLower: false,
              upper: [groupId],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupId_unreadCount',
              lower: [groupId, unreadCount],
              includeLower: false,
              upper: [groupId],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupId_unreadCount',
              lower: [groupId],
              upper: [groupId, unreadCount],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause>
      groupIdEqualToUnreadCountGreaterThan(
    int groupId,
    int unreadCount, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'groupId_unreadCount',
        lower: [groupId, unreadCount],
        includeLower: include,
        upper: [groupId],
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause>
      groupIdEqualToUnreadCountLessThan(
    int groupId,
    int unreadCount, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'groupId_unreadCount',
        lower: [groupId],
        upper: [groupId, unreadCount],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause>
      groupIdEqualToUnreadCountBetween(
    int groupId,
    int lowerUnreadCount,
    int upperUnreadCount, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'groupId_unreadCount',
        lower: [groupId, lowerUnreadCount],
        includeLower: includeLower,
        upper: [groupId, upperUnreadCount],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause> messageIdEqualTo(
      String messageId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'messageId',
        value: [messageId],
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterWhereClause> messageIdNotEqualTo(
      String messageId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'messageId',
              lower: [],
              upper: [messageId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'messageId',
              lower: [messageId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'messageId',
              lower: [messageId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'messageId',
              lower: [],
              upper: [messageId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ThreadQueryFilter on QueryBuilder<Thread, Thread, QFilterCondition> {
  QueryBuilder<Thread, Thread, QAfterFilterCondition> bytesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bytes',
        value: value,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> bytesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bytes',
        value: value,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> bytesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bytes',
        value: value,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> bytesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bytes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> dateTimeEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> dateTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> dateTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> dateTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> datesElementEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dates',
        value: value,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> datesElementGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dates',
        value: value,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> datesElementLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dates',
        value: value,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> datesElementBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dates',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> datesLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dates',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> datesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dates',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> datesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dates',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> datesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dates',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> datesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dates',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> datesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dates',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> fromEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'from',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> fromGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'from',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> fromLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'from',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> fromBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'from',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> fromStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'from',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> fromEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'from',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> fromContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'from',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> fromMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'from',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> fromIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'from',
        value: '',
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> fromIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'from',
        value: '',
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> groupIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'groupId',
        value: value,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> groupIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'groupId',
        value: value,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> groupIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'groupId',
        value: value,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> groupIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'groupId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> idEqualTo(Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Thread, Thread, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Thread, Thread, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Thread, Thread, QAfterFilterCondition> isNewEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isNew',
        value: value,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> isReadEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isRead',
        value: value,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> messageIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'messageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> messageIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'messageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> messageIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'messageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> messageIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'messageId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> messageIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'messageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> messageIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'messageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> messageIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'messageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> messageIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'messageId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> messageIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'messageId',
        value: '',
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> messageIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'messageId',
        value: '',
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> newCountEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'newCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> newCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'newCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> newCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'newCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> newCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'newCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> numberEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'number',
        value: value,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> numberGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'number',
        value: value,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> numberLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'number',
        value: value,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> numberBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'number',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> sendersElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senders',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> sendersElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'senders',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> sendersElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'senders',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> sendersElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'senders',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> sendersElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'senders',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> sendersElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'senders',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> sendersElementContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'senders',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> sendersElementMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'senders',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> sendersElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senders',
        value: '',
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition>
      sendersElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'senders',
        value: '',
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> sendersLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'senders',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> sendersIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'senders',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> sendersIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'senders',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> sendersLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'senders',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> sendersLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'senders',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> sendersLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'senders',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> sizesElementEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sizes',
        value: value,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> sizesElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sizes',
        value: value,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> sizesElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sizes',
        value: value,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> sizesElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sizes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> sizesLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sizes',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> sizesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sizes',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> sizesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sizes',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> sizesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sizes',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> sizesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sizes',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> sizesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sizes',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> subjectEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> subjectGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> subjectLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> subjectBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subject',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> subjectStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> subjectEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> subjectContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> subjectMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subject',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> subjectIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subject',
        value: '',
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> subjectIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subject',
        value: '',
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> totalCountEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> totalCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> totalCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> totalCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> unreadCountEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unreadCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> unreadCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unreadCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> unreadCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unreadCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Thread, Thread, QAfterFilterCondition> unreadCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unreadCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ThreadQueryObject on QueryBuilder<Thread, Thread, QFilterCondition> {}

extension ThreadQueryLinks on QueryBuilder<Thread, Thread, QFilterCondition> {}

extension ThreadQuerySortBy on QueryBuilder<Thread, Thread, QSortBy> {
  QueryBuilder<Thread, Thread, QAfterSortBy> sortByBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bytes', Sort.asc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> sortByBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bytes', Sort.desc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> sortByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.asc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> sortByDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.desc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> sortByFrom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'from', Sort.asc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> sortByFromDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'from', Sort.desc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> sortByGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.asc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> sortByGroupIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.desc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> sortByIsNew() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNew', Sort.asc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> sortByIsNewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNew', Sort.desc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> sortByIsRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRead', Sort.asc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> sortByIsReadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRead', Sort.desc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> sortByMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageId', Sort.asc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> sortByMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageId', Sort.desc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> sortByNewCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newCount', Sort.asc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> sortByNewCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newCount', Sort.desc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> sortByNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'number', Sort.asc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> sortByNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'number', Sort.desc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> sortBySubject() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.asc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> sortBySubjectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.desc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> sortByTotalCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCount', Sort.asc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> sortByTotalCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCount', Sort.desc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> sortByUnreadCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unreadCount', Sort.asc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> sortByUnreadCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unreadCount', Sort.desc);
    });
  }
}

extension ThreadQuerySortThenBy on QueryBuilder<Thread, Thread, QSortThenBy> {
  QueryBuilder<Thread, Thread, QAfterSortBy> thenByBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bytes', Sort.asc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> thenByBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bytes', Sort.desc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> thenByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.asc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> thenByDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.desc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> thenByFrom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'from', Sort.asc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> thenByFromDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'from', Sort.desc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> thenByGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.asc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> thenByGroupIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.desc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> thenByIsNew() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNew', Sort.asc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> thenByIsNewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNew', Sort.desc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> thenByIsRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRead', Sort.asc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> thenByIsReadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRead', Sort.desc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> thenByMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageId', Sort.asc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> thenByMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageId', Sort.desc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> thenByNewCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newCount', Sort.asc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> thenByNewCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newCount', Sort.desc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> thenByNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'number', Sort.asc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> thenByNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'number', Sort.desc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> thenBySubject() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.asc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> thenBySubjectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.desc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> thenByTotalCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCount', Sort.asc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> thenByTotalCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCount', Sort.desc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> thenByUnreadCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unreadCount', Sort.asc);
    });
  }

  QueryBuilder<Thread, Thread, QAfterSortBy> thenByUnreadCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unreadCount', Sort.desc);
    });
  }
}

extension ThreadQueryWhereDistinct on QueryBuilder<Thread, Thread, QDistinct> {
  QueryBuilder<Thread, Thread, QDistinct> distinctByBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bytes');
    });
  }

  QueryBuilder<Thread, Thread, QDistinct> distinctByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateTime');
    });
  }

  QueryBuilder<Thread, Thread, QDistinct> distinctByDates() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dates');
    });
  }

  QueryBuilder<Thread, Thread, QDistinct> distinctByFrom(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'from', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Thread, Thread, QDistinct> distinctByGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'groupId');
    });
  }

  QueryBuilder<Thread, Thread, QDistinct> distinctByIsNew() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isNew');
    });
  }

  QueryBuilder<Thread, Thread, QDistinct> distinctByIsRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isRead');
    });
  }

  QueryBuilder<Thread, Thread, QDistinct> distinctByMessageId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'messageId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Thread, Thread, QDistinct> distinctByNewCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'newCount');
    });
  }

  QueryBuilder<Thread, Thread, QDistinct> distinctByNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'number');
    });
  }

  QueryBuilder<Thread, Thread, QDistinct> distinctBySenders() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senders');
    });
  }

  QueryBuilder<Thread, Thread, QDistinct> distinctBySizes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sizes');
    });
  }

  QueryBuilder<Thread, Thread, QDistinct> distinctBySubject(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subject', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Thread, Thread, QDistinct> distinctByTotalCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalCount');
    });
  }

  QueryBuilder<Thread, Thread, QDistinct> distinctByUnreadCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unreadCount');
    });
  }
}

extension ThreadQueryProperty on QueryBuilder<Thread, Thread, QQueryProperty> {
  QueryBuilder<Thread, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Thread, int, QQueryOperations> bytesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bytes');
    });
  }

  QueryBuilder<Thread, DateTime, QQueryOperations> dateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateTime');
    });
  }

  QueryBuilder<Thread, List<DateTime>, QQueryOperations> datesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dates');
    });
  }

  QueryBuilder<Thread, String, QQueryOperations> fromProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'from');
    });
  }

  QueryBuilder<Thread, int, QQueryOperations> groupIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'groupId');
    });
  }

  QueryBuilder<Thread, bool, QQueryOperations> isNewProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isNew');
    });
  }

  QueryBuilder<Thread, bool, QQueryOperations> isReadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isRead');
    });
  }

  QueryBuilder<Thread, String, QQueryOperations> messageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'messageId');
    });
  }

  QueryBuilder<Thread, int, QQueryOperations> newCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'newCount');
    });
  }

  QueryBuilder<Thread, int, QQueryOperations> numberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'number');
    });
  }

  QueryBuilder<Thread, List<String>, QQueryOperations> sendersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senders');
    });
  }

  QueryBuilder<Thread, List<int>, QQueryOperations> sizesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sizes');
    });
  }

  QueryBuilder<Thread, String, QQueryOperations> subjectProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subject');
    });
  }

  QueryBuilder<Thread, int, QQueryOperations> totalCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalCount');
    });
  }

  QueryBuilder<Thread, int, QQueryOperations> unreadCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unreadCount');
    });
  }
}
