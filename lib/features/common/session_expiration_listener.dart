import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tivi_tea/core/router/app_routes.dart';
import 'package:tivi_tea/core/router/router_config.dart';
import 'package:tivi_tea/core/services/token_expiration_service.dart';
import 'package:tivi_tea/features/login/view_model/login_notifier.dart';

class SessionExpirationListener extends ConsumerStatefulWidget {
  const SessionExpirationListener({
    super.key,
    required this.child,
    this.onSessionExpired,
  });

  final Widget child;
  final VoidCallback? onSessionExpired;

  @override
  ConsumerState<SessionExpirationListener> createState() =>
      _SessionExpirationListenerState();
}

class _SessionExpirationListenerState
    extends ConsumerState<SessionExpirationListener> {
  StreamSubscription<bool>? _tokenExpirationSubscription;
  bool _isHandlingExpiration = false;

  @override
  void initState() {
    super.initState();
    _tokenExpirationSubscription = ref
        .read(tokenExpirationServiceProvider)
        .tokenExpiredStream
        .listen((isExpired) {
      if (isExpired) {
        _handleSessionExpired();
      }
    });
  }

  @override
  void dispose() {
    _tokenExpirationSubscription?.cancel();
    super.dispose();
  }

  void _handleSessionExpired() {
    if (_isHandlingExpiration) {
      return;
    }
    _isHandlingExpiration = true;

    ref.read(loginNotifierProvider.notifier).logout(
      onDataCleared: () {
        if (widget.onSessionExpired != null) {
          widget.onSessionExpired!.call();
        } else {
          router.go(AppRoutes.loginView);
        }
        _isHandlingExpiration = false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
