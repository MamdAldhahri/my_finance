// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'My Finance';

  @override
  String get currency => 'OMR';

  @override
  String get navOverview => 'Overview';

  @override
  String get navCategories => 'Categories';

  @override
  String get navDebt => 'Debt';

  @override
  String get navGoals => 'Goals';

  @override
  String get navTransactions => 'Transactions';

  @override
  String get bucketExpenses => 'Expenses';

  @override
  String get bucketExtras => 'Extras';

  @override
  String get bucketSavings => 'Emergency & Savings';

  @override
  String get bucketInvestments => 'Investments';

  @override
  String get bucketExpensesHint =>
      'Needs: rent, groceries, fuel, bills, debt payments';

  @override
  String get bucketExtrasHint => 'Wants: eating out, shopping, fun';

  @override
  String get bucketSavingsHint => 'Your safety net and savings goals';

  @override
  String get bucketInvestmentsHint =>
      'Long-term growth and paying debt off early';

  @override
  String get presetBalanced => 'Balanced';

  @override
  String get presetEmergencyFirst => 'Emergency first';

  @override
  String get presetAggressive => 'Aggressive saver';

  @override
  String get presetCustom => 'Custom';

  @override
  String get periodDaily => 'Daily';

  @override
  String get periodMonthly => 'Monthly';

  @override
  String get periodYearly => 'Yearly';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String sinceDate(String date) {
    return 'since $date';
  }

  @override
  String cycleSince(String date) {
    return 'Since $date';
  }

  @override
  String get payment => 'Payment';

  @override
  String get deposit => 'Deposit';

  @override
  String get addedByHandNoSms => 'Added by hand, so there is no SMS.';

  @override
  String get changeCategory => 'Change category';

  @override
  String get close => 'Close';

  @override
  String get cash => 'Cash';

  @override
  String get bank => 'Bank';

  @override
  String get unknown => 'Unknown';

  @override
  String get thisCycle => 'This cycle';

  @override
  String get noSalaryYetHint =>
      'No salary found yet. Add your monthly salary in the plan to see planned amounts.';

  @override
  String get cycleEnded => 'ended';

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String incomeDetected(String amount) {
    return 'Salary $amount';
  }

  @override
  String incomeExpected(String amount) {
    return 'Planned on $amount (salary SMS not here yet)';
  }

  @override
  String incomeLastCycle(String amount) {
    return 'Planned on last salary, $amount';
  }

  @override
  String get incomeNone => 'No salary to plan with yet';

  @override
  String amountOver(String amount) {
    return '$amount over';
  }

  @override
  String amountLeft(String amount) {
    return '$amount left';
  }

  @override
  String get done => 'Done';

  @override
  String amountToGo(String amount) {
    return '$amount to go';
  }

  @override
  String get unknownSpendingHint =>
      'Unknown: spending with no category yet. File it from the Categories tab.';

  @override
  String get spendingOverPlan => 'Spending is over plan this cycle';

  @override
  String get safeToSpendPerDay => 'Safe to spend per day';

  @override
  String get planYourSalary => 'Plan your salary';

  @override
  String get planYourSalaryHint =>
      'Split it into Expenses, Extras, Emergency & Savings and Investments.';

  @override
  String get debtLeft => 'Debt left';

  @override
  String get goalsSaved => 'Goals saved';

  @override
  String get recentActivity => 'Recent activity';

  @override
  String get noTransactionsYet =>
      'No transactions yet.\nEnable bank-SMS import from the Transactions tab.';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get totalBalance => 'Total balance';

  @override
  String get vsBeforePayday => 'vs before payday';

  @override
  String get yourAccounts => 'Your accounts';

  @override
  String get switchLanguage => 'Switch language';

  @override
  String get languageToggleLabel => 'ع';

  @override
  String get incomePlan => 'Income plan';

  @override
  String get editPlan => 'Edit plan';

  @override
  String get noPlanYet => 'No plan yet.';

  @override
  String get previousCycles => 'Previous cycles';

  @override
  String get measuredAgainstSplit => 'Measured against your current split.';

  @override
  String get noSalaryThisCycle => 'No salary found for this cycle.';

  @override
  String amountInUnknown(String amount) {
    return '$amount in Unknown (no category)';
  }

  @override
  String get planSetupIntro =>
      'Every payday your salary is split into four parts. The app then compares what you actually spend and save against it.';

  @override
  String get startFrom => 'Start from';

  @override
  String get total100 => 'Total 100%';

  @override
  String totalLeftToAssign(int total, int left) {
    return 'Total $total% · $left% left to assign';
  }

  @override
  String totalTooMuch(int total, int over) {
    return 'Total $total% · $over% too much';
  }

  @override
  String get savePlan => 'Save plan';

  @override
  String get planTip =>
      'Tip: keep Emergency & Savings and Investments in a separate bank account, so the money you planned to keep doesn\'t get spent by accident.';

  @override
  String get yourSalary => 'Your salary';

  @override
  String lastSalarySms(String date) {
    return 'Last salary SMS: $date';
  }

  @override
  String monthlySalaryOmr(String currency) {
    return 'Monthly salary ($currency)';
  }

  @override
  String get optional => 'Optional';

  @override
  String get monthlySalary => 'Monthly salary';

  @override
  String get backupSalary => 'Backup salary';

  @override
  String get noSalarySmsYet =>
      'No salary SMS found yet. Once one arrives, the plan uses the real amount each payday.';

  @override
  String get backupSalaryHint =>
      'Used when this month\'s salary SMS hasn\'t arrived yet. If left empty, last payday\'s salary is used.';

  @override
  String get noGoalsYet => 'No goals yet.\nTap + to set a savings target.';

  @override
  String savedOfTarget(String saved, String target) {
    return '$saved of $target';
  }

  @override
  String byDate(String date) {
    return 'by $date';
  }

  @override
  String get addGoal => 'Add goal';

  @override
  String get editGoal => 'Edit goal';

  @override
  String get goalName => 'Goal name';

  @override
  String targetOmr(String currency) {
    return 'Target ($currency)';
  }

  @override
  String savedOmr(String currency) {
    return 'Saved ($currency)';
  }

  @override
  String get targetDateOptional => 'Target date (optional)';

  @override
  String targetDate(String date) {
    return 'Target: $date';
  }

  @override
  String get save => 'Save';

  @override
  String get invalid => 'Invalid';

  @override
  String get required => 'Required';

  @override
  String get totalRemaining => 'Total remaining';

  @override
  String paidOffOverall(String pct) {
    return '$pct% paid off overall';
  }

  @override
  String get noDebtsYet =>
      'No debts tracked.\nTap + to add one and plan your payoff.';

  @override
  String get paidOff => 'Paid off';

  @override
  String monthsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months left',
      one: '1 month left',
    );
    return '$_temp0';
  }

  @override
  String aprValue(String apr) {
    return '$apr% APR';
  }

  @override
  String perMonth(String amount) {
    return '$amount/mo';
  }

  @override
  String minPaymentPerMonth(String amount) {
    return 'Min payment $amount/mo';
  }

  @override
  String dueOn(String date) {
    return 'Due $date';
  }

  @override
  String get tapToSeePayments => 'Tap to see payments';

  @override
  String pctPaid(String pct) {
    return '$pct% paid';
  }

  @override
  String matchedSmsToConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matched SMS to confirm',
      one: '1 matched SMS to confirm',
    );
    return '$_temp0';
  }

  @override
  String everyMonth(String amount) {
    return '$amount every month';
  }

  @override
  String fromCard(String card) {
    return 'from ••••$card';
  }

  @override
  String toCounterparty(String name) {
    return 'to $name';
  }

  @override
  String get editDebt => 'Edit debt';

  @override
  String get remaining => 'Remaining';

  @override
  String paidOfTotal(String paid, String total) {
    return 'Paid $paid of $total';
  }

  @override
  String lastPaymentOn(String date) {
    return 'last payment $date';
  }

  @override
  String matchedSmsToConfirmCount(int count) {
    return 'Matched SMS to confirm ($count)';
  }

  @override
  String get confirmAll => 'Confirm all';

  @override
  String get matchedSmsHint =>
      'Same account and same amount as this debt. Confirm the ones that are real payments of it.';

  @override
  String get notThisDebt => 'Not this debt';

  @override
  String get confirmPayment => 'Confirm payment';

  @override
  String get payments => 'Payments';

  @override
  String get linkSms => 'Link SMS';

  @override
  String get addPayment => 'Add payment';

  @override
  String includesPaidBefore(String amount) {
    return 'Includes $amount paid before tracking.';
  }

  @override
  String get noPaymentsYet => 'No payments linked yet.';

  @override
  String get removeFromDebt => 'Remove from this debt';

  @override
  String get bankSms => 'Bank SMS';

  @override
  String get manualPayment => 'Manual payment';

  @override
  String addPaymentTo(String name) {
    return 'Add payment to $name';
  }

  @override
  String amountOmr(String currency) {
    return 'Amount ($currency)';
  }

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String paidOnDate(String date) {
    return 'Paid on $date';
  }

  @override
  String get selectRelatedSms => 'Select related SMS';

  @override
  String get moneyOutSmsLast6Months =>
      'Money-out bank SMS from the last 6 months.';

  @override
  String get searchNameOrAmount => 'Search name or amount';

  @override
  String get noMatchingSms => 'No matching bank SMS.';

  @override
  String useSmsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Use $count SMS',
      one: 'Use 1 SMS',
    );
    return '$_temp0';
  }

  @override
  String get selectAtLeastOneSms =>
      'Select at least one SMS of this payment so the app knows which account it goes to.';

  @override
  String foundMoreMatchingSms(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Found $count more matching SMS. Open the debt to confirm them.',
      one: 'Found 1 more matching SMS. Open the debt to confirm it.',
    );
    return '$_temp0';
  }

  @override
  String get addDebt => 'Add debt';

  @override
  String get debtName => 'Debt name';

  @override
  String get lenderOptional => 'Lender (optional)';

  @override
  String totalOmr(String currency) {
    return 'Total ($currency)';
  }

  @override
  String paidBeforeOmr(String currency) {
    return 'Paid before ($currency)';
  }

  @override
  String get paidBeforeHint =>
      'Paid before = anything repaid before the SMS you link below.';

  @override
  String smsSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count SMS selected',
      one: '1 SMS selected',
    );
    return '$_temp0';
  }

  @override
  String andMore(int count) {
    return 'and $count more';
  }

  @override
  String get fixedMonthlyPayment => 'Fixed monthly payment?';

  @override
  String get fixedMonthlyHint =>
      'New SMS to the same account with the same amount will be suggested as payments.';

  @override
  String monthlyAmountOmr(String currency) {
    return 'Monthly amount ($currency)';
  }

  @override
  String get aprPercent => 'APR %';

  @override
  String minPerMonthOmr(String currency) {
    return 'Min / mo ($currency)';
  }

  @override
  String get dueDateOptional => 'Due date (optional)';

  @override
  String dueColon(String date) {
    return 'Due: $date';
  }

  @override
  String get smsPermissionDenied =>
      'SMS permission denied. Enable it in system settings to auto-import bank transactions.';

  @override
  String get noNewBankMessages => 'No new bank messages found.';

  @override
  String importedTransactions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imported $count transactions.',
      one: 'Imported 1 transaction.',
    );
    return '$_temp0';
  }

  @override
  String incomeWithCycle(String cycle) {
    return 'Income · $cycle';
  }

  @override
  String expensesWithCycle(String cycle) {
    return 'Expenses · $cycle';
  }

  @override
  String get filterAll => 'All';

  @override
  String get income => 'Income';

  @override
  String get expenses => 'Expenses';

  @override
  String get noTransactionsTapGear =>
      'No transactions yet.\nTap the gear to pick your bank chat, or + to add one manually.';

  @override
  String get nothingInFilter => 'Nothing in this filter.';

  @override
  String get whichChatIsBank => 'Which chat is your bank?';

  @override
  String get pickBankSenders =>
      'Pick every sender that texts you card alerts. Only these are read.';

  @override
  String get noSmsFoundAndroid =>
      'No SMS found. This works on Android with SMS permission granted.';

  @override
  String get addTransaction => 'Add a transaction';

  @override
  String get oneOffEntryHint => 'A one-off entry that is not from a bank SMS.';

  @override
  String get whatWasIt => 'What was it?';

  @override
  String get enterAmount => 'Enter an amount';

  @override
  String get expense => 'Expense';

  @override
  String get category => 'Category';

  @override
  String get none => 'None';

  @override
  String categoryWithBucket(String name, String bucket) {
    return '$name · $bucket';
  }

  @override
  String dateLabel(String date) {
    return 'Date: $date';
  }

  @override
  String get thisTransaction => 'this transaction';

  @override
  String get addToCategory => 'Add to category';

  @override
  String get debtPaymentNotInCategory =>
      'This is counted as a debt payment, so it is not in a category. You can still file it here.';

  @override
  String filesEveryNamed(String title) {
    return 'Files every \"$title\" transaction into this category. Remove only this one with the button below.';
  }

  @override
  String fileUnderCategory(String title) {
    return 'File \"$title\" under a category.';
  }

  @override
  String get noCategoriesYetCreate =>
      'No categories yet — create one in the Categories tab first.';

  @override
  String get removeThisOne => 'Remove this one';

  @override
  String get delete => 'Delete';

  @override
  String get giveCategoryName => 'Give the category a name first.';

  @override
  String get removeMatchingSmsQ => 'Remove this matching SMS?';

  @override
  String removeRuleBody(String name) {
    return 'Messages from \"$name\" will stop filing here and move to Unknown.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get remove => 'Remove';

  @override
  String get removeMessageQ => 'Remove this message?';

  @override
  String removeMessageBody(String name, String amount, String date) {
    return '$name · $amount on $date will move to Unknown. Other messages from the same place stay in this category.';
  }

  @override
  String get newCategory => 'New category';

  @override
  String get editCategory => 'Edit category';

  @override
  String get categoryName => 'Category name';

  @override
  String get egGroceries => 'e.g. Groceries';

  @override
  String get matchingSms => 'Matching SMS';

  @override
  String get matchingSmsHint =>
      'Pick example SMS. Every past and future SMS to the same shop or person files here automatically. Turn on \"Only this amount\" when the same person gets money for different things.';

  @override
  String get pickExampleSms => 'Pick example SMS';

  @override
  String get orTypeShopName => 'Or type a shop name';

  @override
  String inThisCategoryCount(int count) {
    return 'In this category ($count)';
  }

  @override
  String inThisCategoryPeriodCount(String period, int count) {
    return 'In this category · $period ($count)';
  }

  @override
  String get showAll => 'Show all';

  @override
  String get thisPeriod => 'This period';

  @override
  String get tapXToRemoveHint =>
      'Tap ✕ to take out just that one transaction. SMS counted as a debt payment stay with the debt.';

  @override
  String get nothingMatchesYet => 'Nothing matches yet.';

  @override
  String noSmsInCategoryFor(String period) {
    return 'No SMS in this category for $period.';
  }

  @override
  String get removeFromCategory => 'Remove from this category';

  @override
  String removedCount(int count) {
    return 'Removed ($count)';
  }

  @override
  String get putBack => 'Put back';

  @override
  String get deleteCategory => 'Delete category';

  @override
  String get bucket => 'Bucket';

  @override
  String get remainingIncome => 'Remaining income';

  @override
  String spentWithPeriod(String period) {
    return 'Spent · $period';
  }

  @override
  String incomeLeft(String income, String left) {
    return 'Income $income · left $left';
  }

  @override
  String incomeOverBy(String income, String over) {
    return 'Income $income · over by $over';
  }

  @override
  String get everyExpenseHasCategory => 'Every expense has a category';

  @override
  String withoutCategoryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count without a category',
      one: '1 without a category',
    );
    return '$_temp0';
  }

  @override
  String get viewArrow => 'View ›';

  @override
  String get unknownStartHint =>
      'Every expense starts in Unknown. Open it and move them into new categories, or tap + on a bucket and pick example SMS.';

  @override
  String movedExpensesTo(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Moved $count expenses to $name.',
      one: 'Moved 1 expense to $name.',
    );
    return '$_temp0';
  }

  @override
  String movedTo(String name) {
    return 'Moved to $name.';
  }

  @override
  String get unknownHint =>
      'Expenses no category picked up. Tap Assign to give one a category; others from the same shop or person move with it.';

  @override
  String get nothingLeftThisPeriod => 'Nothing left here for this period.';

  @override
  String get assign => 'Assign';

  @override
  String assignTitle(String title) {
    return 'Assign \"$title\"';
  }

  @override
  String everyNamedExpenseGoes(String title) {
    return 'Every \"$title\" expense will go to this category.';
  }

  @override
  String get onlyThisExpenseMoves => 'Only this one expense moves.';

  @override
  String get create => 'Create';

  @override
  String get debtPayments => 'Debt payments';

  @override
  String get regularPaymentsFromDebts => 'Regular payments from the Debts tab';

  @override
  String get paidAboveRegular => 'Paid above the regular payment';

  @override
  String get debtsTab => 'Debts tab';

  @override
  String addCategoryTo(String bucket) {
    return '+ Add a category to $bucket';
  }

  @override
  String get editArrow => 'Edit ›';

  @override
  String shareOfSpending(int pct, String action) {
    return '$pct% of spending · $action';
  }

  @override
  String get noSmsPickedYet => 'No SMS picked yet';

  @override
  String get anyBank => 'Any bank';

  @override
  String get moneyIn => 'money in';

  @override
  String get moneyOut => 'money out';

  @override
  String get nameContains => 'name contains';

  @override
  String onlyAmount(String amount) {
    return 'Only $amount';
  }

  @override
  String anyAmountTapForOnly(String amount) {
    return 'Any amount · tap for only $amount';
  }

  @override
  String get deleteRule => 'Delete rule';

  @override
  String get onePerShopHint =>
      'One per shop or person is enough; the rest are found for you.';

  @override
  String get saved => 'Saved';

  @override
  String payCyclesSince(String date) {
    return 'Pay cycles since $date';
  }

  @override
  String get previousYear => 'Previous year';

  @override
  String get nextYear => 'Next year';

  @override
  String yearTotalMonths(int year, int started) {
    return '$year total · $started of 12 months';
  }

  @override
  String get spent => 'Spent';

  @override
  String get savedLower => 'saved';

  @override
  String get averageMonth => 'Average month';

  @override
  String get biggestMonth => 'Biggest month';

  @override
  String fromDate(String date) {
    return 'From $date';
  }

  @override
  String get notStartedYet => 'Not started yet';

  @override
  String get running => 'Running';

  @override
  String get highest => 'Highest';

  @override
  String savedAmount(String amount) {
    return 'saved $amount';
  }

  @override
  String overAmount(String amount) {
    return 'over $amount';
  }
}
