import 'package:finance/services/bank_sms_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseBankSms', () {
    test('debit / purchase with merchant and balance line', () {
      final r = parseBankSms(
        'Your account XXXX debited OMR 12.500 at LULU HYPERMARKET on '
        '05/08/2026. Avail bal OMR 340.200',
      );
      expect(r, isNotNull);
      expect(r!.isCredit, isFalse);
      expect(r.amount, 12.500); // not the 340.200 balance
      expect(r.description, 'LULU HYPERMARKET');
      expect(r.date, DateTime(2026, 8, 5));
    });

    test('credit / salary deposit', () {
      final r = parseBankSms(
        'OMR 850.000 credited to a/c XXXX being SALARY on 25-07-2026. '
        'Available balance OMR 900.000',
      );
      expect(r, isNotNull);
      expect(r!.isCredit, isTrue);
      expect(r.amount, 850.000);
      expect(r.date, DateTime(2026, 7, 25));
    });

    test('amount after currency word', () {
      final r = parseBankSms('Purchase of 5.750 OMR at COFFEE SHOP');
      expect(r, isNotNull);
      expect(r!.isCredit, isFalse);
      expect(r.amount, 5.750);
      expect(r.description, 'COFFEE SHOP');
    });

    test('RO currency form with thousands separator', () {
      final r = parseBankSms('Amount RO 1,250.000 withdrawn from ATM');
      expect(r, isNotNull);
      expect(r!.amount, 1250.0);
      expect(r.isCredit, isFalse);
    });

    test('ATM withdrawal falls back to generic description', () {
      final r = parseBankSms('OMR 20.000 withdrawn on 01/08/2026');
      expect(r, isNotNull);
      expect(r!.description, 'Payment');
    });

    test('real "card used for" alert (masked a/c, merchant ref, balance)', () {
      final r = parseBankSms(
        'Card of a/c 0616XXXXXXXX0001 used for OMR 10.405 at TALABAT '
        'OM000000000000 on 16/07/2026 22:46:42. Avl Bal OMR 474.352.',
      );
      expect(r, isNotNull);
      expect(r!.isCredit, isFalse); // "used for" = money out
      expect(r.amount, 10.405); // not the 474.352 balance
      expect(r.balanceAfter, 474.352); // captured from "Avl Bal"
      expect(r.card, '0001'); // last 4 of the account, not the "0616" prefix
      expect(r.description, 'TALABAT'); // ref code trimmed off
      expect(r.date, DateTime(2026, 7, 16));
    });

    test('extracts card last-4 from common phrasings', () {
      expect(
        parseBankSms('Card ending 1234 debited OMR 3.000 at STORE')?.card,
        '1234',
      );
      expect(
        parseBankSms('OMR 5.000 spent on card no. XXXX9876')?.card,
        '9876',
      );
      expect(
        parseBankSms('Purchase OMR 2.000 using a/c ****4321')?.card,
        '4321',
      );
    });

    test('no card mentioned leaves card empty', () {
      expect(parseBankSms('OMR 20.000 withdrawn on 01/08/2026')?.card, '');
    });

    test('English mobile-payment "You have sent" (starts with Dear Customer)',
        () {
      final r = parseBankSms(
        'Dear Customer, You have sent OMR 5.000 to BRAHXXXXXXXXXXXXXOHAM from '
        'your a/c 0304XXXXXXXX0017 on 08/08/2026 11:48:36 using Mobile Payment '
        'services. Txn Id BMCT014934975382. Avl Bal OMR 677.414.',
      );
      expect(r, isNotNull); // "Dear Customer" must NOT reject a real txn
      expect(r!.isCredit, isFalse);
      expect(r.amount, 5.000);
      expect(r.description, 'BRAHXXXXXXXXXXXXXOHAM'); // stops before "from"
      expect(r.card, '0017');
      expect(r.balanceAfter, 677.414);
      expect(r.date, DateTime(2026, 8, 8));
    });

    test('Arabic "you sent" alert: merchant, account, balance', () {
      final r = parseBankSms(
        'عزيزي الزبون، لقد قمت بإرسال OMR 1.000 إلى SHU****LAH من حسابك '
        '0304XXXXXXXX0017 باستخدام خدمات الدفع عبر الهاتف النقال/ المحفظة '
        'الإلكترونية. رقم المعاملة BMCT014862618452. رصيدك الحالي هو OMR 711.441.',
      );
      expect(r, isNotNull);
      expect(r!.isCredit, isFalse); // "قمت بإرسال" = money out
      expect(r.amount, 1.000); // not the 711.441 balance
      expect(r.description, 'SHU****LAH'); // recipient after إلى
      expect(r.card, '0017'); // last 4 of حساب 0304…0017
      expect(r.balanceAfter, 711.441); // after رصيدك الحالي
    });

    test('non-transaction message returns null', () {
      expect(parseBankSms('Your OTP is 123456. Do not share it.'), isNull);
      expect(parseBankSms('Welcome to Bank Muscat mobile banking.'), isNull);
    });

    test('message with amount but no direction keyword returns null', () {
      expect(parseBankSms('Your balance is OMR 500.000'), isNull);
    });

    test('marketing SMS with money + action words is rejected', () {
      // Contains "spend" (a debit word) and an amount, but is an ad.
      expect(
        parseBankSms('Spend OMR 50.000 and get 10% cashback! Apply now.'),
        isNull,
      );
      expect(
        parseBankSms('Get a personal loan today. Exclusive offer, T&C apply.'),
        isNull,
      );
      expect(
        parseBankSms(
          'Congratulations! You won OMR 100.000. Click here: http://x.co',
        ),
        isNull,
      );
    });

    test('credit alert ("is credited to your")', () {
      final r = parseBankSms(
        'OMR 850.000 is credited to your a/c XXXX0001 on 25/07/2026. '
        'New available balance OMR 900.000.',
      );
      expect(r, isNotNull);
      expect(r!.isCredit, isTrue);
      expect(r.amount, 850.000);
      expect(r.balanceAfter, 900.000); // "New available balance OMR 900.000"
      expect(r.card, '0001');
    });

    test('bank marketing words are rejected (dear customer, prize, draw...)',
        () {
      expect(
        parseBankSms('Dear customer, spend OMR 5.000 to enter our lucky draw!'),
        isNull,
      );
      expect(parseBankSms('Win a prize of OMR 1000.000 this month!'), isNull);
      expect(parseBankSms('Pay bills easily and spend OMR 2.000 less.'), isNull);
    });

    test('real Meethaq prize-draw marketing SMS is rejected', () {
      final r = parseBankSms(
        'Dear Customer,\n'
        'Be among the winners of a total cash prize worth OMR 2,250 with '
        'Meethaq Mobile & Internet Banking! Register, pay bills or purchase a '
        'gift voucher worth OMR 50 or more to enter the draw.\n'
        'Offer valid until 30 September 2026\n'
        'T&Cs apply: https://bm.click/MERDTCE\n\n'
        'STOP: lnkom.com/u/Meethaq',
      );
      expect(r, isNull);
    });

    test('"draw" blocklist does not reject a real withdrawal', () {
      // "withdrawn" contains "draw" — must still parse as a transaction.
      final r = parseBankSms(
        'Card of a/c XXXX0001 used for OMR 20.000 withdrawn at ATM. '
        'Avl Bal OMR 100.000',
      );
      expect(r, isNotNull);
      expect(r!.amount, 20.000);
      expect(r.isCredit, isFalse);
    });

    test('real transaction is NOT mistaken for marketing', () {
      final r = parseBankSms(
        'Card of a/c 0616XXXXXXXX0001 used for OMR 10.405 at TALABAT '
        'OM000000000000 on 16/07/2026 22:46:42. Avl Bal OMR 474.352.',
      );
      expect(r, isNotNull);
      expect(r!.amount, 10.405);
    });
  });
}
