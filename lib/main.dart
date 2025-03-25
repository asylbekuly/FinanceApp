import 'package:flutter/material.dart';

void main() {
  runApp(FinanceTrackerApp());
}

class FinanceTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finance Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double balance = 0.0;
  double totalIncome = 0.0;
  double totalExpense = 0.0;
  List<Transaction> transactions = [];

  void _addTransaction(Transaction transaction) {
    setState(() {
      transactions.add(transaction);
      balance += transaction.amount;
      if (transaction.amount > 0) {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount.abs();
      }
    });
  }

  void _editTransaction(int index, Transaction updatedTransaction) {
    final oldTransaction = transactions[index];
    setState(() {
      // Удаляем старую сумму
      balance -= oldTransaction.amount;
      if (oldTransaction.amount > 0) {
        totalIncome -= oldTransaction.amount;
      } else {
        totalExpense -= oldTransaction.amount.abs();
      }

      // Обновляем транзакцию
      transactions[index] = updatedTransaction;
      balance += updatedTransaction.amount;
      if (updatedTransaction.amount > 0) {
        totalIncome += updatedTransaction.amount;
      } else {
        totalExpense += updatedTransaction.amount.abs();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Finance Tracker')),
      body: Column(
        children: [
          BalanceCard(balance: balance, income: totalIncome, expense: totalExpense),
          Expanded(
            child: TransactionList(
              transactions: transactions,
              onEdit: (index) async {
                final edited = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTransactionScreen(transaction: transactions[index]),
                  ),
                );
                if (edited != null) {
                  _editTransaction(index, edited);
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTransaction = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTransactionScreen()),
          );
          if (newTransaction != null) {
            _addTransaction(newTransaction);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class BalanceCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expense;
  
  BalanceCard({required this.balance, required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue[100],
      margin: EdgeInsets.all(16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Current Balance', style: TextStyle(fontSize: 18.0)),
            Text('${balance.toStringAsFixed(2)} ₸',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text('Income', style: TextStyle(fontSize: 16.0, color: Colors.green)),
                    Text('${income.toStringAsFixed(2)} ₸',
                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
                Column(
                  children: [
                    Text('Expenses', style: TextStyle(fontSize: 16.0, color: Colors.red)),
                    Text('${expense.toStringAsFixed(2)} ₸',
                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.red)),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(int) onEdit;

  TransactionList({required this.transactions, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return ListTile(
          title: Text(transaction.title),
          subtitle: Text(transaction.date.toString()),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${transaction.amount.toStringAsFixed(2)} ₸',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: transaction.amount < 0 ? Colors.red : Colors.green,
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => onEdit(index),
              ),
            ],
          ),
        );
      },
    );
  }
}

class Transaction {
  final String title;
  final double amount;
  final DateTime date;

  Transaction({required this.title, required this.amount, required this.date});
}

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction;

  AddTransactionScreen({this.transaction});

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  late TextEditingController titleController;
  late TextEditingController amountController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.transaction?.title ?? '');
    amountController = TextEditingController(text: widget.transaction?.amount.toString() ?? '');
  }

  void _submitTransaction() {
    final title = titleController.text;
    final amount = double.tryParse(amountController.text) ?? 0;
    if (title.isNotEmpty && amount != 0) {
      final newTransaction = Transaction(
        title: title,
        amount: amount,
        date: DateTime.now(),
      );
      Navigator.pop(context, newTransaction);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.transaction == null ? 'Add Transaction' : 'Edit Transaction')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitTransaction,
              child: Text(widget.transaction == null ? 'Add' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}