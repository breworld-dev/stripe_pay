import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:stripe_pay/keys.dart';

class StripeServices {
// define private constructor
  StripeServices._();

  static final StripeServices instance = StripeServices._();

  Future<void> makePayment() async {
    try {
      String? paymentIntentClientSecret = await createPaymentIntent(100, "usd");
      if (paymentIntentClientSecret == null) return;
      //initialize stripe payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: "Brendon Lucima",
        ),
      );
      await processPyment();
    } catch (e) {
      print(e);
    }
  }

  // function to create payment intent
  Future<String?> createPaymentIntent(int amount, String currency) async {
    try {
      // Initialize dio client/new instance of Dio()
      final Dio dio = Dio();
      Map<String, dynamic> paymentData = {
        "amount": calculateAmount(amount),
        "currency": currency
      };
      // define API call,headers and send request
      var response = await dio.post(
        "https://api.stripe.com/v1/payment_intents",
        data: paymentData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            "Authorization": "Bearer $stripeSecretKey",
            "Content-Type": "application/x-www-form-urlencoded"
          },
        ),
      );
      // return payment intent is available
      if (response.data != null) {
        return response.data["client_secret"];
      }
      // return error message if payment intent is not available
      // return null if response is null
      return null;
    } catch (e) {
      print(e);
    }
  }

  // use payment sheet to make payment function
  Future<void> processPyment() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      //stripe confirm paymentSheet
      await Stripe.instance.confirmPaymentSheetPayment();
    } catch (e) {
      print(e);
    }
  }

// Handy dandy function to calculate amount and returns a String
  String calculateAmount(int amount) {
    final calculatedAmount = amount * 100;
    return calculatedAmount.toString();
  }
}
