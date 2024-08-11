import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';

class NewExpense extends StatefulWidget {
  const NewExpense(this.onAddExpense, {super.key});

  final Function(Expense) onAddExpense;

  @override
  State<NewExpense> createState() => _NewExpenseState();
}

class _NewExpenseState extends State<NewExpense> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime? _selectedDate;
  Category _selectedCategory = Category.leisure;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _showDialog() {
    if (Platform.isIOS) {
      showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
                title: const Text('Invalid input'),
                content: const Text(
                    'Please make sure a valid title, amount, date and category was entered.'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                      },
                      child: const Text('Okay'))
                ],
              ));
    } else {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: const Text('Invalid input'),
                content: const Text(
                    'Please make sure a valid title, amount, date and category was entered.'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                      },
                      child: const Text('Okay'))
                ],
              ));
    }
  }

  void _submitExpenseData() {
    final enteredAmount = double.tryParse(_amountController.text);

    final amountIsIvalid = enteredAmount == null || enteredAmount <= 0;

    if (_titleController.text.trim().isEmpty ||
        amountIsIvalid ||
        _selectedDate == null) {
      _showDialog();
      return;
    }

    widget.onAddExpense(Expense(
        title: _titleController.text,
        amount: enteredAmount,
        date: _selectedDate!,
        category: _selectedCategory));

    Navigator.pop(context);
  }

  void _presentDayPicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: firstDate,
        lastDate: now);

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void _changeCategory(value) {
    setState(() {
      _selectedCategory = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    return LayoutBuilder(builder: (ctx, constraints) {
      final width = constraints.maxWidth;
      return SizedBox(
        height: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardSpace + 16),
            child: Column(
              children: [
                if (width >= 600)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child:
                            TitleTextField(titleController: _titleController),
                      ),
                      const SizedBox(
                        width: 24,
                      ),
                      Expanded(
                        child: AmountTextField(
                            amountController: _amountController),
                      ),
                    ],
                  )
                else
                  TitleTextField(titleController: _titleController),
                if (width >= 600)
                  Row(
                    children: [
                      CategoryDropDownButton(
                        selectedCategory: _selectedCategory,
                        onCategoryChanged: _changeCategory,
                      ),
                      const SizedBox(
                        width: 24,
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(_selectedDate == null
                                ? 'No date selected'
                                : formatter.format(_selectedDate!)),
                            IconButton(
                                onPressed: _presentDayPicker,
                                icon: const Icon(Icons.calendar_month))
                          ],
                        ),
                      )
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: AmountTextField(
                            amountController: _amountController),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(_selectedDate == null
                                ? 'No date selected'
                                : formatter.format(_selectedDate!)),
                            IconButton(
                                onPressed: _presentDayPicker,
                                icon: const Icon(Icons.calendar_month))
                          ],
                        ),
                      )
                    ],
                  ),
                const SizedBox(
                  height: 16,
                ),
                if (width >= 600)
                  Row(
                    children: [
                      const Spacer(),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel')),
                      ElevatedButton(
                          onPressed: _submitExpenseData,
                          child: const Text('Save'))
                    ],
                  )
                else
                  Row(
                    children: [
                      DropdownButton(
                          value: _selectedCategory,
                          items: Category.values
                              .map((category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(
                                    category.name.toUpperCase(),
                                  )))
                              .toList(),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _selectedCategory = value;
                            });
                            print(_selectedCategory);
                          }),
                      const Spacer(),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel')),
                      ElevatedButton(
                          onPressed: _submitExpenseData,
                          child: const Text('Save'))
                    ],
                  )
              ],
            ),
          ),
        ),
      );
    });
  }
}

class CategoryDropDownButton extends StatelessWidget {
  const CategoryDropDownButton(
      {super.key,
      required Category selectedCategory,
      required this.onCategoryChanged})
      : _selectedCategory = selectedCategory;

  final Category _selectedCategory;
  final Function(Category) onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
        value: _selectedCategory,
        items: Category.values
            .map((category) => DropdownMenuItem(
                value: category,
                child: Text(
                  category.name.toUpperCase(),
                )))
            .toList(),
        onChanged: (value) {
          if (value == null) {
            return;
          }
          onCategoryChanged(value);
        });
  }
}

class AmountTextField extends StatelessWidget {
  const AmountTextField({
    super.key,
    required TextEditingController amountController,
  }) : _amountController = amountController;

  final TextEditingController _amountController;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _amountController,
      decoration:
          const InputDecoration(label: Text('Amount'), prefixText: '\$'),
      keyboardType: TextInputType.number,
    );
  }
}

class TitleTextField extends StatelessWidget {
  const TitleTextField({
    super.key,
    required TextEditingController titleController,
  }) : _titleController = titleController;

  final TextEditingController _titleController;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _titleController,
      maxLength: 50,
      decoration: const InputDecoration(label: Text('Title')),
    );
  }
}
