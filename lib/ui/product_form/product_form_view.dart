import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../models/product_model.dart';
import 'product_form_viewmodel.dart';

class ProductFormView extends StackedView<ProductFormViewModel> {
  final Product? product;

  const ProductFormView({
    super.key,
    this.product,
  });

  @override
  Widget builder(
    BuildContext context,
    ProductFormViewModel viewModel,
    Widget? child,
  ) {
    final product = this.product;

    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(
      text: product?.name ?? '',
    );

    final priceController = TextEditingController(
      text: product != null ? product.price.toInt().toString() : '',
    );

    final stockController = TextEditingController(
      text: product?.stock != null ? product!.stock.toString() : '',
    );

    final descriptionController = TextEditingController(
      text: product?.description ?? '',
    );

    final imageUuidController = TextEditingController(
      text: product?.imageUrl ?? '',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          viewModel.isEdit ? 'Edit Produk' : 'Tambah Produk Baru',
        ),
        backgroundColor: const Color.fromARGB(255, 188, 68, 102),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (viewModel.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          viewModel.errorMessage!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Produk *',
                  hintText: 'Contoh: Laptop Asus ROG',
                  prefixIcon: const Icon(
                    Icons.shopping_bag_outlined,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama produk wajib diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Harga (Rp) *',
                  hintText: 'Contoh: 7500000',
                  prefixIcon: const Icon(
                    Icons.attach_money_rounded,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Harga wajib diisi';
                  }

                  if (double.tryParse(value.trim()) == null) {
                    return 'Harga harus berupa angka';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Jumlah Stok (Opsional)',
                  hintText: 'Contoh: 10',
                  prefixIcon: const Icon(
                    Icons.inventory_rounded,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: imageUuidController,
                decoration: InputDecoration(
                  labelText: 'Asset Image UUID (Opsional)',
                  hintText: 'Contoh: 7e82272d-9218-41ee-8733-9b6326854a39',
                  prefixIcon: const Icon(
                    Icons.image_outlined,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Deskripsi Produk (Opsional)',
                  hintText: 'Tuliskan rincian spesifikasi produk...',
                  prefixIcon: const Icon(
                    Icons.description_outlined,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: viewModel.isLoading
                      ? null
                      : () {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          viewModel.submit(
                            name: nameController.text.trim(),
                            price:
                                double.tryParse(priceController.text.trim()) ??
                                    0.0,
                            stock: int.tryParse(
                              stockController.text.trim(),
                            ),
                            description: descriptionController.text.trim(),
                            imageUrl: imageUuidController.text.trim(),
                          );
                        },
                  icon: viewModel.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          viewModel.isEdit
                              ? Icons.save_rounded
                              : Icons.add_rounded,
                        ),
                  label: Text(
                    viewModel.isLoading
                        ? 'Menyimpan...'
                        : (viewModel.isEdit
                            ? 'Simpan Perubahan (PATCH)'
                            : 'Tambah Produk (POST)'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                      255,
                      188,
                      68,
                      102,
                    ),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  ProductFormViewModel viewModelBuilder(BuildContext context) {
    return ProductFormViewModel();
  }

  @override
  void onViewModelReady(ProductFormViewModel viewModel) {
    viewModel.initialize(product);
  }
}