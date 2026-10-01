import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../app.locator.dart';
import '../../app.router.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';

class DashboardViewModel extends BaseViewModel {
  final _apiService = locator<ApiService>();
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();
  final _dialogService = locator<DialogService>();

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];

  List<Product> get products => _filteredProducts;
  int get totalProducts => _allProducts.length;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  double get totalInventoryValue {
    double total = 0;

    for (var product in _allProducts) {
      total += product.price;
    }

    return total;
  }

  Future<void> init() async {
    await fetchProducts();
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final products = await _apiService.getProducts();

      _allProducts = products;
      _applyFilter();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.trim().isEmpty) {
      _filteredProducts = List.from(_allProducts);
    } else {
      final query = _searchQuery.trim().toLowerCase();

      _filteredProducts = _allProducts.where((product) {
        final nameMatch = product.name.toLowerCase().contains(query);

        final descriptionMatch =
            product.description?.toLowerCase().contains(query) ?? false;

        return nameMatch || descriptionMatch;
      }).toList();
    }
  }

  Future<void> deleteProduct(Product product) async {
    if (product.id == null) return;

    final response = await _dialogService.showConfirmationDialog(
      title: 'Hapus Produk',
      description: 'Apakah Anda yakin ingin menghapus "${product.name}"?',
      confirmationTitle: 'Hapus',
      cancelTitle: 'Batal',
    );

    if (response?.confirmed != true) return;

    try {
      await _apiService.deleteProduct(product.id!);

      _snackbarService.showSnackbar(
        message: 'Produk berhasil dihapus!',
        duration: const Duration(seconds: 2),
      );

      await fetchProducts();
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Gagal menghapus produk: $e',
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Navigasi untuk menambahkan produk baru
  Future<void> goToAddProduct() async {
    final result = await _navigationService.navigateToProductFormView();

    if (result == true) {
      await fetchProducts();
    }
  }

  // Navigasi untuk mengedit produk
  Future<void> goToEditProduct(Product product) async {
    final result = await _navigationService.navigateToProductFormView(
      product: product,
    );

    if (result == true) {
      await fetchProducts();
    }
  }

  // Navigasi untuk melihat detail produk
  Future<void> goToDetail(Product product) async {
    final result = await _navigationService.navigateToProductDetailView(
      product: product,
    );

    if (result == true) {
      await fetchProducts();
    }
  }

  // Navigasi untuk logout
  Future<void> logout() async {
    await _navigationService.clearStackAndShow(Routes.loginView);
  }
}
