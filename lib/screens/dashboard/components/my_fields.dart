import 'dart:io';
import 'package:admin/models/my_files.dart';
import 'package:admin/responsive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:html' as html;
import 'dart:typed_data';

import '../../../constants.dart';
import 'file_info_card.dart';

// Uint8List? _webImageBytes; // Add this at the top of your state class
List<Uint8List> _webImageBytesList = [];


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
                                  _priceController, "Price ৳", true,
                                  isNumber: true)),
                          const SizedBox(width: 16),
                          Expanded(
                              child: _buildTextField(
                                  _discountController, "Discount %", false,
                                  isNumber: true)),
                        ],
                      ),
                      _buildDropdownCategory(),
                      // _buildTextField(
                      //     _prepTimeController, "Preparation Time", false),
                      _buildTimePickerField(),

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
    TextEditingController controller,
    String label,
    bool required, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        inputFormatters: isNumber
            ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))]
            : [],
        maxLines: maxLines,
        validator: required
            ? (value) =>
                (value == null || value.isEmpty) ? "$label is required" : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.black,
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
      const Text("Product Images"),
      const SizedBox(height: 8),
      ElevatedButton.icon(
        onPressed: _pickImage,
        icon: const Icon(Icons.upload),
        label: const Text("Upload Images"),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _webImageBytesList.map((imageData) {
          return Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(imageData, fit: BoxFit.cover),
            ),
          );
        }).toList(),
      ),
    ],
  );
}



  Future<void> _pickImage() async {
  final uploadInput = html.FileUploadInputElement()
    ..accept = 'image/*'
    ..multiple = true; // ✅ enable multiple files
  uploadInput.click();

  uploadInput.onChange.listen((event) {
    final files = uploadInput.files;
    if (files == null || files.isEmpty) return;

    _webImageBytesList.clear(); // Optional: reset previous images

    for (final file in files) {
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((event) {
        setState(() {
          _webImageBytesList.add(reader.result as Uint8List);
        });
      });
    }
  });
}


  Widget _buildTimePickerField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: _prepTimeController,
        readOnly: true,
        onTap: () async {
          TimeOfDay? time = await showTimePicker(
            context: context,
            initialTime:
                const TimeOfDay(hour: 0, minute: 15), // default 15 mins
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(alwaysUse24HourFormat: true),
                child: child!,
              );
            },
          );

          if (time != null) {
            final durationText = time.hour > 0
                ? "${time.hour}h ${time.minute}m"
                : "${time.minute} mints";

            setState(() {
              _prepTimeController.text = durationText;
            });
          }
        },
        decoration: const InputDecoration(
          labelText: "Preparation Time",
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.black,
          suffixIcon: Icon(Icons.access_time),
        ),
      ),
    );
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
