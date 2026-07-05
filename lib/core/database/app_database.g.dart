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
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sugarPer100Meta = const VerificationMeta(
    'sugarPer100',
  );
  @override
  late final GeneratedColumn<double> sugarPer100 = GeneratedColumn<double>(
    'sugar_per100',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _saturatedFatPer100Meta =
      const VerificationMeta('saturatedFatPer100');
  @override
  late final GeneratedColumn<double> saturatedFatPer100 =
      GeneratedColumn<double>(
        'saturated_fat_per100',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sodiumPer100Meta = const VerificationMeta(
    'sodiumPer100',
  );
  @override
  late final GeneratedColumn<double> sodiumPer100 = GeneratedColumn<double>(
    'sodium_per100',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fiberPer100Meta = const VerificationMeta(
    'fiberPer100',
  );
  @override
  late final GeneratedColumn<double> fiberPer100 = GeneratedColumn<double>(
    'fiber_per100',
    aliasedName,
    true,
    type: DriftSqlType.double,
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
    barcode,
    source,
    sugarPer100,
    saturatedFatPer100,
    sodiumPer100,
    fiberPer100,
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
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('sugar_per100')) {
      context.handle(
        _sugarPer100Meta,
        sugarPer100.isAcceptableOrUnknown(
          data['sugar_per100']!,
          _sugarPer100Meta,
        ),
      );
    }
    if (data.containsKey('saturated_fat_per100')) {
      context.handle(
        _saturatedFatPer100Meta,
        saturatedFatPer100.isAcceptableOrUnknown(
          data['saturated_fat_per100']!,
          _saturatedFatPer100Meta,
        ),
      );
    }
    if (data.containsKey('sodium_per100')) {
      context.handle(
        _sodiumPer100Meta,
        sodiumPer100.isAcceptableOrUnknown(
          data['sodium_per100']!,
          _sodiumPer100Meta,
        ),
      );
    }
    if (data.containsKey('fiber_per100')) {
      context.handle(
        _fiberPer100Meta,
        fiberPer100.isAcceptableOrUnknown(
          data['fiber_per100']!,
          _fiberPer100Meta,
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
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
      sugarPer100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sugar_per100'],
      ),
      saturatedFatPer100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}saturated_fat_per100'],
      ),
      sodiumPer100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sodium_per100'],
      ),
      fiberPer100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fiber_per100'],
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
  final String? barcode;
  final String? source;
  final double? sugarPer100;
  final double? saturatedFatPer100;
  final double? sodiumPer100;
  final double? fiberPer100;
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
    this.barcode,
    this.source,
    this.sugarPer100,
    this.saturatedFatPer100,
    this.sodiumPer100,
    this.fiberPer100,
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
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    if (!nullToAbsent || sugarPer100 != null) {
      map['sugar_per100'] = Variable<double>(sugarPer100);
    }
    if (!nullToAbsent || saturatedFatPer100 != null) {
      map['saturated_fat_per100'] = Variable<double>(saturatedFatPer100);
    }
    if (!nullToAbsent || sodiumPer100 != null) {
      map['sodium_per100'] = Variable<double>(sodiumPer100);
    }
    if (!nullToAbsent || fiberPer100 != null) {
      map['fiber_per100'] = Variable<double>(fiberPer100);
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
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
      sugarPer100: sugarPer100 == null && nullToAbsent
          ? const Value.absent()
          : Value(sugarPer100),
      saturatedFatPer100: saturatedFatPer100 == null && nullToAbsent
          ? const Value.absent()
          : Value(saturatedFatPer100),
      sodiumPer100: sodiumPer100 == null && nullToAbsent
          ? const Value.absent()
          : Value(sodiumPer100),
      fiberPer100: fiberPer100 == null && nullToAbsent
          ? const Value.absent()
          : Value(fiberPer100),
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
      barcode: serializer.fromJson<String?>(json['barcode']),
      source: serializer.fromJson<String?>(json['source']),
      sugarPer100: serializer.fromJson<double?>(json['sugarPer100']),
      saturatedFatPer100: serializer.fromJson<double?>(
        json['saturatedFatPer100'],
      ),
      sodiumPer100: serializer.fromJson<double?>(json['sodiumPer100']),
      fiberPer100: serializer.fromJson<double?>(json['fiberPer100']),
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
      'barcode': serializer.toJson<String?>(barcode),
      'source': serializer.toJson<String?>(source),
      'sugarPer100': serializer.toJson<double?>(sugarPer100),
      'saturatedFatPer100': serializer.toJson<double?>(saturatedFatPer100),
      'sodiumPer100': serializer.toJson<double?>(sodiumPer100),
      'fiberPer100': serializer.toJson<double?>(fiberPer100),
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
    Value<String?> barcode = const Value.absent(),
    Value<String?> source = const Value.absent(),
    Value<double?> sugarPer100 = const Value.absent(),
    Value<double?> saturatedFatPer100 = const Value.absent(),
    Value<double?> sodiumPer100 = const Value.absent(),
    Value<double?> fiberPer100 = const Value.absent(),
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
    barcode: barcode.present ? barcode.value : this.barcode,
    source: source.present ? source.value : this.source,
    sugarPer100: sugarPer100.present ? sugarPer100.value : this.sugarPer100,
    saturatedFatPer100: saturatedFatPer100.present
        ? saturatedFatPer100.value
        : this.saturatedFatPer100,
    sodiumPer100: sodiumPer100.present ? sodiumPer100.value : this.sodiumPer100,
    fiberPer100: fiberPer100.present ? fiberPer100.value : this.fiberPer100,
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
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      source: data.source.present ? data.source.value : this.source,
      sugarPer100: data.sugarPer100.present
          ? data.sugarPer100.value
          : this.sugarPer100,
      saturatedFatPer100: data.saturatedFatPer100.present
          ? data.saturatedFatPer100.value
          : this.saturatedFatPer100,
      sodiumPer100: data.sodiumPer100.present
          ? data.sodiumPer100.value
          : this.sodiumPer100,
      fiberPer100: data.fiberPer100.present
          ? data.fiberPer100.value
          : this.fiberPer100,
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
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('barcode: $barcode, ')
          ..write('source: $source, ')
          ..write('sugarPer100: $sugarPer100, ')
          ..write('saturatedFatPer100: $saturatedFatPer100, ')
          ..write('sodiumPer100: $sodiumPer100, ')
          ..write('fiberPer100: $fiberPer100')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
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
    barcode,
    source,
    sugarPer100,
    saturatedFatPer100,
    sodiumPer100,
    fiberPer100,
  ]);
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
          other.lastSyncedAt == this.lastSyncedAt &&
          other.barcode == this.barcode &&
          other.source == this.source &&
          other.sugarPer100 == this.sugarPer100 &&
          other.saturatedFatPer100 == this.saturatedFatPer100 &&
          other.sodiumPer100 == this.sodiumPer100 &&
          other.fiberPer100 == this.fiberPer100);
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
  final Value<String?> barcode;
  final Value<String?> source;
  final Value<double?> sugarPer100;
  final Value<double?> saturatedFatPer100;
  final Value<double?> sodiumPer100;
  final Value<double?> fiberPer100;
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
    this.barcode = const Value.absent(),
    this.source = const Value.absent(),
    this.sugarPer100 = const Value.absent(),
    this.saturatedFatPer100 = const Value.absent(),
    this.sodiumPer100 = const Value.absent(),
    this.fiberPer100 = const Value.absent(),
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
    this.barcode = const Value.absent(),
    this.source = const Value.absent(),
    this.sugarPer100 = const Value.absent(),
    this.saturatedFatPer100 = const Value.absent(),
    this.sodiumPer100 = const Value.absent(),
    this.fiberPer100 = const Value.absent(),
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
    Expression<String>? barcode,
    Expression<String>? source,
    Expression<double>? sugarPer100,
    Expression<double>? saturatedFatPer100,
    Expression<double>? sodiumPer100,
    Expression<double>? fiberPer100,
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
      if (barcode != null) 'barcode': barcode,
      if (source != null) 'source': source,
      if (sugarPer100 != null) 'sugar_per100': sugarPer100,
      if (saturatedFatPer100 != null)
        'saturated_fat_per100': saturatedFatPer100,
      if (sodiumPer100 != null) 'sodium_per100': sodiumPer100,
      if (fiberPer100 != null) 'fiber_per100': fiberPer100,
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
    Value<String?>? barcode,
    Value<String?>? source,
    Value<double?>? sugarPer100,
    Value<double?>? saturatedFatPer100,
    Value<double?>? sodiumPer100,
    Value<double?>? fiberPer100,
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
      barcode: barcode ?? this.barcode,
      source: source ?? this.source,
      sugarPer100: sugarPer100 ?? this.sugarPer100,
      saturatedFatPer100: saturatedFatPer100 ?? this.saturatedFatPer100,
      sodiumPer100: sodiumPer100 ?? this.sodiumPer100,
      fiberPer100: fiberPer100 ?? this.fiberPer100,
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
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (sugarPer100.present) {
      map['sugar_per100'] = Variable<double>(sugarPer100.value);
    }
    if (saturatedFatPer100.present) {
      map['saturated_fat_per100'] = Variable<double>(saturatedFatPer100.value);
    }
    if (sodiumPer100.present) {
      map['sodium_per100'] = Variable<double>(sodiumPer100.value);
    }
    if (fiberPer100.present) {
      map['fiber_per100'] = Variable<double>(fiberPer100.value);
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
          ..write('barcode: $barcode, ')
          ..write('source: $source, ')
          ..write('sugarPer100: $sugarPer100, ')
          ..write('saturatedFatPer100: $saturatedFatPer100, ')
          ..write('sodiumPer100: $sodiumPer100, ')
          ..write('fiberPer100: $fiberPer100, ')
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

class $OcrScanReportRowsTable extends OcrScanReportRows
    with TableInfo<$OcrScanReportRowsTable, OcrScanReportRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OcrScanReportRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawOcrTextMeta = const VerificationMeta(
    'rawOcrText',
  );
  @override
  late final GeneratedColumn<String> rawOcrText = GeneratedColumn<String>(
    'raw_ocr_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parsedJsonMeta = const VerificationMeta(
    'parsedJson',
  );
  @override
  late final GeneratedColumn<String> parsedJson = GeneratedColumn<String>(
    'parsed_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctedJsonMeta = const VerificationMeta(
    'correctedJson',
  );
  @override
  late final GeneratedColumn<String> correctedJson = GeneratedColumn<String>(
    'corrected_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _detectedBasisMeta = const VerificationMeta(
    'detectedBasis',
  );
  @override
  late final GeneratedColumn<String> detectedBasis = GeneratedColumn<String>(
    'detected_basis',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parserWarningsMeta = const VerificationMeta(
    'parserWarnings',
  );
  @override
  late final GeneratedColumn<String> parserWarnings = GeneratedColumn<String>(
    'parser_warnings',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parserConfidenceMeta = const VerificationMeta(
    'parserConfidence',
  );
  @override
  late final GeneratedColumn<double> parserConfidence = GeneratedColumn<double>(
    'parser_confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wasParserCorrectMeta = const VerificationMeta(
    'wasParserCorrect',
  );
  @override
  late final GeneratedColumn<bool> wasParserCorrect = GeneratedColumn<bool>(
    'was_parser_correct',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("was_parser_correct" IN (0, 1))',
    ),
  );
  static const VerificationMeta _userFeedbackMeta = const VerificationMeta(
    'userFeedback',
  );
  @override
  late final GeneratedColumn<String> userFeedback = GeneratedColumn<String>(
    'user_feedback',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ocr'),
  );
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appVersionMeta = const VerificationMeta(
    'appVersion',
  );
  @override
  late final GeneratedColumn<String> appVersion = GeneratedColumn<String>(
    'app_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageSavedMeta = const VerificationMeta(
    'imageSaved',
  );
  @override
  late final GeneratedColumn<bool> imageSaved = GeneratedColumn<bool>(
    'image_saved',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("image_saved" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _imageStoragePathMeta = const VerificationMeta(
    'imageStoragePath',
  );
  @override
  late final GeneratedColumn<String> imageStoragePath = GeneratedColumn<String>(
    'image_storage_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageCropStoragePathMeta =
      const VerificationMeta('imageCropStoragePath');
  @override
  late final GeneratedColumn<String> imageCropStoragePath =
      GeneratedColumn<String>(
        'image_crop_storage_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _imagePathLocalMeta = const VerificationMeta(
    'imagePathLocal',
  );
  @override
  late final GeneratedColumn<String> imagePathLocal = GeneratedColumn<String>(
    'image_path_local',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    rawOcrText,
    parsedJson,
    correctedJson,
    detectedBasis,
    parserWarnings,
    parserConfidence,
    wasParserCorrect,
    userFeedback,
    productId,
    productName,
    barcode,
    source,
    platform,
    appVersion,
    imageSaved,
    imageStoragePath,
    imageCropStoragePath,
    imagePathLocal,
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
  static const String $name = 'ocr_scan_reports';
  @override
  VerificationContext validateIntegrity(
    Insertable<OcrScanReportRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('raw_ocr_text')) {
      context.handle(
        _rawOcrTextMeta,
        rawOcrText.isAcceptableOrUnknown(
          data['raw_ocr_text']!,
          _rawOcrTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rawOcrTextMeta);
    }
    if (data.containsKey('parsed_json')) {
      context.handle(
        _parsedJsonMeta,
        parsedJson.isAcceptableOrUnknown(data['parsed_json']!, _parsedJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_parsedJsonMeta);
    }
    if (data.containsKey('corrected_json')) {
      context.handle(
        _correctedJsonMeta,
        correctedJson.isAcceptableOrUnknown(
          data['corrected_json']!,
          _correctedJsonMeta,
        ),
      );
    }
    if (data.containsKey('detected_basis')) {
      context.handle(
        _detectedBasisMeta,
        detectedBasis.isAcceptableOrUnknown(
          data['detected_basis']!,
          _detectedBasisMeta,
        ),
      );
    }
    if (data.containsKey('parser_warnings')) {
      context.handle(
        _parserWarningsMeta,
        parserWarnings.isAcceptableOrUnknown(
          data['parser_warnings']!,
          _parserWarningsMeta,
        ),
      );
    }
    if (data.containsKey('parser_confidence')) {
      context.handle(
        _parserConfidenceMeta,
        parserConfidence.isAcceptableOrUnknown(
          data['parser_confidence']!,
          _parserConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('was_parser_correct')) {
      context.handle(
        _wasParserCorrectMeta,
        wasParserCorrect.isAcceptableOrUnknown(
          data['was_parser_correct']!,
          _wasParserCorrectMeta,
        ),
      );
    }
    if (data.containsKey('user_feedback')) {
      context.handle(
        _userFeedbackMeta,
        userFeedback.isAcceptableOrUnknown(
          data['user_feedback']!,
          _userFeedbackMeta,
        ),
      );
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    } else if (isInserting) {
      context.missing(_platformMeta);
    }
    if (data.containsKey('app_version')) {
      context.handle(
        _appVersionMeta,
        appVersion.isAcceptableOrUnknown(data['app_version']!, _appVersionMeta),
      );
    }
    if (data.containsKey('image_saved')) {
      context.handle(
        _imageSavedMeta,
        imageSaved.isAcceptableOrUnknown(data['image_saved']!, _imageSavedMeta),
      );
    }
    if (data.containsKey('image_storage_path')) {
      context.handle(
        _imageStoragePathMeta,
        imageStoragePath.isAcceptableOrUnknown(
          data['image_storage_path']!,
          _imageStoragePathMeta,
        ),
      );
    }
    if (data.containsKey('image_crop_storage_path')) {
      context.handle(
        _imageCropStoragePathMeta,
        imageCropStoragePath.isAcceptableOrUnknown(
          data['image_crop_storage_path']!,
          _imageCropStoragePathMeta,
        ),
      );
    }
    if (data.containsKey('image_path_local')) {
      context.handle(
        _imagePathLocalMeta,
        imagePathLocal.isAcceptableOrUnknown(
          data['image_path_local']!,
          _imagePathLocalMeta,
        ),
      );
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
  OcrScanReportRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OcrScanReportRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      rawOcrText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_ocr_text'],
      )!,
      parsedJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parsed_json'],
      )!,
      correctedJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}corrected_json'],
      ),
      detectedBasis: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detected_basis'],
      ),
      parserWarnings: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parser_warnings'],
      ),
      parserConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}parser_confidence'],
      ),
      wasParserCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}was_parser_correct'],
      ),
      userFeedback: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_feedback'],
      ),
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      ),
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      ),
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      platform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform'],
      )!,
      appVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_version'],
      ),
      imageSaved: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}image_saved'],
      )!,
      imageStoragePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_storage_path'],
      ),
      imageCropStoragePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_crop_storage_path'],
      ),
      imagePathLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path_local'],
      ),
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
  $OcrScanReportRowsTable createAlias(String alias) {
    return $OcrScanReportRowsTable(attachedDatabase, alias);
  }
}

