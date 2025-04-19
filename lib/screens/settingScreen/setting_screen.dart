import 'package:admin/models/category_model.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'category_cache.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  List<Category> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    final cache = CategoryCache();
    if (cache.hasData) {
      _categories = cache.getCategories();
      _loading = false;
    } else {
      fetchCategories();
    }
  }

  Future<void> fetchCategories() async {
    final url = Uri.parse(
        "https://poplar-spice.vercel.app/api/v1/category/all-category");

    final response = await http.get(
      url,
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY2ZGEzMDM4MTcyZjlkZWY1Y2FmMjQ5ZiIsImlhdCI6MTc0NTA4OTI1NCwiZXhwIjoxNzQ1Njk0MDU0fQ.8nG4rK2dmN76CJB3ffYR02gOhiRHGVMmUVBOid7mqGM',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> allCategories = data['allCategories'];
      final List<Category> loaded =
          allCategories.map((e) => Category.fromJson(e)).toList();

      CategoryCache().setCategories(loaded);

      setState(() {
        _categories = loaded;
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
      debugPrint('Failed to load categories');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "All Categories",
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(color: Colors.black),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: _categories.map((category) {
                        return Container(
                          width: 150,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Image.network(category.imageUrl,
                                  height: 50, fit: BoxFit.cover),
                              const SizedBox(height: 8),
                              Text(
                                category.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
