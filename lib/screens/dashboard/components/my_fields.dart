import 'dart:io';

import 'package:admin/models/my_files.dart';
import 'package:admin/responsive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:typed_data';

import '../../../constants.dart';
import 'file_info_card.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:html' as html; // For web-specific fixes if needed

Uint8List? _webImageBytes; // Add this at the top of your state class

class MyFiles extends StatelessWidget {
  const MyFiles({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "My Files",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ElevatedButton.icon(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: defaultPadding * 1.5,
                  vertical:
                      defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const AddProductDialog(),
                );
              },
              icon: Icon(Icons.add),
              label: Text("Add Product"),
            ),
          ],
        ),
        SizedBox(height: defaultPadding),
        Responsive(
          mobile: FileInfoCardGridView(
            crossAxisCount: _size.width < 650 ? 2 : 4,
            childAspectRatio: _size.width < 650 && _size.width > 350 ? 1.3 : 1,
          ),
          tablet: FileInfoCardGridView(),
          desktop: FileInfoCardGridView(
            childAspectRatio: _size.width < 1400 ? 1.1 : 1.4,
          ),
        ),
      ],
    );
  }
}

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({Key? key}) : super(key: key);

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  bool _isAvailable = true;
  File? _pickedImage;

  final _categories = ["Appetizer", "Main Course", "Dessert", "Drinks"];
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _tagsController = TextEditingController();
  final _prepTimeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isMobile = screenSize.width < 600;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : screenSize.width * 0.25,
        vertical: 24,
      ),
      child: Container(
        width: isMobile ? double.infinity : screenSize.width * 0.5,
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(
          maxHeight: 700,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Add New Product",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(_nameController, "Product Name", true),
                      _buildTextField(
                          _descController, "Product Description", true,
                          maxLines: 3),
                      Row(
                        children: [
                          Expanded(
                              child: _buildTextField(
                                  _priceController, "Price", true,
                                  isNumber: true)),
                          const SizedBox(width: 16),
                          Expanded(
                              child: _buildTextField(
                                  _discountController, "Discount", false,
                                  isNumber: true)),
                        ],
                      ),
                      _buildDropdownCategory(),
                      _buildTextField(
                          _prepTimeController, "Preparation Time", false),
                      _buildTextField(_tagsController,
                          "Tags / Ingredients (comma separated)", false),
                      _buildAvailabilitySwitch(),
                      _buildImagePicker(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  child: const Text("Add Product"),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: handle form submit
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, bool required,
      {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        validator: required
            ? (value) =>
                (value == null || value.isEmpty) ? "$label is required" : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdownCategory() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        onChanged: (value) => setState(() => _selectedCategory = value),
        validator: (value) => value == null ? "Category is required" : null,
        decoration: const InputDecoration(
          labelText: "Category",
          border: OutlineInputBorder(),
        ),
        items: _categories
            .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
            .toList(),
      ),
    );
  }

  Widget _buildAvailabilitySwitch() {
    return SwitchListTile(
      title: const Text("Available"),
      value: _isAvailable,
      onChanged: (value) => setState(() => _isAvailable = value),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Product Image"),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.upload),
              label: const Text("Upload Image"),
            ),
            const SizedBox(width: 12),
            if (_webImageBytes != null)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(_webImageBytes!, fit: BoxFit.cover),
                ),
              ),
            // if (_pickedImage != null)
            //   if (_pickedImage != null)
            //     Image.file(_pickedImage!,
            //         width: 80, height: 80, fit: BoxFit.cover)
            //   else if (_webImageBytes != null)
            //     Image.memory(_webImageBytes!,
            //         width: 80, height: 80, fit: BoxFit.cover)

            // Container(
            //   width: 80,
            //   height: 80,
            //   decoration: BoxDecoration(
            //     border: Border.all(color: Colors.grey),
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: ClipRRect(
            //     borderRadius: BorderRadius.circular(8),
            //     child: Image.file(_pickedImage!, fit: BoxFit.cover),
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final file = uploadInput.files?.first;
      final reader = html.FileReader();

      reader.readAsArrayBuffer(file!);
      reader.onLoadEnd.listen((e) {
        setState(() {
          _webImageBytes = reader.result as Uint8List;
        });
      });
    });
  }
}

class FileInfoCardGridView extends StatelessWidget {
  const FileInfoCardGridView({
    Key? key,
    this.crossAxisCount = 4,
    this.childAspectRatio = 1,
  }) : super(key: key);

  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: demoMyFiles.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) => FileInfoCard(info: demoMyFiles[index]),
    );
  }
}
