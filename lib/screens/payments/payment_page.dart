import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:mentor_me/config/paths.dart';
import 'package:mentor_me/utils/session_helper.dart';

import '../../models/event_model.dart';
import '../events/bloc/event_bloc.dart';

class PaymentPage extends StatefulWidget {
  final String JoinCode;

  const PaymentPage({
    Key? key,
    required this.JoinCode,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  Event? cur;
  @override
  void initState() {
    fun();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (cur == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    Future<void> initPaymentSheet(context,
        {required String email, required int amount}) async {
      try {
        // 1. create payment intent on the server
        final response = await http.post(
            Uri.parse(
                'https://us-central1-mentorme-8e9da.cloudfunctions.net/stripePaymentIntentRequest'),
            body: {
              'email': email,
              'amount': amount.toString(),
            });

        final jsonResponse = jsonDecode(response.body);
        log(jsonResponse.toString());

        //2. initialize the payment sheet
        await Stripe.instance
            .initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: jsonResponse['paymentIntent'],
            merchantDisplayName: cur!.eventName,
            customerId: jsonResponse['customer'],
            customerEphemeralKeySecret: jsonResponse['ephemeralKey'],
            style: ThemeMode.light,
          ),
        )
            .then((value) async {
          await Stripe.instance.presentPaymentSheet().then((value) async {
            log("hi");
            await context
                .read<EventBloc>()
                .directToPayment(joinCode: widget.JoinCode);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Congrats !You have joined the grp')),
            );
          });
        });
      } catch (e) {
        if (e is StripeException) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sorry! Payment Failed'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Payment"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
              onPressed: () async {
                await initPaymentSheet(context,
                    email: "example@gmail.com", amount: cur!.joiningAmount);
              },
              child: Text(
                "Join the ${cur!.eventName}",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }

  fun() async {
    final collection = FirebaseFirestore.instance.collection(Paths.events);
    final snap = await collection.get();
    for (var element in snap.docs) {
      if (element.data()["roomCode"] == widget.JoinCode) {
        collection.doc(element.id).update({
          "memberIds": FieldValue.arrayUnion([SessionHelper.uid])
        });
        cur = Event.fromMap(element.data(), element.id);
        setState(() {});
      }
    }
  }
}
