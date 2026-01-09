import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class RestaurantTile extends StatelessWidget {
  final Map<String, dynamic> restaurant;

  const RestaurantTile({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(restaurant['imagine']),
        radius: 30.0,
      ),
      title: Text(restaurant['restaurantName']),
      subtitle: Text(
        restaurant['available'] ? "Open" : "Closed",
        style: TextStyle(
          color: restaurant['available'] ? Colors.green : Colors.red,
        ),
      ),
      trailing: IconButton(
        icon: Icon(
          restaurant['favorite'] ? Icons.favorite : Icons.favorite_border,
          color: Colors.red,
        ),
        onPressed: () {
          userProvider.toggleFavorite(
            context, 
            restaurant['id'],
            restaurant['restaurantName'],
          );
        },
      ),
    );
  }
}
