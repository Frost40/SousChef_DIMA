import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../screens/address_search_screen.dart';

/// Widget che mostra l'indirizzo salvato dell'utente sulla home page
/// Stato A: Nessun indirizzo salvato - mostra "scegli la tua posizione"
/// Stato B: Indirizzo salvato - mostra l'indirizzo
class AddressDisplay extends StatelessWidget {
  const AddressDisplay({super.key});

  /// Estrae la parte dell'indirizzo prima della seconda virgola
  String _extractAddressBeforeSecondComma(String address) {
    final parts = address.split(',');
    if (parts.length >= 2) {
      return '${parts[0]}, ${parts[1]}';
    }
    return address;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userData = userProvider.userData;

    // Determina lo stato: se c'è un indirizzo salvato o no
    final hasSavedAddress =
        userData?.savedAddress != null && userData!.savedAddress!.isNotEmpty;

    final displayText =
        hasSavedAddress
            ? _extractAddressBeforeSecondComma(userData.savedAddress!)
            : 'Choose your location';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Area testo (non cliccabile)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected location:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayText,
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        hasSavedAddress
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.4),
                    fontWeight:
                        hasSavedAddress ? FontWeight.w500 : FontWeight.normal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Area interattiva - Solo l'icona è cliccabile
          InkWell(
            onTap: () => _navigateToSearch(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Naviga alla schermata di ricerca indirizzo
  void _navigateToSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddressSearchScreen()),
    );
  }
}
