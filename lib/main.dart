import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/intro_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/service_request_screen.dart';
import 'screens/results_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/provider_dashboard.dart';
import 'screens/provider_profile_screen.dart';
import 'screens/admin_statistics_screen.dart';

void main() {
  runApp(const SoutraApp());
}

class SoutraApp extends StatelessWidget {
  const SoutraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soutra AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        IntroScreen.routeName: (_) => const IntroScreen(),
        RoleSelectionScreen.routeName: (_) => const RoleSelectionScreen(),
        ServiceRequestScreen.routeName: (_) => const ServiceRequestScreen(),
        ResultsScreen.routeName: (_) => const ResultsScreen(),
        AiChatScreen.routeName: (_) => const AiChatScreen(),
        ProviderDashboard.routeName: (_) => const ProviderDashboard(),
        ProviderProfileScreen.routeName: (_) => const ProviderProfileScreen(),
        AdminStatisticsScreen.routeName: (_) => const AdminStatisticsScreen(),
      },
    );
  }
}