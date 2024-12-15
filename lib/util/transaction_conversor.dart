import 'package:prime_store/model/data/transaction_model.dart';

TransactionState transactionStateFromBBDDConversion(String category){
  if(category == "COMPLETED") return TransactionState.COMPLETED;
  if(category == "PENDING") return TransactionState.PENDING;
  return TransactionState.CANCELED;
}

PayMethod payMethodFromBBDDConversion(String category){
  if(category == "CARD") return PayMethod.CARD;
  if(category == "PAYPAL") return PayMethod.PAYPAL;
  if(category == "CASH") return PayMethod.CASH;
  return PayMethod.WALLET;
}

DeliveryMethod deliveryMethodFromBBDDConversion(String category){
  if(category == "DELIVERY") return DeliveryMethod.DELIVERY;
  return DeliveryMethod.PERSON;
}