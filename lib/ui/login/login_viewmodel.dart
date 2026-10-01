import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../app.locator.dart';
import '../../services/api_service.dart';
import '../../app.router.dart';

class LoginViewModel extends BaseViewModel {
  final _apiService = locator<ApiService>();
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.login(email, password);
      // Pindah ke dashboard, hapus history login
      await _navigationService.replaceWith(Routes.dashboardView);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _snackbarService.showSnackbar(
        message: _errorMessage ?? 'Login gagal',
        duration: const Duration(seconds: 2),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
