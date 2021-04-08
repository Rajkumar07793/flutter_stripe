import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe_payment/flutter_stripe_payment.dart';
import 'package:http/http.dart' as http;

class MyApp2 extends StatefulWidget {
  @override
  _MyApp2State createState() => _MyApp2State();
}

class _MyApp2State extends State<MyApp2> {
  PaymentResponse _paymentMethod;
  String _paymentMethodId;
  String _errorMessage = "";
  final _stripePayment = FlutterStripePayment();
  dynamic clientSecret;

  createIntent() async{
    var url = Uri.parse('https://api.stripe.com/v1/payment_intents');
    var response = await http.post(url, headers: {'Authorization': 'Bearer sk_test_51IcrCaSGgp78HSWonqKdKI1a4DBeu3sSN44Yb6kR2yg4XzAsll1AflVCP8fEbhf7dleQj2pjf89QKwZ9EtN9jvWn00h0a5NKH3'},encoding: Encoding.getByName('x-www-form-urlencoded'),body: {'amount': '1000', 'currency': 'inr'});
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    dynamic data = json.decode(response.body);
    setState(() {
      clientSecret = data['client_secret'];
      print(clientSecret);
    });
  }

  @override
  void initState() {
    super.initState();
    _stripePayment.setStripeSettings(
        "pk_test_51IcrCaSGgp78HSWo97V4Z9xHkZ8aYfbJJwA588p5XxmMGQLbESkrNASsxZ5jZlpqUd7xluY1DDkwaJrsarf5XSJt00jZ0YKVIm");
    _stripePayment.onCancel = () {
      print("the payment form was cancelled");
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Stripe App Example'),
        ),
        body: ListView(
          children: <Widget>[
            _paymentMethodId != null
                ? Text(
              "Payment Method Returned is $_paymentMethodId",
              textAlign: TextAlign.center,
            )
                : Container(
              child: Text(_errorMessage),
            ),
            ElevatedButton(
              child: Text("Add Card"),
              onPressed: () async {
                var paymentResponse = await _stripePayment.addPaymentMethod();
                setState(() {
                  if (paymentResponse.status ==
                      PaymentResponseStatus.succeeded) {
                    _paymentMethodId = paymentResponse.paymentMethodId;
                    _paymentMethod = paymentResponse;
                  } else {
                    _errorMessage = paymentResponse.errorMessage;
                  }
                });
              },
            ),
            if(_paymentMethod!=null)
            Text(_paymentMethod.status.toString()),
            ElevatedButton(
              child: Text("Create payment intent"),
              onPressed: () async {
                createIntent();
              },
            ),
            ElevatedButton(
              child: Text("Pay by Card"),
              onPressed: () async {
                var paymentResponse = await _stripePayment.confirmPaymentIntent(clientSecret, _paymentMethodId, 20000);
                setState(() {
                  if (paymentResponse.status ==
                      PaymentResponseStatus.succeeded) {
                    _paymentMethodId = paymentResponse.paymentMethodId;
                  } else {
                    _errorMessage = paymentResponse.errorMessage;
                  }
                });
              },
            ),
            if(clientSecret!=null)
            Text(clientSecret.toString())
          ],
        ),
      ),
    );
  }
}
