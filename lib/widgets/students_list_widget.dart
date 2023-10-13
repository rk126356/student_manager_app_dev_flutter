import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class StudentListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl; // New imageUrl parameter
  final Function() onTap;
  final VoidCallback onPaymentsTap;
  final VoidCallback onEditTap;

  StudentListTile({
    required this.title,
    required this.subtitle,
    required this.imageUrl, // New imageUrl parameter
    required this.onTap,
    required this.onPaymentsTap,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(15),
          leading: CachedNetworkImage(
            width: 60,
            height: 60,
            imageUrl: imageUrl,
            imageBuilder: (context, imageProvider) => Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle, // Makes it a circle (Avatar-like)
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover, // You can use other BoxFit values
                ),
              ),
            ),
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          onTap: onTap,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.payment,
                  color: Colors.blue, // Customize icon color
                ),
                onPressed: onPaymentsTap,
              ),
              SizedBox(width: 10),
              IconButton(
                icon: Icon(
                  Icons.info,
                  color: Colors.green, // Customize icon color
                ),
                onPressed: onEditTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
