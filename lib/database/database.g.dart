// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCreditMeta = const VerificationMeta(
    'isCredit',
  );
  @override
  late final GeneratedColumn<bool> isCredit = GeneratedColumn<bool>(
    'is_credit',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_credit" IN (0, 1))',
    ),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TxSource, int> source =
      GeneratedColumn<int>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<TxSource>($TransactionsTable.$convertersource);
  static const VerificationMeta _senderMeta = const VerificationMeta('sender');
  @override
  late final GeneratedColumn<String> sender = GeneratedColumn<String>(
    'sender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _cardMeta = const VerificationMeta('card');
  @override
  late final GeneratedColumn<String> card = GeneratedColumn<String>(
    'card',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _balanceAfterMeta = const VerificationMeta(
    'balanceAfter',
  );
  @override
  late final GeneratedColumn<double> balanceAfter = GeneratedColumn<double>(
    'balance_after',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawMessageMeta = const VerificationMeta(
    'rawMessage',
  );
  @override
  late final GeneratedColumn<String> rawMessage = GeneratedColumn<String>(
    'raw_message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _smsIdMeta = const VerificationMeta('smsId');
  @override
  late final GeneratedColumn<int> smsId = GeneratedColumn<int>(
    'sms_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amount,
    isCredit,
    description,
    date,
    source,
    sender,
    card,
    balanceAfter,
    categoryId,
    rawMessage,
    smsId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('is_credit')) {
      context.handle(
        _isCreditMeta,
        isCredit.isAcceptableOrUnknown(data['is_credit']!, _isCreditMeta),
      );
    } else if (isInserting) {
      context.missing(_isCreditMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('sender')) {
      context.handle(
        _senderMeta,
        sender.isAcceptableOrUnknown(data['sender']!, _senderMeta),
      );
    }
    if (data.containsKey('card')) {
      context.handle(
        _cardMeta,
        card.isAcceptableOrUnknown(data['card']!, _cardMeta),
      );
    }
    if (data.containsKey('balance_after')) {
      context.handle(
        _balanceAfterMeta,
        balanceAfter.isAcceptableOrUnknown(
          data['balance_after']!,
          _balanceAfterMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('raw_message')) {
      context.handle(
        _rawMessageMeta,
        rawMessage.isAcceptableOrUnknown(data['raw_message']!, _rawMessageMeta),
      );
    }
    if (data.containsKey('sms_id')) {
      context.handle(
        _smsIdMeta,
        smsId.isAcceptableOrUnknown(data['sms_id']!, _smsIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      isCredit: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_credit'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      source: $TransactionsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}source'],
        )!,
      ),
      sender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender'],
      )!,
      card: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card'],
      )!,
      balanceAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}balance_after'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      rawMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_message'],
      )!,
      smsId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sms_id'],
      ),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TxSource, int, int> $convertersource =
      const EnumIndexConverter<TxSource>(TxSource.values);
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final double amount;
  final bool isCredit;
  final String description;
  final DateTime date;
  final TxSource source;

  /// Bank sender id, e.g. "bank muscat" (SMS rows only).
  final String sender;

  /// Last 4 digits of the account/card the alert is about (SMS rows only).
  final String card;

  /// The "Avl Bal" the bank reported after this transaction (SMS rows only).
  final double? balanceAfter;

  /// Manual category assignment; overrides automatic shop-name matching.
  final int? categoryId;
  final String rawMessage;
  final int? smsId;
  const Transaction({
    required this.id,
    required this.amount,
    required this.isCredit,
    required this.description,
    required this.date,
    required this.source,
    required this.sender,
    required this.card,
    this.balanceAfter,
    this.categoryId,
    required this.rawMessage,
    this.smsId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount'] = Variable<double>(amount);
    map['is_credit'] = Variable<bool>(isCredit);
    map['description'] = Variable<String>(description);
    map['date'] = Variable<DateTime>(date);
    {
      map['source'] = Variable<int>(
        $TransactionsTable.$convertersource.toSql(source),
      );
    }
    map['sender'] = Variable<String>(sender);
    map['card'] = Variable<String>(card);
    if (!nullToAbsent || balanceAfter != null) {
      map['balance_after'] = Variable<double>(balanceAfter);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['raw_message'] = Variable<String>(rawMessage);
    if (!nullToAbsent || smsId != null) {
      map['sms_id'] = Variable<int>(smsId);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      amount: Value(amount),
      isCredit: Value(isCredit),
      description: Value(description),
      date: Value(date),
      source: Value(source),
      sender: Value(sender),
      card: Value(card),
      balanceAfter: balanceAfter == null && nullToAbsent
          ? const Value.absent()
          : Value(balanceAfter),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      rawMessage: Value(rawMessage),
      smsId: smsId == null && nullToAbsent
          ? const Value.absent()
          : Value(smsId),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      amount: serializer.fromJson<double>(json['amount']),
      isCredit: serializer.fromJson<bool>(json['isCredit']),
      description: serializer.fromJson<String>(json['description']),
      date: serializer.fromJson<DateTime>(json['date']),
      source: $TransactionsTable.$convertersource.fromJson(
        serializer.fromJson<int>(json['source']),
      ),
      sender: serializer.fromJson<String>(json['sender']),
      card: serializer.fromJson<String>(json['card']),
      balanceAfter: serializer.fromJson<double?>(json['balanceAfter']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      rawMessage: serializer.fromJson<String>(json['rawMessage']),
      smsId: serializer.fromJson<int?>(json['smsId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amount': serializer.toJson<double>(amount),
      'isCredit': serializer.toJson<bool>(isCredit),
      'description': serializer.toJson<String>(description),
      'date': serializer.toJson<DateTime>(date),
      'source': serializer.toJson<int>(
        $TransactionsTable.$convertersource.toJson(source),
      ),
      'sender': serializer.toJson<String>(sender),
      'card': serializer.toJson<String>(card),
      'balanceAfter': serializer.toJson<double?>(balanceAfter),
      'categoryId': serializer.toJson<int?>(categoryId),
      'rawMessage': serializer.toJson<String>(rawMessage),
      'smsId': serializer.toJson<int?>(smsId),
    };
  }

  Transaction copyWith({
    int? id,
    double? amount,
    bool? isCredit,
    String? description,
    DateTime? date,
    TxSource? source,
    String? sender,
    String? card,
    Value<double?> balanceAfter = const Value.absent(),
    Value<int?> categoryId = const Value.absent(),
    String? rawMessage,
    Value<int?> smsId = const Value.absent(),
  }) => Transaction(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    isCredit: isCredit ?? this.isCredit,
    description: description ?? this.description,
    date: date ?? this.date,
    source: source ?? this.source,
    sender: sender ?? this.sender,
    card: card ?? this.card,
    balanceAfter: balanceAfter.present ? balanceAfter.value : this.balanceAfter,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    rawMessage: rawMessage ?? this.rawMessage,
    smsId: smsId.present ? smsId.value : this.smsId,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      isCredit: data.isCredit.present ? data.isCredit.value : this.isCredit,
      description: data.description.present
          ? data.description.value
          : this.description,
      date: data.date.present ? data.date.value : this.date,
      source: data.source.present ? data.source.value : this.source,
      sender: data.sender.present ? data.sender.value : this.sender,
      card: data.card.present ? data.card.value : this.card,
      balanceAfter: data.balanceAfter.present
          ? data.balanceAfter.value
          : this.balanceAfter,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      rawMessage: data.rawMessage.present
          ? data.rawMessage.value
          : this.rawMessage,
      smsId: data.smsId.present ? data.smsId.value : this.smsId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('isCredit: $isCredit, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('source: $source, ')
          ..write('sender: $sender, ')
          ..write('card: $card, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('categoryId: $categoryId, ')
          ..write('rawMessage: $rawMessage, ')
          ..write('smsId: $smsId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amount,
    isCredit,
    description,
    date,
    source,
    sender,
    card,
    balanceAfter,
    categoryId,
    rawMessage,
    smsId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.isCredit == this.isCredit &&
          other.description == this.description &&
          other.date == this.date &&
          other.source == this.source &&
          other.sender == this.sender &&
          other.card == this.card &&
          other.balanceAfter == this.balanceAfter &&
          other.categoryId == this.categoryId &&
          other.rawMessage == this.rawMessage &&
          other.smsId == this.smsId);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<double> amount;
  final Value<bool> isCredit;
  final Value<String> description;
  final Value<DateTime> date;
  final Value<TxSource> source;
  final Value<String> sender;
  final Value<String> card;
  final Value<double?> balanceAfter;
  final Value<int?> categoryId;
  final Value<String> rawMessage;
  final Value<int?> smsId;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.isCredit = const Value.absent(),
    this.description = const Value.absent(),
    this.date = const Value.absent(),
    this.source = const Value.absent(),
    this.sender = const Value.absent(),
    this.card = const Value.absent(),
    this.balanceAfter = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.rawMessage = const Value.absent(),
    this.smsId = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required double amount,
    required bool isCredit,
    this.description = const Value.absent(),
    required DateTime date,
    this.source = const Value.absent(),
    this.sender = const Value.absent(),
    this.card = const Value.absent(),
    this.balanceAfter = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.rawMessage = const Value.absent(),
    this.smsId = const Value.absent(),
  }) : amount = Value(amount),
       isCredit = Value(isCredit),
       date = Value(date);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<double>? amount,
    Expression<bool>? isCredit,
    Expression<String>? description,
    Expression<DateTime>? date,
    Expression<int>? source,
    Expression<String>? sender,
    Expression<String>? card,
    Expression<double>? balanceAfter,
    Expression<int>? categoryId,
    Expression<String>? rawMessage,
    Expression<int>? smsId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (isCredit != null) 'is_credit': isCredit,
      if (description != null) 'description': description,
      if (date != null) 'date': date,
      if (source != null) 'source': source,
      if (sender != null) 'sender': sender,
      if (card != null) 'card': card,
      if (balanceAfter != null) 'balance_after': balanceAfter,
      if (categoryId != null) 'category_id': categoryId,
      if (rawMessage != null) 'raw_message': rawMessage,
      if (smsId != null) 'sms_id': smsId,
    });
  }

  TransactionsCompanion copyWith({
    Value<int>? id,
    Value<double>? amount,
    Value<bool>? isCredit,
    Value<String>? description,
    Value<DateTime>? date,
    Value<TxSource>? source,
    Value<String>? sender,
    Value<String>? card,
    Value<double?>? balanceAfter,
    Value<int?>? categoryId,
    Value<String>? rawMessage,
    Value<int?>? smsId,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      isCredit: isCredit ?? this.isCredit,
      description: description ?? this.description,
      date: date ?? this.date,
      source: source ?? this.source,
      sender: sender ?? this.sender,
      card: card ?? this.card,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      categoryId: categoryId ?? this.categoryId,
      rawMessage: rawMessage ?? this.rawMessage,
      smsId: smsId ?? this.smsId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (isCredit.present) {
      map['is_credit'] = Variable<bool>(isCredit.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (source.present) {
      map['source'] = Variable<int>(
        $TransactionsTable.$convertersource.toSql(source.value),
      );
    }
    if (sender.present) {
      map['sender'] = Variable<String>(sender.value);
    }
    if (card.present) {
      map['card'] = Variable<String>(card.value);
    }
    if (balanceAfter.present) {
      map['balance_after'] = Variable<double>(balanceAfter.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (rawMessage.present) {
      map['raw_message'] = Variable<String>(rawMessage.value);
    }
    if (smsId.present) {
      map['sms_id'] = Variable<int>(smsId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('isCredit: $isCredit, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('source: $source, ')
          ..write('sender: $sender, ')
          ..write('card: $card, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('categoryId: $categoryId, ')
          ..write('rawMessage: $rawMessage, ')
          ..write('smsId: $smsId')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#3F6F63'),
  );
  static const VerificationMeta _senderIdsMeta = const VerificationMeta(
    'senderIds',
  );
  @override
  late final GeneratedColumn<String> senderIds = GeneratedColumn<String>(
    'sender_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _shopNamesMeta = const VerificationMeta(
    'shopNames',
  );
  @override
  late final GeneratedColumn<String> shopNames = GeneratedColumn<String>(
    'shop_names',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    color,
    senderIds,
    shopNames,
    parentId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('sender_ids')) {
      context.handle(
        _senderIdsMeta,
        senderIds.isAcceptableOrUnknown(data['sender_ids']!, _senderIdsMeta),
      );
    }
    if (data.containsKey('shop_names')) {
      context.handle(
        _shopNamesMeta,
        shopNames.isAcceptableOrUnknown(data['shop_names']!, _shopNamesMeta),
      );
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      senderIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_ids'],
      )!,
      shopNames: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_names'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_id'],
      ),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  final String color;
  final String senderIds;
  final String shopNames;

  /// The top-level category this one sits under (null = top level).
  final int? parentId;
  const Category({
    required this.id,
    required this.name,
    required this.color,
    required this.senderIds,
    required this.shopNames,
    this.parentId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<String>(color);
    map['sender_ids'] = Variable<String>(senderIds);
    map['shop_names'] = Variable<String>(shopNames);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<int>(parentId);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      senderIds: Value(senderIds),
      shopNames: Value(shopNames),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String>(json['color']),
      senderIds: serializer.fromJson<String>(json['senderIds']),
      shopNames: serializer.fromJson<String>(json['shopNames']),
      parentId: serializer.fromJson<int?>(json['parentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String>(color),
      'senderIds': serializer.toJson<String>(senderIds),
      'shopNames': serializer.toJson<String>(shopNames),
      'parentId': serializer.toJson<int?>(parentId),
    };
  }

  Category copyWith({
    int? id,
    String? name,
    String? color,
    String? senderIds,
    String? shopNames,
    Value<int?> parentId = const Value.absent(),
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    color: color ?? this.color,
    senderIds: senderIds ?? this.senderIds,
    shopNames: shopNames ?? this.shopNames,
    parentId: parentId.present ? parentId.value : this.parentId,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      senderIds: data.senderIds.present ? data.senderIds.value : this.senderIds,
      shopNames: data.shopNames.present ? data.shopNames.value : this.shopNames,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('senderIds: $senderIds, ')
          ..write('shopNames: $shopNames, ')
          ..write('parentId: $parentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, color, senderIds, shopNames, parentId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.senderIds == this.senderIds &&
          other.shopNames == this.shopNames &&
          other.parentId == this.parentId);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> color;
  final Value<String> senderIds;
  final Value<String> shopNames;
  final Value<int?> parentId;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.senderIds = const Value.absent(),
    this.shopNames = const Value.absent(),
    this.parentId = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.color = const Value.absent(),
    this.senderIds = const Value.absent(),
    this.shopNames = const Value.absent(),
    this.parentId = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? color,
    Expression<String>? senderIds,
    Expression<String>? shopNames,
    Expression<int>? parentId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (senderIds != null) 'sender_ids': senderIds,
      if (shopNames != null) 'shop_names': shopNames,
      if (parentId != null) 'parent_id': parentId,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? color,
    Value<String>? senderIds,
    Value<String>? shopNames,
    Value<int?>? parentId,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      senderIds: senderIds ?? this.senderIds,
      shopNames: shopNames ?? this.shopNames,
      parentId: parentId ?? this.parentId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (senderIds.present) {
      map['sender_ids'] = Variable<String>(senderIds.value);
    }
    if (shopNames.present) {
      map['shop_names'] = Variable<String>(shopNames.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('senderIds: $senderIds, ')
          ..write('shopNames: $shopNames, ')
          ..write('parentId: $parentId')
          ..write(')'))
        .toString();
  }
}

class $CategoryRulesTable extends CategoryRules
    with TableInfo<$CategoryRulesTable, CategoryRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderMeta = const VerificationMeta('sender');
  @override
  late final GeneratedColumn<String> sender = GeneratedColumn<String>(
    'sender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _counterpartyMeta = const VerificationMeta(
    'counterparty',
  );
  @override
  late final GeneratedColumn<String> counterparty = GeneratedColumn<String>(
    'counterparty',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exactMeta = const VerificationMeta('exact');
  @override
  late final GeneratedColumn<bool> exact = GeneratedColumn<bool>(
    'exact',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("exact" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _matchAmountMeta = const VerificationMeta(
    'matchAmount',
  );
  @override
  late final GeneratedColumn<bool> matchAmount = GeneratedColumn<bool>(
    'match_amount',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("match_amount" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isCreditMeta = const VerificationMeta(
    'isCredit',
  );
  @override
  late final GeneratedColumn<bool> isCredit = GeneratedColumn<bool>(
    'is_credit',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_credit" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryId,
    sender,
    counterparty,
    exact,
    matchAmount,
    amount,
    isCredit,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('sender')) {
      context.handle(
        _senderMeta,
        sender.isAcceptableOrUnknown(data['sender']!, _senderMeta),
      );
    }
    if (data.containsKey('counterparty')) {
      context.handle(
        _counterpartyMeta,
        counterparty.isAcceptableOrUnknown(
          data['counterparty']!,
          _counterpartyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_counterpartyMeta);
    }
    if (data.containsKey('exact')) {
      context.handle(
        _exactMeta,
        exact.isAcceptableOrUnknown(data['exact']!, _exactMeta),
      );
    }
    if (data.containsKey('match_amount')) {
      context.handle(
        _matchAmountMeta,
        matchAmount.isAcceptableOrUnknown(
          data['match_amount']!,
          _matchAmountMeta,
        ),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('is_credit')) {
      context.handle(
        _isCreditMeta,
        isCredit.isAcceptableOrUnknown(data['is_credit']!, _isCreditMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      sender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender'],
      )!,
      counterparty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}counterparty'],
      )!,
      exact: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}exact'],
      )!,
      matchAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}match_amount'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      isCredit: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_credit'],
      ),
    );
  }

  @override
  $CategoryRulesTable createAlias(String alias) {
    return $CategoryRulesTable(attachedDatabase, alias);
  }
}

class CategoryRule extends DataClass implements Insertable<CategoryRule> {
  final int id;
  final int categoryId;
  final String sender;
  final String counterparty;
  final bool exact;
  final bool matchAmount;
  final double amount;
  final bool? isCredit;
  const CategoryRule({
    required this.id,
    required this.categoryId,
    required this.sender,
    required this.counterparty,
    required this.exact,
    required this.matchAmount,
    required this.amount,
    this.isCredit,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category_id'] = Variable<int>(categoryId);
    map['sender'] = Variable<String>(sender);
    map['counterparty'] = Variable<String>(counterparty);
    map['exact'] = Variable<bool>(exact);
    map['match_amount'] = Variable<bool>(matchAmount);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || isCredit != null) {
      map['is_credit'] = Variable<bool>(isCredit);
    }
    return map;
  }

  CategoryRulesCompanion toCompanion(bool nullToAbsent) {
    return CategoryRulesCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      sender: Value(sender),
      counterparty: Value(counterparty),
      exact: Value(exact),
      matchAmount: Value(matchAmount),
      amount: Value(amount),
      isCredit: isCredit == null && nullToAbsent
          ? const Value.absent()
          : Value(isCredit),
    );
  }

  factory CategoryRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRule(
      id: serializer.fromJson<int>(json['id']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      sender: serializer.fromJson<String>(json['sender']),
      counterparty: serializer.fromJson<String>(json['counterparty']),
      exact: serializer.fromJson<bool>(json['exact']),
      matchAmount: serializer.fromJson<bool>(json['matchAmount']),
      amount: serializer.fromJson<double>(json['amount']),
      isCredit: serializer.fromJson<bool?>(json['isCredit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryId': serializer.toJson<int>(categoryId),
      'sender': serializer.toJson<String>(sender),
      'counterparty': serializer.toJson<String>(counterparty),
      'exact': serializer.toJson<bool>(exact),
      'matchAmount': serializer.toJson<bool>(matchAmount),
      'amount': serializer.toJson<double>(amount),
      'isCredit': serializer.toJson<bool?>(isCredit),
    };
  }

  CategoryRule copyWith({
    int? id,
    int? categoryId,
    String? sender,
    String? counterparty,
    bool? exact,
    bool? matchAmount,
    double? amount,
    Value<bool?> isCredit = const Value.absent(),
  }) => CategoryRule(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    sender: sender ?? this.sender,
    counterparty: counterparty ?? this.counterparty,
    exact: exact ?? this.exact,
    matchAmount: matchAmount ?? this.matchAmount,
    amount: amount ?? this.amount,
    isCredit: isCredit.present ? isCredit.value : this.isCredit,
  );
  CategoryRule copyWithCompanion(CategoryRulesCompanion data) {
    return CategoryRule(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      sender: data.sender.present ? data.sender.value : this.sender,
      counterparty: data.counterparty.present
          ? data.counterparty.value
          : this.counterparty,
      exact: data.exact.present ? data.exact.value : this.exact,
      matchAmount: data.matchAmount.present
          ? data.matchAmount.value
          : this.matchAmount,
      amount: data.amount.present ? data.amount.value : this.amount,
      isCredit: data.isCredit.present ? data.isCredit.value : this.isCredit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRule(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('sender: $sender, ')
          ..write('counterparty: $counterparty, ')
          ..write('exact: $exact, ')
          ..write('matchAmount: $matchAmount, ')
          ..write('amount: $amount, ')
          ..write('isCredit: $isCredit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    categoryId,
    sender,
    counterparty,
    exact,
    matchAmount,
    amount,
    isCredit,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRule &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.sender == this.sender &&
          other.counterparty == this.counterparty &&
          other.exact == this.exact &&
          other.matchAmount == this.matchAmount &&
          other.amount == this.amount &&
          other.isCredit == this.isCredit);
}

class CategoryRulesCompanion extends UpdateCompanion<CategoryRule> {
  final Value<int> id;
  final Value<int> categoryId;
  final Value<String> sender;
  final Value<String> counterparty;
  final Value<bool> exact;
  final Value<bool> matchAmount;
  final Value<double> amount;
  final Value<bool?> isCredit;
  const CategoryRulesCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.sender = const Value.absent(),
    this.counterparty = const Value.absent(),
    this.exact = const Value.absent(),
    this.matchAmount = const Value.absent(),
    this.amount = const Value.absent(),
    this.isCredit = const Value.absent(),
  });
  CategoryRulesCompanion.insert({
    this.id = const Value.absent(),
    required int categoryId,
    this.sender = const Value.absent(),
    required String counterparty,
    this.exact = const Value.absent(),
    this.matchAmount = const Value.absent(),
    this.amount = const Value.absent(),
    this.isCredit = const Value.absent(),
  }) : categoryId = Value(categoryId),
       counterparty = Value(counterparty);
  static Insertable<CategoryRule> custom({
    Expression<int>? id,
    Expression<int>? categoryId,
    Expression<String>? sender,
    Expression<String>? counterparty,
    Expression<bool>? exact,
    Expression<bool>? matchAmount,
    Expression<double>? amount,
    Expression<bool>? isCredit,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (sender != null) 'sender': sender,
      if (counterparty != null) 'counterparty': counterparty,
      if (exact != null) 'exact': exact,
      if (matchAmount != null) 'match_amount': matchAmount,
      if (amount != null) 'amount': amount,
      if (isCredit != null) 'is_credit': isCredit,
    });
  }

  CategoryRulesCompanion copyWith({
    Value<int>? id,
    Value<int>? categoryId,
    Value<String>? sender,
    Value<String>? counterparty,
    Value<bool>? exact,
    Value<bool>? matchAmount,
    Value<double>? amount,
    Value<bool?>? isCredit,
  }) {
    return CategoryRulesCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      sender: sender ?? this.sender,
      counterparty: counterparty ?? this.counterparty,
      exact: exact ?? this.exact,
      matchAmount: matchAmount ?? this.matchAmount,
      amount: amount ?? this.amount,
      isCredit: isCredit ?? this.isCredit,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (sender.present) {
      map['sender'] = Variable<String>(sender.value);
    }
    if (counterparty.present) {
      map['counterparty'] = Variable<String>(counterparty.value);
    }
    if (exact.present) {
      map['exact'] = Variable<bool>(exact.value);
    }
    if (matchAmount.present) {
      map['match_amount'] = Variable<bool>(matchAmount.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (isCredit.present) {
      map['is_credit'] = Variable<bool>(isCredit.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRulesCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('sender: $sender, ')
          ..write('counterparty: $counterparty, ')
          ..write('exact: $exact, ')
          ..write('matchAmount: $matchAmount, ')
          ..write('amount: $amount, ')
          ..write('isCredit: $isCredit')
          ..write(')'))
        .toString();
  }
}

class $CategoryExclusionsTable extends CategoryExclusions
    with TableInfo<$CategoryExclusionsTable, CategoryExclusion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryExclusionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<int> transactionId = GeneratedColumn<int>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, categoryId, transactionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_exclusions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryExclusion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {categoryId, transactionId},
  ];
  @override
  CategoryExclusion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryExclusion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transaction_id'],
      )!,
    );
  }

  @override
  $CategoryExclusionsTable createAlias(String alias) {
    return $CategoryExclusionsTable(attachedDatabase, alias);
  }
}

class CategoryExclusion extends DataClass
    implements Insertable<CategoryExclusion> {
  final int id;
  final int categoryId;
  final int transactionId;
  const CategoryExclusion({
    required this.id,
    required this.categoryId,
    required this.transactionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category_id'] = Variable<int>(categoryId);
    map['transaction_id'] = Variable<int>(transactionId);
    return map;
  }

  CategoryExclusionsCompanion toCompanion(bool nullToAbsent) {
    return CategoryExclusionsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      transactionId: Value(transactionId),
    );
  }

  factory CategoryExclusion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryExclusion(
      id: serializer.fromJson<int>(json['id']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      transactionId: serializer.fromJson<int>(json['transactionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryId': serializer.toJson<int>(categoryId),
      'transactionId': serializer.toJson<int>(transactionId),
    };
  }

  CategoryExclusion copyWith({int? id, int? categoryId, int? transactionId}) =>
      CategoryExclusion(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        transactionId: transactionId ?? this.transactionId,
      );
  CategoryExclusion copyWithCompanion(CategoryExclusionsCompanion data) {
    return CategoryExclusion(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryExclusion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('transactionId: $transactionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, categoryId, transactionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryExclusion &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.transactionId == this.transactionId);
}

class CategoryExclusionsCompanion extends UpdateCompanion<CategoryExclusion> {
  final Value<int> id;
  final Value<int> categoryId;
  final Value<int> transactionId;
  const CategoryExclusionsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.transactionId = const Value.absent(),
  });
  CategoryExclusionsCompanion.insert({
    this.id = const Value.absent(),
    required int categoryId,
    required int transactionId,
  }) : categoryId = Value(categoryId),
       transactionId = Value(transactionId);
  static Insertable<CategoryExclusion> custom({
    Expression<int>? id,
    Expression<int>? categoryId,
    Expression<int>? transactionId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (transactionId != null) 'transaction_id': transactionId,
    });
  }

  CategoryExclusionsCompanion copyWith({
    Value<int>? id,
    Value<int>? categoryId,
    Value<int>? transactionId,
  }) {
    return CategoryExclusionsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      transactionId: transactionId ?? this.transactionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<int>(transactionId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryExclusionsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('transactionId: $transactionId')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, Goal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetAmountMeta = const VerificationMeta(
    'targetAmount',
  );
  @override
  late final GeneratedColumn<double> targetAmount = GeneratedColumn<double>(
    'target_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedAmountMeta = const VerificationMeta(
    'savedAmount',
  );
  @override
  late final GeneratedColumn<double> savedAmount = GeneratedColumn<double>(
    'saved_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _targetDateMeta = const VerificationMeta(
    'targetDate',
  );
  @override
  late final GeneratedColumn<DateTime> targetDate = GeneratedColumn<DateTime>(
    'target_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    targetAmount,
    savedAmount,
    targetDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Goal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target_amount')) {
      context.handle(
        _targetAmountMeta,
        targetAmount.isAcceptableOrUnknown(
          data['target_amount']!,
          _targetAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetAmountMeta);
    }
    if (data.containsKey('saved_amount')) {
      context.handle(
        _savedAmountMeta,
        savedAmount.isAcceptableOrUnknown(
          data['saved_amount']!,
          _savedAmountMeta,
        ),
      );
    }
    if (data.containsKey('target_date')) {
      context.handle(
        _targetDateMeta,
        targetDate.isAcceptableOrUnknown(data['target_date']!, _targetDateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Goal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Goal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      targetAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_amount'],
      )!,
      savedAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}saved_amount'],
      )!,
      targetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}target_date'],
      ),
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }
}

class Goal extends DataClass implements Insertable<Goal> {
  final int id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final DateTime? targetDate;
  const Goal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    this.targetDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['target_amount'] = Variable<double>(targetAmount);
    map['saved_amount'] = Variable<double>(savedAmount);
    if (!nullToAbsent || targetDate != null) {
      map['target_date'] = Variable<DateTime>(targetDate);
    }
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      name: Value(name),
      targetAmount: Value(targetAmount),
      savedAmount: Value(savedAmount),
      targetDate: targetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDate),
    );
  }

  factory Goal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Goal(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      targetAmount: serializer.fromJson<double>(json['targetAmount']),
      savedAmount: serializer.fromJson<double>(json['savedAmount']),
      targetDate: serializer.fromJson<DateTime?>(json['targetDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'targetAmount': serializer.toJson<double>(targetAmount),
      'savedAmount': serializer.toJson<double>(savedAmount),
      'targetDate': serializer.toJson<DateTime?>(targetDate),
    };
  }

  Goal copyWith({
    int? id,
    String? name,
    double? targetAmount,
    double? savedAmount,
    Value<DateTime?> targetDate = const Value.absent(),
  }) => Goal(
    id: id ?? this.id,
    name: name ?? this.name,
    targetAmount: targetAmount ?? this.targetAmount,
    savedAmount: savedAmount ?? this.savedAmount,
    targetDate: targetDate.present ? targetDate.value : this.targetDate,
  );
  Goal copyWithCompanion(GoalsCompanion data) {
    return Goal(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      targetAmount: data.targetAmount.present
          ? data.targetAmount.value
          : this.targetAmount,
      savedAmount: data.savedAmount.present
          ? data.savedAmount.value
          : this.savedAmount,
      targetDate: data.targetDate.present
          ? data.targetDate.value
          : this.targetDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Goal(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('savedAmount: $savedAmount, ')
          ..write('targetDate: $targetDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, targetAmount, savedAmount, targetDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Goal &&
          other.id == this.id &&
          other.name == this.name &&
          other.targetAmount == this.targetAmount &&
          other.savedAmount == this.savedAmount &&
          other.targetDate == this.targetDate);
}

class GoalsCompanion extends UpdateCompanion<Goal> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> targetAmount;
  final Value<double> savedAmount;
  final Value<DateTime?> targetDate;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.targetAmount = const Value.absent(),
    this.savedAmount = const Value.absent(),
    this.targetDate = const Value.absent(),
  });
  GoalsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double targetAmount,
    this.savedAmount = const Value.absent(),
    this.targetDate = const Value.absent(),
  }) : name = Value(name),
       targetAmount = Value(targetAmount);
  static Insertable<Goal> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? targetAmount,
    Expression<double>? savedAmount,
    Expression<DateTime>? targetDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (targetAmount != null) 'target_amount': targetAmount,
      if (savedAmount != null) 'saved_amount': savedAmount,
      if (targetDate != null) 'target_date': targetDate,
    });
  }

  GoalsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<double>? targetAmount,
    Value<double>? savedAmount,
    Value<DateTime?>? targetDate,
  }) {
    return GoalsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      targetDate: targetDate ?? this.targetDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (targetAmount.present) {
      map['target_amount'] = Variable<double>(targetAmount.value);
    }
    if (savedAmount.present) {
      map['saved_amount'] = Variable<double>(savedAmount.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<DateTime>(targetDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('savedAmount: $savedAmount, ')
          ..write('targetDate: $targetDate')
          ..write(')'))
        .toString();
  }
}

class $DebtsTable extends Debts with TableInfo<$DebtsTable, Debt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DebtsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creditorMeta = const VerificationMeta(
    'creditor',
  );
  @override
  late final GeneratedColumn<String> creditor = GeneratedColumn<String>(
    'creditor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidAmountMeta = const VerificationMeta(
    'paidAmount',
  );
  @override
  late final GeneratedColumn<double> paidAmount = GeneratedColumn<double>(
    'paid_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _aprMeta = const VerificationMeta('apr');
  @override
  late final GeneratedColumn<double> apr = GeneratedColumn<double>(
    'apr',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _minPaymentMeta = const VerificationMeta(
    'minPayment',
  );
  @override
  late final GeneratedColumn<double> minPayment = GeneratedColumn<double>(
    'min_payment',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFixedMeta = const VerificationMeta(
    'isFixed',
  );
  @override
  late final GeneratedColumn<bool> isFixed = GeneratedColumn<bool>(
    'is_fixed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_fixed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _fixedAmountMeta = const VerificationMeta(
    'fixedAmount',
  );
  @override
  late final GeneratedColumn<double> fixedAmount = GeneratedColumn<double>(
    'fixed_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _matchSenderMeta = const VerificationMeta(
    'matchSender',
  );
  @override
  late final GeneratedColumn<String> matchSender = GeneratedColumn<String>(
    'match_sender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _matchCardMeta = const VerificationMeta(
    'matchCard',
  );
  @override
  late final GeneratedColumn<String> matchCard = GeneratedColumn<String>(
    'match_card',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _matchCounterpartyMeta = const VerificationMeta(
    'matchCounterparty',
  );
  @override
  late final GeneratedColumn<String> matchCounterparty =
      GeneratedColumn<String>(
        'match_counterparty',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    creditor,
    totalAmount,
    paidAmount,
    apr,
    minPayment,
    dueDate,
    isFixed,
    fixedAmount,
    matchSender,
    matchCard,
    matchCounterparty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'debts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Debt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('creditor')) {
      context.handle(
        _creditorMeta,
        creditor.isAcceptableOrUnknown(data['creditor']!, _creditorMeta),
      );
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('paid_amount')) {
      context.handle(
        _paidAmountMeta,
        paidAmount.isAcceptableOrUnknown(data['paid_amount']!, _paidAmountMeta),
      );
    }
    if (data.containsKey('apr')) {
      context.handle(
        _aprMeta,
        apr.isAcceptableOrUnknown(data['apr']!, _aprMeta),
      );
    }
    if (data.containsKey('min_payment')) {
      context.handle(
        _minPaymentMeta,
        minPayment.isAcceptableOrUnknown(data['min_payment']!, _minPaymentMeta),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('is_fixed')) {
      context.handle(
        _isFixedMeta,
        isFixed.isAcceptableOrUnknown(data['is_fixed']!, _isFixedMeta),
      );
    }
    if (data.containsKey('fixed_amount')) {
      context.handle(
        _fixedAmountMeta,
        fixedAmount.isAcceptableOrUnknown(
          data['fixed_amount']!,
          _fixedAmountMeta,
        ),
      );
    }
    if (data.containsKey('match_sender')) {
      context.handle(
        _matchSenderMeta,
        matchSender.isAcceptableOrUnknown(
          data['match_sender']!,
          _matchSenderMeta,
        ),
      );
    }
    if (data.containsKey('match_card')) {
      context.handle(
        _matchCardMeta,
        matchCard.isAcceptableOrUnknown(data['match_card']!, _matchCardMeta),
      );
    }
    if (data.containsKey('match_counterparty')) {
      context.handle(
        _matchCounterpartyMeta,
        matchCounterparty.isAcceptableOrUnknown(
          data['match_counterparty']!,
          _matchCounterpartyMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Debt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Debt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      creditor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}creditor'],
      )!,
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      )!,
      paidAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}paid_amount'],
      )!,
      apr: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}apr'],
      )!,
      minPayment: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_payment'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      isFixed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_fixed'],
      )!,
      fixedAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fixed_amount'],
      )!,
      matchSender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}match_sender'],
      )!,
      matchCard: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}match_card'],
      )!,
      matchCounterparty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}match_counterparty'],
      )!,
    );
  }

  @override
  $DebtsTable createAlias(String alias) {
    return $DebtsTable(attachedDatabase, alias);
  }
}

