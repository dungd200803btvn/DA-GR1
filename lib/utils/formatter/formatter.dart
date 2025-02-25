import 'package:intl/intl.dart';
class DFormatter{
  static String formatDate(DateTime? date){
    date??=DateTime.now();
    return DateFormat('dd-MMM-yyyy').format(date);
  }
  static String formatCurrency(double amount){
    return NumberFormat.currency(locale: "en_US",symbol: '\$').format(amount);
  }
  static String formatPhoneNumber(String phonenumber){
    if(phonenumber.length ==10){
      return '(${phonenumber.substring(0,3)}) ${phonenumber.substring(3,6)} ${phonenumber.substring(6)} ';
    }else if(phonenumber.length ==11){
      return '(${phonenumber.substring(0,4)}) ${phonenumber.substring(4,7)} ${phonenumber.substring(7)} ';
    }
    return phonenumber;
  }
  static String internationalFormatPhoneNumber(String phonenumber){
    var digitOnly = phonenumber.replaceAll(RegExp(r'\D'),' ');
    String countryCode = '+${digitOnly.substring(0,2)}';
    final formattedNumber = StringBuffer();
    formattedNumber.write('($countryCode)');
    int i = 0;
    while(i< digitOnly.length ){
      int groupLength =2;
      if(i==0 && countryCode=='+1'){
        groupLength =3;
      }
      int end = i+ groupLength;
      formattedNumber.write(digitOnly.substring(i,end));
      if(end< digitOnly.length){
        formattedNumber.write(' ');
      }
      i=end;
    }
    return formattedNumber.toString();
  }

  static String formattedAmount(num amount){
    return NumberFormat("#,###","en_US").format(amount);
  }
  static String FormattedDate(DateTime day){
    return DateFormat("dd/MM/yyyy HH:mm").format(day);
  }
  static String calculateAmountForStripe(double amount){
    final calculatedAmount = amount*100;
    return calculatedAmount.round().toString();
  }

}
