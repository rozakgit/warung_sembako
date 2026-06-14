import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final VoidCallback onTap;

  const UserCard({
    super.key,
    required this.name,
    required this.email,
    required this.role,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return Card(

      margin: const EdgeInsets.only(
        bottom: 12,
      ),

      child: ListTile(

        leading: CircleAvatar(
          child: Text(
            name.isNotEmpty
                ? name[0].toUpperCase()
                : '?',
          ),
        ),

        title: Text(name),

        subtitle: Text(email),

        trailing: Container(

          padding:
          const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),

          decoration: BoxDecoration(
            color: role == "admin"
                ? Colors.orange
                : Colors.blue,
            borderRadius:
            BorderRadius.circular(20),
          ),

          child: Text(
            role.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),

        onTap: onTap,
      ),
    );
  }
}