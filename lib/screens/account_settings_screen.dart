import 'package:flutter/material.dart';

        class AccountSettingsScreen extends StatelessWidget {
          const AccountSettingsScreen({super.key});

          @override
          Widget build(BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Impostazioni Account'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              body: const Center(
                child: Text('Pagina delle impostazioni account'),
              ),
            );
          }
        }