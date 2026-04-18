import 'package:flutter/foundation.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';

class Transaction {
  final double amount;
  final String bank;
  final DateTime date;
  final bool isDebit;

  Transaction({
    required this.amount,
    required this.bank,
    required this.date,
    required this.isDebit,
  });
}

class FinanceEngine extends ChangeNotifier {
  final SmsQuery _query = SmsQuery();
  List<Transaction> _transactions = [];
  double _dailySpent = 0.0;

  List<Transaction> get transactions => _transactions;
  double get dailySpent => _dailySpent;

  FinanceEngine() {
    refreshFinanceData();
  }

  Future<void> refreshFinanceData() async {
    var permission = await Permission.sms.status;
    if (permission.isGranted) {
      final messages = await _query.querySms(
        kinds: [SmsQueryKind.inbox],
        count: 50, // Scan last 50 messages
      );

      _parseMessages(messages);
      notifyListeners();
    }
  }

  void _parseMessages(List<SmsMessage> messages) {
    final List<Transaction> found = [];
    double daily = 0.0;
    final now = DateTime.now();

    // Regex for common transaction formats: "Rs. 500.00 debited", "$10.50 spent", "Amt: 1,200.00"
    final RegExp amountRegExp = RegExp(
      r'(?:Rs|INR|USD|\$|Amt)[:\.\s]*([\d,]+\.?\d{0,2})',
    );
    final List<String> debitKeywords = [
      'debited',
      'spent',
      'paid',
      'purchased',
      'sent',
    ];

    for (var msg in messages) {
      final body = msg.body?.toLowerCase() ?? "";
      final match = amountRegExp.firstMatch(msg.body ?? "");

      if (match != null) {
        final amountStr = match.group(1)?.replaceAll(',', '') ?? "0";
        final amount = double.tryParse(amountStr) ?? 0.0;

        bool isDebit = debitKeywords.any((kw) => body.contains(kw));

        if (amount > 0) {
          final tx = Transaction(
            amount: amount,
            bank: _extractBank(msg.sender ?? "Unknown"),
            date: msg.date ?? DateTime.now(),
            isDebit: isDebit,
          );
          found.add(tx);

          // Calculate daily spent if it's a debit from today
          if (isDebit &&
              tx.date.day == now.day &&
              tx.date.month == now.month &&
              tx.date.year == now.year) {
            daily += amount;
          }
        }
      }
    }
    _transactions = found;
    _dailySpent = daily;
  }

  String _extractBank(String sender) {
    // Basic extraction from sender IDs like "VM-HDFCBK" or "AD-KOTAKB"
    if (sender.contains('-')) {
      return sender.split('-').last;
    }
    return sender;
  }
}
