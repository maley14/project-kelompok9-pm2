import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../app.locator.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';
import '../../app.router.dart';

class ProductDetailViewModel extends BaseViewModel {
  final _apiService = locator<ApiService>();
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();
  final _dialogService = locator<DialogService>();

  late Product _product;
  Product get product => _product;

  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;

  void initialize(Product product) {
    _product = product;
  }

  Future<void> deleteProduct() async {
    if (_product.id == null) return;

    final response = await _dialogService.showConfirmationDialog(
      title: 'Hapus Produk',
      description: 'Apakah Anda yakin ingin menghapus "${_product.name}"?',
      confirmationTitle: 'Hapus',
      cancelTitle: 'Batal',
    );

    if (response?.confirmed != true) return;

    _isDeleting = true;
    notifyListeners();

    try {
      await _apiService.deleteProduct(_product.id!);
      _snackbarService.showSnackbar(
        message: 'Produk berhasil dihapus!',
        duration: const Duration(seconds: 2),
      );
      _navigationService.back(result: true);
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Gagal menghapus produk: $e',
        duration: const Duration(seconds: 3),
      );
      _isDeleting = false;
      notifyListeners();
    }
  }

  Future<void> editProduct() async {
    final result = await _navigationService.navigateTo(
      Routes.productFormView,
      arguments: ProductFormViewArguments(product: _product),
    );
    if (result == true) {
      _navigationService.back(result: true);
    }
  }
}
