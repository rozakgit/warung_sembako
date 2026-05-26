import 'package:flutter/material.dart';

import '../../config/app_color.dart';

import '../../widgets/report_card.dart';

class DailyReportPage extends StatelessWidget {

  const DailyReportPage({super.key});

  @override
  Widget build(BuildContext context) {

    final List transactions = [

      {
        "product": "Beras Premium",
        "qty": "2",
        "price": "Rp 150.000",
      },

      {
        "product": "Minyak Goreng",
        "qty": "3",
        "price": "Rp 60.000",
      },

      {
        "product": "Telur Ayam",
        "qty": "5",
        "price": "Rp 150.000",
      },

      {
        "product": "Gula Pasir",
        "qty": "1",
        "price": "Rp 18.000",
      },

    ];

    return Scaffold(

      backgroundColor: AppColor.background,

      appBar: AppBar(

        backgroundColor: AppColor.primary,

        elevation: 0,

        title: const Text(

          "Laporan Harian",

          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(20),

          child: Column(

            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              // DATE
              Container(

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(

                  color: Colors.white,

                  borderRadius:
                  BorderRadius.circular(20),
                ),

                child: Row(

                  children: [

                    Container(

                      padding:
                      const EdgeInsets.all(12),

                      decoration: BoxDecoration(

                        color: AppColor.primary
                            .withOpacity(0.1),

                        borderRadius:
                        BorderRadius.circular(
                          14,
                        ),
                      ),

                      child: const Icon(

                        Icons.calendar_month,

                        color: AppColor.primary,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Column(

                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: const [

                        Text(

                          "Laporan Hari Ini",

                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(

                          "26 Mei 2026",

                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // REPORT CARD
              Row(

                children: [

                  const Expanded(

                    child: ReportCard(

                      title: "Pendapatan",

                      total: "Rp 1.2 JT",

                      icon: Icons.attach_money,
                    ),
                  ),

                  const SizedBox(width: 15),

                  const Expanded(

                    child: ReportCard(

                      title: "Transaksi",

                      total: "23",

                      icon: Icons.receipt_long,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Row(

                children: [

                  const Expanded(

                    child: ReportCard(

                      title: "Produk",

                      total: "87",

                      icon: Icons.inventory_2,
                    ),
                  ),

                  const SizedBox(width: 15),

                  const Expanded(

                    child: ReportCard(

                      title: "Pelanggan",

                      total: "15",

                      icon: Icons.people,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // TITLE
              const Text(

                "Transaksi Hari Ini",

                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // LIST TRANSACTION
              ListView.builder(

                itemCount: transactions.length,

                shrinkWrap: true,

                physics:
                const NeverScrollableScrollPhysics(),

                itemBuilder: (context, index) {

                  final item =
                  transactions[index];

                  return Container(

                    margin:
                    const EdgeInsets.only(
                      bottom: 15,
                    ),

                    padding:
                    const EdgeInsets.all(18),

                    decoration: BoxDecoration(

                      color: Colors.white,

                      borderRadius:
                      BorderRadius.circular(
                        20,
                      ),
                    ),

                    child: Row(

                      children: [

                        Container(

                          height: 55,
                          width: 55,

                          decoration: BoxDecoration(

                            color: AppColor.primary
                                .withOpacity(0.1),

                            borderRadius:
                            BorderRadius.circular(
                              14,
                            ),
                          ),

                          child: const Icon(

                            Icons.shopping_bag,

                            color: AppColor.primary,
                          ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(

                          child: Column(

                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                            children: [

                              Text(

                                item['product'],

                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(

                                "Qty : ${item['qty']}",

                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Text(

                          item['price'],

                          style: const TextStyle(

                            color: Colors.orange,

                            fontWeight:
                            FontWeight.bold,

                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}