import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductEdit extends StatefulWidget {
  final String productId;
  final String title;
  final String description;
  final String price;
  final String imageUrl;

  const ProductEdit({
    Key? key,
    required this.productId,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
  }) : super(key: key);

  @override
  _ProductEditState createState() => _ProductEditState();
}

class _ProductEditState extends State<ProductEdit> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  File? _imageFile;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _descriptionController = TextEditingController(text: widget.description);
    _priceController = TextEditingController(text: widget.price);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  Future<void> _updateProductData() async {
    // Ensure at least one field to update is not empty
    if (_titleController.text.isEmpty &&
        _descriptionController.text.isEmpty &&
        _priceController.text.isEmpty &&
        _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill at least one field')));
      return;
    }

    // Define a map to hold the fields to update
    final Map<String, dynamic> productDataToUpdate = {};

    // Update the fields if they are not empty
    if (_titleController.text.isNotEmpty) {
      productDataToUpdate['title'] = _titleController.text;
    }
    if (_descriptionController.text.isNotEmpty) {
      productDataToUpdate['description'] = _descriptionController.text;
    }
    if (_priceController.text.isNotEmpty) {
      productDataToUpdate['price'] = _priceController.text;
    }

    // If a new image is selected, upload it to storage and update the 'image' field
    if (_imageFile != null) {
      // Delete previous image from storage if exists
      if (widget.imageUrl.isNotEmpty) {
        try {
          await FirebaseStorage.instance.refFromURL(widget.imageUrl).delete();
        } catch (error) {
          print('Error deleting previous image: $error');
        }
      }

      // Upload new image to storage
      final ref = _storage.ref().child('productImage/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(_imageFile!);
      final downloadUrl = await ref.getDownloadURL();

      // Update 'image' field
      productDataToUpdate['image'] = downloadUrl.toString();
    }

    // Update Firestore document with the updated fields
    try {
      await FirebaseFirestore.instance.collection('products').doc(widget.productId).update(productDataToUpdate);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product Updated')));
      // Navigate back to ProductList screen
      Navigator.pop(context);
    } catch (error) {
      print('Error updating product: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update product')));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Product',
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              leading: Icon(Icons.photo_library),
                              title: Text('Choose from gallery'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImageFromGallery();
                              },
                            ),

                            ListTile(
                              leading: Icon(Icons.photo_camera),
                              title: Text('Take a picture'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImageFromCamera();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10.0),
                    image: _imageFile != null
                        ? DecorationImage(
                      image: FileImage(File(_imageFile!.path)),
                      fit: BoxFit.cover,
                    )
                        : widget.imageUrl.isNotEmpty
                        ? DecorationImage(
                      image: NetworkImage(widget.imageUrl),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: _imageFile == null && widget.imageUrl.isEmpty
                      ? Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
                      : null,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _updateProductData();
                },
                child: Text('Update Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