class OcrScanReportRow extends DataClass
    implements Insertable<OcrScanReportRow> {
  final String id;
  final String rawOcrText;
  final String parsedJson;
  final String? correctedJson;
  final String? detectedBasis;
  final String? parserWarnings;
  final double? parserConfidence;
  final bool? wasParserCorrect;
  final String? userFeedback;
  final String? productId;
  final String? productName;
  final String? barcode;
  final String source;
  final String platform;
  final String? appVersion;
  final bool imageSaved;
  final String? imageStoragePath;
  final String? imageCropStoragePath;
  final String? imagePathLocal;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? userId;
  final String syncStatus;
  final DateTime? lastSyncedAt;
  const OcrScanReportRow({
    required this.id,
    required this.rawOcrText,
    required this.parsedJson,
    this.correctedJson,
    this.detectedBasis,
    this.parserWarnings,
    this.parserConfidence,
    this.wasParserCorrect,
    this.userFeedback,
    this.productId,
    this.productName,
    this.barcode,
    required this.source,
    required this.platform,
    this.appVersion,
    required this.imageSaved,
    this.imageStoragePath,
    this.imageCropStoragePath,
    this.imagePathLocal,
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
    map['raw_ocr_text'] = Variable<String>(rawOcrText);
    map['parsed_json'] = Variable<String>(parsedJson);
    if (!nullToAbsent || correctedJson != null) {
      map['corrected_json'] = Variable<String>(correctedJson);
    }
    if (!nullToAbsent || detectedBasis != null) {
      map['detected_basis'] = Variable<String>(detectedBasis);
    }
    if (!nullToAbsent || parserWarnings != null) {
      map['parser_warnings'] = Variable<String>(parserWarnings);
    }
    if (!nullToAbsent || parserConfidence != null) {
      map['parser_confidence'] = Variable<double>(parserConfidence);
    }
    if (!nullToAbsent || wasParserCorrect != null) {
      map['was_parser_correct'] = Variable<bool>(wasParserCorrect);
    }
    if (!nullToAbsent || userFeedback != null) {
      map['user_feedback'] = Variable<String>(userFeedback);
    }
    if (!nullToAbsent || productId != null) {
      map['product_id'] = Variable<String>(productId);
    }
    if (!nullToAbsent || productName != null) {
      map['product_name'] = Variable<String>(productName);
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['source'] = Variable<String>(source);
    map['platform'] = Variable<String>(platform);
    if (!nullToAbsent || appVersion != null) {
      map['app_version'] = Variable<String>(appVersion);
    }
    map['image_saved'] = Variable<bool>(imageSaved);
    if (!nullToAbsent || imageStoragePath != null) {
      map['image_storage_path'] = Variable<String>(imageStoragePath);
    }
    if (!nullToAbsent || imageCropStoragePath != null) {
      map['image_crop_storage_path'] = Variable<String>(imageCropStoragePath);
    }
    if (!nullToAbsent || imagePathLocal != null) {
      map['image_path_local'] = Variable<String>(imagePathLocal);
    }
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

  OcrScanReportRowsCompanion toCompanion(bool nullToAbsent) {
    return OcrScanReportRowsCompanion(
      id: Value(id),
      rawOcrText: Value(rawOcrText),
      parsedJson: Value(parsedJson),
      correctedJson: correctedJson == null && nullToAbsent
          ? const Value.absent()
          : Value(correctedJson),
      detectedBasis: detectedBasis == null && nullToAbsent
          ? const Value.absent()
          : Value(detectedBasis),
      parserWarnings: parserWarnings == null && nullToAbsent
          ? const Value.absent()
          : Value(parserWarnings),
      parserConfidence: parserConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(parserConfidence),
      wasParserCorrect: wasParserCorrect == null && nullToAbsent
          ? const Value.absent()
          : Value(wasParserCorrect),
      userFeedback: userFeedback == null && nullToAbsent
          ? const Value.absent()
          : Value(userFeedback),
      productId: productId == null && nullToAbsent
          ? const Value.absent()
          : Value(productId),
      productName: productName == null && nullToAbsent
          ? const Value.absent()
          : Value(productName),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      source: Value(source),
      platform: Value(platform),
      appVersion: appVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(appVersion),
      imageSaved: Value(imageSaved),
      imageStoragePath: imageStoragePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imageStoragePath),
      imageCropStoragePath: imageCropStoragePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imageCropStoragePath),
      imagePathLocal: imagePathLocal == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePathLocal),
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

  factory OcrScanReportRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OcrScanReportRow(
      id: serializer.fromJson<String>(json['id']),
      rawOcrText: serializer.fromJson<String>(json['rawOcrText']),
      parsedJson: serializer.fromJson<String>(json['parsedJson']),
      correctedJson: serializer.fromJson<String?>(json['correctedJson']),
      detectedBasis: serializer.fromJson<String?>(json['detectedBasis']),
      parserWarnings: serializer.fromJson<String?>(json['parserWarnings']),
      parserConfidence: serializer.fromJson<double?>(json['parserConfidence']),
      wasParserCorrect: serializer.fromJson<bool?>(json['wasParserCorrect']),
      userFeedback: serializer.fromJson<String?>(json['userFeedback']),
      productId: serializer.fromJson<String?>(json['productId']),
      productName: serializer.fromJson<String?>(json['productName']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      source: serializer.fromJson<String>(json['source']),
      platform: serializer.fromJson<String>(json['platform']),
      appVersion: serializer.fromJson<String?>(json['appVersion']),
      imageSaved: serializer.fromJson<bool>(json['imageSaved']),
      imageStoragePath: serializer.fromJson<String?>(json['imageStoragePath']),
      imageCropStoragePath: serializer.fromJson<String?>(
        json['imageCropStoragePath'],
      ),
      imagePathLocal: serializer.fromJson<String?>(json['imagePathLocal']),
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
      'rawOcrText': serializer.toJson<String>(rawOcrText),
      'parsedJson': serializer.toJson<String>(parsedJson),
      'correctedJson': serializer.toJson<String?>(correctedJson),
      'detectedBasis': serializer.toJson<String?>(detectedBasis),
      'parserWarnings': serializer.toJson<String?>(parserWarnings),
      'parserConfidence': serializer.toJson<double?>(parserConfidence),
      'wasParserCorrect': serializer.toJson<bool?>(wasParserCorrect),
      'userFeedback': serializer.toJson<String?>(userFeedback),
      'productId': serializer.toJson<String?>(productId),
      'productName': serializer.toJson<String?>(productName),
      'barcode': serializer.toJson<String?>(barcode),
      'source': serializer.toJson<String>(source),
      'platform': serializer.toJson<String>(platform),
      'appVersion': serializer.toJson<String?>(appVersion),
      'imageSaved': serializer.toJson<bool>(imageSaved),
      'imageStoragePath': serializer.toJson<String?>(imageStoragePath),
      'imageCropStoragePath': serializer.toJson<String?>(imageCropStoragePath),
      'imagePathLocal': serializer.toJson<String?>(imagePathLocal),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'userId': serializer.toJson<String?>(userId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  OcrScanReportRow copyWith({
    String? id,
    String? rawOcrText,
    String? parsedJson,
    Value<String?> correctedJson = const Value.absent(),
    Value<String?> detectedBasis = const Value.absent(),
    Value<String?> parserWarnings = const Value.absent(),
    Value<double?> parserConfidence = const Value.absent(),
    Value<bool?> wasParserCorrect = const Value.absent(),
    Value<String?> userFeedback = const Value.absent(),
    Value<String?> productId = const Value.absent(),
    Value<String?> productName = const Value.absent(),
    Value<String?> barcode = const Value.absent(),
    String? source,
    String? platform,
    Value<String?> appVersion = const Value.absent(),
    bool? imageSaved,
    Value<String?> imageStoragePath = const Value.absent(),
    Value<String?> imageCropStoragePath = const Value.absent(),
    Value<String?> imagePathLocal = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> userId = const Value.absent(),
    String? syncStatus,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => OcrScanReportRow(
    id: id ?? this.id,
    rawOcrText: rawOcrText ?? this.rawOcrText,
    parsedJson: parsedJson ?? this.parsedJson,
    correctedJson: correctedJson.present
        ? correctedJson.value
        : this.correctedJson,
    detectedBasis: detectedBasis.present
        ? detectedBasis.value
        : this.detectedBasis,
    parserWarnings: parserWarnings.present
        ? parserWarnings.value
        : this.parserWarnings,
    parserConfidence: parserConfidence.present
        ? parserConfidence.value
        : this.parserConfidence,
    wasParserCorrect: wasParserCorrect.present
        ? wasParserCorrect.value
        : this.wasParserCorrect,
    userFeedback: userFeedback.present ? userFeedback.value : this.userFeedback,
    productId: productId.present ? productId.value : this.productId,
    productName: productName.present ? productName.value : this.productName,
    barcode: barcode.present ? barcode.value : this.barcode,
    source: source ?? this.source,
    platform: platform ?? this.platform,
    appVersion: appVersion.present ? appVersion.value : this.appVersion,
    imageSaved: imageSaved ?? this.imageSaved,
    imageStoragePath: imageStoragePath.present
        ? imageStoragePath.value
        : this.imageStoragePath,
    imageCropStoragePath: imageCropStoragePath.present
        ? imageCropStoragePath.value
        : this.imageCropStoragePath,
    imagePathLocal: imagePathLocal.present
        ? imagePathLocal.value
        : this.imagePathLocal,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    userId: userId.present ? userId.value : this.userId,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  OcrScanReportRow copyWithCompanion(OcrScanReportRowsCompanion data) {
    return OcrScanReportRow(
      id: data.id.present ? data.id.value : this.id,
      rawOcrText: data.rawOcrText.present
          ? data.rawOcrText.value
          : this.rawOcrText,
      parsedJson: data.parsedJson.present
          ? data.parsedJson.value
          : this.parsedJson,
      correctedJson: data.correctedJson.present
          ? data.correctedJson.value
          : this.correctedJson,
      detectedBasis: data.detectedBasis.present
          ? data.detectedBasis.value
          : this.detectedBasis,
      parserWarnings: data.parserWarnings.present
          ? data.parserWarnings.value
          : this.parserWarnings,
      parserConfidence: data.parserConfidence.present
          ? data.parserConfidence.value
          : this.parserConfidence,
      wasParserCorrect: data.wasParserCorrect.present
          ? data.wasParserCorrect.value
          : this.wasParserCorrect,
      userFeedback: data.userFeedback.present
          ? data.userFeedback.value
          : this.userFeedback,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      source: data.source.present ? data.source.value : this.source,
      platform: data.platform.present ? data.platform.value : this.platform,
      appVersion: data.appVersion.present
          ? data.appVersion.value
          : this.appVersion,
      imageSaved: data.imageSaved.present
          ? data.imageSaved.value
          : this.imageSaved,
      imageStoragePath: data.imageStoragePath.present
          ? data.imageStoragePath.value
          : this.imageStoragePath,
      imageCropStoragePath: data.imageCropStoragePath.present
          ? data.imageCropStoragePath.value
          : this.imageCropStoragePath,
      imagePathLocal: data.imagePathLocal.present
          ? data.imagePathLocal.value
          : this.imagePathLocal,
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
    return (StringBuffer('OcrScanReportRow(')
          ..write('id: $id, ')
          ..write('rawOcrText: $rawOcrText, ')
          ..write('parsedJson: $parsedJson, ')
          ..write('correctedJson: $correctedJson, ')
          ..write('detectedBasis: $detectedBasis, ')
          ..write('parserWarnings: $parserWarnings, ')
          ..write('parserConfidence: $parserConfidence, ')
          ..write('wasParserCorrect: $wasParserCorrect, ')
          ..write('userFeedback: $userFeedback, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('barcode: $barcode, ')
          ..write('source: $source, ')
          ..write('platform: $platform, ')
          ..write('appVersion: $appVersion, ')
          ..write('imageSaved: $imageSaved, ')
          ..write('imageStoragePath: $imageStoragePath, ')
          ..write('imageCropStoragePath: $imageCropStoragePath, ')
          ..write('imagePathLocal: $imagePathLocal, ')
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
  int get hashCode => Object.hashAll([
    id,
    rawOcrText,
    parsedJson,
    correctedJson,
    detectedBasis,
    parserWarnings,
    parserConfidence,
    wasParserCorrect,
    userFeedback,
    productId,
    productName,
    barcode,
    source,
    platform,
    appVersion,
    imageSaved,
    imageStoragePath,
    imageCropStoragePath,
    imagePathLocal,
    createdAt,
    updatedAt,
    deletedAt,
    userId,
    syncStatus,
    lastSyncedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OcrScanReportRow &&
          other.id == this.id &&
          other.rawOcrText == this.rawOcrText &&
          other.parsedJson == this.parsedJson &&
          other.correctedJson == this.correctedJson &&
          other.detectedBasis == this.detectedBasis &&
          other.parserWarnings == this.parserWarnings &&
          other.parserConfidence == this.parserConfidence &&
          other.wasParserCorrect == this.wasParserCorrect &&
          other.userFeedback == this.userFeedback &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.barcode == this.barcode &&
          other.source == this.source &&
          other.platform == this.platform &&
          other.appVersion == this.appVersion &&
          other.imageSaved == this.imageSaved &&
          other.imageStoragePath == this.imageStoragePath &&
          other.imageCropStoragePath == this.imageCropStoragePath &&
          other.imagePathLocal == this.imagePathLocal &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.userId == this.userId &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class OcrScanReportRowsCompanion extends UpdateCompanion<OcrScanReportRow> {
  final Value<String> id;
  final Value<String> rawOcrText;
  final Value<String> parsedJson;
  final Value<String?> correctedJson;
  final Value<String?> detectedBasis;
  final Value<String?> parserWarnings;
  final Value<double?> parserConfidence;
  final Value<bool?> wasParserCorrect;
  final Value<String?> userFeedback;
  final Value<String?> productId;
  final Value<String?> productName;
  final Value<String?> barcode;
  final Value<String> source;
  final Value<String> platform;
  final Value<String?> appVersion;
  final Value<bool> imageSaved;
  final Value<String?> imageStoragePath;
  final Value<String?> imageCropStoragePath;
  final Value<String?> imagePathLocal;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> userId;
  final Value<String> syncStatus;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const OcrScanReportRowsCompanion({
    this.id = const Value.absent(),
    this.rawOcrText = const Value.absent(),
    this.parsedJson = const Value.absent(),
    this.correctedJson = const Value.absent(),
    this.detectedBasis = const Value.absent(),
    this.parserWarnings = const Value.absent(),
    this.parserConfidence = const Value.absent(),
    this.wasParserCorrect = const Value.absent(),
    this.userFeedback = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.barcode = const Value.absent(),
    this.source = const Value.absent(),
    this.platform = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.imageSaved = const Value.absent(),
    this.imageStoragePath = const Value.absent(),
    this.imageCropStoragePath = const Value.absent(),
    this.imagePathLocal = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.userId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OcrScanReportRowsCompanion.insert({
    required String id,
    required String rawOcrText,
    required String parsedJson,
    this.correctedJson = const Value.absent(),
    this.detectedBasis = const Value.absent(),
    this.parserWarnings = const Value.absent(),
    this.parserConfidence = const Value.absent(),
    this.wasParserCorrect = const Value.absent(),
    this.userFeedback = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.barcode = const Value.absent(),
    this.source = const Value.absent(),
    required String platform,
    this.appVersion = const Value.absent(),
    this.imageSaved = const Value.absent(),
    this.imageStoragePath = const Value.absent(),
    this.imageCropStoragePath = const Value.absent(),
    this.imagePathLocal = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.userId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       rawOcrText = Value(rawOcrText),
       parsedJson = Value(parsedJson),
       platform = Value(platform),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<OcrScanReportRow> custom({
    Expression<String>? id,
    Expression<String>? rawOcrText,
    Expression<String>? parsedJson,
    Expression<String>? correctedJson,
    Expression<String>? detectedBasis,
    Expression<String>? parserWarnings,
    Expression<double>? parserConfidence,
    Expression<bool>? wasParserCorrect,
    Expression<String>? userFeedback,
    Expression<String>? productId,
    Expression<String>? productName,
    Expression<String>? barcode,
    Expression<String>? source,
    Expression<String>? platform,
    Expression<String>? appVersion,
    Expression<bool>? imageSaved,
    Expression<String>? imageStoragePath,
    Expression<String>? imageCropStoragePath,
    Expression<String>? imagePathLocal,
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
      if (rawOcrText != null) 'raw_ocr_text': rawOcrText,
      if (parsedJson != null) 'parsed_json': parsedJson,
      if (correctedJson != null) 'corrected_json': correctedJson,
      if (detectedBasis != null) 'detected_basis': detectedBasis,
      if (parserWarnings != null) 'parser_warnings': parserWarnings,
      if (parserConfidence != null) 'parser_confidence': parserConfidence,
      if (wasParserCorrect != null) 'was_parser_correct': wasParserCorrect,
      if (userFeedback != null) 'user_feedback': userFeedback,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (barcode != null) 'barcode': barcode,
      if (source != null) 'source': source,
      if (platform != null) 'platform': platform,
      if (appVersion != null) 'app_version': appVersion,
      if (imageSaved != null) 'image_saved': imageSaved,
      if (imageStoragePath != null) 'image_storage_path': imageStoragePath,
      if (imageCropStoragePath != null)
        'image_crop_storage_path': imageCropStoragePath,
      if (imagePathLocal != null) 'image_path_local': imagePathLocal,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (userId != null) 'user_id': userId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OcrScanReportRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? rawOcrText,
    Value<String>? parsedJson,
    Value<String?>? correctedJson,
    Value<String?>? detectedBasis,
    Value<String?>? parserWarnings,
    Value<double?>? parserConfidence,
    Value<bool?>? wasParserCorrect,
    Value<String?>? userFeedback,
    Value<String?>? productId,
    Value<String?>? productName,
    Value<String?>? barcode,
    Value<String>? source,
    Value<String>? platform,
    Value<String?>? appVersion,
    Value<bool>? imageSaved,
    Value<String?>? imageStoragePath,
    Value<String?>? imageCropStoragePath,
    Value<String?>? imagePathLocal,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? userId,
    Value<String>? syncStatus,
    Value<DateTime?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return OcrScanReportRowsCompanion(
      id: id ?? this.id,
      rawOcrText: rawOcrText ?? this.rawOcrText,
      parsedJson: parsedJson ?? this.parsedJson,
      correctedJson: correctedJson ?? this.correctedJson,
      detectedBasis: detectedBasis ?? this.detectedBasis,
      parserWarnings: parserWarnings ?? this.parserWarnings,
      parserConfidence: parserConfidence ?? this.parserConfidence,
      wasParserCorrect: wasParserCorrect ?? this.wasParserCorrect,
      userFeedback: userFeedback ?? this.userFeedback,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      barcode: barcode ?? this.barcode,
      source: source ?? this.source,
      platform: platform ?? this.platform,
      appVersion: appVersion ?? this.appVersion,
      imageSaved: imageSaved ?? this.imageSaved,
      imageStoragePath: imageStoragePath ?? this.imageStoragePath,
      imageCropStoragePath: imageCropStoragePath ?? this.imageCropStoragePath,
      imagePathLocal: imagePathLocal ?? this.imagePathLocal,
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
    if (rawOcrText.present) {
      map['raw_ocr_text'] = Variable<String>(rawOcrText.value);
    }
    if (parsedJson.present) {
      map['parsed_json'] = Variable<String>(parsedJson.value);
    }
    if (correctedJson.present) {
      map['corrected_json'] = Variable<String>(correctedJson.value);
    }
    if (detectedBasis.present) {
      map['detected_basis'] = Variable<String>(detectedBasis.value);
    }
    if (parserWarnings.present) {
      map['parser_warnings'] = Variable<String>(parserWarnings.value);
    }
    if (parserConfidence.present) {
      map['parser_confidence'] = Variable<double>(parserConfidence.value);
    }
    if (wasParserCorrect.present) {
      map['was_parser_correct'] = Variable<bool>(wasParserCorrect.value);
    }
    if (userFeedback.present) {
      map['user_feedback'] = Variable<String>(userFeedback.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (appVersion.present) {
      map['app_version'] = Variable<String>(appVersion.value);
    }
    if (imageSaved.present) {
      map['image_saved'] = Variable<bool>(imageSaved.value);
    }
    if (imageStoragePath.present) {
      map['image_storage_path'] = Variable<String>(imageStoragePath.value);
    }
    if (imageCropStoragePath.present) {
      map['image_crop_storage_path'] = Variable<String>(
        imageCropStoragePath.value,
      );
    }
    if (imagePathLocal.present) {
      map['image_path_local'] = Variable<String>(imagePathLocal.value);
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
    return (StringBuffer('OcrScanReportRowsCompanion(')
          ..write('id: $id, ')
          ..write('rawOcrText: $rawOcrText, ')
          ..write('parsedJson: $parsedJson, ')
          ..write('correctedJson: $correctedJson, ')
          ..write('detectedBasis: $detectedBasis, ')
          ..write('parserWarnings: $parserWarnings, ')
          ..write('parserConfidence: $parserConfidence, ')
          ..write('wasParserCorrect: $wasParserCorrect, ')
          ..write('userFeedback: $userFeedback, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('barcode: $barcode, ')
          ..write('source: $source, ')
          ..write('platform: $platform, ')
          ..write('appVersion: $appVersion, ')
          ..write('imageSaved: $imageSaved, ')
          ..write('imageStoragePath: $imageStoragePath, ')
          ..write('imageCropStoragePath: $imageCropStoragePath, ')
          ..write('imagePathLocal: $imagePathLocal, ')
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

class $AppSettingRowsTable extends AppSettingRows
    with TableInfo<$AppSettingRowsTable, AppSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingRowsTable createAlias(String alias) {
    return $AppSettingRowsTable(attachedDatabase, alias);
  }
}

class AppSettingRow extends DataClass implements Insertable<AppSettingRow> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AppSettingRow({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingRowsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingRowsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSettingRow copyWith({String? key, String? value, DateTime? updatedAt}) =>
      AppSettingRow(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSettingRow copyWithCompanion(AppSettingRowsCompanion data) {
    return AppSettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingRow(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingRow &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppSettingRowsCompanion extends UpdateCompanion<AppSettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingRowsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingRowsCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<AppSettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingRowsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingRowsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingRowsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
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
  late final $OcrScanReportRowsTable ocrScanReportRows =
      $OcrScanReportRowsTable(this);
  late final $AppSettingRowsTable appSettingRows = $AppSettingRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    productRows,
    logItemRows,
    ocrScanReportRows,
    appSettingRows,
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
      Value<String?> barcode,
      Value<String?> source,
      Value<double?> sugarPer100,
      Value<double?> saturatedFatPer100,
      Value<double?> sodiumPer100,
      Value<double?> fiberPer100,
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
      Value<String?> barcode,
      Value<String?> source,
      Value<double?> sugarPer100,
      Value<double?> saturatedFatPer100,
      Value<double?> sodiumPer100,
      Value<double?> fiberPer100,
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

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sugarPer100 => $composableBuilder(
    column: $table.sugarPer100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get saturatedFatPer100 => $composableBuilder(
    column: $table.saturatedFatPer100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sodiumPer100 => $composableBuilder(
    column: $table.sodiumPer100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fiberPer100 => $composableBuilder(
    column: $table.fiberPer100,
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

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sugarPer100 => $composableBuilder(
    column: $table.sugarPer100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get saturatedFatPer100 => $composableBuilder(
    column: $table.saturatedFatPer100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sodiumPer100 => $composableBuilder(
    column: $table.sodiumPer100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fiberPer100 => $composableBuilder(
    column: $table.fiberPer100,
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

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<double> get sugarPer100 => $composableBuilder(
    column: $table.sugarPer100,
    builder: (column) => column,
  );

  GeneratedColumn<double> get saturatedFatPer100 => $composableBuilder(
    column: $table.saturatedFatPer100,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sodiumPer100 => $composableBuilder(
    column: $table.sodiumPer100,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fiberPer100 => $composableBuilder(
    column: $table.fiberPer100,
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
                Value<String?> barcode = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<double?> sugarPer100 = const Value.absent(),
                Value<double?> saturatedFatPer100 = const Value.absent(),
                Value<double?> sodiumPer100 = const Value.absent(),
                Value<double?> fiberPer100 = const Value.absent(),
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
                barcode: barcode,
                source: source,
                sugarPer100: sugarPer100,
                saturatedFatPer100: saturatedFatPer100,
                sodiumPer100: sodiumPer100,
                fiberPer100: fiberPer100,
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
                Value<String?> barcode = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<double?> sugarPer100 = const Value.absent(),
                Value<double?> saturatedFatPer100 = const Value.absent(),
                Value<double?> sodiumPer100 = const Value.absent(),
                Value<double?> fiberPer100 = const Value.absent(),
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
                barcode: barcode,
                source: source,
                sugarPer100: sugarPer100,
                saturatedFatPer100: saturatedFatPer100,
                sodiumPer100: sodiumPer100,
                fiberPer100: fiberPer100,
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
typedef $$OcrScanReportRowsTableCreateCompanionBuilder =
    OcrScanReportRowsCompanion Function({
      required String id,
      required String rawOcrText,
      required String parsedJson,
      Value<String?> correctedJson,
      Value<String?> detectedBasis,
      Value<String?> parserWarnings,
      Value<double?> parserConfidence,
      Value<bool?> wasParserCorrect,
      Value<String?> userFeedback,
      Value<String?> productId,
      Value<String?> productName,
      Value<String?> barcode,
      Value<String> source,
      required String platform,
      Value<String?> appVersion,
      Value<bool> imageSaved,
      Value<String?> imageStoragePath,
      Value<String?> imageCropStoragePath,
      Value<String?> imagePathLocal,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> userId,
      Value<String> syncStatus,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });
typedef $$OcrScanReportRowsTableUpdateCompanionBuilder =
    OcrScanReportRowsCompanion Function({
      Value<String> id,
      Value<String> rawOcrText,
      Value<String> parsedJson,
      Value<String?> correctedJson,
      Value<String?> detectedBasis,
      Value<String?> parserWarnings,
      Value<double?> parserConfidence,
      Value<bool?> wasParserCorrect,
      Value<String?> userFeedback,
      Value<String?> productId,
      Value<String?> productName,
      Value<String?> barcode,
      Value<String> source,
      Value<String> platform,
      Value<String?> appVersion,
      Value<bool> imageSaved,
      Value<String?> imageStoragePath,
      Value<String?> imageCropStoragePath,
      Value<String?> imagePathLocal,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> userId,
      Value<String> syncStatus,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });

class $$OcrScanReportRowsTableFilterComposer
    extends Composer<_$AppDatabase, $OcrScanReportRowsTable> {
  $$OcrScanReportRowsTableFilterComposer({
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

  ColumnFilters<String> get rawOcrText => $composableBuilder(
    column: $table.rawOcrText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parsedJson => $composableBuilder(
    column: $table.parsedJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get correctedJson => $composableBuilder(
    column: $table.correctedJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detectedBasis => $composableBuilder(
    column: $table.detectedBasis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parserWarnings => $composableBuilder(
    column: $table.parserWarnings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get parserConfidence => $composableBuilder(
    column: $table.parserConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wasParserCorrect => $composableBuilder(
    column: $table.wasParserCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userFeedback => $composableBuilder(
    column: $table.userFeedback,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get imageSaved => $composableBuilder(
    column: $table.imageSaved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageStoragePath => $composableBuilder(
    column: $table.imageStoragePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageCropStoragePath => $composableBuilder(
    column: $table.imageCropStoragePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePathLocal => $composableBuilder(
    column: $table.imagePathLocal,
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

class $$OcrScanReportRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $OcrScanReportRowsTable> {
  $$OcrScanReportRowsTableOrderingComposer({
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

  ColumnOrderings<String> get rawOcrText => $composableBuilder(
    column: $table.rawOcrText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parsedJson => $composableBuilder(
    column: $table.parsedJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get correctedJson => $composableBuilder(
    column: $table.correctedJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detectedBasis => $composableBuilder(
    column: $table.detectedBasis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parserWarnings => $composableBuilder(
    column: $table.parserWarnings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get parserConfidence => $composableBuilder(
    column: $table.parserConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wasParserCorrect => $composableBuilder(
    column: $table.wasParserCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userFeedback => $composableBuilder(
    column: $table.userFeedback,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get imageSaved => $composableBuilder(
    column: $table.imageSaved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageStoragePath => $composableBuilder(
    column: $table.imageStoragePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageCropStoragePath => $composableBuilder(
    column: $table.imageCropStoragePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePathLocal => $composableBuilder(
    column: $table.imagePathLocal,
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

class $$OcrScanReportRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OcrScanReportRowsTable> {
  $$OcrScanReportRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rawOcrText => $composableBuilder(
    column: $table.rawOcrText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parsedJson => $composableBuilder(
    column: $table.parsedJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get correctedJson => $composableBuilder(
    column: $table.correctedJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get detectedBasis => $composableBuilder(
    column: $table.detectedBasis,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parserWarnings => $composableBuilder(
    column: $table.parserWarnings,
    builder: (column) => column,
  );

  GeneratedColumn<double> get parserConfidence => $composableBuilder(
    column: $table.parserConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get wasParserCorrect => $composableBuilder(
    column: $table.wasParserCorrect,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userFeedback => $composableBuilder(
    column: $table.userFeedback,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get imageSaved => $composableBuilder(
    column: $table.imageSaved,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageStoragePath => $composableBuilder(
    column: $table.imageStoragePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageCropStoragePath => $composableBuilder(
    column: $table.imageCropStoragePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagePathLocal => $composableBuilder(
    column: $table.imagePathLocal,
    builder: (column) => column,
  );

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

class $$OcrScanReportRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OcrScanReportRowsTable,
          OcrScanReportRow,
          $$OcrScanReportRowsTableFilterComposer,
          $$OcrScanReportRowsTableOrderingComposer,
          $$OcrScanReportRowsTableAnnotationComposer,
          $$OcrScanReportRowsTableCreateCompanionBuilder,
          $$OcrScanReportRowsTableUpdateCompanionBuilder,
          (
            OcrScanReportRow,
            BaseReferences<
              _$AppDatabase,
              $OcrScanReportRowsTable,
              OcrScanReportRow
            >,
          ),
          OcrScanReportRow,
          PrefetchHooks Function()
        > {
  $$OcrScanReportRowsTableTableManager(
    _$AppDatabase db,
    $OcrScanReportRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OcrScanReportRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OcrScanReportRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OcrScanReportRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> rawOcrText = const Value.absent(),
                Value<String> parsedJson = const Value.absent(),
                Value<String?> correctedJson = const Value.absent(),
                Value<String?> detectedBasis = const Value.absent(),
                Value<String?> parserWarnings = const Value.absent(),
                Value<double?> parserConfidence = const Value.absent(),
                Value<bool?> wasParserCorrect = const Value.absent(),
                Value<String?> userFeedback = const Value.absent(),
                Value<String?> productId = const Value.absent(),
                Value<String?> productName = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<String?> appVersion = const Value.absent(),
                Value<bool> imageSaved = const Value.absent(),
                Value<String?> imageStoragePath = const Value.absent(),
                Value<String?> imageCropStoragePath = const Value.absent(),
                Value<String?> imagePathLocal = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OcrScanReportRowsCompanion(
                id: id,
                rawOcrText: rawOcrText,
                parsedJson: parsedJson,
                correctedJson: correctedJson,
                detectedBasis: detectedBasis,
                parserWarnings: parserWarnings,
                parserConfidence: parserConfidence,
                wasParserCorrect: wasParserCorrect,
                userFeedback: userFeedback,
                productId: productId,
                productName: productName,
                barcode: barcode,
                source: source,
                platform: platform,
                appVersion: appVersion,
                imageSaved: imageSaved,
                imageStoragePath: imageStoragePath,
                imageCropStoragePath: imageCropStoragePath,
                imagePathLocal: imagePathLocal,
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
                required String rawOcrText,
                required String parsedJson,
                Value<String?> correctedJson = const Value.absent(),
                Value<String?> detectedBasis = const Value.absent(),
                Value<String?> parserWarnings = const Value.absent(),
                Value<double?> parserConfidence = const Value.absent(),
                Value<bool?> wasParserCorrect = const Value.absent(),
                Value<String?> userFeedback = const Value.absent(),
                Value<String?> productId = const Value.absent(),
                Value<String?> productName = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String> source = const Value.absent(),
                required String platform,
                Value<String?> appVersion = const Value.absent(),
                Value<bool> imageSaved = const Value.absent(),
                Value<String?> imageStoragePath = const Value.absent(),
                Value<String?> imageCropStoragePath = const Value.absent(),
                Value<String?> imagePathLocal = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OcrScanReportRowsCompanion.insert(
                id: id,
                rawOcrText: rawOcrText,
                parsedJson: parsedJson,
                correctedJson: correctedJson,
                detectedBasis: detectedBasis,
                parserWarnings: parserWarnings,
                parserConfidence: parserConfidence,
                wasParserCorrect: wasParserCorrect,
                userFeedback: userFeedback,
                productId: productId,
                productName: productName,
                barcode: barcode,
                source: source,
                platform: platform,
                appVersion: appVersion,
                imageSaved: imageSaved,
                imageStoragePath: imageStoragePath,
                imageCropStoragePath: imageCropStoragePath,
                imagePathLocal: imagePathLocal,
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

typedef $$OcrScanReportRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OcrScanReportRowsTable,
      OcrScanReportRow,
      $$OcrScanReportRowsTableFilterComposer,
      $$OcrScanReportRowsTableOrderingComposer,
      $$OcrScanReportRowsTableAnnotationComposer,
      $$OcrScanReportRowsTableCreateCompanionBuilder,
      $$OcrScanReportRowsTableUpdateCompanionBuilder,
      (
        OcrScanReportRow,
        BaseReferences<
          _$AppDatabase,
          $OcrScanReportRowsTable,
          OcrScanReportRow
        >,
      ),
      OcrScanReportRow,
      PrefetchHooks Function()
    >;
typedef $$AppSettingRowsTableCreateCompanionBuilder =
    AppSettingRowsCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingRowsTableUpdateCompanionBuilder =
    AppSettingRowsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingRowsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingRowsTable> {
  $$AppSettingRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingRowsTable> {
  $$AppSettingRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingRowsTable> {
  $$AppSettingRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingRowsTable,
          AppSettingRow,
          $$AppSettingRowsTableFilterComposer,
          $$AppSettingRowsTableOrderingComposer,
          $$AppSettingRowsTableAnnotationComposer,
          $$AppSettingRowsTableCreateCompanionBuilder,
          $$AppSettingRowsTableUpdateCompanionBuilder,
          (
            AppSettingRow,
            BaseReferences<_$AppDatabase, $AppSettingRowsTable, AppSettingRow>,
          ),
          AppSettingRow,
          PrefetchHooks Function()
        > {
  $$AppSettingRowsTableTableManager(
    _$AppDatabase db,
    $AppSettingRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingRowsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingRowsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingRowsTable,
      AppSettingRow,
      $$AppSettingRowsTableFilterComposer,
      $$AppSettingRowsTableOrderingComposer,
      $$AppSettingRowsTableAnnotationComposer,
      $$AppSettingRowsTableCreateCompanionBuilder,
      $$AppSettingRowsTableUpdateCompanionBuilder,
      (
        AppSettingRow,
        BaseReferences<_$AppDatabase, $AppSettingRowsTable, AppSettingRow>,
      ),
      AppSettingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProductRowsTableTableManager get productRows =>
      $$ProductRowsTableTableManager(_db, _db.productRows);
  $$LogItemRowsTableTableManager get logItemRows =>
      $$LogItemRowsTableTableManager(_db, _db.logItemRows);
  $$OcrScanReportRowsTableTableManager get ocrScanReportRows =>
      $$OcrScanReportRowsTableTableManager(_db, _db.ocrScanReportRows);
  $$AppSettingRowsTableTableManager get appSettingRows =>
      $$AppSettingRowsTableTableManager(_db, _db.appSettingRows);
}
