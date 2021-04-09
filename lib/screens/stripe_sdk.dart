import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_stripe_payment/flutter_stripe_payment.dart';
import 'package:http/http.dart' as http;

class MyApp2 extends StatefulWidget {
  @override
  _MyApp2State createState() => _MyApp2State();
}

class _MyApp2State extends State<MyApp2> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _amount = TextEditingController();
  PaymentResponse _paymentMethod;
  String _paymentMethodId;
  String _errorMessage = "";
  final _stripePayment = FlutterStripePayment();
  dynamic clientSecret;
  int amount1;
  var paymentResponse1;

  createIntent() async {
    var url = Uri.parse('https://api.stripe.com/v1/payment_intents');
    var response = await http.post(url,
        headers: {
          'Authorization':
              'Bearer sk_test_51IcrCaSGgp78HSWonqKdKI1a4DBeu3sSN44Yb6kR2yg4XzAsll1AflVCP8fEbhf7dleQj2pjf89QKwZ9EtN9jvWn00h0a5NKH3'
        },
        encoding: Encoding.getByName('x-www-form-urlencoded'),
        body: {'amount': '$amount1', 'currency': 'inr'});
    print('Response status: ${response.statusCode}');
    if(response.statusCode==200){
      print('Response body: ${response.body}');
      dynamic data = json.decode(response.body);
      setState(() {
        clientSecret = data['client_secret'];
        print(clientSecret);
      });
    }
    else {
      throw Exception("failed");
    }
  }

  authPayment() async {
    var paymentResponse = await _stripePayment.confirmPaymentIntent(
        clientSecret, _paymentMethodId, amount1.toDouble());
    setState(() {
      if (paymentResponse.status == PaymentResponseStatus.succeeded) {
        _paymentMethodId = paymentResponse.paymentMethodId;
        print(paymentResponse.status);
        setState(() {
          paymentResponse1 = paymentResponse.status;
        });
      } else {
        _errorMessage = paymentResponse.errorMessage;
      }
    });
  }

  pay() async {
    var url = Uri.parse('https://api.stripe.com/v1/charges');
    var response = await http.post(url,
        headers: {
          'Authorization':
          'Bearer sk_test_51IcrCaSGgp78HSWonqKdKI1a4DBeu3sSN44Yb6kR2yg4XzAsll1AflVCP8fEbhf7dleQj2pjf89QKwZ9EtN9jvWn00h0a5NKH3'
        },
        encoding: Encoding.getByName('x-www-form-urlencoded'),
        body: {'amount': '$amount1', 'currency': 'inr', "customer": "cus_JG1UBRJpPEbvuS"});
    print('Response status: ${response.statusCode}');
    if(response.statusCode==200){
      print('Response body: ${response.body}');
      dynamic data = json.decode(response.body);
      setState(() {
        clientSecret = data['client_secret'];
        print(clientSecret);
      });
    }
    else {
      throw Exception(response.body);
    }
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
        body: Form(key: _formKey,
          child: ListView(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            children: <Widget>[
              TextFormField(
                keyboardType: TextInputType.number,
                controller: _amount,
                onChanged: (amount){
                  _formKey.currentState.validate();
                  double amount2 = double.parse(amount)*100;
                  amount1 = amount2.round();
                  print(amount1);
                },
                decoration: InputDecoration(
                    hintText: 'Enter Amount in Rupees',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50))),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some amount';
                  }
                  return null;
                },
              ),
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
                onPressed:() async {
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
              if (_paymentMethod != null) Text("Method: "+_paymentMethod.status.toString()),
              ElevatedButton(
                child: Text("Create payment intent"),
                onPressed:(_paymentMethod != null)?() async {
                  if(_formKey.currentState.validate()){
                    await createIntent();
                    print('clientSecret: ' + clientSecret);
                    authPayment();
                  }
                }:null,
              ),
              ElevatedButton(
                child: Text("Pay by Card"),
                onPressed:() async {
                  // var paymentResponse = await _stripePayment.confirmPaymentIntent(
                  //     clientSecret, _paymentMethodId, 20000);
                  // setState(() {
                  //   if (paymentResponse.status ==
                  //       PaymentResponseStatus.succeeded) {
                  //     _paymentMethodId = paymentResponse.paymentMethodId;
                  //   } else {
                  //     _errorMessage = paymentResponse.errorMessage;
                  //   }
                  // });
                  pay();
                },
              ),
              if (paymentResponse1 != null) Text(paymentResponse1.toString())
            ],
          ),
        ),
      ),
    );
  }
}
