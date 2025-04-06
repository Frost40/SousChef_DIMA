import 'package:flutter/material.dart';

        class AccountSettingsScreen extends StatelessWidget {
          const AccountSettingsScreen({super.key});

          @override
          Widget build(BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Impostazioni Account'),
                automaticallyImplyLeading: true, // Mostra il pulsante back
              ),
              body: const Center(
                child: Text('Pagina delle impostazioni account'),
              ),
            );
          }
        }