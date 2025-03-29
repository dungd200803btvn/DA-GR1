import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lcd_ecommerce_app/features/payment/services/stripe_service.dart';

class PaymentTest extends StatefulWidget {
  const PaymentTest({super.key});

  @override
  State<PaymentTest> createState() => _PaymentTestState();
}

class _PaymentTestState extends State<PaymentTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Payment Demo Stripe"
        ),
      ),
      body: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
              MaterialButton(onPressed: (){
                // StripeService.instance.makePayment();
              },color: Colors.green,
              child: const Text('Payment'),)
          ],
        ),
      ),
    );
  }
}
