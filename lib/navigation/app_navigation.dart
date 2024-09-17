import 'package:cj/models/invoice_model.dart';
import 'package:cj/services/auth/auth_service.dart';
import 'package:cj/views/auth/login_view.dart';
import 'package:cj/views/home/home_view.dart';
import 'package:cj/views/invoice/createInvoice_view.dart';
import 'package:cj/views/invoice/credit_view.dart';
import 'package:cj/views/invoice/finishinvoice_view.dart';
import 'package:cj/views/invoice/invoice_view.dart';
import 'package:cj/views/invoice/tpd_view.dart';
import 'package:cj/views/shop/addShop_view.dart';
import 'package:cj/views/shop/shop_view.dart';
import 'package:cj/views/stock/addStock_view.dart';
import 'package:cj/views/stock/stock_view.dart';
import 'package:cj/views/stock/viewPriceList_view.dart';
import 'package:cj/views/stock/viewStock_view.dart';
import 'package:cj/wrapper/main_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppNavigation {
  AppNavigation._();

  static String initial = "/home";

  // Private navigators
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorHome =
      GlobalKey<NavigatorState>(debugLabel: 'shellHome');
  static final _shellNavigatorinvoice =
      GlobalKey<NavigatorState>(debugLabel: 'shellinvoice');
  static final _shellNavigatorstock =
      GlobalKey<NavigatorState>(debugLabel: 'shellstock');
  static final _shellNavigatorshop =
      GlobalKey<NavigatorState>(debugLabel: 'shellshop');

  // GoRouter configuration
  static final GoRouter router = GoRouter(
    initialLocation: initial,
    redirect: (context, state) async {
      final String? token = await AuthService.getToken();
      final bool isAuthenticated = token != null;

      if (isAuthenticated) {
        return null;
      } else if (!isAuthenticated) {
        return "/login";
      } else {
        return null;
      }
    },
    debugLogDiagnostics: true,
    navigatorKey: _rootNavigatorKey,
    routes: [
      /// Login Route
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (BuildContext context, GoRouterState state) => LoginView(),
      ),

      /// MainWrapper
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(
            navigationShell: navigationShell,
          );
        },
        branches: <StatefulShellBranch>[
          /// Branch Home
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHome,
            routes: <RouteBase>[
              GoRoute(
                path: "/home",
                name: "home",
                builder: (BuildContext context, GoRouterState state) =>
                    const HomeView(),
              ),
            ],
          ),

          StatefulShellBranch(
            navigatorKey: _shellNavigatorinvoice,
            routes: <RouteBase>[
              GoRoute(
                  path: "/invoice",
                  name: "invoice",
                  builder: (BuildContext context, GoRouterState state) =>
                      const InvoiceView(),
                  routes: [
                    GoRoute(
                      path: "createInvoice",
                      name: "createInvoice",
                      pageBuilder: (context, state) {
                        return CustomTransitionPage<void>(
                          key: state.pageKey,
                          child: CreateinvoiceView(),
                          transitionsBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                            child,
                          ) =>
                              FadeTransition(opacity: animation, child: child),
                        );
                      },
                    ),
                    GoRoute(
                      path: "tpd",
                      name: "tpd",
                      pageBuilder: (context, state) {
                        return CustomTransitionPage<void>(
                          key: state.pageKey,
                          child: const TpdView(),
                          transitionsBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                            child,
                          ) =>
                              FadeTransition(opacity: animation, child: child),
                        );
                      },
                    ),
                    GoRoute(
                      path: "finishinvoiceView",
                      name: "finishinvoiceView",
                      pageBuilder: (context, state) {
                        // Retrieve the list of InvoiceItem from the extra parameter
                        final List<InvoiceItem> items =
                            state.extra as List<InvoiceItem>;

                        return CustomTransitionPage<void>(
                          key: state.pageKey,
                          child: FinishinvoiceView(
                              items: items), // Pass the items to the view
                          transitionsBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                            child,
                          ) =>
                              FadeTransition(opacity: animation, child: child),
                        );
                      },
                    ),
                    GoRoute(
                      path: "creditView",
                      name: "creditView",
                      pageBuilder: (context, state) {
                        return CustomTransitionPage<void>(
                          key: state.pageKey,
                          child: const CreditView(),
                          transitionsBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                            child,
                          ) =>
                              FadeTransition(opacity: animation, child: child),
                        );
                      },
                    ),
                  ]),
            ],
          ),

          StatefulShellBranch(
            navigatorKey: _shellNavigatorstock,
            routes: <RouteBase>[
              GoRoute(
                  path: "/stock",
                  name: "stock",
                  builder: (BuildContext context, GoRouterState state) =>
                      const StockView(),
                  routes: [
                    GoRoute(
                      path: "addstock",
                      name: "addstock",
                      pageBuilder: (context, state) {
                        return CustomTransitionPage<void>(
                          key: state.pageKey,
                          child: const AddstockView(),
                          transitionsBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                            child,
                          ) =>
                              FadeTransition(opacity: animation, child: child),
                        );
                      },
                    ),
                    GoRoute(
                      path: "viewpricelist",
                      name: "viewpricelist",
                      pageBuilder: (context, state) {
                        return CustomTransitionPage<void>(
                          key: state.pageKey,
                          child: const ViewpricelistView(),
                          transitionsBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                            child,
                          ) =>
                              FadeTransition(opacity: animation, child: child),
                        );
                      },
                    ),
                    GoRoute(
                      path: "viewstock",
                      name: "viewstock",
                      pageBuilder: (context, state) {
                        return CustomTransitionPage<void>(
                          key: state.pageKey,
                          child: const ViewstockView(),
                          transitionsBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                            child,
                          ) =>
                              FadeTransition(opacity: animation, child: child),
                        );
                      },
                    ),
                  ]),
            ],
          ),

          StatefulShellBranch(
            navigatorKey: _shellNavigatorshop,
            routes: <RouteBase>[
              GoRoute(
                  path: "/shop",
                  name: "shop",
                  builder: (BuildContext context, GoRouterState state) =>
                      const ShopView(),
                  routes: [
                    GoRoute(
                      path: "addshop",
                      name: "addshop",
                      pageBuilder: (context, state) {
                        return CustomTransitionPage<void>(
                          key: state.pageKey,
                          child: const AddshopView(),
                          transitionsBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                            child,
                          ) =>
                              FadeTransition(opacity: animation, child: child),
                        );
                      },
                    ),
                  ]),
            ],
          ),
        ],
      ),
    ],
  );
}
