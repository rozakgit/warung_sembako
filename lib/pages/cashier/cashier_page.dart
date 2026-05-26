// pages/cashier/cashier_page.dart

import 'package:flutter/material.dart';

import '../../config/app_color.dart';

class CashierPage extends StatelessWidget {

  const CashierPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: AppColor.background,

      appBar: AppBar(

        backgroundColor: AppColor.primary,

        title: const Text(

          "Cashier Dashboard",

          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(

        child: Padding(

          padding: const EdgeInsets.all(20),

          child: Column(

            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              // HEADER
              Container(

                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(

                  color: Colors.white,

                  borderRadius:
                  BorderRadius.circular(24),
                ),

                child: Row(

                  children: [

                    Container(

                      padding:
                      const EdgeInsets.all(14),

                      decoration: BoxDecoration(

                        color: AppColor.primary
                            .withOpacity(0.1),

                        borderRadius:
                        BorderRadius.circular(
                          16,
                        ),
                      ),

                      child: const Icon(

                        Icons.point_of_sale,

                        color: AppColor.primary,

                        size: 35,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Column(

                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: const [

                        Text(

                          "Selamat Datang",

                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(

                          "Kasir Warung",

                          style: TextStyle(
                            fontSize: 22,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // MENU
              GridView.count(

                crossAxisCount: 2,

                shrinkWrap: true,

                physics:
                const NeverScrollableScrollPhysics(),

                crossAxisSpacing: 15,
                mainAxisSpacing: 15,

                children: [

                  cashierMenu(
                    icon: Icons.shopping_cart,
                    title: "Transaksi",
                  ),

                  cashierMenu(
                    icon: Icons.receipt,
                    title: "Cetak Struk",
                  ),

                  cashierMenu(
                    icon: Icons.history,
                    title: "Riwayat",
                  ),

                  cashierMenu(
                    icon: Icons.person,
                    title: "Profile",
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget cashierMenu({

    required IconData icon,
    required String title,

  }) {

    return Container(

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
        BorderRadius.circular(24),

        boxShadow: [

          BoxShadow(

            color:
            Colors.black.withOpacity(0.05),

            blurRadius: 10,

            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(

        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [

          Container(

            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(

              color:
              AppColor.primary.withOpacity(
                0.1,
              ),

              borderRadius:
              BorderRadius.circular(18),
            ),

            child: Icon(

              icon,

              color: AppColor.primary,

              size: 35,
            ),
          ),

          const SizedBox(height: 15),

          Text(

            title,

            textAlign: TextAlign.center,

            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}