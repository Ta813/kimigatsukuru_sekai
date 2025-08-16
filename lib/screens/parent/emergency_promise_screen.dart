// lib/screens/parent_mode/emergency_promise_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../helpers/shared_prefs_helper.dart';

class EmergencyPromiseScreen extends StatefulWidget {
  const EmergencyPromiseScreen({super.key});

  @override
  State<EmergencyPromiseScreen> createState() => _EmergencyPromiseScreenState();
}

class _EmergencyPromiseScreenState extends State<EmergencyPromiseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _durationController = TextEditingController(text: '10'); // 初期値を10分に
  final _pointsController = TextEditingController(text: '10'); // 初期値を10ポイントに

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  void _savePromise() async {
    if (_formKey.currentState!.validate()) {
      final emergencyPromise = {
        'title': _titleController.text,
        'duration': int.tryParse(_durationController.text) ?? 10,
        'points': int.tryParse(_pointsController.text) ?? 10,
      };
      // SharedPreferencesに保存
      await SharedPrefsHelper.saveEmergencyPromise(emergencyPromise);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('「${_titleController.text}」を緊急やくそくに設定しました。')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('緊急のやくそく設定')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'やくそくの名前（例: おもちゃのかたづけ）',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'やくそくの名前を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(labelText: '時間（分）'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pointsController,
                decoration: const InputDecoration(labelText: 'ポイント'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _savePromise,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('このやくそくをセットする'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
