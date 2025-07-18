import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../common/widgets/appbar/appbar.dart';
import '../../../l10n/app_localizations.dart';
import '../../personalization/controllers/user_controller.dart';
import '../controller/reward_controller.dart';
import '../widgets/reward_voucher_card.dart';

class RewardsScreen extends StatelessWidget {
  RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context);
    final user = UserController.instance.user.value;
    final controller = RewardController.instance;
    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text(
          lang.translate('exchange_rewards'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Phần Header: Greeting và current bonus points
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${lang.translate('hello')}, ${user.fullname}",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('User')
                            .doc(user.id)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }

                          if (snapshot.hasError) {
                            return Text("Error: ${snapshot.error}");
                          }

                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return Text("User data not found.");
                          }

                          // Cập nhật điểm thưởng từ dữ liệu Firestore
                          final userData = snapshot.data!.data() as Map<String, dynamic>;
                          final points = userData['points'] ?? 0;

                          return Text(
                            "${lang.translate('current_bonus_points')}: $points",
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black87,
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: controller.vouchers.length,
                        itemBuilder: (context, index) {
                          final voucher = controller.vouchers[index];
                          return RewardVoucherCard(
                            voucher: voucher,
                            onRedeem: () async {
                             await controller.exchangeReward(user.id, voucher);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}
