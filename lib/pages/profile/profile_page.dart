import 'package:flutter/material.dart';
import '../profile/profile_page.dart';
import '../../config/app_color.dart';
import '../auth/login_page.dart';

class ProfilePage extends StatelessWidget {

  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: AppColor.background,

      appBar: AppBar(

        backgroundColor: AppColor.primary,

        elevation: 0,

        title: const Text(

          "Profile",

          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            const SizedBox(height: 20),

            // FOTO PROFIL
            CircleAvatar(

              radius: 55,

              backgroundColor:
              AppColor.primary.withOpacity(0.1),

              backgroundImage: const AssetImage(
                "assets/images/profile.png",
              ),
            ),

            const SizedBox(height: 15),

            const Text(

              "Muhammad Ardiansyah",

              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text(

              "ardiansyah@gmail.com",

              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 5),

            Container(

              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 6,
              ),

              decoration: BoxDecoration(

                color:
                AppColor.primary.withOpacity(0.1),

                borderRadius:
                BorderRadius.circular(20),
              ),

              child: const Text(

                "Admin",

                style: TextStyle(
                  color: AppColor.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // MENU

            profileMenu(
              icon: Icons.person_outline,
              title: "Edit Profile",
              onTap: () {},
            ),

            profileMenu(
              icon: Icons.lock_outline,
              title: "Ganti Password",
              onTap: () {},
            ),

            profileMenu(
              icon: Icons.info_outline,
              title: "Tentang Aplikasi",
              onTap: () {},
            ),

            profileMenu(
              icon: Icons.contact_support_outlined,
              title: "Bantuan",
              onTap: () {},
            ),

            const SizedBox(height: 30),

            SizedBox(

              width: double.infinity,

              height: 55,

              child: ElevatedButton.icon(

                onPressed: () {

                  Navigator.pushAndRemoveUntil(

                    context,

                    MaterialPageRoute(
                      builder: (_) =>
                      const LoginPage(),
                    ),

                        (route) => false,
                  );
                },

                style: ElevatedButton.styleFrom(

                  backgroundColor: Colors.red,

                  shape:
                  RoundedRectangleBorder(

                    borderRadius:
                    BorderRadius.circular(16),
                  ),
                ),

                icon: const Icon(
                  Icons.logout,
                  color: Colors.white,
                ),

                label: const Text(

                  "Logout",

                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget profileMenu({

    required IconData icon,
    required String title,
    required VoidCallback onTap,

  }) {

    return Container(

      margin: const EdgeInsets.only(
        bottom: 15,
      ),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
        BorderRadius.circular(18),

        boxShadow: [

          BoxShadow(

            color:
            Colors.black.withOpacity(0.05),

            blurRadius: 10,

            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: ListTile(

        leading: Icon(
          icon,
          color: AppColor.primary,
        ),

        title: Text(title),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
        ),

        onTap: onTap,
      ),
    );
  }
}