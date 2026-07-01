// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProductRowsTable extends ProductRows
    with TableInfo<$ProductRowsTable, ProductRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _servingSizeMeta = const VerificationMeta(
    'servingSize',
  );
  @override
  late final GeneratedColumn<double> servingSize = GeneratedColumn<double>(
    'serving_size',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _servingUnitMeta = const VerificationMeta(
    'servingUnit',
  );
  @override
  late final GeneratedColumn<String> servingUnit = GeneratedColumn<String>(
    'serving_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _baseUnitMeta = const VerificationMeta(
    'baseUnit',
  );
  @override
  late final GeneratedColumn<String> baseUnit = GeneratedColumn<String>(
    'base_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesPer100Meta = const VerificationMeta(
    'caloriesPer100',
  );
  @override
  late final GeneratedColumn<double> caloriesPer100 = GeneratedColumn<double>(
    'calories_per100',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinPer100Meta = const VerificationMeta(
    'proteinPer100',
  );
  @override
  late final GeneratedColumn<double> proteinPer100 = GeneratedColumn<double>(
    'protein_per100',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsPer100Meta = const VerificationMeta(
    'carbsPer100',
  );
  @override
  late final GeneratedColumn<double> carbsPer100 = GeneratedColumn<double>(
    'carbs_per100',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatPer100Meta = const VerificationMeta(
    'fatPer100',
  );
  @override
  late final GeneratedColumn<double> fatPer100 = GeneratedColumn<double>(
    'fat_per100',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    brand,
    servingSize,
    servingUnit,
    baseUnit,
    caloriesPer100,
    proteinPer100,
    carbsPer100,
    fatPer100,
    createdAt,
    updatedAt,
    deletedAt,
    userId,
    syncStatus,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('serving_size')) {
      context.handle(
        _servingSizeMeta,
        servingSize.isAcceptableOrUnknown(
          data['serving_size']!,
          _servingSizeMeta,
        ),
      );
    }
    if (data.containsKey('serving_unit')) {
      context.handle(
        _servingUnitMeta,
        servingUnit.isAcceptableOrUnknown(
          data['serving_unit']!,
          _servingUnitMeta,
        ),
      );
    }
    if (data.containsKey('base_unit')) {
      context.handle(
        _baseUnitMeta,
        baseUnit.isAcceptableOrUnknown(data['base_unit']!, _baseUnitMeta),
      );
    } else if (isInserting) {
      context.missing(_baseUnitMeta);
    }
    if (data.containsKey('calories_per100')) {
      context.handle(
        _caloriesPer100Meta,
        caloriesPer100.isAcceptableOrUnknown(
          data['calories_per100']!,
          _caloriesPer100Meta,
        ),
      );
    } else if (isInserting) {
      context.missing(_caloriesPer100Meta);
    }
    if (data.containsKey('protein_per100')) {
      context.handle(
        _proteinPer100Meta,
        proteinPer100.isAcceptableOrUnknown(
          data['protein_per100']!,
          _proteinPer100Meta,
        ),
      );
    } else if (isInserting) {
      context.missing(_proteinPer100Meta);
    }
    if (data.containsKey('carbs_per100')) {
      context.handle(
        _carbsPer100Meta,
        carbsPer100.isAcceptableOrUnknown(
          data['carbs_per100']!,
          _carbsPer100Meta,
        ),
      );
    } else if (isInserting) {
      context.missing(_carbsPer100Meta);
    }
    if (data.containsKey('fat_per100')) {
      context.handle(
        _fatPer100Meta,
        fatPer100.isAcceptableOrUnknown(data['fat_per100']!, _fatPer100Meta),
      );
    } else if (isInserting) {
      context.missing(_fatPer100Meta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      servingSize: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}serving_size'],
      ),
      servingUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serving_unit'],
      ),
      baseUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_unit'],
      )!,
      caloriesPer100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories_per100'],
      )!,
      proteinPer100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_per100'],
      )!,
      carbsPer100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_per100'],
      )!,
      fatPer100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_per100'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $ProductRowsTable createAlias(String alias) {
    return $ProductRowsTable(attachedDatabase, alias);
  }
}

