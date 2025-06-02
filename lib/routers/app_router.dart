import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../views/register/register_page.dart';
import '../views/login/login_page.dart';
import '../views/forgot_password/forgot_password_page.dart';
import '../views/home/home_page.dart';
import '../views/contact_details/contact_details_page.dart';
import '../views/camera/camera_page.dart';
import '../views/form/form_page.dart';
import '../entities/contact_entity.dart';
import '../views/profile/profile_page.dart';

class AppRouter {
  static final AppRouter _instance = AppRouter._internal();
  factory AppRouter() => _instance;
  AppRouter._internal();

  final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    // Start the app at the Login page
    initialLocation: '/login',
    routes: [
      // Register screen
      GoRoute(
        name: RegisterPage.routeName,
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),

      // Login screen
      GoRoute(
        name: LoginPage.routeName,
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),

      // Forgot Password screen
      GoRoute(
        name: ForgotPasswordPage.routeName,
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        name: ProfilePage.routeName,
        path: '/profile',
        builder: (ctx, state) => const ProfilePage(),
      ),

      // Home screen and its nested routes
      GoRoute(
        name: HomePage.routeName,
        path: '/',
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            name: ContactDetailsPage.routeName,
            path: 'details/:id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id']!)!;
              return ContactDetailsPage(id: id);
            },
          ),
          GoRoute(
            name: CameraPage.routeName,
            path: 'camera',
            builder: (context, state) => const CameraPage(),
            routes: [
              GoRoute(
                name: FormPage.routeName,
                path: 'form',
                builder: (context, state) {
                  final contact = state.extra! as ContactEntity;
                  return FormPage(contactEntity: contact);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );

  // Navigation helper methods
  void navigateToHome(BuildContext context) => context.goNamed(HomePage.routeName);
  void navigateToLogin(BuildContext context) => context.goNamed(LoginPage.routeName);
  void navigateToRegister(BuildContext context) => context.goNamed(RegisterPage.routeName);
  void navigateToForgotPassword(BuildContext context) => context.goNamed(ForgotPasswordPage.routeName);
  void navigateToCamera(BuildContext context, ContactEntity contact) =>
      context.goNamed(CameraPage.routeName, extra: contact);
  void navigateToDetails(BuildContext context, int id) =>
      context.go('/details/$id');
  void navigateToForm(BuildContext context, ContactEntity contact) =>
      context.goNamed(FormPage.routeName, extra: contact);
  void navigateToProfile(BuildContext ctx) =>
      ctx.goNamed(ProfilePage.routeName);

}
