import 'package:flutter/material.dart';

class FavoritesList extends StatefulWidget {
  const FavoritesList({super.key});

  @override
  State<FavoritesList> createState() => _FavoritesListState();
}

class _FavoritesListState extends State<FavoritesList> {
  // Dati di esempio
  final List<Map<String, dynamic>> preferiti = [
    {
      'immagine': 'https://i.pravatar.cc/150?img=5',
      'nomeRistorante': 'Ristorante A',
      'modalitaOrdini': 'Aperto',
      'preferito': true,
    },
    {
      'immagine': 'https://i.pravatar.cc/150?img=5',
      'nomeRistorante': 'Ristorante B',
      'modalitaOrdini': 'Chiuso',
      'preferito': true,
    },
    {
      'immagine': 'https://i.pravatar.cc/150?img=5',
      'nomeRistorante': 'Ristorante C',
      'modalitaOrdini': 'Chiuso',
      'preferito': true,
    },
    {
      'immagine': 'https://i.pravatar.cc/150?img=5',
      'nomeRistorante': 'Ristorante C',
      'modalitaOrdini': 'Chiuso',
      'preferito': true,
    },
    {
      'immagine': 'https://i.pravatar.cc/150?img=5',
      'nomeRistorante': 'Ristorante C',
      'modalitaOrdini': 'Aperto',
      'preferito': true,
    },
    {
      'immagine': 'https://i.pravatar.cc/150?img=5',
      'nomeRistorante': 'Ristorante C',
      'modalitaOrdini': 'Aperto',
      'preferito': true,
    },
    {
      'immagine': 'https://i.pravatar.cc/150?img=5',
      'nomeRistorante': 'Ristorante C',
      'modalitaOrdini': 'Chiuso',
      'preferito': true,
    },
    {
      'immagine': 'https://i.pravatar.cc/150?img=5',
      'nomeRistorante': 'Ristorante C',
      'modalitaOrdini': 'Aperto',
      'preferito': true,
    },
    {
      'immagine': 'https://i.pravatar.cc/150?img=5',
      'nomeRistorante': 'Ristorante C',
      'modalitaOrdini': 'Chiuso',
      'preferito': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      itemCount: preferiti.length,
      itemBuilder: (context, index) {
        final ristorante = preferiti[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(ristorante['immagine']),
            radius: 30.0,
          ),
          title: Text(ristorante['nomeRistorante']),
          subtitle: Text(
            ristorante['modalitaOrdini'],
            style: TextStyle(
              color:
                  ristorante['modalitaOrdini'] == 'Aperto'
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
              setState(() {
                ristorante['preferito'] = !ristorante['preferito'];
              });
            },
          ),
        );
      },
      separatorBuilder:
          (context, index) => const Divider(color: Colors.grey, thickness: 1.0),
    );
  }
}
