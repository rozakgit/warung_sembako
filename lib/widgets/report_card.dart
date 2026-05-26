
import 'package:flutter/material.dart';

import '../config/app_color.dart';

class ReportCard extends StatelessWidget {

  final String title;
  final String total;
  final IconData icon;

  const ReportCard({
    super.key,
    required this.title,
    required this.total,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
        BorderRadius.circular(24),

        boxShadow: [

          BoxShadow(

            color: Colors.black.withOpacity(
              0.05,
            ),

            blurRadius: 10,

            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Container(

            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(

              color: AppColor.primary
                  .withOpacity(0.1),

              borderRadius:
              BorderRadius.circular(14),
            ),

            child: Icon(

              icon,

              color: AppColor.primary,
            ),
          ),

          const SizedBox(height: 15),

          Text(

            total,

            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(

            title,

            style: const TextStyle(
              color: Colors.grey,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}