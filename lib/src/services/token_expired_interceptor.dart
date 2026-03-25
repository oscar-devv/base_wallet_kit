import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import '../config/router/base_router.dart';
import 'secure_token_storage.dart';

/// Interceptor que detecta respuestas 401 y muestra la pantalla de sesión expirada.
/// Configura la ruta de login mediante [BaseWalletKit.init].
class TokenExpiredInterceptor extends Interceptor {
  static bool _isHandlingExpiration = false;

  /// Permite suprimir temporalmente la alerta (ej: flujo de registro)
  static bool suppress = false;

  /// Paths que no deben disparar el logout al recibir 401
  static List<String> excludedPaths = [
    'auth/login',
    'auth/mfa',
    'auth/password',
    'create-user',
    'check-preregister',
  ];

  bool _isExcludedEndpoint(String path) =>
      excludedPaths.any((p) => path.contains(p));

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.statusCode == 401 &&
        !_isExcludedEndpoint(response.requestOptions.path)) {
      _handleTokenExpired();
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401 &&
        !_isExcludedEndpoint(err.requestOptions.path)) {
      _handleTokenExpired();
    }
    handler.next(err);
  }

  static void handleExpired() =>
      TokenExpiredInterceptor()._handleTokenExpired();

  void _handleTokenExpired() {
    if (_isHandlingExpiration || suppress) return;
    _isHandlingExpiration = true;
    SecureTokenStorage.clearAllTokens();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = BaseWalletKit.navigatorKey.currentContext;
      if (context == null) {
        _isHandlingExpiration = false;
        return;
      }
      _showExpiredDialog(context);
    });
  }

  void _showExpiredDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        barrierColor: Colors.white,
        pageBuilder: (dialogContext, _, __) => PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 40.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/lotties/error.json',
                      width: 200.w,
                      height: 200.h,
                      repeat: true,
                    ),
                    SizedBox(height: 40.h),
                    Text(
                      'Sesión Expirada',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF101010),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Cerramos tu sesión por inactividad. Por favor, inicia sesión nuevamente.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF666666),
                      ),
                    ),
                    SizedBox(height: 60.h),
                    Container(
                      width: 302.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4BCEFC), Color(0xFF174AFC)],
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext, rootNavigator: true).pop();
                          _isHandlingExpiration = false;
                          final navContext =
                              BaseWalletKit.navigatorKey.currentContext;
                          if (navContext != null) {
                            GoRouter.of(navContext)
                                .go(BaseWalletKit.loginRoute);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          'Aceptar',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
