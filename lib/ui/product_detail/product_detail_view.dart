import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../models/product_model.dart';
import '../../services/api_service.dart';
import 'product_detail_viewmodel.dart';

class ProductDetailView extends StackedView<ProductDetailViewModel> {
  final Product product;

  const ProductDetailView({
    super.key,
    required this.product,
  });

  @override
  Widget builder(
    BuildContext context,
    ProductDetailViewModel viewModel,
    Widget? child,
  ) {
    final product = viewModel.product;
    final imageUrl = ApiService.getImageUrl(product.imageUrl);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        backgroundColor: const Color.fromARGB(255, 188, 68, 102),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Produk',
            onPressed: viewModel.editProduct,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Hapus Produk',
            onPressed: viewModel.isDeleting
                ? null
                : viewModel.deleteProduct,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.indigo.shade50,
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image_rounded,
                                size: 64,
                                color: Colors.indigo.shade200,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Gambar tidak dapat dimuat',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_rounded,
                            size: 80,
                            color: Colors.indigo.shade300,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tidak ada gambar produk',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    product.formattedPrice,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 188, 68, 102),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  _DetailRow(
                    icon: Icons.qr_code_rounded,
                    label: 'ID Produk (UUID)',
                    value: product.id ?? '-',
                  ),

                  const SizedBox(height: 12),

                  _DetailRow(
                    icon: Icons.inventory_rounded,
                    label: 'Jumlah Stok',
                    value: product.stock != null
                        ? '${product.stock} unit'
                        : 'Tidak ditentukan',
                  ),

                  const SizedBox(height: 12),

                  _DetailRow(
                    icon: Icons.image_outlined,
                    label: 'Asset ID Gambar',
                    value: product.imageUrl ?? 'Tanpa Asset Image',
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Deskripsi Produk',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      product.description != null &&
                              product.description!.isNotEmpty
                          ? product.description!
                          : 'Tidak ada deskripsi tersedia.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  ProductDetailViewModel viewModelBuilder(BuildContext context) {
    return ProductDetailViewModel();
  }

  @override
  void onViewModelReady(ProductDetailViewModel viewModel) {
    viewModel.initialize(product);
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color.fromARGB(255, 188, 68, 102),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}