class Debt extends DataClass implements Insertable<Debt> {
  final int id;
  final String name;
  final String creditor;
  final double totalAmount;
  final double paidAmount;
  final double apr;
  final double minPayment;
  final DateTime? dueDate;
  final bool isFixed;
  final double fixedAmount;
  final String matchSender;
  final String matchCard;
  final String matchCounterparty;
  const Debt({
    required this.id,
    required this.name,
    required this.creditor,
    required this.totalAmount,
    required this.paidAmount,
    required this.apr,
    required this.minPayment,
    this.dueDate,
    required this.isFixed,
    required this.fixedAmount,
    required this.matchSender,
    required this.matchCard,
    required this.matchCounterparty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['creditor'] = Variable<String>(creditor);
    map['total_amount'] = Variable<double>(totalAmount);
    map['paid_amount'] = Variable<double>(paidAmount);
    map['apr'] = Variable<double>(apr);
    map['min_payment'] = Variable<double>(minPayment);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['is_fixed'] = Variable<bool>(isFixed);
    map['fixed_amount'] = Variable<double>(fixedAmount);
    map['match_sender'] = Variable<String>(matchSender);
    map['match_card'] = Variable<String>(matchCard);
    map['match_counterparty'] = Variable<String>(matchCounterparty);
    return map;
  }

  DebtsCompanion toCompanion(bool nullToAbsent) {
    return DebtsCompanion(
      id: Value(id),
      name: Value(name),
      creditor: Value(creditor),
      totalAmount: Value(totalAmount),
      paidAmount: Value(paidAmount),
      apr: Value(apr),
      minPayment: Value(minPayment),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      isFixed: Value(isFixed),
      fixedAmount: Value(fixedAmount),
      matchSender: Value(matchSender),
      matchCard: Value(matchCard),
      matchCounterparty: Value(matchCounterparty),
    );
  }

  factory Debt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Debt(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      creditor: serializer.fromJson<String>(json['creditor']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      paidAmount: serializer.fromJson<double>(json['paidAmount']),
      apr: serializer.fromJson<double>(json['apr']),
      minPayment: serializer.fromJson<double>(json['minPayment']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      isFixed: serializer.fromJson<bool>(json['isFixed']),
      fixedAmount: serializer.fromJson<double>(json['fixedAmount']),
      matchSender: serializer.fromJson<String>(json['matchSender']),
      matchCard: serializer.fromJson<String>(json['matchCard']),
      matchCounterparty: serializer.fromJson<String>(json['matchCounterparty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'creditor': serializer.toJson<String>(creditor),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'paidAmount': serializer.toJson<double>(paidAmount),
      'apr': serializer.toJson<double>(apr),
      'minPayment': serializer.toJson<double>(minPayment),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'isFixed': serializer.toJson<bool>(isFixed),
      'fixedAmount': serializer.toJson<double>(fixedAmount),
      'matchSender': serializer.toJson<String>(matchSender),
      'matchCard': serializer.toJson<String>(matchCard),
      'matchCounterparty': serializer.toJson<String>(matchCounterparty),
    };
  }

  Debt copyWith({
    int? id,
    String? name,
    String? creditor,
    double? totalAmount,
    double? paidAmount,
    double? apr,
    double? minPayment,
    Value<DateTime?> dueDate = const Value.absent(),
    bool? isFixed,
    double? fixedAmount,
    String? matchSender,
    String? matchCard,
    String? matchCounterparty,
  }) => Debt(
    id: id ?? this.id,
    name: name ?? this.name,
    creditor: creditor ?? this.creditor,
    totalAmount: totalAmount ?? this.totalAmount,
    paidAmount: paidAmount ?? this.paidAmount,
    apr: apr ?? this.apr,
    minPayment: minPayment ?? this.minPayment,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    isFixed: isFixed ?? this.isFixed,
    fixedAmount: fixedAmount ?? this.fixedAmount,
    matchSender: matchSender ?? this.matchSender,
    matchCard: matchCard ?? this.matchCard,
    matchCounterparty: matchCounterparty ?? this.matchCounterparty,
  );
  Debt copyWithCompanion(DebtsCompanion data) {
    return Debt(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      creditor: data.creditor.present ? data.creditor.value : this.creditor,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      paidAmount: data.paidAmount.present
          ? data.paidAmount.value
          : this.paidAmount,
      apr: data.apr.present ? data.apr.value : this.apr,
      minPayment: data.minPayment.present
          ? data.minPayment.value
          : this.minPayment,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      isFixed: data.isFixed.present ? data.isFixed.value : this.isFixed,
      fixedAmount: data.fixedAmount.present
          ? data.fixedAmount.value
          : this.fixedAmount,
      matchSender: data.matchSender.present
          ? data.matchSender.value
          : this.matchSender,
      matchCard: data.matchCard.present ? data.matchCard.value : this.matchCard,
      matchCounterparty: data.matchCounterparty.present
          ? data.matchCounterparty.value
          : this.matchCounterparty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Debt(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('creditor: $creditor, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('apr: $apr, ')
          ..write('minPayment: $minPayment, ')
          ..write('dueDate: $dueDate, ')
          ..write('isFixed: $isFixed, ')
          ..write('fixedAmount: $fixedAmount, ')
          ..write('matchSender: $matchSender, ')
          ..write('matchCard: $matchCard, ')
          ..write('matchCounterparty: $matchCounterparty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    creditor,
    totalAmount,
    paidAmount,
    apr,
    minPayment,
    dueDate,
    isFixed,
    fixedAmount,
    matchSender,
    matchCard,
    matchCounterparty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Debt &&
          other.id == this.id &&
          other.name == this.name &&
          other.creditor == this.creditor &&
          other.totalAmount == this.totalAmount &&
          other.paidAmount == this.paidAmount &&
          other.apr == this.apr &&
          other.minPayment == this.minPayment &&
          other.dueDate == this.dueDate &&
          other.isFixed == this.isFixed &&
          other.fixedAmount == this.fixedAmount &&
          other.matchSender == this.matchSender &&
          other.matchCard == this.matchCard &&
          other.matchCounterparty == this.matchCounterparty);
}

class DebtsCompanion extends UpdateCompanion<Debt> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> creditor;
  final Value<double> totalAmount;
  final Value<double> paidAmount;
  final Value<double> apr;
  final Value<double> minPayment;
  final Value<DateTime?> dueDate;
  final Value<bool> isFixed;
  final Value<double> fixedAmount;
  final Value<String> matchSender;
  final Value<String> matchCard;
  final Value<String> matchCounterparty;
  const DebtsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.creditor = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.paidAmount = const Value.absent(),
    this.apr = const Value.absent(),
    this.minPayment = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.isFixed = const Value.absent(),
    this.fixedAmount = const Value.absent(),
    this.matchSender = const Value.absent(),
    this.matchCard = const Value.absent(),
    this.matchCounterparty = const Value.absent(),
  });
  DebtsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.creditor = const Value.absent(),
    required double totalAmount,
    this.paidAmount = const Value.absent(),
    this.apr = const Value.absent(),
    this.minPayment = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.isFixed = const Value.absent(),
    this.fixedAmount = const Value.absent(),
    this.matchSender = const Value.absent(),
    this.matchCard = const Value.absent(),
    this.matchCounterparty = const Value.absent(),
  }) : name = Value(name),
       totalAmount = Value(totalAmount);
  static Insertable<Debt> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? creditor,
    Expression<double>? totalAmount,
    Expression<double>? paidAmount,
    Expression<double>? apr,
    Expression<double>? minPayment,
    Expression<DateTime>? dueDate,
    Expression<bool>? isFixed,
    Expression<double>? fixedAmount,
    Expression<String>? matchSender,
    Expression<String>? matchCard,
    Expression<String>? matchCounterparty,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (creditor != null) 'creditor': creditor,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (paidAmount != null) 'paid_amount': paidAmount,
      if (apr != null) 'apr': apr,
      if (minPayment != null) 'min_payment': minPayment,
      if (dueDate != null) 'due_date': dueDate,
      if (isFixed != null) 'is_fixed': isFixed,
      if (fixedAmount != null) 'fixed_amount': fixedAmount,
      if (matchSender != null) 'match_sender': matchSender,
      if (matchCard != null) 'match_card': matchCard,
      if (matchCounterparty != null) 'match_counterparty': matchCounterparty,
    });
  }

  DebtsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? creditor,
    Value<double>? totalAmount,
    Value<double>? paidAmount,
    Value<double>? apr,
    Value<double>? minPayment,
    Value<DateTime?>? dueDate,
    Value<bool>? isFixed,
    Value<double>? fixedAmount,
    Value<String>? matchSender,
    Value<String>? matchCard,
    Value<String>? matchCounterparty,
  }) {
    return DebtsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      creditor: creditor ?? this.creditor,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      apr: apr ?? this.apr,
      minPayment: minPayment ?? this.minPayment,
      dueDate: dueDate ?? this.dueDate,
      isFixed: isFixed ?? this.isFixed,
      fixedAmount: fixedAmount ?? this.fixedAmount,
      matchSender: matchSender ?? this.matchSender,
      matchCard: matchCard ?? this.matchCard,
      matchCounterparty: matchCounterparty ?? this.matchCounterparty,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (creditor.present) {
      map['creditor'] = Variable<String>(creditor.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (paidAmount.present) {
      map['paid_amount'] = Variable<double>(paidAmount.value);
    }
    if (apr.present) {
      map['apr'] = Variable<double>(apr.value);
    }
    if (minPayment.present) {
      map['min_payment'] = Variable<double>(minPayment.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (isFixed.present) {
      map['is_fixed'] = Variable<bool>(isFixed.value);
    }
    if (fixedAmount.present) {
      map['fixed_amount'] = Variable<double>(fixedAmount.value);
    }
    if (matchSender.present) {
      map['match_sender'] = Variable<String>(matchSender.value);
    }
    if (matchCard.present) {
      map['match_card'] = Variable<String>(matchCard.value);
    }
    if (matchCounterparty.present) {
      map['match_counterparty'] = Variable<String>(matchCounterparty.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DebtsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('creditor: $creditor, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('apr: $apr, ')
          ..write('minPayment: $minPayment, ')
          ..write('dueDate: $dueDate, ')
          ..write('isFixed: $isFixed, ')
          ..write('fixedAmount: $fixedAmount, ')
          ..write('matchSender: $matchSender, ')
          ..write('matchCard: $matchCard, ')
          ..write('matchCounterparty: $matchCounterparty')
          ..write(')'))
        .toString();
  }
}

class $DebtPaymentsTable extends DebtPayments
    with TableInfo<$DebtPaymentsTable, DebtPayment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DebtPaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _debtIdMeta = const VerificationMeta('debtId');
  @override
  late final GeneratedColumn<int> debtId = GeneratedColumn<int>(
    'debt_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<int> transactionId = GeneratedColumn<int>(
    'transaction_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<PaymentStatus, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<PaymentStatus>($DebtPaymentsTable.$converterstatus);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    debtId,
    transactionId,
    amount,
    date,
    note,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'debt_payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<DebtPayment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('debt_id')) {
      context.handle(
        _debtIdMeta,
        debtId.isAcceptableOrUnknown(data['debt_id']!, _debtIdMeta),
      );
    } else if (isInserting) {
      context.missing(_debtIdMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {debtId, transactionId},
  ];
  @override
  DebtPayment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DebtPayment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      debtId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}debt_id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transaction_id'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      status: $DebtPaymentsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
    );
  }

  @override
  $DebtPaymentsTable createAlias(String alias) {
    return $DebtPaymentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PaymentStatus, int, int> $converterstatus =
      const EnumIndexConverter<PaymentStatus>(PaymentStatus.values);
}

class DebtPayment extends DataClass implements Insertable<DebtPayment> {
  final int id;
  final int debtId;
  final int? transactionId;
  final double amount;
  final DateTime date;
  final String note;
  final PaymentStatus status;
  const DebtPayment({
    required this.id,
    required this.debtId,
    this.transactionId,
    required this.amount,
    required this.date,
    required this.note,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['debt_id'] = Variable<int>(debtId);
    if (!nullToAbsent || transactionId != null) {
      map['transaction_id'] = Variable<int>(transactionId);
    }
    map['amount'] = Variable<double>(amount);
    map['date'] = Variable<DateTime>(date);
    map['note'] = Variable<String>(note);
    {
      map['status'] = Variable<int>(
        $DebtPaymentsTable.$converterstatus.toSql(status),
      );
    }
    return map;
  }

  DebtPaymentsCompanion toCompanion(bool nullToAbsent) {
    return DebtPaymentsCompanion(
      id: Value(id),
      debtId: Value(debtId),
      transactionId: transactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionId),
      amount: Value(amount),
      date: Value(date),
      note: Value(note),
      status: Value(status),
    );
  }

  factory DebtPayment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DebtPayment(
      id: serializer.fromJson<int>(json['id']),
      debtId: serializer.fromJson<int>(json['debtId']),
      transactionId: serializer.fromJson<int?>(json['transactionId']),
      amount: serializer.fromJson<double>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      note: serializer.fromJson<String>(json['note']),
      status: $DebtPaymentsTable.$converterstatus.fromJson(
        serializer.fromJson<int>(json['status']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'debtId': serializer.toJson<int>(debtId),
      'transactionId': serializer.toJson<int?>(transactionId),
      'amount': serializer.toJson<double>(amount),
      'date': serializer.toJson<DateTime>(date),
      'note': serializer.toJson<String>(note),
      'status': serializer.toJson<int>(
        $DebtPaymentsTable.$converterstatus.toJson(status),
      ),
    };
  }

  DebtPayment copyWith({
    int? id,
    int? debtId,
    Value<int?> transactionId = const Value.absent(),
    double? amount,
    DateTime? date,
    String? note,
    PaymentStatus? status,
  }) => DebtPayment(
    id: id ?? this.id,
    debtId: debtId ?? this.debtId,
    transactionId: transactionId.present
        ? transactionId.value
        : this.transactionId,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    note: note ?? this.note,
    status: status ?? this.status,
  );
  DebtPayment copyWithCompanion(DebtPaymentsCompanion data) {
    return DebtPayment(
      id: data.id.present ? data.id.value : this.id,
      debtId: data.debtId.present ? data.debtId.value : this.debtId,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      note: data.note.present ? data.note.value : this.note,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DebtPayment(')
          ..write('id: $id, ')
          ..write('debtId: $debtId, ')
          ..write('transactionId: $transactionId, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, debtId, transactionId, amount, date, note, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DebtPayment &&
          other.id == this.id &&
          other.debtId == this.debtId &&
          other.transactionId == this.transactionId &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.note == this.note &&
          other.status == this.status);
}

class DebtPaymentsCompanion extends UpdateCompanion<DebtPayment> {
  final Value<int> id;
  final Value<int> debtId;
  final Value<int?> transactionId;
  final Value<double> amount;
  final Value<DateTime> date;
  final Value<String> note;
  final Value<PaymentStatus> status;
  const DebtPaymentsCompanion({
    this.id = const Value.absent(),
    this.debtId = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.note = const Value.absent(),
    this.status = const Value.absent(),
  });
  DebtPaymentsCompanion.insert({
    this.id = const Value.absent(),
    required int debtId,
    this.transactionId = const Value.absent(),
    required double amount,
    required DateTime date,
    this.note = const Value.absent(),
    this.status = const Value.absent(),
  }) : debtId = Value(debtId),
       amount = Value(amount),
       date = Value(date);
  static Insertable<DebtPayment> custom({
    Expression<int>? id,
    Expression<int>? debtId,
    Expression<int>? transactionId,
    Expression<double>? amount,
    Expression<DateTime>? date,
    Expression<String>? note,
    Expression<int>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (debtId != null) 'debt_id': debtId,
      if (transactionId != null) 'transaction_id': transactionId,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (note != null) 'note': note,
      if (status != null) 'status': status,
    });
  }

  DebtPaymentsCompanion copyWith({
    Value<int>? id,
    Value<int>? debtId,
    Value<int?>? transactionId,
    Value<double>? amount,
    Value<DateTime>? date,
    Value<String>? note,
    Value<PaymentStatus>? status,
  }) {
    return DebtPaymentsCompanion(
      id: id ?? this.id,
      debtId: debtId ?? this.debtId,
      transactionId: transactionId ?? this.transactionId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (debtId.present) {
      map['debt_id'] = Variable<int>(debtId.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<int>(transactionId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $DebtPaymentsTable.$converterstatus.toSql(status.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DebtPaymentsCompanion(')
          ..write('id: $id, ')
          ..write('debtId: $debtId, ')
          ..write('transactionId: $transactionId, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
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
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $CategoryRulesTable categoryRules = $CategoryRulesTable(this);
  late final $CategoryExclusionsTable categoryExclusions =
      $CategoryExclusionsTable(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $DebtsTable debts = $DebtsTable(this);
  late final $DebtPaymentsTable debtPayments = $DebtPaymentsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    transactions,
    categories,
    categoryRules,
    categoryExclusions,
    goals,
    debts,
    debtPayments,
    settings,
  ];
}

typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      required double amount,
      required bool isCredit,
      Value<String> description,
      required DateTime date,
      Value<TxSource> source,
      Value<String> sender,
      Value<String> card,
      Value<double?> balanceAfter,
      Value<int?> categoryId,
      Value<String> rawMessage,
      Value<int?> smsId,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<double> amount,
      Value<bool> isCredit,
      Value<String> description,
      Value<DateTime> date,
      Value<TxSource> source,
      Value<String> sender,
      Value<String> card,
      Value<double?> balanceAfter,
      Value<int?> categoryId,
      Value<String> rawMessage,
      Value<int?> smsId,
    });

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCredit => $composableBuilder(
    column: $table.isCredit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TxSource, TxSource, int> get source =>
      $composableBuilder(
        column: $table.source,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get card => $composableBuilder(
    column: $table.card,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawMessage => $composableBuilder(
    column: $table.rawMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get smsId => $composableBuilder(
    column: $table.smsId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCredit => $composableBuilder(
    column: $table.isCredit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get card => $composableBuilder(
    column: $table.card,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawMessage => $composableBuilder(
    column: $table.rawMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get smsId => $composableBuilder(
    column: $table.smsId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<bool> get isCredit =>
      $composableBuilder(column: $table.isCredit, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TxSource, int> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get sender =>
      $composableBuilder(column: $table.sender, builder: (column) => column);

  GeneratedColumn<String> get card =>
      $composableBuilder(column: $table.card, builder: (column) => column);

  GeneratedColumn<double> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => column,
  );

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawMessage => $composableBuilder(
    column: $table.rawMessage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get smsId =>
      $composableBuilder(column: $table.smsId, builder: (column) => column);
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (
            Transaction,
            BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>,
          ),
          Transaction,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<bool> isCredit = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<TxSource> source = const Value.absent(),
                Value<String> sender = const Value.absent(),
                Value<String> card = const Value.absent(),
                Value<double?> balanceAfter = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<String> rawMessage = const Value.absent(),
                Value<int?> smsId = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                amount: amount,
                isCredit: isCredit,
                description: description,
                date: date,
                source: source,
                sender: sender,
                card: card,
                balanceAfter: balanceAfter,
                categoryId: categoryId,
                rawMessage: rawMessage,
                smsId: smsId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required double amount,
                required bool isCredit,
                Value<String> description = const Value.absent(),
                required DateTime date,
                Value<TxSource> source = const Value.absent(),
                Value<String> sender = const Value.absent(),
                Value<String> card = const Value.absent(),
                Value<double?> balanceAfter = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<String> rawMessage = const Value.absent(),
                Value<int?> smsId = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                amount: amount,
                isCredit: isCredit,
                description: description,
                date: date,
                source: source,
                sender: sender,
                card: card,
                balanceAfter: balanceAfter,
                categoryId: categoryId,
                rawMessage: rawMessage,
                smsId: smsId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (
        Transaction,
        BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>,
      ),
      Transaction,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String name,
      Value<String> color,
      Value<String> senderIds,
      Value<String> shopNames,
      Value<int?> parentId,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> color,
      Value<String> senderIds,
      Value<String> shopNames,
      Value<int?> parentId,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderIds => $composableBuilder(
    column: $table.senderIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shopNames => $composableBuilder(
    column: $table.shopNames,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderIds => $composableBuilder(
    column: $table.senderIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shopNames => $composableBuilder(
    column: $table.shopNames,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get senderIds =>
      $composableBuilder(column: $table.senderIds, builder: (column) => column);

  GeneratedColumn<String> get shopNames =>
      $composableBuilder(column: $table.shopNames, builder: (column) => column);

  GeneratedColumn<int> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
          Category,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<String> senderIds = const Value.absent(),
                Value<String> shopNames = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                color: color,
                senderIds: senderIds,
                shopNames: shopNames,
                parentId: parentId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> color = const Value.absent(),
                Value<String> senderIds = const Value.absent(),
                Value<String> shopNames = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                color: color,
                senderIds: senderIds,
                shopNames: shopNames,
                parentId: parentId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
      Category,
      PrefetchHooks Function()
    >;
typedef $$CategoryRulesTableCreateCompanionBuilder =
    CategoryRulesCompanion Function({
      Value<int> id,
      required int categoryId,
      Value<String> sender,
      required String counterparty,
      Value<bool> exact,
      Value<bool> matchAmount,
      Value<double> amount,
      Value<bool?> isCredit,
    });
typedef $$CategoryRulesTableUpdateCompanionBuilder =
    CategoryRulesCompanion Function({
      Value<int> id,
      Value<int> categoryId,
      Value<String> sender,
      Value<String> counterparty,
      Value<bool> exact,
      Value<bool> matchAmount,
      Value<double> amount,
      Value<bool?> isCredit,
    });

class $$CategoryRulesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryRulesTable> {
  $$CategoryRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get counterparty => $composableBuilder(
    column: $table.counterparty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get exact => $composableBuilder(
    column: $table.exact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get matchAmount => $composableBuilder(
    column: $table.matchAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCredit => $composableBuilder(
    column: $table.isCredit,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoryRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryRulesTable> {
  $$CategoryRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get counterparty => $composableBuilder(
    column: $table.counterparty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get exact => $composableBuilder(
    column: $table.exact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get matchAmount => $composableBuilder(
    column: $table.matchAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCredit => $composableBuilder(
    column: $table.isCredit,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoryRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryRulesTable> {
  $$CategoryRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sender =>
      $composableBuilder(column: $table.sender, builder: (column) => column);

  GeneratedColumn<String> get counterparty => $composableBuilder(
    column: $table.counterparty,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get exact =>
      $composableBuilder(column: $table.exact, builder: (column) => column);

  GeneratedColumn<bool> get matchAmount => $composableBuilder(
    column: $table.matchAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<bool> get isCredit =>
      $composableBuilder(column: $table.isCredit, builder: (column) => column);
}

class $$CategoryRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoryRulesTable,
          CategoryRule,
          $$CategoryRulesTableFilterComposer,
          $$CategoryRulesTableOrderingComposer,
          $$CategoryRulesTableAnnotationComposer,
          $$CategoryRulesTableCreateCompanionBuilder,
          $$CategoryRulesTableUpdateCompanionBuilder,
          (
            CategoryRule,
            BaseReferences<_$AppDatabase, $CategoryRulesTable, CategoryRule>,
          ),
          CategoryRule,
          PrefetchHooks Function()
        > {
  $$CategoryRulesTableTableManager(_$AppDatabase db, $CategoryRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<String> sender = const Value.absent(),
                Value<String> counterparty = const Value.absent(),
                Value<bool> exact = const Value.absent(),
                Value<bool> matchAmount = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<bool?> isCredit = const Value.absent(),
              }) => CategoryRulesCompanion(
                id: id,
                categoryId: categoryId,
                sender: sender,
                counterparty: counterparty,
                exact: exact,
                matchAmount: matchAmount,
                amount: amount,
                isCredit: isCredit,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int categoryId,
                Value<String> sender = const Value.absent(),
                required String counterparty,
                Value<bool> exact = const Value.absent(),
                Value<bool> matchAmount = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<bool?> isCredit = const Value.absent(),
              }) => CategoryRulesCompanion.insert(
                id: id,
                categoryId: categoryId,
                sender: sender,
                counterparty: counterparty,
                exact: exact,
                matchAmount: matchAmount,
                amount: amount,
                isCredit: isCredit,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoryRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoryRulesTable,
      CategoryRule,
      $$CategoryRulesTableFilterComposer,
      $$CategoryRulesTableOrderingComposer,
      $$CategoryRulesTableAnnotationComposer,
      $$CategoryRulesTableCreateCompanionBuilder,
      $$CategoryRulesTableUpdateCompanionBuilder,
      (
        CategoryRule,
        BaseReferences<_$AppDatabase, $CategoryRulesTable, CategoryRule>,
      ),
      CategoryRule,
      PrefetchHooks Function()
    >;
typedef $$CategoryExclusionsTableCreateCompanionBuilder =
    CategoryExclusionsCompanion Function({
      Value<int> id,
      required int categoryId,
      required int transactionId,
    });
typedef $$CategoryExclusionsTableUpdateCompanionBuilder =
    CategoryExclusionsCompanion Function({
      Value<int> id,
      Value<int> categoryId,
      Value<int> transactionId,
    });

class $$CategoryExclusionsTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryExclusionsTable> {
  $$CategoryExclusionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoryExclusionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryExclusionsTable> {
  $$CategoryExclusionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoryExclusionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryExclusionsTable> {
  $$CategoryExclusionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );
}

class $$CategoryExclusionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoryExclusionsTable,
          CategoryExclusion,
          $$CategoryExclusionsTableFilterComposer,
          $$CategoryExclusionsTableOrderingComposer,
          $$CategoryExclusionsTableAnnotationComposer,
          $$CategoryExclusionsTableCreateCompanionBuilder,
          $$CategoryExclusionsTableUpdateCompanionBuilder,
          (
            CategoryExclusion,
            BaseReferences<
              _$AppDatabase,
              $CategoryExclusionsTable,
              CategoryExclusion
            >,
          ),
          CategoryExclusion,
          PrefetchHooks Function()
        > {
  $$CategoryExclusionsTableTableManager(
    _$AppDatabase db,
    $CategoryExclusionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryExclusionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryExclusionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryExclusionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<int> transactionId = const Value.absent(),
              }) => CategoryExclusionsCompanion(
                id: id,
                categoryId: categoryId,
                transactionId: transactionId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int categoryId,
                required int transactionId,
              }) => CategoryExclusionsCompanion.insert(
                id: id,
                categoryId: categoryId,
                transactionId: transactionId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoryExclusionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoryExclusionsTable,
      CategoryExclusion,
      $$CategoryExclusionsTableFilterComposer,
      $$CategoryExclusionsTableOrderingComposer,
      $$CategoryExclusionsTableAnnotationComposer,
      $$CategoryExclusionsTableCreateCompanionBuilder,
      $$CategoryExclusionsTableUpdateCompanionBuilder,
      (
        CategoryExclusion,
        BaseReferences<
          _$AppDatabase,
          $CategoryExclusionsTable,
          CategoryExclusion
        >,
      ),
      CategoryExclusion,
      PrefetchHooks Function()
    >;
typedef $$GoalsTableCreateCompanionBuilder =
    GoalsCompanion Function({
      Value<int> id,
      required String name,
      required double targetAmount,
      Value<double> savedAmount,
      Value<DateTime?> targetDate,
    });
typedef $$GoalsTableUpdateCompanionBuilder =
    GoalsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<double> targetAmount,
      Value<double> savedAmount,
      Value<DateTime?> targetDate,
    });

class $$GoalsTableFilterComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get savedAmount => $composableBuilder(
    column: $table.savedAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get savedAmount => $composableBuilder(
    column: $table.savedAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get savedAmount => $composableBuilder(
    column: $table.savedAmount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => column,
  );
}

class $$GoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalsTable,
          Goal,
          $$GoalsTableFilterComposer,
          $$GoalsTableOrderingComposer,
          $$GoalsTableAnnotationComposer,
          $$GoalsTableCreateCompanionBuilder,
          $$GoalsTableUpdateCompanionBuilder,
          (Goal, BaseReferences<_$AppDatabase, $GoalsTable, Goal>),
          Goal,
          PrefetchHooks Function()
        > {
  $$GoalsTableTableManager(_$AppDatabase db, $GoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> targetAmount = const Value.absent(),
                Value<double> savedAmount = const Value.absent(),
                Value<DateTime?> targetDate = const Value.absent(),
              }) => GoalsCompanion(
                id: id,
                name: name,
                targetAmount: targetAmount,
                savedAmount: savedAmount,
                targetDate: targetDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required double targetAmount,
                Value<double> savedAmount = const Value.absent(),
                Value<DateTime?> targetDate = const Value.absent(),
              }) => GoalsCompanion.insert(
                id: id,
                name: name,
                targetAmount: targetAmount,
                savedAmount: savedAmount,
                targetDate: targetDate,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalsTable,
      Goal,
      $$GoalsTableFilterComposer,
      $$GoalsTableOrderingComposer,
      $$GoalsTableAnnotationComposer,
      $$GoalsTableCreateCompanionBuilder,
      $$GoalsTableUpdateCompanionBuilder,
      (Goal, BaseReferences<_$AppDatabase, $GoalsTable, Goal>),
      Goal,
      PrefetchHooks Function()
    >;
typedef $$DebtsTableCreateCompanionBuilder =
    DebtsCompanion Function({
      Value<int> id,
      required String name,
      Value<String> creditor,
      required double totalAmount,
      Value<double> paidAmount,
      Value<double> apr,
      Value<double> minPayment,
      Value<DateTime?> dueDate,
      Value<bool> isFixed,
      Value<double> fixedAmount,
      Value<String> matchSender,
      Value<String> matchCard,
      Value<String> matchCounterparty,
    });
typedef $$DebtsTableUpdateCompanionBuilder =
    DebtsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> creditor,
      Value<double> totalAmount,
      Value<double> paidAmount,
      Value<double> apr,
      Value<double> minPayment,
      Value<DateTime?> dueDate,
      Value<bool> isFixed,
      Value<double> fixedAmount,
      Value<String> matchSender,
      Value<String> matchCard,
      Value<String> matchCounterparty,
    });

class $$DebtsTableFilterComposer extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get creditor => $composableBuilder(
    column: $table.creditor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get apr => $composableBuilder(
    column: $table.apr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minPayment => $composableBuilder(
    column: $table.minPayment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFixed => $composableBuilder(
    column: $table.isFixed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fixedAmount => $composableBuilder(
    column: $table.fixedAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matchSender => $composableBuilder(
    column: $table.matchSender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matchCard => $composableBuilder(
    column: $table.matchCard,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matchCounterparty => $composableBuilder(
    column: $table.matchCounterparty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DebtsTableOrderingComposer
    extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get creditor => $composableBuilder(
    column: $table.creditor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get apr => $composableBuilder(
    column: $table.apr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minPayment => $composableBuilder(
    column: $table.minPayment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFixed => $composableBuilder(
    column: $table.isFixed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fixedAmount => $composableBuilder(
    column: $table.fixedAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matchSender => $composableBuilder(
    column: $table.matchSender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matchCard => $composableBuilder(
    column: $table.matchCard,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matchCounterparty => $composableBuilder(
    column: $table.matchCounterparty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DebtsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get creditor =>
      $composableBuilder(column: $table.creditor, builder: (column) => column);

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get apr =>
      $composableBuilder(column: $table.apr, builder: (column) => column);

  GeneratedColumn<double> get minPayment => $composableBuilder(
    column: $table.minPayment,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<bool> get isFixed =>
      $composableBuilder(column: $table.isFixed, builder: (column) => column);

  GeneratedColumn<double> get fixedAmount => $composableBuilder(
    column: $table.fixedAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get matchSender => $composableBuilder(
    column: $table.matchSender,
    builder: (column) => column,
  );

  GeneratedColumn<String> get matchCard =>
      $composableBuilder(column: $table.matchCard, builder: (column) => column);

  GeneratedColumn<String> get matchCounterparty => $composableBuilder(
    column: $table.matchCounterparty,
    builder: (column) => column,
  );
}

class $$DebtsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DebtsTable,
          Debt,
          $$DebtsTableFilterComposer,
          $$DebtsTableOrderingComposer,
          $$DebtsTableAnnotationComposer,
          $$DebtsTableCreateCompanionBuilder,
          $$DebtsTableUpdateCompanionBuilder,
          (Debt, BaseReferences<_$AppDatabase, $DebtsTable, Debt>),
          Debt,
          PrefetchHooks Function()
        > {
  $$DebtsTableTableManager(_$AppDatabase db, $DebtsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DebtsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DebtsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DebtsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> creditor = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<double> paidAmount = const Value.absent(),
                Value<double> apr = const Value.absent(),
                Value<double> minPayment = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<bool> isFixed = const Value.absent(),
                Value<double> fixedAmount = const Value.absent(),
                Value<String> matchSender = const Value.absent(),
                Value<String> matchCard = const Value.absent(),
                Value<String> matchCounterparty = const Value.absent(),
              }) => DebtsCompanion(
                id: id,
                name: name,
                creditor: creditor,
                totalAmount: totalAmount,
                paidAmount: paidAmount,
                apr: apr,
                minPayment: minPayment,
                dueDate: dueDate,
                isFixed: isFixed,
                fixedAmount: fixedAmount,
                matchSender: matchSender,
                matchCard: matchCard,
                matchCounterparty: matchCounterparty,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> creditor = const Value.absent(),
                required double totalAmount,
                Value<double> paidAmount = const Value.absent(),
                Value<double> apr = const Value.absent(),
                Value<double> minPayment = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<bool> isFixed = const Value.absent(),
                Value<double> fixedAmount = const Value.absent(),
                Value<String> matchSender = const Value.absent(),
                Value<String> matchCard = const Value.absent(),
                Value<String> matchCounterparty = const Value.absent(),
              }) => DebtsCompanion.insert(
                id: id,
                name: name,
                creditor: creditor,
                totalAmount: totalAmount,
                paidAmount: paidAmount,
                apr: apr,
                minPayment: minPayment,
                dueDate: dueDate,
                isFixed: isFixed,
                fixedAmount: fixedAmount,
                matchSender: matchSender,
                matchCard: matchCard,
                matchCounterparty: matchCounterparty,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DebtsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DebtsTable,
      Debt,
      $$DebtsTableFilterComposer,
      $$DebtsTableOrderingComposer,
      $$DebtsTableAnnotationComposer,
      $$DebtsTableCreateCompanionBuilder,
      $$DebtsTableUpdateCompanionBuilder,
      (Debt, BaseReferences<_$AppDatabase, $DebtsTable, Debt>),
      Debt,
      PrefetchHooks Function()
    >;
typedef $$DebtPaymentsTableCreateCompanionBuilder =
    DebtPaymentsCompanion Function({
      Value<int> id,
      required int debtId,
      Value<int?> transactionId,
      required double amount,
      required DateTime date,
      Value<String> note,
      Value<PaymentStatus> status,
    });
typedef $$DebtPaymentsTableUpdateCompanionBuilder =
    DebtPaymentsCompanion Function({
      Value<int> id,
      Value<int> debtId,
      Value<int?> transactionId,
      Value<double> amount,
      Value<DateTime> date,
      Value<String> note,
      Value<PaymentStatus> status,
    });

class $$DebtPaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $DebtPaymentsTable> {
  $$DebtPaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get debtId => $composableBuilder(
    column: $table.debtId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PaymentStatus, PaymentStatus, int>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$DebtPaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $DebtPaymentsTable> {
  $$DebtPaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get debtId => $composableBuilder(
    column: $table.debtId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DebtPaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DebtPaymentsTable> {
  $$DebtPaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get debtId =>
      $composableBuilder(column: $table.debtId, builder: (column) => column);

  GeneratedColumn<int> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PaymentStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$DebtPaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DebtPaymentsTable,
          DebtPayment,
          $$DebtPaymentsTableFilterComposer,
          $$DebtPaymentsTableOrderingComposer,
          $$DebtPaymentsTableAnnotationComposer,
          $$DebtPaymentsTableCreateCompanionBuilder,
          $$DebtPaymentsTableUpdateCompanionBuilder,
          (
            DebtPayment,
            BaseReferences<_$AppDatabase, $DebtPaymentsTable, DebtPayment>,
          ),
          DebtPayment,
          PrefetchHooks Function()
        > {
  $$DebtPaymentsTableTableManager(_$AppDatabase db, $DebtPaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DebtPaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DebtPaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DebtPaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> debtId = const Value.absent(),
                Value<int?> transactionId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<PaymentStatus> status = const Value.absent(),
              }) => DebtPaymentsCompanion(
                id: id,
                debtId: debtId,
                transactionId: transactionId,
                amount: amount,
                date: date,
                note: note,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int debtId,
                Value<int?> transactionId = const Value.absent(),
                required double amount,
                required DateTime date,
                Value<String> note = const Value.absent(),
                Value<PaymentStatus> status = const Value.absent(),
              }) => DebtPaymentsCompanion.insert(
                id: id,
                debtId: debtId,
                transactionId: transactionId,
                amount: amount,
                date: date,
                note: note,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DebtPaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DebtPaymentsTable,
      DebtPayment,
      $$DebtPaymentsTableFilterComposer,
      $$DebtPaymentsTableOrderingComposer,
      $$DebtPaymentsTableAnnotationComposer,
      $$DebtPaymentsTableCreateCompanionBuilder,
      $$DebtPaymentsTableUpdateCompanionBuilder,
      (
        DebtPayment,
        BaseReferences<_$AppDatabase, $DebtPaymentsTable, DebtPayment>,
      ),
      DebtPayment,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
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
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
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
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
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
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$CategoryRulesTableTableManager get categoryRules =>
      $$CategoryRulesTableTableManager(_db, _db.categoryRules);
  $$CategoryExclusionsTableTableManager get categoryExclusions =>
      $$CategoryExclusionsTableTableManager(_db, _db.categoryExclusions);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$DebtsTableTableManager get debts =>
      $$DebtsTableTableManager(_db, _db.debts);
  $$DebtPaymentsTableTableManager get debtPayments =>
      $$DebtPaymentsTableTableManager(_db, _db.debtPayments);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
