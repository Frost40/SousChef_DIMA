import 'package:flutter/material.dart';

class RestaurantTile extends StatelessWidget {
  final Map<String, dynamic> ristorante;

  const RestaurantTile({Key? key, required this.ristorante}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(ristorante['immagine']),
        radius: 30.0,
      ),
      title: Text(ristorante['nomeRistorante']),
      subtitle: Text(
        ristorante['modalitaOrdini'],
        style: TextStyle(
          color: ristorante['modalitaOrdini'] == 'Aperto'
              ? Colors.green
              : Colors.red,
        ),
      ),
      trailing: IconButton(
        icon: Icon(
          ristorante['preferito'] ? Icons.favorite : Icons.favorite_border,
          color: Colors.red,
        ),
        onPressed: () {
          // setState(() { // Removed setState as this is now a StatelessWidget
          //   ristorante['preferito'] = !ristorante['preferito'];
          // });
        },
      ),
    );
  }
}
