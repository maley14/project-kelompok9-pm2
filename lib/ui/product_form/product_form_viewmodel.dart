import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../app.locator.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';

class ProductFormViewModel extends BaseViewModel {
  final _apiService = locator<ApiService>();
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();

  Product? _product;
  Product? get product => _product;
  bool get isEdit => _product != null;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void initialize(Product? product) {
    _product = product;
  }

  Future<void> submit({
    required String name,
    required double price,
    int? stock,
    String? description,
    String? imageUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (isEdit) {
        // PATCH
        final Map<String, dynamic> updateData = {'name': name, 'price': price};
        if (description != null && description.isNotEmpty) {
          updateData['description'] = description;
        }
        if (stock != null) updateData['stock'] = stock;
        if (imageUrl != null && imageUrl.isNotEmpty) {
          updateData['image_url'] = imageUrl;
        }

        await _apiService.updateProduct(_product!.id!, updateData);

        _snackbarService.showSnackbar(
          message: 'Produk berhasil diperbarui!',
          duration: const Duration(seconds: 2),
        );
      } else {
        // POST
        final newProduct = Product(
          name: name,
          price: price,
          stock: stock,
          description: description != null && description.isNotEmpty
              ? description
              : null,
          imageUrl: imageUrl != null && imageUrl.isNotEmpty ? imageUrl : null,
          status: 'draft',
        );

        await _apiService.createProduct(newProduct);

        _snackbarService.showSnackbar(
          message: 'Produk baru berhasil ditambahkan!',
          duration: const Duration(seconds: 2),
        );
      }

      _navigationService.back(result: true);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _snackbarService.showSnackbar(
        message: _errorMessage ?? 'Terjadi kesalahan saat menyimpan',
        duration: const Duration(seconds: 3),
      );
      _isLoading = false;
      notifyListeners();
    }
  }
}
