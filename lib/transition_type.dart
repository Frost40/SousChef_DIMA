import 'package:flutter/material.dart';

enum TransitionType {
  slideLeft,
  slideRight,
  fade,
  smooth,
  instagram,
  spotify,
  youtube,
  bottomSheet,
  scale
}

class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final TransitionType transitionType;
  final Duration duration;
  final Color? barrierColor;
  final bool maintainState;

  CustomPageRoute({
    required this.page,
    this.transitionType = TransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.barrierColor,
    this.maintainState = true,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      switch (transitionType) {
        case TransitionType.slideRight:
          const begin = Offset(1.0, 0.0); // Slide from right
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );

        case TransitionType.slideLeft:
          const begin = Offset(-1.0, 0.0); // Slide from left
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );

        case TransitionType.smooth:
          const begin = Offset(0.3, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutQuint;

          var tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.2, end: 1.0)
                  .chain(CurveTween(curve: curve))
                  .animate(animation),
              child: child,
            ),
          );

        case TransitionType.instagram:
        // Instagram-like transition with subtle slide and fade
          return FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0)
                .chain(CurveTween(curve: Curves.fastLinearToSlowEaseIn))
                .animate(animation),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.05),
                end: Offset.zero,
              )
                  .chain(CurveTween(curve: Curves.easeOutQuint))
                  .animate(animation),
              child: child,
            ),
          );

        case TransitionType.spotify:
        // Spotify's smooth transition with scale and fade
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.8, curve: Curves.fastOutSlowIn),
            ),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0)
                  .chain(CurveTween(curve: Curves.easeOutCubic))
                  .animate(animation),
              child: child,
            ),
          );

        case TransitionType.youtube:
        // YouTube's quick slide up with fade
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.1),
                end: Offset.zero,
              )
                  .chain(CurveTween(curve: Curves.fastOutSlowIn))
                  .animate(animation),
              child: child,
            ),
          );

        case TransitionType.bottomSheet:
        // Bottom sheet style transition
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            )
                .chain(CurveTween(curve: Curves.easeOutQuad))
                .animate(animation),
            child: child,
          );

        case TransitionType.scale:
        // Scale transition with fade
          return ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0)
                .chain(CurveTween(curve: Curves.easeOut))
                .animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );

        case TransitionType.fade:
        default:
          return FadeTransition(
            opacity: animation,
            child: child,
          );
      }
    },
    transitionDuration: duration,
    barrierColor: barrierColor,
    maintainState: maintainState,
    fullscreenDialog: false,
  );
}