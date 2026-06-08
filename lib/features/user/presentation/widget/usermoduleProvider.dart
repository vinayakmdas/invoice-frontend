import 'package:flutter/material.dart';
import 'package:invoice/features/user/data/datasources/user_api_datasource.dart';
import 'package:invoice/features/user/data/repoimpl/user_invoice_repo_imple.dart';
import 'package:invoice/features/user/data/repoimpl/user_item_repo_impl.dart';
import 'package:invoice/features/user/presentation/screens/user_home_screen.dart';
import 'package:invoice/features/user/presentation/viewmodel/invoice_view_model.dart';
import 'package:invoice/features/user/presentation/viewmodel/item_view_model.dart';
import 'package:invoice/features/user/presentation/viewmodel/user_session_provider.dart';
import 'package:provider/provider.dart';

/// Wrap this around your app (or the user flow) to inject all user-module deps.
///
/// Usage in main.dart (or wherever you navigate after login):
///
/// ```dart
/// Navigator.pushReplacement(
///   context,
///   MaterialPageRoute(
///     builder: (_) => UserModuleProviders(
///       child: UserHomeScreen(),
///     ),
///   ),
/// );
/// ```
///
/// Then call `context.read<UserSessionProvider>().setUser(id: ..., name: ...)`
/// right before or after pushing — the session provider will already be in scope.
class UserModuleProviders extends StatelessWidget {
  final Widget child;
  final UserSessionProvider? session;
  final ItemViewModel? itemVm;
  final InvoiceViewModel? invoiceVm;

  const UserModuleProviders({
    super.key,
    required this.child,
    this.session,
    this.itemVm,
    this.invoiceVm,
  });

  @override
  Widget build(BuildContext context) {
    final datasource = UserApiDatasource();

    return MultiProvider(
      providers: [
        // Session (singleton across the user module)
        session != null
            ? ChangeNotifierProvider<UserSessionProvider>.value(value: session!)
            : ChangeNotifierProvider<UserSessionProvider>(
                create: (_) => UserSessionProvider(),
              ),
        // Item ViewModel
        itemVm != null
            ? ChangeNotifierProvider<ItemViewModel>.value(value: itemVm!)
            : ChangeNotifierProvider<ItemViewModel>(
                create: (_) => ItemViewModel(UserItemRepositoryImpl(datasource)),
              ),
        // Invoice ViewModel
        invoiceVm != null
            ? ChangeNotifierProvider<InvoiceViewModel>.value(value: invoiceVm!)
            : ChangeNotifierProvider<InvoiceViewModel>(
                create: (_) =>
                    InvoiceViewModel(UserInvoiceRepositoryImpl(datasource)),
              ),
      ],
      child: child,
    );
  }
}

/// Convenience widget: sets user session and shows UserHomeScreen.
/// Use this as the destination when navigating after a successful login.
///
/// Pass the userId and userName from your existing auth result.
class UserModuleRoot extends StatefulWidget {
  final int userId;
  final String userName;

  const UserModuleRoot({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<UserModuleRoot> createState() => _UserModuleRootState();
}

class _UserModuleRootState extends State<UserModuleRoot> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserSessionProvider>().setUser(
        id: widget.userId,
        name: widget.userName,
      );
    });
  }

  @override
  Widget build(BuildContext context) => const UserHomeScreen();
}
