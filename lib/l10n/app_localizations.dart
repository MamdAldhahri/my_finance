import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'My Finance'**
  String get appTitle;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'OMR'**
  String get currency;

  /// No description provided for @navOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get navOverview;

  /// No description provided for @navCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get navCategories;

  /// No description provided for @navDebt.
  ///
  /// In en, this message translates to:
  /// **'Debt'**
  String get navDebt;

  /// No description provided for @navGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get navGoals;

  /// No description provided for @navTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get navTransactions;

  /// No description provided for @bucketExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get bucketExpenses;

  /// No description provided for @bucketExtras.
  ///
  /// In en, this message translates to:
  /// **'Extras'**
  String get bucketExtras;

  /// No description provided for @bucketSavings.
  ///
  /// In en, this message translates to:
  /// **'Emergency & Savings'**
  String get bucketSavings;

  /// No description provided for @bucketInvestments.
  ///
  /// In en, this message translates to:
  /// **'Investments'**
  String get bucketInvestments;

  /// No description provided for @bucketExpensesHint.
  ///
  /// In en, this message translates to:
  /// **'Needs: rent, groceries, fuel, bills, debt payments'**
  String get bucketExpensesHint;

  /// No description provided for @bucketExtrasHint.
  ///
  /// In en, this message translates to:
  /// **'Wants: eating out, shopping, fun'**
  String get bucketExtrasHint;

  /// No description provided for @bucketSavingsHint.
  ///
  /// In en, this message translates to:
  /// **'Your safety net and savings goals'**
  String get bucketSavingsHint;

  /// No description provided for @bucketInvestmentsHint.
  ///
  /// In en, this message translates to:
  /// **'Long-term growth and paying debt off early'**
  String get bucketInvestmentsHint;

  /// No description provided for @presetBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get presetBalanced;

  /// No description provided for @presetEmergencyFirst.
  ///
  /// In en, this message translates to:
  /// **'Emergency first'**
  String get presetEmergencyFirst;

  /// No description provided for @presetAggressive.
  ///
  /// In en, this message translates to:
  /// **'Aggressive saver'**
  String get presetAggressive;

  /// No description provided for @presetCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get presetCustom;

  /// No description provided for @periodDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get periodDaily;

  /// No description provided for @periodMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get periodMonthly;

  /// No description provided for @periodYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get periodYearly;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @sinceDate.
  ///
  /// In en, this message translates to:
  /// **'since {date}'**
  String sinceDate(String date);

  /// No description provided for @cycleSince.
  ///
  /// In en, this message translates to:
  /// **'Since {date}'**
  String cycleSince(String date);

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @deposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get deposit;

  /// No description provided for @addedByHandNoSms.
  ///
  /// In en, this message translates to:
  /// **'Added by hand, so there is no SMS.'**
  String get addedByHandNoSms;

  /// No description provided for @changeCategory.
  ///
  /// In en, this message translates to:
  /// **'Change category'**
  String get changeCategory;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @bank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bank;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @thisCycle.
  ///
  /// In en, this message translates to:
  /// **'This cycle'**
  String get thisCycle;

  /// No description provided for @noSalaryYetHint.
  ///
  /// In en, this message translates to:
  /// **'No salary found yet. Add your monthly salary in the plan to see planned amounts.'**
  String get noSalaryYetHint;

  /// No description provided for @cycleEnded.
  ///
  /// In en, this message translates to:
  /// **'ended'**
  String get cycleEnded;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day left} other{{count} days left}}'**
  String daysLeft(int count);

  /// No description provided for @incomeDetected.
  ///
  /// In en, this message translates to:
  /// **'Salary {amount}'**
  String incomeDetected(String amount);

  /// No description provided for @incomeExpected.
  ///
  /// In en, this message translates to:
  /// **'Planned on {amount} (salary SMS not here yet)'**
  String incomeExpected(String amount);

  /// No description provided for @incomeLastCycle.
  ///
  /// In en, this message translates to:
  /// **'Planned on last salary, {amount}'**
  String incomeLastCycle(String amount);

  /// No description provided for @incomeNone.
  ///
  /// In en, this message translates to:
  /// **'No salary to plan with yet'**
  String get incomeNone;

  /// No description provided for @amountOver.
  ///
  /// In en, this message translates to:
  /// **'{amount} over'**
  String amountOver(String amount);

  /// No description provided for @amountLeft.
  ///
  /// In en, this message translates to:
  /// **'{amount} left'**
  String amountLeft(String amount);

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @amountToGo.
  ///
  /// In en, this message translates to:
  /// **'{amount} to go'**
  String amountToGo(String amount);

  /// No description provided for @unknownSpendingHint.
  ///
  /// In en, this message translates to:
  /// **'Unknown: spending with no category yet. File it from the Categories tab.'**
  String get unknownSpendingHint;

  /// No description provided for @spendingOverPlan.
  ///
  /// In en, this message translates to:
  /// **'Spending is over plan this cycle'**
  String get spendingOverPlan;

  /// No description provided for @safeToSpendPerDay.
  ///
  /// In en, this message translates to:
  /// **'Safe to spend per day'**
  String get safeToSpendPerDay;

  /// No description provided for @planYourSalary.
  ///
  /// In en, this message translates to:
  /// **'Plan your salary'**
  String get planYourSalary;

  /// No description provided for @planYourSalaryHint.
  ///
  /// In en, this message translates to:
  /// **'Split it into Expenses, Extras, Emergency & Savings and Investments.'**
  String get planYourSalaryHint;

  /// No description provided for @debtLeft.
  ///
  /// In en, this message translates to:
  /// **'Debt left'**
  String get debtLeft;

  /// No description provided for @goalsSaved.
  ///
  /// In en, this message translates to:
  /// **'Goals saved'**
  String get goalsSaved;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recentActivity;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet.\nEnable bank-SMS import from the Transactions tab.'**
  String get noTransactionsYet;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total balance'**
  String get totalBalance;

  /// No description provided for @vsBeforePayday.
  ///
  /// In en, this message translates to:
  /// **'vs before payday'**
  String get vsBeforePayday;

  /// No description provided for @yourAccounts.
  ///
  /// In en, this message translates to:
  /// **'Your accounts'**
  String get yourAccounts;

  /// No description provided for @switchLanguage.
  ///
  /// In en, this message translates to:
  /// **'Switch language'**
  String get switchLanguage;

  /// No description provided for @languageToggleLabel.
  ///
  /// In en, this message translates to:
  /// **'ع'**
  String get languageToggleLabel;

  /// No description provided for @incomePlan.
  ///
  /// In en, this message translates to:
  /// **'Income plan'**
  String get incomePlan;

  /// No description provided for @editPlan.
  ///
  /// In en, this message translates to:
  /// **'Edit plan'**
  String get editPlan;

  /// No description provided for @noPlanYet.
  ///
  /// In en, this message translates to:
  /// **'No plan yet.'**
  String get noPlanYet;

  /// No description provided for @previousCycles.
  ///
  /// In en, this message translates to:
  /// **'Previous cycles'**
  String get previousCycles;

  /// No description provided for @measuredAgainstSplit.
  ///
  /// In en, this message translates to:
  /// **'Measured against your current split.'**
  String get measuredAgainstSplit;

  /// No description provided for @noSalaryThisCycle.
  ///
  /// In en, this message translates to:
  /// **'No salary found for this cycle.'**
  String get noSalaryThisCycle;

  /// No description provided for @amountInUnknown.
  ///
  /// In en, this message translates to:
  /// **'{amount} in Unknown (no category)'**
  String amountInUnknown(String amount);

  /// No description provided for @planSetupIntro.
  ///
  /// In en, this message translates to:
  /// **'Every payday your salary is split into four parts. The app then compares what you actually spend and save against it.'**
  String get planSetupIntro;

  /// No description provided for @startFrom.
  ///
  /// In en, this message translates to:
  /// **'Start from'**
  String get startFrom;

  /// No description provided for @total100.
  ///
  /// In en, this message translates to:
  /// **'Total 100%'**
  String get total100;

  /// No description provided for @totalLeftToAssign.
  ///
  /// In en, this message translates to:
  /// **'Total {total}% · {left}% left to assign'**
  String totalLeftToAssign(int total, int left);

  /// No description provided for @totalTooMuch.
  ///
  /// In en, this message translates to:
  /// **'Total {total}% · {over}% too much'**
  String totalTooMuch(int total, int over);

  /// No description provided for @savePlan.
  ///
  /// In en, this message translates to:
  /// **'Save plan'**
  String get savePlan;

  /// No description provided for @planTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: keep Emergency & Savings and Investments in a separate bank account, so the money you planned to keep doesn\'t get spent by accident.'**
  String get planTip;

  /// No description provided for @yourSalary.
  ///
  /// In en, this message translates to:
  /// **'Your salary'**
  String get yourSalary;

  /// No description provided for @lastSalarySms.
  ///
  /// In en, this message translates to:
  /// **'Last salary SMS: {date}'**
  String lastSalarySms(String date);

  /// No description provided for @monthlySalaryOmr.
  ///
  /// In en, this message translates to:
  /// **'Monthly salary ({currency})'**
  String monthlySalaryOmr(String currency);

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @monthlySalary.
  ///
  /// In en, this message translates to:
  /// **'Monthly salary'**
  String get monthlySalary;

  /// No description provided for @backupSalary.
  ///
  /// In en, this message translates to:
  /// **'Backup salary'**
  String get backupSalary;

  /// No description provided for @noSalarySmsYet.
  ///
  /// In en, this message translates to:
  /// **'No salary SMS found yet. Once one arrives, the plan uses the real amount each payday.'**
  String get noSalarySmsYet;

  /// No description provided for @backupSalaryHint.
  ///
  /// In en, this message translates to:
  /// **'Used when this month\'s salary SMS hasn\'t arrived yet. If left empty, last payday\'s salary is used.'**
  String get backupSalaryHint;

  /// No description provided for @noGoalsYet.
  ///
  /// In en, this message translates to:
  /// **'No goals yet.\nTap + to set a savings target.'**
  String get noGoalsYet;

  /// No description provided for @savedOfTarget.
  ///
  /// In en, this message translates to:
  /// **'{saved} of {target}'**
  String savedOfTarget(String saved, String target);

  /// No description provided for @byDate.
  ///
  /// In en, this message translates to:
  /// **'by {date}'**
  String byDate(String date);

  /// No description provided for @addGoal.
  ///
  /// In en, this message translates to:
  /// **'Add goal'**
  String get addGoal;

  /// No description provided for @editGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit goal'**
  String get editGoal;

  /// No description provided for @goalName.
  ///
  /// In en, this message translates to:
  /// **'Goal name'**
  String get goalName;

  /// No description provided for @targetOmr.
  ///
  /// In en, this message translates to:
  /// **'Target ({currency})'**
  String targetOmr(String currency);

  /// No description provided for @savedOmr.
  ///
  /// In en, this message translates to:
  /// **'Saved ({currency})'**
  String savedOmr(String currency);

  /// No description provided for @targetDateOptional.
  ///
  /// In en, this message translates to:
  /// **'Target date (optional)'**
  String get targetDateOptional;

  /// No description provided for @targetDate.
  ///
  /// In en, this message translates to:
  /// **'Target: {date}'**
  String targetDate(String date);

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid'**
  String get invalid;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @totalRemaining.
  ///
  /// In en, this message translates to:
  /// **'Total remaining'**
  String get totalRemaining;

  /// No description provided for @paidOffOverall.
  ///
  /// In en, this message translates to:
  /// **'{pct}% paid off overall'**
  String paidOffOverall(String pct);

  /// No description provided for @noDebtsYet.
  ///
  /// In en, this message translates to:
  /// **'No debts tracked.\nTap + to add one and plan your payoff.'**
  String get noDebtsYet;

  /// No description provided for @paidOff.
  ///
  /// In en, this message translates to:
  /// **'Paid off'**
  String get paidOff;

  /// No description provided for @monthsLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month left} other{{count} months left}}'**
  String monthsLeft(int count);

  /// No description provided for @aprValue.
  ///
  /// In en, this message translates to:
  /// **'{apr}% APR'**
  String aprValue(String apr);

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'{amount}/mo'**
  String perMonth(String amount);

  /// No description provided for @minPaymentPerMonth.
  ///
  /// In en, this message translates to:
  /// **'Min payment {amount}/mo'**
  String minPaymentPerMonth(String amount);

  /// No description provided for @dueOn.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String dueOn(String date);

  /// No description provided for @tapToSeePayments.
  ///
  /// In en, this message translates to:
  /// **'Tap to see payments'**
  String get tapToSeePayments;

  /// No description provided for @pctPaid.
  ///
  /// In en, this message translates to:
  /// **'{pct}% paid'**
  String pctPaid(String pct);

  /// No description provided for @matchedSmsToConfirm.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 matched SMS to confirm} other{{count} matched SMS to confirm}}'**
  String matchedSmsToConfirm(int count);

  /// No description provided for @everyMonth.
  ///
  /// In en, this message translates to:
  /// **'{amount} every month'**
  String everyMonth(String amount);

  /// No description provided for @fromCard.
  ///
  /// In en, this message translates to:
  /// **'from ••••{card}'**
  String fromCard(String card);

  /// No description provided for @toCounterparty.
  ///
  /// In en, this message translates to:
  /// **'to {name}'**
  String toCounterparty(String name);

  /// No description provided for @editDebt.
  ///
  /// In en, this message translates to:
  /// **'Edit debt'**
  String get editDebt;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @paidOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Paid {paid} of {total}'**
  String paidOfTotal(String paid, String total);

  /// No description provided for @lastPaymentOn.
  ///
  /// In en, this message translates to:
  /// **'last payment {date}'**
  String lastPaymentOn(String date);

  /// No description provided for @matchedSmsToConfirmCount.
  ///
  /// In en, this message translates to:
  /// **'Matched SMS to confirm ({count})'**
  String matchedSmsToConfirmCount(int count);

  /// No description provided for @confirmAll.
  ///
  /// In en, this message translates to:
  /// **'Confirm all'**
  String get confirmAll;

  /// No description provided for @matchedSmsHint.
  ///
  /// In en, this message translates to:
  /// **'Same account and same amount as this debt. Confirm the ones that are real payments of it.'**
  String get matchedSmsHint;

  /// No description provided for @notThisDebt.
  ///
  /// In en, this message translates to:
  /// **'Not this debt'**
  String get notThisDebt;

  /// No description provided for @confirmPayment.
  ///
  /// In en, this message translates to:
  /// **'Confirm payment'**
  String get confirmPayment;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @linkSms.
  ///
  /// In en, this message translates to:
  /// **'Link SMS'**
  String get linkSms;

  /// No description provided for @addPayment.
  ///
  /// In en, this message translates to:
  /// **'Add payment'**
  String get addPayment;

  /// No description provided for @includesPaidBefore.
  ///
  /// In en, this message translates to:
  /// **'Includes {amount} paid before tracking.'**
  String includesPaidBefore(String amount);

  /// No description provided for @noPaymentsYet.
  ///
  /// In en, this message translates to:
  /// **'No payments linked yet.'**
  String get noPaymentsYet;

  /// No description provided for @removeFromDebt.
  ///
  /// In en, this message translates to:
  /// **'Remove from this debt'**
  String get removeFromDebt;

  /// No description provided for @bankSms.
  ///
  /// In en, this message translates to:
  /// **'Bank SMS'**
  String get bankSms;

  /// No description provided for @manualPayment.
  ///
  /// In en, this message translates to:
  /// **'Manual payment'**
  String get manualPayment;

  /// No description provided for @addPaymentTo.
  ///
  /// In en, this message translates to:
  /// **'Add payment to {name}'**
  String addPaymentTo(String name);

  /// No description provided for @amountOmr.
  ///
  /// In en, this message translates to:
  /// **'Amount ({currency})'**
  String amountOmr(String currency);

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @paidOnDate.
  ///
  /// In en, this message translates to:
  /// **'Paid on {date}'**
  String paidOnDate(String date);

  /// No description provided for @selectRelatedSms.
  ///
  /// In en, this message translates to:
  /// **'Select related SMS'**
  String get selectRelatedSms;

  /// No description provided for @moneyOutSmsLast6Months.
  ///
  /// In en, this message translates to:
  /// **'Money-out bank SMS from the last 6 months.'**
  String get moneyOutSmsLast6Months;

  /// No description provided for @searchNameOrAmount.
  ///
  /// In en, this message translates to:
  /// **'Search name or amount'**
  String get searchNameOrAmount;

  /// No description provided for @noMatchingSms.
  ///
  /// In en, this message translates to:
  /// **'No matching bank SMS.'**
  String get noMatchingSms;

  /// No description provided for @useSmsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Use 1 SMS} other{Use {count} SMS}}'**
  String useSmsCount(int count);

  /// No description provided for @selectAtLeastOneSms.
  ///
  /// In en, this message translates to:
  /// **'Select at least one SMS of this payment so the app knows which account it goes to.'**
  String get selectAtLeastOneSms;

  /// No description provided for @foundMoreMatchingSms.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Found 1 more matching SMS. Open the debt to confirm it.} other{Found {count} more matching SMS. Open the debt to confirm them.}}'**
  String foundMoreMatchingSms(int count);

  /// No description provided for @addDebt.
  ///
  /// In en, this message translates to:
  /// **'Add debt'**
  String get addDebt;

  /// No description provided for @debtName.
  ///
  /// In en, this message translates to:
  /// **'Debt name'**
  String get debtName;

  /// No description provided for @lenderOptional.
  ///
  /// In en, this message translates to:
  /// **'Lender (optional)'**
  String get lenderOptional;

  /// No description provided for @totalOmr.
  ///
  /// In en, this message translates to:
  /// **'Total ({currency})'**
  String totalOmr(String currency);

  /// No description provided for @paidBeforeOmr.
  ///
  /// In en, this message translates to:
  /// **'Paid before ({currency})'**
  String paidBeforeOmr(String currency);

  /// No description provided for @paidBeforeHint.
  ///
  /// In en, this message translates to:
  /// **'Paid before = anything repaid before the SMS you link below.'**
  String get paidBeforeHint;

  /// No description provided for @smsSelected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 SMS selected} other{{count} SMS selected}}'**
  String smsSelected(int count);

  /// No description provided for @andMore.
  ///
  /// In en, this message translates to:
  /// **'and {count} more'**
  String andMore(int count);

  /// No description provided for @fixedMonthlyPayment.
  ///
  /// In en, this message translates to:
  /// **'Fixed monthly payment?'**
  String get fixedMonthlyPayment;

  /// No description provided for @fixedMonthlyHint.
  ///
  /// In en, this message translates to:
  /// **'New SMS to the same account with the same amount will be suggested as payments.'**
  String get fixedMonthlyHint;

  /// No description provided for @monthlyAmountOmr.
  ///
  /// In en, this message translates to:
  /// **'Monthly amount ({currency})'**
  String monthlyAmountOmr(String currency);

  /// No description provided for @aprPercent.
  ///
  /// In en, this message translates to:
  /// **'APR %'**
  String get aprPercent;

  /// No description provided for @minPerMonthOmr.
  ///
  /// In en, this message translates to:
  /// **'Min / mo ({currency})'**
  String minPerMonthOmr(String currency);

  /// No description provided for @dueDateOptional.
  ///
  /// In en, this message translates to:
  /// **'Due date (optional)'**
  String get dueDateOptional;

  /// No description provided for @dueColon.
  ///
  /// In en, this message translates to:
  /// **'Due: {date}'**
  String dueColon(String date);

  /// No description provided for @smsPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'SMS permission denied. Enable it in system settings to auto-import bank transactions.'**
  String get smsPermissionDenied;

  /// No description provided for @noNewBankMessages.
  ///
  /// In en, this message translates to:
  /// **'No new bank messages found.'**
  String get noNewBankMessages;

  /// No description provided for @importedTransactions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Imported 1 transaction.} other{Imported {count} transactions.}}'**
  String importedTransactions(int count);

  /// No description provided for @incomeWithCycle.
  ///
  /// In en, this message translates to:
  /// **'Income · {cycle}'**
  String incomeWithCycle(String cycle);

  /// No description provided for @expensesWithCycle.
  ///
  /// In en, this message translates to:
  /// **'Expenses · {cycle}'**
  String expensesWithCycle(String cycle);

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @noTransactionsTapGear.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet.\nTap the gear to pick your bank chat, or + to add one manually.'**
  String get noTransactionsTapGear;

  /// No description provided for @nothingInFilter.
  ///
  /// In en, this message translates to:
  /// **'Nothing in this filter.'**
  String get nothingInFilter;

  /// No description provided for @whichChatIsBank.
  ///
  /// In en, this message translates to:
  /// **'Which chat is your bank?'**
  String get whichChatIsBank;

  /// No description provided for @pickBankSenders.
  ///
  /// In en, this message translates to:
  /// **'Pick every sender that texts you card alerts. Only these are read.'**
  String get pickBankSenders;

  /// No description provided for @noSmsFoundAndroid.
  ///
  /// In en, this message translates to:
  /// **'No SMS found. This works on Android with SMS permission granted.'**
  String get noSmsFoundAndroid;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add a transaction'**
  String get addTransaction;

  /// No description provided for @oneOffEntryHint.
  ///
  /// In en, this message translates to:
  /// **'A one-off entry that is not from a bank SMS.'**
  String get oneOffEntryHint;

  /// No description provided for @whatWasIt.
  ///
  /// In en, this message translates to:
  /// **'What was it?'**
  String get whatWasIt;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get enterAmount;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @categoryWithBucket.
  ///
  /// In en, this message translates to:
  /// **'{name} · {bucket}'**
  String categoryWithBucket(String name, String bucket);

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String dateLabel(String date);

  /// No description provided for @thisTransaction.
  ///
  /// In en, this message translates to:
  /// **'this transaction'**
  String get thisTransaction;

  /// No description provided for @addToCategory.
  ///
  /// In en, this message translates to:
  /// **'Add to category'**
  String get addToCategory;

  /// No description provided for @debtPaymentNotInCategory.
  ///
  /// In en, this message translates to:
  /// **'This is counted as a debt payment, so it is not in a category. You can still file it here.'**
  String get debtPaymentNotInCategory;

  /// No description provided for @filesEveryNamed.
  ///
  /// In en, this message translates to:
  /// **'Files every \"{title}\" transaction into this category. Remove only this one with the button below.'**
  String filesEveryNamed(String title);

  /// No description provided for @fileUnderCategory.
  ///
  /// In en, this message translates to:
  /// **'File \"{title}\" under a category.'**
  String fileUnderCategory(String title);

  /// No description provided for @noCategoriesYetCreate.
  ///
  /// In en, this message translates to:
  /// **'No categories yet — create one in the Categories tab first.'**
  String get noCategoriesYetCreate;

  /// No description provided for @removeThisOne.
  ///
  /// In en, this message translates to:
  /// **'Remove this one'**
  String get removeThisOne;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @giveCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Give the category a name first.'**
  String get giveCategoryName;

  /// No description provided for @removeMatchingSmsQ.
  ///
  /// In en, this message translates to:
  /// **'Remove this matching SMS?'**
  String get removeMatchingSmsQ;

  /// No description provided for @removeRuleBody.
  ///
  /// In en, this message translates to:
  /// **'Messages from \"{name}\" will stop filing here and move to Unknown.'**
  String removeRuleBody(String name);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @removeMessageQ.
  ///
  /// In en, this message translates to:
  /// **'Remove this message?'**
  String get removeMessageQ;

  /// No description provided for @removeMessageBody.
  ///
  /// In en, this message translates to:
  /// **'{name} · {amount} on {date} will move to Unknown. Other messages from the same place stay in this category.'**
  String removeMessageBody(String name, String amount, String date);

  /// No description provided for @newCategory.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get newCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryName;

  /// No description provided for @egGroceries.
  ///
  /// In en, this message translates to:
  /// **'e.g. Groceries'**
  String get egGroceries;

  /// No description provided for @matchingSms.
  ///
  /// In en, this message translates to:
  /// **'Matching SMS'**
  String get matchingSms;

  /// No description provided for @matchingSmsHint.
  ///
  /// In en, this message translates to:
  /// **'Pick example SMS. Every past and future SMS to the same shop or person files here automatically. Turn on \"Only this amount\" when the same person gets money for different things.'**
  String get matchingSmsHint;

  /// No description provided for @pickExampleSms.
  ///
  /// In en, this message translates to:
  /// **'Pick example SMS'**
  String get pickExampleSms;

  /// No description provided for @orTypeShopName.
  ///
  /// In en, this message translates to:
  /// **'Or type a shop name'**
  String get orTypeShopName;

  /// No description provided for @inThisCategoryCount.
  ///
  /// In en, this message translates to:
  /// **'In this category ({count})'**
  String inThisCategoryCount(int count);

  /// No description provided for @inThisCategoryPeriodCount.
  ///
  /// In en, this message translates to:
  /// **'In this category · {period} ({count})'**
  String inThisCategoryPeriodCount(String period, int count);

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get showAll;

  /// No description provided for @thisPeriod.
  ///
  /// In en, this message translates to:
  /// **'This period'**
  String get thisPeriod;

  /// No description provided for @tapXToRemoveHint.
  ///
  /// In en, this message translates to:
  /// **'Tap ✕ to take out just that one transaction. SMS counted as a debt payment stay with the debt.'**
  String get tapXToRemoveHint;

  /// No description provided for @nothingMatchesYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches yet.'**
  String get nothingMatchesYet;

  /// No description provided for @noSmsInCategoryFor.
  ///
  /// In en, this message translates to:
  /// **'No SMS in this category for {period}.'**
  String noSmsInCategoryFor(String period);

  /// No description provided for @removeFromCategory.
  ///
  /// In en, this message translates to:
  /// **'Remove from this category'**
  String get removeFromCategory;

  /// No description provided for @removedCount.
  ///
  /// In en, this message translates to:
  /// **'Removed ({count})'**
  String removedCount(int count);

  /// No description provided for @putBack.
  ///
  /// In en, this message translates to:
  /// **'Put back'**
  String get putBack;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get deleteCategory;

  /// No description provided for @bucket.
  ///
  /// In en, this message translates to:
  /// **'Bucket'**
  String get bucket;

  /// No description provided for @remainingIncome.
  ///
  /// In en, this message translates to:
  /// **'Remaining income'**
  String get remainingIncome;

  /// No description provided for @spentWithPeriod.
  ///
  /// In en, this message translates to:
  /// **'Spent · {period}'**
  String spentWithPeriod(String period);

  /// No description provided for @incomeLeft.
  ///
  /// In en, this message translates to:
  /// **'Income {income} · left {left}'**
  String incomeLeft(String income, String left);

  /// No description provided for @incomeOverBy.
  ///
  /// In en, this message translates to:
  /// **'Income {income} · over by {over}'**
  String incomeOverBy(String income, String over);

  /// No description provided for @everyExpenseHasCategory.
  ///
  /// In en, this message translates to:
  /// **'Every expense has a category'**
  String get everyExpenseHasCategory;

  /// No description provided for @withoutCategoryCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 without a category} other{{count} without a category}}'**
  String withoutCategoryCount(int count);

  /// No description provided for @viewArrow.
  ///
  /// In en, this message translates to:
  /// **'View ›'**
  String get viewArrow;

  /// No description provided for @unknownStartHint.
  ///
  /// In en, this message translates to:
  /// **'Every expense starts in Unknown. Open it and move them into new categories, or tap + on a bucket and pick example SMS.'**
  String get unknownStartHint;

  /// No description provided for @movedExpensesTo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Moved 1 expense to {name}.} other{Moved {count} expenses to {name}.}}'**
  String movedExpensesTo(int count, String name);

  /// No description provided for @movedTo.
  ///
  /// In en, this message translates to:
  /// **'Moved to {name}.'**
  String movedTo(String name);

  /// No description provided for @unknownHint.
  ///
  /// In en, this message translates to:
  /// **'Expenses no category picked up. Tap Assign to give one a category; others from the same shop or person move with it.'**
  String get unknownHint;

  /// No description provided for @nothingLeftThisPeriod.
  ///
  /// In en, this message translates to:
  /// **'Nothing left here for this period.'**
  String get nothingLeftThisPeriod;

  /// No description provided for @assign.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get assign;

  /// No description provided for @assignTitle.
  ///
  /// In en, this message translates to:
  /// **'Assign \"{title}\"'**
  String assignTitle(String title);

  /// No description provided for @everyNamedExpenseGoes.
  ///
  /// In en, this message translates to:
  /// **'Every \"{title}\" expense will go to this category.'**
  String everyNamedExpenseGoes(String title);

  /// No description provided for @onlyThisExpenseMoves.
  ///
  /// In en, this message translates to:
  /// **'Only this one expense moves.'**
  String get onlyThisExpenseMoves;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @debtPayments.
  ///
  /// In en, this message translates to:
  /// **'Debt payments'**
  String get debtPayments;

  /// No description provided for @regularPaymentsFromDebts.
  ///
  /// In en, this message translates to:
  /// **'Regular payments from the Debts tab'**
  String get regularPaymentsFromDebts;

  /// No description provided for @paidAboveRegular.
  ///
  /// In en, this message translates to:
  /// **'Paid above the regular payment'**
  String get paidAboveRegular;

  /// No description provided for @debtsTab.
  ///
  /// In en, this message translates to:
  /// **'Debts tab'**
  String get debtsTab;

  /// No description provided for @addCategoryTo.
  ///
  /// In en, this message translates to:
  /// **'+ Add a category to {bucket}'**
  String addCategoryTo(String bucket);

  /// No description provided for @editArrow.
  ///
  /// In en, this message translates to:
  /// **'Edit ›'**
  String get editArrow;

  /// No description provided for @shareOfSpending.
  ///
  /// In en, this message translates to:
  /// **'{pct}% of spending · {action}'**
  String shareOfSpending(int pct, String action);

  /// No description provided for @noSmsPickedYet.
  ///
  /// In en, this message translates to:
  /// **'No SMS picked yet'**
  String get noSmsPickedYet;

  /// No description provided for @anyBank.
  ///
  /// In en, this message translates to:
  /// **'Any bank'**
  String get anyBank;

  /// No description provided for @moneyIn.
  ///
  /// In en, this message translates to:
  /// **'money in'**
  String get moneyIn;

  /// No description provided for @moneyOut.
  ///
  /// In en, this message translates to:
  /// **'money out'**
  String get moneyOut;

  /// No description provided for @nameContains.
  ///
  /// In en, this message translates to:
  /// **'name contains'**
  String get nameContains;

  /// No description provided for @onlyAmount.
  ///
  /// In en, this message translates to:
  /// **'Only {amount}'**
  String onlyAmount(String amount);

  /// No description provided for @anyAmountTapForOnly.
  ///
  /// In en, this message translates to:
  /// **'Any amount · tap for only {amount}'**
  String anyAmountTapForOnly(String amount);

  /// No description provided for @deleteRule.
  ///
  /// In en, this message translates to:
  /// **'Delete rule'**
  String get deleteRule;

  /// No description provided for @onePerShopHint.
  ///
  /// In en, this message translates to:
  /// **'One per shop or person is enough; the rest are found for you.'**
  String get onePerShopHint;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @payCyclesSince.
  ///
  /// In en, this message translates to:
  /// **'Pay cycles since {date}'**
  String payCyclesSince(String date);

  /// No description provided for @previousYear.
  ///
  /// In en, this message translates to:
  /// **'Previous year'**
  String get previousYear;

  /// No description provided for @nextYear.
  ///
  /// In en, this message translates to:
  /// **'Next year'**
  String get nextYear;

  /// No description provided for @yearTotalMonths.
  ///
  /// In en, this message translates to:
  /// **'{year} total · {started} of 12 months'**
  String yearTotalMonths(int year, int started);

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @savedLower.
  ///
  /// In en, this message translates to:
  /// **'saved'**
  String get savedLower;

  /// No description provided for @averageMonth.
  ///
  /// In en, this message translates to:
  /// **'Average month'**
  String get averageMonth;

  /// No description provided for @biggestMonth.
  ///
  /// In en, this message translates to:
  /// **'Biggest month'**
  String get biggestMonth;

  /// No description provided for @fromDate.
  ///
  /// In en, this message translates to:
  /// **'From {date}'**
  String fromDate(String date);

  /// No description provided for @notStartedYet.
  ///
  /// In en, this message translates to:
  /// **'Not started yet'**
  String get notStartedYet;

  /// No description provided for @running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get running;

  /// No description provided for @highest.
  ///
  /// In en, this message translates to:
  /// **'Highest'**
  String get highest;

  /// No description provided for @savedAmount.
  ///
  /// In en, this message translates to:
  /// **'saved {amount}'**
  String savedAmount(String amount);

  /// No description provided for @overAmount.
  ///
  /// In en, this message translates to:
  /// **'over {amount}'**
  String overAmount(String amount);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