class ProductRow extends DataClass implements Insertable<ProductRow> {
  final String id;
  final String name;
  final String? brand;
  final double? servingSize;
  final String? servingUnit;
  final String baseUnit;
  final double caloriesPer100;
  final double proteinPer100;
  final double carbsPer100;
  final double fatPer100;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? userId;
  final String syncStatus;
  final DateTime? lastSyncedAt;
  const ProductRow({
    required this.id,
    required this.name,
    this.brand,
    this.servingSize,
    this.servingUnit,
    required this.baseUnit,
    required this.caloriesPer100,
    required this.proteinPer100,
    required this.carbsPer100,
    required this.fatPer100,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.userId,
    required this.syncStatus,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || servingSize != null) {
      map['serving_size'] = Variable<double>(servingSize);
    }
    if (!nullToAbsent || servingUnit != null) {
      map['serving_unit'] = Variable<String>(servingUnit);
    }
    map['base_unit'] = Variable<String>(baseUnit);
    map['calories_per100'] = Variable<double>(caloriesPer100);
    map['protein_per100'] = Variable<double>(proteinPer100);
    map['carbs_per100'] = Variable<double>(carbsPer100);
    map['fat_per100'] = Variable<double>(fatPer100);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  ProductRowsCompanion toCompanion(bool nullToAbsent) {
    return ProductRowsCompanion(
      id: Value(id),
      name: Value(name),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      servingSize: servingSize == null && nullToAbsent
          ? const Value.absent()
          : Value(servingSize),
      servingUnit: servingUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(servingUnit),
      baseUnit: Value(baseUnit),
      caloriesPer100: Value(caloriesPer100),
      proteinPer100: Value(proteinPer100),
      carbsPer100: Value(carbsPer100),
      fatPer100: Value(fatPer100),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory ProductRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String?>(json['brand']),
      servingSize: serializer.fromJson<double?>(json['servingSize']),
      servingUnit: serializer.fromJson<String?>(json['servingUnit']),
      baseUnit: serializer.fromJson<String>(json['baseUnit']),
      caloriesPer100: serializer.fromJson<double>(json['caloriesPer100']),
      proteinPer100: serializer.fromJson<double>(json['proteinPer100']),
      carbsPer100: serializer.fromJson<double>(json['carbsPer100']),
      fatPer100: serializer.fromJson<double>(json['fatPer100']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      userId: serializer.fromJson<String?>(json['userId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String?>(brand),
      'servingSize': serializer.toJson<double?>(servingSize),
      'servingUnit': serializer.toJson<String?>(servingUnit),
      'baseUnit': serializer.toJson<String>(baseUnit),
      'caloriesPer100': serializer.toJson<double>(caloriesPer100),
      'proteinPer100': serializer.toJson<double>(proteinPer100),
      'carbsPer100': serializer.toJson<double>(carbsPer100),
      'fatPer100': serializer.toJson<double>(fatPer100),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'userId': serializer.toJson<String?>(userId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  ProductRow copyWith({
    String? id,
    String? name,
    Value<String?> brand = const Value.absent(),
    Value<double?> servingSize = const Value.absent(),
    Value<String?> servingUnit = const Value.absent(),
    String? baseUnit,
    double? caloriesPer100,
    double? proteinPer100,
    double? carbsPer100,
    double? fatPer100,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> userId = const Value.absent(),
    String? syncStatus,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => ProductRow(
    id: id ?? this.id,
    name: name ?? this.name,
    brand: brand.present ? brand.value : this.brand,
    servingSize: servingSize.present ? servingSize.value : this.servingSize,
    servingUnit: servingUnit.present ? servingUnit.value : this.servingUnit,
    baseUnit: baseUnit ?? this.baseUnit,
    caloriesPer100: caloriesPer100 ?? this.caloriesPer100,
    proteinPer100: proteinPer100 ?? this.proteinPer100,
    carbsPer100: carbsPer100 ?? this.carbsPer100,
    fatPer100: fatPer100 ?? this.fatPer100,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    userId: userId.present ? userId.value : this.userId,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  ProductRow copyWithCompanion(ProductRowsCompanion data) {
    return ProductRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      servingSize: data.servingSize.present
          ? data.servingSize.value
          : this.servingSize,
      servingUnit: data.servingUnit.present
          ? data.servingUnit.value
          : this.servingUnit,
      baseUnit: data.baseUnit.present ? data.baseUnit.value : this.baseUnit,
      caloriesPer100: data.caloriesPer100.present
          ? data.caloriesPer100.value
          : this.caloriesPer100,
      proteinPer100: data.proteinPer100.present
          ? data.proteinPer100.value
          : this.proteinPer100,
      carbsPer100: data.carbsPer100.present
          ? data.carbsPer100.value
          : this.carbsPer100,
      fatPer100: data.fatPer100.present ? data.fatPer100.value : this.fatPer100,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      userId: data.userId.present ? data.userId.value : this.userId,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('servingSize: $servingSize, ')
          ..write('servingUnit: $servingUnit, ')
          ..write('baseUnit: $baseUnit, ')
          ..write('caloriesPer100: $caloriesPer100, ')
          ..write('proteinPer100: $proteinPer100, ')
          ..write('carbsPer100: $carbsPer100, ')
          ..write('fatPer100: $fatPer100, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('userId: $userId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    brand,
    servingSize,
    servingUnit,
    baseUnit,
    caloriesPer100,
    proteinPer100,
    carbsPer100,
    fatPer100,
    createdAt,
    updatedAt,
    deletedAt,
    userId,
    syncStatus,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.servingSize == this.servingSize &&
          other.servingUnit == this.servingUnit &&
          other.baseUnit == this.baseUnit &&
          other.caloriesPer100 == this.caloriesPer100 &&
          other.proteinPer100 == this.proteinPer100 &&
          other.carbsPer100 == this.carbsPer100 &&
          other.fatPer100 == this.fatPer100 &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.userId == this.userId &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class ProductRowsCompanion extends UpdateCompanion<ProductRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> brand;
  final Value<double?> servingSize;
  final Value<String?> servingUnit;
  final Value<String> baseUnit;
  final Value<double> caloriesPer100;
  final Value<double> proteinPer100;
  final Value<double> carbsPer100;
  final Value<double> fatPer100;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> userId;
  final Value<String> syncStatus;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const ProductRowsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.servingSize = const Value.absent(),
    this.servingUnit = const Value.absent(),
    this.baseUnit = const Value.absent(),
    this.caloriesPer100 = const Value.absent(),
    this.proteinPer100 = const Value.absent(),
    this.carbsPer100 = const Value.absent(),
    this.fatPer100 = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.userId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductRowsCompanion.insert({
    required String id,
    required String name,
    this.brand = const Value.absent(),
    this.servingSize = const Value.absent(),
    this.servingUnit = const Value.absent(),
    required String baseUnit,
    required double caloriesPer100,
    required double proteinPer100,
    required double carbsPer100,
    required double fatPer100,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.userId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       baseUnit = Value(baseUnit),
       caloriesPer100 = Value(caloriesPer100),
       proteinPer100 = Value(proteinPer100),
       carbsPer100 = Value(carbsPer100),
       fatPer100 = Value(fatPer100),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ProductRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<double>? servingSize,
    Expression<String>? servingUnit,
    Expression<String>? baseUnit,
    Expression<double>? caloriesPer100,
    Expression<double>? proteinPer100,
    Expression<double>? carbsPer100,
    Expression<double>? fatPer100,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? userId,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (servingSize != null) 'serving_size': servingSize,
      if (servingUnit != null) 'serving_unit': servingUnit,
      if (baseUnit != null) 'base_unit': baseUnit,
      if (caloriesPer100 != null) 'calories_per100': caloriesPer100,
      if (proteinPer100 != null) 'protein_per100': proteinPer100,
      if (carbsPer100 != null) 'carbs_per100': carbsPer100,
      if (fatPer100 != null) 'fat_per100': fatPer100,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (userId != null) 'user_id': userId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? brand,
    Value<double?>? servingSize,
    Value<String?>? servingUnit,
    Value<String>? baseUnit,
    Value<double>? caloriesPer100,
    Value<double>? proteinPer100,
    Value<double>? carbsPer100,
    Value<double>? fatPer100,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? userId,
    Value<String>? syncStatus,
    Value<DateTime?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return ProductRowsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      servingSize: servingSize ?? this.servingSize,
      servingUnit: servingUnit ?? this.servingUnit,
      baseUnit: baseUnit ?? this.baseUnit,
      caloriesPer100: caloriesPer100 ?? this.caloriesPer100,
      proteinPer100: proteinPer100 ?? this.proteinPer100,
      carbsPer100: carbsPer100 ?? this.carbsPer100,
      fatPer100: fatPer100 ?? this.fatPer100,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      userId: userId ?? this.userId,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (servingSize.present) {
      map['serving_size'] = Variable<double>(servingSize.value);
    }
    if (servingUnit.present) {
      map['serving_unit'] = Variable<String>(servingUnit.value);
    }
    if (baseUnit.present) {
      map['base_unit'] = Variable<String>(baseUnit.value);
    }
    if (caloriesPer100.present) {
      map['calories_per100'] = Variable<double>(caloriesPer100.value);
    }
    if (proteinPer100.present) {
      map['protein_per100'] = Variable<double>(proteinPer100.value);
    }
    if (carbsPer100.present) {
      map['carbs_per100'] = Variable<double>(carbsPer100.value);
    }
    if (fatPer100.present) {
      map['fat_per100'] = Variable<double>(fatPer100.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductRowsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('servingSize: $servingSize, ')
          ..write('servingUnit: $servingUnit, ')
          ..write('baseUnit: $baseUnit, ')
          ..write('caloriesPer100: $caloriesPer100, ')
          ..write('proteinPer100: $proteinPer100, ')
          ..write('carbsPer100: $carbsPer100, ')
          ..write('fatPer100: $fatPer100, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('userId: $userId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LogItemRowsTable extends LogItemRows
    with TableInfo<$LogItemRowsTable, LogItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LogItemRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mealTypeMeta = const VerificationMeta(
    'mealType',
  );
  @override
  late final GeneratedColumn<String> mealType = GeneratedColumn<String>(
    'meal_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
    'calories',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinMeta = const VerificationMeta(
    'protein',
  );
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
    'protein',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<double> carbs = GeneratedColumn<double>(
    'carbs',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<double> fat = GeneratedColumn<double>(
    'fat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    mealType,
    quantity,
    unit,
    calories,
    protein,
    carbs,
    fat,
    createdAt,
    updatedAt,
    deletedAt,
    userId,
    syncStatus,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'log_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<LogItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('meal_type')) {
      context.handle(
        _mealTypeMeta,
        mealType.isAcceptableOrUnknown(data['meal_type']!, _mealTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mealTypeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    } else if (isInserting) {
      context.missing(_caloriesMeta);
    }
    if (data.containsKey('protein')) {
      context.handle(
        _proteinMeta,
        protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta),
      );
    } else if (isInserting) {
      context.missing(_proteinMeta);
    }
    if (data.containsKey('carbs')) {
      context.handle(
        _carbsMeta,
        carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta),
      );
    } else if (isInserting) {
      context.missing(_carbsMeta);
    }
    if (data.containsKey('fat')) {
      context.handle(
        _fatMeta,
        fat.isAcceptableOrUnknown(data['fat']!, _fatMeta),
      );
    } else if (isInserting) {
      context.missing(_fatMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LogItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LogItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      mealType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal_type'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories'],
      )!,
      protein: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein'],
      )!,
      carbs: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs'],
      )!,
      fat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $LogItemRowsTable createAlias(String alias) {
    return $LogItemRowsTable(attachedDatabase, alias);
  }
}

class LogItemRow extends DataClass implements Insertable<LogItemRow> {
  final String id;
  final String productId;
  final String mealType;
  final double quantity;
  final String unit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? userId;
  final String syncStatus;
  final DateTime? lastSyncedAt;
  const LogItemRow({
    required this.id,
    required this.productId,
    required this.mealType,
    required this.quantity,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.userId,
    required this.syncStatus,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['meal_type'] = Variable<String>(mealType);
    map['quantity'] = Variable<double>(quantity);
    map['unit'] = Variable<String>(unit);
    map['calories'] = Variable<double>(calories);
    map['protein'] = Variable<double>(protein);
    map['carbs'] = Variable<double>(carbs);
    map['fat'] = Variable<double>(fat);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  LogItemRowsCompanion toCompanion(bool nullToAbsent) {
    return LogItemRowsCompanion(
      id: Value(id),
      productId: Value(productId),
      mealType: Value(mealType),
      quantity: Value(quantity),
      unit: Value(unit),
      calories: Value(calories),
      protein: Value(protein),
      carbs: Value(carbs),
      fat: Value(fat),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory LogItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LogItemRow(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      mealType: serializer.fromJson<String>(json['mealType']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
      calories: serializer.fromJson<double>(json['calories']),
      protein: serializer.fromJson<double>(json['protein']),
      carbs: serializer.fromJson<double>(json['carbs']),
      fat: serializer.fromJson<double>(json['fat']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      userId: serializer.fromJson<String?>(json['userId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'mealType': serializer.toJson<String>(mealType),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String>(unit),
      'calories': serializer.toJson<double>(calories),
      'protein': serializer.toJson<double>(protein),
      'carbs': serializer.toJson<double>(carbs),
      'fat': serializer.toJson<double>(fat),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'userId': serializer.toJson<String?>(userId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  LogItemRow copyWith({
    String? id,
    String? productId,
    String? mealType,
    double? quantity,
    String? unit,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> userId = const Value.absent(),
    String? syncStatus,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => LogItemRow(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    mealType: mealType ?? this.mealType,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    calories: calories ?? this.calories,
    protein: protein ?? this.protein,
    carbs: carbs ?? this.carbs,
    fat: fat ?? this.fat,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    userId: userId.present ? userId.value : this.userId,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  LogItemRow copyWithCompanion(LogItemRowsCompanion data) {
    return LogItemRow(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      mealType: data.mealType.present ? data.mealType.value : this.mealType,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      calories: data.calories.present ? data.calories.value : this.calories,
      protein: data.protein.present ? data.protein.value : this.protein,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
      fat: data.fat.present ? data.fat.value : this.fat,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      userId: data.userId.present ? data.userId.value : this.userId,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LogItemRow(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('mealType: $mealType, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('userId: $userId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productId,
    mealType,
    quantity,
    unit,
    calories,
    protein,
    carbs,
    fat,
    createdAt,
    updatedAt,
    deletedAt,
    userId,
    syncStatus,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LogItemRow &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.mealType == this.mealType &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.calories == this.calories &&
          other.protein == this.protein &&
          other.carbs == this.carbs &&
          other.fat == this.fat &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.userId == this.userId &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class LogItemRowsCompanion extends UpdateCompanion<LogItemRow> {
  final Value<String> id;
  final Value<String> productId;
  final Value<String> mealType;
  final Value<double> quantity;
  final Value<String> unit;
  final Value<double> calories;
  final Value<double> protein;
  final Value<double> carbs;
  final Value<double> fat;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> userId;
  final Value<String> syncStatus;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const LogItemRowsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.mealType = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.calories = const Value.absent(),
    this.protein = const Value.absent(),
    this.carbs = const Value.absent(),
    this.fat = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.userId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LogItemRowsCompanion.insert({
    required String id,
    required String productId,
    required String mealType,
    required double quantity,
    required String unit,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.userId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId),
       mealType = Value(mealType),
       quantity = Value(quantity),
       unit = Value(unit),
       calories = Value(calories),
       protein = Value(protein),
       carbs = Value(carbs),
       fat = Value(fat),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LogItemRow> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? mealType,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<double>? calories,
    Expression<double>? protein,
    Expression<double>? carbs,
    Expression<double>? fat,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? userId,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (mealType != null) 'meal_type': mealType,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (calories != null) 'calories': calories,
      if (protein != null) 'protein': protein,
      if (carbs != null) 'carbs': carbs,
      if (fat != null) 'fat': fat,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (userId != null) 'user_id': userId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LogItemRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? productId,
    Value<String>? mealType,
    Value<double>? quantity,
    Value<String>? unit,
    Value<double>? calories,
    Value<double>? protein,
    Value<double>? carbs,
    Value<double>? fat,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? userId,
    Value<String>? syncStatus,
    Value<DateTime?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return LogItemRowsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      mealType: mealType ?? this.mealType,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      userId: userId ?? this.userId,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (mealType.present) {
      map['meal_type'] = Variable<String>(mealType.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (calories.present) {
      map['calories'] = Variable<double>(calories.value);
    }
    if (protein.present) {
      map['protein'] = Variable<double>(protein.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<double>(carbs.value);
    }
    if (fat.present) {
      map['fat'] = Variable<double>(fat.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LogItemRowsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('mealType: $mealType, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('userId: $userId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProductRowsTable productRows = $ProductRowsTable(this);
  late final $LogItemRowsTable logItemRows = $LogItemRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    productRows,
    logItemRows,
  ];
}

typedef $$ProductRowsTableCreateCompanionBuilder =
    ProductRowsCompanion Function({
      required String id,
      required String name,
      Value<String?> brand,
      Value<double?> servingSize,
      Value<String?> servingUnit,
      required String baseUnit,
      required double caloriesPer100,
      required double proteinPer100,
      required double carbsPer100,
      required double fatPer100,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> userId,
      Value<String> syncStatus,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });
typedef $$ProductRowsTableUpdateCompanionBuilder =
    ProductRowsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> brand,
      Value<double?> servingSize,
      Value<String?> servingUnit,
      Value<String> baseUnit,
      Value<double> caloriesPer100,
      Value<double> proteinPer100,
      Value<double> carbsPer100,
      Value<double> fatPer100,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> userId,
      Value<String> syncStatus,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });

class $$ProductRowsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductRowsTable> {
  $$ProductRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get servingSize => $composableBuilder(
    column: $table.servingSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get servingUnit => $composableBuilder(
    column: $table.servingUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseUnit => $composableBuilder(
    column: $table.baseUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get caloriesPer100 => $composableBuilder(
    column: $table.caloriesPer100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinPer100 => $composableBuilder(
    column: $table.proteinPer100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsPer100 => $composableBuilder(
    column: $table.carbsPer100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatPer100 => $composableBuilder(
    column: $table.fatPer100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductRowsTable> {
  $$ProductRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get servingSize => $composableBuilder(
    column: $table.servingSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get servingUnit => $composableBuilder(
    column: $table.servingUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseUnit => $composableBuilder(
    column: $table.baseUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get caloriesPer100 => $composableBuilder(
    column: $table.caloriesPer100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinPer100 => $composableBuilder(
    column: $table.proteinPer100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsPer100 => $composableBuilder(
    column: $table.carbsPer100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatPer100 => $composableBuilder(
    column: $table.fatPer100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductRowsTable> {
  $$ProductRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<double> get servingSize => $composableBuilder(
    column: $table.servingSize,
    builder: (column) => column,
  );

  GeneratedColumn<String> get servingUnit => $composableBuilder(
    column: $table.servingUnit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get baseUnit =>
      $composableBuilder(column: $table.baseUnit, builder: (column) => column);

  GeneratedColumn<double> get caloriesPer100 => $composableBuilder(
    column: $table.caloriesPer100,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinPer100 => $composableBuilder(
    column: $table.proteinPer100,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbsPer100 => $composableBuilder(
    column: $table.carbsPer100,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fatPer100 =>
      $composableBuilder(column: $table.fatPer100, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$ProductRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductRowsTable,
          ProductRow,
          $$ProductRowsTableFilterComposer,
          $$ProductRowsTableOrderingComposer,
          $$ProductRowsTableAnnotationComposer,
          $$ProductRowsTableCreateCompanionBuilder,
          $$ProductRowsTableUpdateCompanionBuilder,
          (
            ProductRow,
            BaseReferences<_$AppDatabase, $ProductRowsTable, ProductRow>,
          ),
          ProductRow,
          PrefetchHooks Function()
        > {
  $$ProductRowsTableTableManager(_$AppDatabase db, $ProductRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<double?> servingSize = const Value.absent(),
                Value<String?> servingUnit = const Value.absent(),
                Value<String> baseUnit = const Value.absent(),
                Value<double> caloriesPer100 = const Value.absent(),
                Value<double> proteinPer100 = const Value.absent(),
                Value<double> carbsPer100 = const Value.absent(),
                Value<double> fatPer100 = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductRowsCompanion(
                id: id,
                name: name,
                brand: brand,
                servingSize: servingSize,
                servingUnit: servingUnit,
                baseUnit: baseUnit,
                caloriesPer100: caloriesPer100,
                proteinPer100: proteinPer100,
                carbsPer100: carbsPer100,
                fatPer100: fatPer100,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                userId: userId,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> brand = const Value.absent(),
                Value<double?> servingSize = const Value.absent(),
                Value<String?> servingUnit = const Value.absent(),
                required String baseUnit,
                required double caloriesPer100,
                required double proteinPer100,
                required double carbsPer100,
                required double fatPer100,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductRowsCompanion.insert(
                id: id,
                name: name,
                brand: brand,
                servingSize: servingSize,
                servingUnit: servingUnit,
                baseUnit: baseUnit,
                caloriesPer100: caloriesPer100,
                proteinPer100: proteinPer100,
                carbsPer100: carbsPer100,
                fatPer100: fatPer100,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                userId: userId,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductRowsTable,
      ProductRow,
      $$ProductRowsTableFilterComposer,
      $$ProductRowsTableOrderingComposer,
      $$ProductRowsTableAnnotationComposer,
      $$ProductRowsTableCreateCompanionBuilder,
      $$ProductRowsTableUpdateCompanionBuilder,
      (
        ProductRow,
        BaseReferences<_$AppDatabase, $ProductRowsTable, ProductRow>,
      ),
      ProductRow,
      PrefetchHooks Function()
    >;
typedef $$LogItemRowsTableCreateCompanionBuilder =
    LogItemRowsCompanion Function({
      required String id,
      required String productId,
      required String mealType,
      required double quantity,
      required String unit,
      required double calories,
      required double protein,
      required double carbs,
      required double fat,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> userId,
      Value<String> syncStatus,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });
typedef $$LogItemRowsTableUpdateCompanionBuilder =
    LogItemRowsCompanion Function({
      Value<String> id,
      Value<String> productId,
      Value<String> mealType,
      Value<double> quantity,
      Value<String> unit,
      Value<double> calories,
      Value<double> protein,
      Value<double> carbs,
      Value<double> fat,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> userId,
      Value<String> syncStatus,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });

class $$LogItemRowsTableFilterComposer
    extends Composer<_$AppDatabase, $LogItemRowsTable> {
  $$LogItemRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mealType => $composableBuilder(
    column: $table.mealType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LogItemRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $LogItemRowsTable> {
  $$LogItemRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mealType => $composableBuilder(
    column: $table.mealType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LogItemRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LogItemRowsTable> {
  $$LogItemRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get mealType =>
      $composableBuilder(column: $table.mealType, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<double> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);

  GeneratedColumn<double> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$LogItemRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LogItemRowsTable,
          LogItemRow,
          $$LogItemRowsTableFilterComposer,
          $$LogItemRowsTableOrderingComposer,
          $$LogItemRowsTableAnnotationComposer,
          $$LogItemRowsTableCreateCompanionBuilder,
          $$LogItemRowsTableUpdateCompanionBuilder,
          (
            LogItemRow,
            BaseReferences<_$AppDatabase, $LogItemRowsTable, LogItemRow>,
          ),
          LogItemRow,
          PrefetchHooks Function()
        > {
  $$LogItemRowsTableTableManager(_$AppDatabase db, $LogItemRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LogItemRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LogItemRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LogItemRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> mealType = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<double> calories = const Value.absent(),
                Value<double> protein = const Value.absent(),
                Value<double> carbs = const Value.absent(),
                Value<double> fat = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LogItemRowsCompanion(
                id: id,
                productId: productId,
                mealType: mealType,
                quantity: quantity,
                unit: unit,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                userId: userId,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productId,
                required String mealType,
                required double quantity,
                required String unit,
                required double calories,
                required double protein,
                required double carbs,
                required double fat,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LogItemRowsCompanion.insert(
                id: id,
                productId: productId,
                mealType: mealType,
                quantity: quantity,
                unit: unit,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                userId: userId,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LogItemRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LogItemRowsTable,
      LogItemRow,
      $$LogItemRowsTableFilterComposer,
      $$LogItemRowsTableOrderingComposer,
      $$LogItemRowsTableAnnotationComposer,
      $$LogItemRowsTableCreateCompanionBuilder,
      $$LogItemRowsTableUpdateCompanionBuilder,
      (
        LogItemRow,
        BaseReferences<_$AppDatabase, $LogItemRowsTable, LogItemRow>,
      ),
      LogItemRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProductRowsTableTableManager get productRows =>
      $$ProductRowsTableTableManager(_db, _db.productRows);
  $$LogItemRowsTableTableManager get logItemRows =>
      $$LogItemRowsTableTableManager(_db, _db.logItemRows);
}
