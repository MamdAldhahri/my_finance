// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'مالي';

  @override
  String get currency => 'ر.ع.';

  @override
  String get navOverview => 'الرئيسية';

  @override
  String get navCategories => 'الفئات';

  @override
  String get navDebt => 'الديون';

  @override
  String get navGoals => 'الأهداف';

  @override
  String get navTransactions => 'المعاملات';

  @override
  String get bucketExpenses => 'المصاريف';

  @override
  String get bucketExtras => 'الكماليات';

  @override
  String get bucketSavings => 'الطوارئ والادخار';

  @override
  String get bucketInvestments => 'الاستثمار';

  @override
  String get bucketExpensesHint =>
      'الضروريات: الإيجار، البقالة، الوقود، الفواتير، أقساط الديون';

  @override
  String get bucketExtrasHint => 'الرغبات: المطاعم، التسوق، الترفيه';

  @override
  String get bucketSavingsHint => 'شبكة الأمان وأهداف الادخار';

  @override
  String get bucketInvestmentsHint => 'النمو طويل المدى وسداد الديون مبكرًا';

  @override
  String get presetBalanced => 'متوازن';

  @override
  String get presetEmergencyFirst => 'الطوارئ أولًا';

  @override
  String get presetAggressive => 'مدّخر بقوة';

  @override
  String get presetCustom => 'مخصص';

  @override
  String get periodDaily => 'يومي';

  @override
  String get periodMonthly => 'شهري';

  @override
  String get periodYearly => 'سنوي';

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String sinceDate(String date) {
    return 'منذ $date';
  }

  @override
  String cycleSince(String date) {
    return 'منذ $date';
  }

  @override
  String get payment => 'دفعة';

  @override
  String get deposit => 'إيداع';

  @override
  String get addedByHandNoSms => 'أُضيفت يدويًا، لذا لا توجد رسالة.';

  @override
  String get changeCategory => 'تغيير الفئة';

  @override
  String get close => 'إغلاق';

  @override
  String get cash => 'نقدًا';

  @override
  String get bank => 'بنك';

  @override
  String get unknown => 'غير مصنّف';

  @override
  String get thisCycle => 'هذه الدورة';

  @override
  String get noSalaryYetHint =>
      'لم يُعثر على راتب بعد. أضف راتبك الشهري في الخطة لرؤية المبالغ المخططة.';

  @override
  String get cycleEnded => 'انتهت';

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يوم متبقٍ',
      many: '$count يومًا متبقيًا',
      few: '$count أيام متبقية',
      two: 'يومان متبقيان',
      one: 'يوم واحد متبقٍ',
      zero: 'لا أيام متبقية',
    );
    return '$_temp0';
  }

  @override
  String incomeDetected(String amount) {
    return 'الراتب $amount';
  }

  @override
  String incomeExpected(String amount) {
    return 'مخطط على $amount (رسالة الراتب لم تصل بعد)';
  }

  @override
  String incomeLastCycle(String amount) {
    return 'مخطط على آخر راتب، $amount';
  }

  @override
  String get incomeNone => 'لا يوجد راتب للتخطيط بعد';

  @override
  String amountOver(String amount) {
    return '$amount تجاوز';
  }

  @override
  String amountLeft(String amount) {
    return '$amount متبقٍ';
  }

  @override
  String get done => 'تم';

  @override
  String amountToGo(String amount) {
    return '$amount متبقٍ للهدف';
  }

  @override
  String get unknownSpendingHint =>
      'غير مصنّف: مصاريف بلا فئة بعد. صنّفها من تبويب الفئات.';

  @override
  String get spendingOverPlan => 'المصاريف تجاوزت الخطة في هذه الدورة';

  @override
  String get safeToSpendPerDay => 'المتاح صرفه يوميًا';

  @override
  String get planYourSalary => 'خطّط راتبك';

  @override
  String get planYourSalaryHint =>
      'قسّمه إلى المصاريف والكماليات والطوارئ والادخار والاستثمار.';

  @override
  String get debtLeft => 'الدين المتبقي';

  @override
  String get goalsSaved => 'المدّخر للأهداف';

  @override
  String get recentActivity => 'آخر النشاطات';

  @override
  String get noTransactionsYet =>
      'لا توجد معاملات بعد.\nفعّل استيراد رسائل البنك من تبويب المعاملات.';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'مساء الخير';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String get totalBalance => 'إجمالي الرصيد';

  @override
  String get vsBeforePayday => 'مقارنة بما قبل الراتب';

  @override
  String get yourAccounts => 'حساباتك';

  @override
  String get switchLanguage => 'تغيير اللغة';

  @override
  String get languageToggleLabel => 'EN';

  @override
  String get incomePlan => 'خطة الدخل';

  @override
  String get editPlan => 'تعديل الخطة';

  @override
  String get noPlanYet => 'لا توجد خطة بعد.';

  @override
  String get previousCycles => 'الدورات السابقة';

  @override
  String get measuredAgainstSplit => 'مقارنة بتقسيمك الحالي.';

  @override
  String get noSalaryThisCycle => 'لم يُعثر على راتب لهذه الدورة.';

  @override
  String amountInUnknown(String amount) {
    return '$amount في غير المصنّف (بلا فئة)';
  }

  @override
  String get planSetupIntro =>
      'في كل يوم راتب يُقسَّم راتبك إلى أربعة أجزاء، ثم يقارن التطبيق ما تصرفه وتدّخره فعليًا بهذا التقسيم.';

  @override
  String get startFrom => 'ابدأ من';

  @override
  String get total100 => 'المجموع 100%';

  @override
  String totalLeftToAssign(int total, int left) {
    return 'المجموع $total% · $left% متبقٍ للتوزيع';
  }

  @override
  String totalTooMuch(int total, int over) {
    return 'المجموع $total% · $over% زيادة';
  }

  @override
  String get savePlan => 'حفظ الخطة';

  @override
  String get planTip =>
      'نصيحة: احتفظ بأموال الطوارئ والادخار والاستثمار في حساب بنكي منفصل، حتى لا تصرف بالخطأ المال الذي خططت للاحتفاظ به.';

  @override
  String get yourSalary => 'راتبك';

  @override
  String lastSalarySms(String date) {
    return 'آخر رسالة راتب: $date';
  }

  @override
  String monthlySalaryOmr(String currency) {
    return 'الراتب الشهري ($currency)';
  }

  @override
  String get optional => 'اختياري';

  @override
  String get monthlySalary => 'الراتب الشهري';

  @override
  String get backupSalary => 'الراتب الاحتياطي';

  @override
  String get noSalarySmsYet =>
      'لم تُعثر على رسالة راتب بعد. عند وصولها، تستخدم الخطة المبلغ الفعلي في كل يوم راتب.';

  @override
  String get backupSalaryHint =>
      'يُستخدم عندما لا تصل رسالة راتب هذا الشهر بعد. إذا تُرك فارغًا، يُستخدم راتب آخر يوم راتب.';

  @override
  String get noGoalsYet => 'لا توجد أهداف بعد.\nاضغط + لتحديد هدف ادخار.';

  @override
  String savedOfTarget(String saved, String target) {
    return '$saved من $target';
  }

  @override
  String byDate(String date) {
    return 'بحلول $date';
  }

  @override
  String get addGoal => 'إضافة هدف';

  @override
  String get editGoal => 'تعديل الهدف';

  @override
  String get goalName => 'اسم الهدف';

  @override
  String targetOmr(String currency) {
    return 'المبلغ المستهدف ($currency)';
  }

  @override
  String savedOmr(String currency) {
    return 'المدّخر ($currency)';
  }

  @override
  String get targetDateOptional => 'التاريخ المستهدف (اختياري)';

  @override
  String targetDate(String date) {
    return 'الموعد: $date';
  }

  @override
  String get save => 'حفظ';

  @override
  String get invalid => 'غير صالح';

  @override
  String get required => 'مطلوب';

  @override
  String get totalRemaining => 'إجمالي المتبقي';

  @override
  String paidOffOverall(String pct) {
    return 'تم سداد $pct% إجمالًا';
  }

  @override
  String get noDebtsYet =>
      'لا توجد ديون مسجلة.\nاضغط + لإضافة دين وتخطيط سداده.';

  @override
  String get paidOff => 'مسدَّد';

  @override
  String monthsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count شهر متبقٍ',
      many: '$count شهرًا متبقيًا',
      few: '$count أشهر متبقية',
      two: 'شهران متبقيان',
      one: 'شهر واحد متبقٍ',
      zero: 'لا أشهر متبقية',
    );
    return '$_temp0';
  }

  @override
  String aprValue(String apr) {
    return '$apr% فائدة سنوية';
  }

  @override
  String perMonth(String amount) {
    return '$amount/شهريًا';
  }

  @override
  String minPaymentPerMonth(String amount) {
    return 'الحد الأدنى $amount/شهريًا';
  }

  @override
  String dueOn(String date) {
    return 'مستحق في $date';
  }

  @override
  String get tapToSeePayments => 'اضغط لعرض الدفعات';

  @override
  String pctPaid(String pct) {
    return 'تم سداد $pct%';
  }

  @override
  String matchedSmsToConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count رسالة مطابقة بانتظار التأكيد',
      few: '$count رسائل مطابقة بانتظار التأكيد',
      two: 'رسالتان مطابقتان بانتظار التأكيد',
      one: 'رسالة مطابقة واحدة بانتظار التأكيد',
    );
    return '$_temp0';
  }

  @override
  String everyMonth(String amount) {
    return '$amount كل شهر';
  }

  @override
  String fromCard(String card) {
    return 'من ••••$card';
  }

  @override
  String toCounterparty(String name) {
    return 'إلى $name';
  }

  @override
  String get editDebt => 'تعديل الدين';

  @override
  String get remaining => 'المتبقي';

  @override
  String paidOfTotal(String paid, String total) {
    return 'تم سداد $paid من $total';
  }

  @override
  String lastPaymentOn(String date) {
    return 'آخر دفعة $date';
  }

  @override
  String matchedSmsToConfirmCount(int count) {
    return 'رسائل مطابقة للتأكيد ($count)';
  }

  @override
  String get confirmAll => 'تأكيد الكل';

  @override
  String get matchedSmsHint =>
      'نفس الحساب ونفس مبلغ هذا الدين. أكّد الرسائل التي تمثل دفعات فعلية له.';

  @override
  String get notThisDebt => 'ليست لهذا الدين';

  @override
  String get confirmPayment => 'تأكيد الدفعة';

  @override
  String get payments => 'الدفعات';

  @override
  String get linkSms => 'ربط رسالة';

  @override
  String get addPayment => 'إضافة دفعة';

  @override
  String includesPaidBefore(String amount) {
    return 'يشمل $amount سُدّدت قبل بدء التتبع.';
  }

  @override
  String get noPaymentsYet => 'لا توجد دفعات مرتبطة بعد.';

  @override
  String get removeFromDebt => 'إزالة من هذا الدين';

  @override
  String get bankSms => 'رسالة البنك';

  @override
  String get manualPayment => 'دفعة يدوية';

  @override
  String addPaymentTo(String name) {
    return 'إضافة دفعة إلى $name';
  }

  @override
  String amountOmr(String currency) {
    return 'المبلغ ($currency)';
  }

  @override
  String get noteOptional => 'ملاحظة (اختياري)';

  @override
  String paidOnDate(String date) {
    return 'دُفعت في $date';
  }

  @override
  String get selectRelatedSms => 'اختر الرسائل المرتبطة';

  @override
  String get moneyOutSmsLast6Months =>
      'رسائل البنك للمبالغ الخارجة خلال آخر 6 أشهر.';

  @override
  String get searchNameOrAmount => 'ابحث بالاسم أو المبلغ';

  @override
  String get noMatchingSms => 'لا توجد رسائل بنك مطابقة.';

  @override
  String useSmsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'استخدام $count رسالة',
      few: 'استخدام $count رسائل',
      two: 'استخدام رسالتين',
      one: 'استخدام رسالة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get selectAtLeastOneSms =>
      'اختر رسالة واحدة على الأقل لهذه الدفعة حتى يعرف التطبيق الحساب الذي تخرج منه.';

  @override
  String foundMoreMatchingSms(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'وُجدت $count رسالة مطابقة أخرى. افتح الدين لتأكيدها.',
      few: 'وُجدت $count رسائل مطابقة أخرى. افتح الدين لتأكيدها.',
      two: 'وُجدت رسالتان مطابقتان أخريان. افتح الدين لتأكيدهما.',
      one: 'وُجدت رسالة مطابقة أخرى. افتح الدين لتأكيدها.',
    );
    return '$_temp0';
  }

  @override
  String get addDebt => 'إضافة دين';

  @override
  String get debtName => 'اسم الدين';

  @override
  String get lenderOptional => 'الجهة الدائنة (اختياري)';

  @override
  String totalOmr(String currency) {
    return 'الإجمالي ($currency)';
  }

  @override
  String paidBeforeOmr(String currency) {
    return 'المسدد سابقًا ($currency)';
  }

  @override
  String get paidBeforeHint =>
      'المسدد سابقًا = أي مبلغ سُدّد قبل الرسائل التي تربطها أدناه.';

  @override
  String smsSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count رسالة محددة',
      few: '$count رسائل محددة',
      two: 'رسالتان محددتان',
      one: 'رسالة واحدة محددة',
    );
    return '$_temp0';
  }

  @override
  String andMore(int count) {
    return 'و$count أخرى';
  }

  @override
  String get fixedMonthlyPayment => 'دفعة شهرية ثابتة؟';

  @override
  String get fixedMonthlyHint =>
      'ستُقترح الرسائل الجديدة لنفس الحساب وبنفس المبلغ كدفعات.';

  @override
  String monthlyAmountOmr(String currency) {
    return 'المبلغ الشهري ($currency)';
  }

  @override
  String get aprPercent => 'الفائدة السنوية %';

  @override
  String minPerMonthOmr(String currency) {
    return 'الحد الأدنى / شهر ($currency)';
  }

  @override
  String get dueDateOptional => 'تاريخ الاستحقاق (اختياري)';

  @override
  String dueColon(String date) {
    return 'الاستحقاق: $date';
  }

  @override
  String get smsPermissionDenied =>
      'تم رفض إذن الرسائل. فعّله من إعدادات النظام لاستيراد معاملات البنك تلقائيًا.';

  @override
  String get noNewBankMessages => 'لم تُعثر على رسائل بنك جديدة.';

  @override
  String importedTransactions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم استيراد $count معاملة.',
      few: 'تم استيراد $count معاملات.',
      two: 'تم استيراد معاملتين.',
      one: 'تم استيراد معاملة واحدة.',
      zero: 'لم تُستورد أي معاملة.',
    );
    return '$_temp0';
  }

  @override
  String incomeWithCycle(String cycle) {
    return 'الدخل · $cycle';
  }

  @override
  String expensesWithCycle(String cycle) {
    return 'المصاريف · $cycle';
  }

  @override
  String get filterAll => 'الكل';

  @override
  String get income => 'الدخل';

  @override
  String get expenses => 'المصاريف';

  @override
  String get noTransactionsTapGear =>
      'لا توجد معاملات بعد.\nاضغط على الترس لاختيار محادثة البنك، أو + لإضافة معاملة يدويًا.';

  @override
  String get nothingInFilter => 'لا شيء ضمن هذا الفلتر.';

  @override
  String get whichChatIsBank => 'أي محادثة تخص بنكك؟';

  @override
  String get pickBankSenders =>
      'اختر كل مرسل يرسل لك تنبيهات البطاقة. تُقرأ رسائلهم فقط.';

  @override
  String get noSmsFoundAndroid =>
      'لم تُعثر على رسائل. تعمل هذه الميزة على أندرويد مع منح إذن الرسائل.';

  @override
  String get addTransaction => 'إضافة معاملة';

  @override
  String get oneOffEntryHint => 'إدخال لمرة واحدة ليس من رسالة بنك.';

  @override
  String get whatWasIt => 'ما هي؟';

  @override
  String get enterAmount => 'أدخل مبلغًا';

  @override
  String get expense => 'مصروف';

  @override
  String get category => 'الفئة';

  @override
  String get none => 'بدون';

  @override
  String categoryWithBucket(String name, String bucket) {
    return '$name · $bucket';
  }

  @override
  String dateLabel(String date) {
    return 'التاريخ: $date';
  }

  @override
  String get thisTransaction => 'هذه المعاملة';

  @override
  String get addToCategory => 'إضافة إلى فئة';

  @override
  String get debtPaymentNotInCategory =>
      'تُحسب هذه كدفعة دين، لذا ليست ضمن فئة. ما زال بإمكانك تصنيفها هنا.';

  @override
  String filesEveryNamed(String title) {
    return 'تُصنَّف كل معاملات \"$title\" في هذه الفئة. أزل هذه فقط بالزر أدناه.';
  }

  @override
  String fileUnderCategory(String title) {
    return 'صنّف \"$title\" ضمن فئة.';
  }

  @override
  String get noCategoriesYetCreate =>
      'لا توجد فئات بعد، أنشئ فئة من تبويب الفئات أولًا.';

  @override
  String get removeThisOne => 'إزالة هذه فقط';

  @override
  String get delete => 'حذف';

  @override
  String get giveCategoryName => 'أعطِ الفئة اسمًا أولًا.';

  @override
  String get removeMatchingSmsQ => 'إزالة هذه الرسالة المطابقة؟';

  @override
  String removeRuleBody(String name) {
    return 'ستتوقف رسائل \"$name\" عن التصنيف هنا وستنتقل إلى غير المصنّف.';
  }

  @override
  String get cancel => 'إلغاء';

  @override
  String get remove => 'إزالة';

  @override
  String get removeMessageQ => 'إزالة هذه الرسالة؟';

  @override
  String removeMessageBody(String name, String amount, String date) {
    return 'ستنتقل $name · $amount بتاريخ $date إلى غير المصنّف. تبقى الرسائل الأخرى من نفس المكان في هذه الفئة.';
  }

  @override
  String get newCategory => 'فئة جديدة';

  @override
  String get editCategory => 'تعديل الفئة';

  @override
  String get categoryName => 'اسم الفئة';

  @override
  String get egGroceries => 'مثال: البقالة';

  @override
  String get matchingSms => 'الرسائل المطابقة';

  @override
  String get matchingSmsHint =>
      'اختر رسائل كأمثلة. كل رسالة سابقة أو قادمة لنفس المتجر أو الشخص تُصنَّف هنا تلقائيًا. فعّل \"هذا المبلغ فقط\" عندما يستلم نفس الشخص أموالًا لأغراض مختلفة.';

  @override
  String get pickExampleSms => 'اختر رسائل كأمثلة';

  @override
  String get orTypeShopName => 'أو اكتب اسم متجر';

  @override
  String inThisCategoryCount(int count) {
    return 'في هذه الفئة ($count)';
  }

  @override
  String inThisCategoryPeriodCount(String period, int count) {
    return 'في هذه الفئة · $period ($count)';
  }

  @override
  String get showAll => 'عرض الكل';

  @override
  String get thisPeriod => 'هذه الفترة';

  @override
  String get tapXToRemoveHint =>
      'اضغط ✕ لإخراج تلك المعاملة فقط. الرسائل المحسوبة كدفعات دين تبقى مع الدين.';

  @override
  String get nothingMatchesYet => 'لا يوجد تطابق بعد.';

  @override
  String noSmsInCategoryFor(String period) {
    return 'لا توجد رسائل في هذه الفئة خلال $period.';
  }

  @override
  String get removeFromCategory => 'إزالة من هذه الفئة';

  @override
  String removedCount(int count) {
    return 'المُزالة ($count)';
  }

  @override
  String get putBack => 'إرجاع';

  @override
  String get deleteCategory => 'حذف الفئة';

  @override
  String get bucket => 'القسم';

  @override
  String get remainingIncome => 'الدخل المتبقي';

  @override
  String spentWithPeriod(String period) {
    return 'المصروف · $period';
  }

  @override
  String incomeLeft(String income, String left) {
    return 'الدخل $income · المتبقي $left';
  }

  @override
  String incomeOverBy(String income, String over) {
    return 'الدخل $income · تجاوز بمقدار $over';
  }

  @override
  String get everyExpenseHasCategory => 'كل المصاريف لها فئة';

  @override
  String withoutCategoryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count معاملة بلا فئة',
      few: '$count معاملات بلا فئة',
      two: 'معاملتان بلا فئة',
      one: 'معاملة واحدة بلا فئة',
    );
    return '$_temp0';
  }

  @override
  String get viewArrow => 'عرض ‹';

  @override
  String get unknownStartHint =>
      'كل مصروف يبدأ في غير المصنّف. افتحه وانقل المصاريف إلى فئات جديدة، أو اضغط + على قسم واختر رسائل كأمثلة.';

  @override
  String movedExpensesTo(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'نُقل $count مصروفًا إلى $name.',
      few: 'نُقلت $count مصاريف إلى $name.',
      two: 'نُقل مصروفان إلى $name.',
      one: 'نُقل مصروف واحد إلى $name.',
    );
    return '$_temp0';
  }

  @override
  String movedTo(String name) {
    return 'نُقل إلى $name.';
  }

  @override
  String get unknownHint =>
      'مصاريف لم تلتقطها أي فئة. اضغط تعيين لإعطائها فئة؛ وستنتقل معها المصاريف الأخرى من نفس المتجر أو الشخص.';

  @override
  String get nothingLeftThisPeriod => 'لم يتبقَّ شيء هنا لهذه الفترة.';

  @override
  String get assign => 'تعيين';

  @override
  String assignTitle(String title) {
    return 'تعيين \"$title\"';
  }

  @override
  String everyNamedExpenseGoes(String title) {
    return 'كل مصاريف \"$title\" ستذهب إلى هذه الفئة.';
  }

  @override
  String get onlyThisExpenseMoves => 'سينتقل هذا المصروف فقط.';

  @override
  String get create => 'إنشاء';

  @override
  String get debtPayments => 'دفعات الديون';

  @override
  String get regularPaymentsFromDebts => 'الدفعات المنتظمة من تبويب الديون';

  @override
  String get paidAboveRegular => 'المدفوع فوق الدفعة المنتظمة';

  @override
  String get debtsTab => 'تبويب الديون';

  @override
  String addCategoryTo(String bucket) {
    return '+ إضافة فئة إلى $bucket';
  }

  @override
  String get editArrow => 'تعديل ‹';

  @override
  String shareOfSpending(int pct, String action) {
    return '$pct% من المصاريف · $action';
  }

  @override
  String get noSmsPickedYet => 'لم تُختر رسائل بعد';

  @override
  String get anyBank => 'أي بنك';

  @override
  String get moneyIn => 'مبالغ واردة';

  @override
  String get moneyOut => 'مبالغ صادرة';

  @override
  String get nameContains => 'الاسم يحتوي';

  @override
  String onlyAmount(String amount) {
    return 'فقط $amount';
  }

  @override
  String anyAmountTapForOnly(String amount) {
    return 'أي مبلغ · اضغط لتحديد $amount فقط';
  }

  @override
  String get deleteRule => 'حذف القاعدة';

  @override
  String get onePerShopHint =>
      'تكفي رسالة واحدة لكل متجر أو شخص؛ وسيُعثر على الباقي تلقائيًا.';

  @override
  String get saved => 'المدّخر';

  @override
  String payCyclesSince(String date) {
    return 'دورات الراتب منذ $date';
  }

  @override
  String get previousYear => 'السنة السابقة';

  @override
  String get nextYear => 'السنة التالية';

  @override
  String yearTotalMonths(int year, int started) {
    return 'إجمالي $year · $started من 12 شهرًا';
  }

  @override
  String get spent => 'المصروف';

  @override
  String get savedLower => 'مدّخر';

  @override
  String get averageMonth => 'متوسط الشهر';

  @override
  String get biggestMonth => 'أعلى شهر';

  @override
  String fromDate(String date) {
    return 'من $date';
  }

  @override
  String get notStartedYet => 'لم تبدأ بعد';

  @override
  String get running => 'جارية';

  @override
  String get highest => 'الأعلى';

  @override
  String savedAmount(String amount) {
    return 'مدّخر $amount';
  }

  @override
  String overAmount(String amount) {
    return 'تجاوز $amount';
  }
}
