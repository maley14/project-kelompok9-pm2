import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

import 'services/api_service.dart';
import 'ui/login/login_view.dart';
import 'ui/dashboard/dashboard_view.dart';
import 'ui/product_detail/product_detail_view.dart';
import 'ui/product_form/product_form_view.dart';

@StackedApp(
  routes: [
    MaterialRoute(page: LoginView, initial: true),
    MaterialRoute(page: DashboardView),
    MaterialRoute(page: ProductDetailView),
    MaterialRoute(page: ProductFormView),
  ],
  dependencies: [
    LazySingleton(classType: ApiService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: SnackbarService),
    LazySingleton(classType: NavigationService),
  ],
  logger: StackedLogger(),
)
class App {
  /// This class has no logic in it, it's used only to generate the locator and router
}
