import 'package:flutter/material.dart';

import '../config/app_color.dart';

class DashboardCard extends StatelessWidget {

  final String title;
  final String total;
  final IconData icon;

  const DashboardCard({
    super.key,
    required this.title,
    required this.total,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Icon(
            icon,
            color: AppColor.primary,
          ),

          const SizedBox(height: 12),

          Text(
            total,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),

        ],
      ),
    );
  }
}