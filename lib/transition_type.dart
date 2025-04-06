import 'package:flutter/material.dart';

enum TransitionType { slideLeft, slideRight, fade, smooth }

class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final TransitionType transitionType;

  CustomPageRoute({
    required this.page,
    this.transitionType = TransitionType.fade,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            switch (transitionType) {

              case TransitionType.slideRight:
                const begin = Offset(1.0, 0.0); // Slide from right
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );


              case TransitionType.slideLeft:
                const begin = Offset(-1.0, 0.0); // Slide from left
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );

              case TransitionType.smooth:
                // Transizione fluida stile Spotify/Just Eat
                const begin = Offset(0.3, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeOutQuint;

                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0.2, end: 1.0)
                        .chain(CurveTween(curve: curve))
                        .animate(animation),
                    child: child,
                  ),
                );

              default:
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
            }
          },
          transitionDuration: const Duration(milliseconds: 250),
        );
}