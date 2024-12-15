import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:prime_store/keys/keys.dart';

class StripeService {
  StripeService._();
  static final StripeService instance = StripeService._();
  final Dio _dio = Dio();

  Future<bool> makePayment(double amount) async{//retornaba un void
    try{
      String? paymentIntentClientSecret = await _createPaymentIntent(amount, "EUR");
      if(paymentIntentClientSecret == null) return false;
      await Stripe.instance.initPaymentSheet(paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntentClientSecret,
        merchantDisplayName:"PrimeStore"
      ));
      return await _processPayment();
    }catch(e){
      return false; 
    }
  }

  Future<String?> _createPaymentIntent(double amount, String currency) async{
    try{
      Map<String, dynamic> data = {
        "amount": _calculateAmount(amount),
        "currency": currency
      };
      Response response =  await _dio.post(
        "https://api.stripe.com/v1/payment_intents",
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            "Authorization": "Bearer ${ApiKeys.stripeSecretKey}",
            "Content-Type": "application/x-www-form-urlencoded"
          }
        )
      );
      if(response.data != null){
        return response.data["client_secret"];
      }
      return null;
    }catch(e){
      //
    }
    return null;
  }

  Future<bool> _processPayment() async{
    try{
      await Stripe.instance.presentPaymentSheet(); //Muestra el modal de pago
      return true;
    }catch(e){
      if(e is StripeException){
        if(e.error.code == FailureCode.Canceled){
          //El usuario ha cancelado el pago
          return false;
        }else{
          //En este caso el error puede ser debido a un fallo de red o de Stripe
          return false;
        }
      }else{
        //Error no relacionado con Stripe
        return false;
      }
    }
  }

  String _calculateAmount(double amount){
    final total = (amount * 100).toInt();
    return total.toString();
  }
}