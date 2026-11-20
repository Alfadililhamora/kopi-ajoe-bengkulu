import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'models/user_model.dart';
import 'providers/app_provider.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/customer_main_screen.dart';
import 'screens/login_screen.dart';
import 'screens/operator_dashboard_screen.dart';

class KopiAjoeApp extends StatelessWidget {
  const KopiAjoeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: MaterialApp(
        title: 'Kopi Ajoe Bengkulu',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: Consumer<AppProvider>(
          builder: (context, provider, _) {
            final user = provider.currentUser;
            if (user == null) return const LoginScreen();
            switch (user.role) {
              case UserRole.pelanggan:
                return const CustomerMainScreen();
              case UserRole.operator:
                return const OperatorDashboardScreen();
              case UserRole.admin:
                return const AdminDashboardScreen();
            }
          },
        ),
      ),
    );
  }
}
