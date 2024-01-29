import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Helper/String.dart';
import '../repository/authRepository.dart';
import 'package:http/http.dart' as http;

import 'UserProvider.dart';

class AuthenticationProvider extends ChangeNotifier {
  // value for parameter
  String? mobilennumberPara, passwordPara;

  // singup data
  String? name, countrycode, referCode, friendCode, sinUpPassword, singUPemail, gst;
  // for reset password
  String? newPassword;

  // data
  bool? error;
  String errorMessage = '';
  String? password,
      mobile,
      username,
      email,
      id,
      mobileno,
      city,
      area,
      pincode,
      address,
      latitude,
      longitude,
      image;

  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();
  int count = 1;
  get mobilenumbervalue => mobilennumberPara;
  setMobileNumber(String? value) {
    mobilennumberPara = value;
    notifyListeners();
  }

  setNewPassword(String? value) {
    newPassword = value;
    notifyListeners();
  }

  setSingUp(String? value) {
    singUPemail = value;
    notifyListeners();
  }
  setGST(String? value) {
    gst = value;
    notifyListeners();
  }

  setfriendCode(String? value) {
    friendCode = value;
    notifyListeners();
  }

  setsinUpPassword(String? value) {
    sinUpPassword = value;
    notifyListeners();
  }

  setcountrycode(String? value) {
    countrycode = value;
    notifyListeners();
  }

  setUserName(String? value) {
    name = value;
    notifyListeners();
  }

  setreferCode(String? value) {
    referCode = value;
    notifyListeners();
  }

  setPassword(String? value) {
    passwordPara = value;
    notifyListeners();
  }

  //get System Policies
  Future<Map<String, dynamic>> getLoginData(BuildContext context) async {
    try {
      var parameter = {MOBILE: mobilennumberPara, PASSWORD: passwordPara};
      var result = await AuthRepository.fetchLoginData(parameter: parameter);

      errorMessage = result['message'];

      error = result['error'];

      print(result.toString()+"_______________________++++++++++++++");
      UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
      if (!error!) {
        var getdata = result['data'][0];
        id = getdata[ID];
        username = getdata[USERNAME];
        email = getdata[EMAIL];
        mobile = getdata[MOBILE];
        city = getdata[CITY];
        area = getdata[AREA];
        address = getdata[ADDRESS];
        pincode = getdata[PINCODE];
        latitude = getdata[LATITUDE];
        longitude = getdata[LONGITUDE];
        image = getdata[IMAGE];
        print("${getdata["gst_number"]}"+"+++++++++++++++++++++++=");
        userProvider.setShopName(getdata[SHOPNAME] ?? '');
        userProvider.setGstnumber(getdata["gst_number"] ?? '');
        CUR_USERID = id;
        return result;
      } else {
        return result;
      }
    } catch (e) {
      errorMessage = e.toString();
      return {};
    }
  }

  //for login
  Future<Map<String, dynamic>> getVerifyUser() async {
    try {
      var parameter = {
        MOBILE: mobilennumberPara,
        // "type":"forget"
      };
      var result =
          await AuthRepository.fetchverificationData(parameter: parameter);
      return result;
    } catch (e) {
      errorMessage = e.toString();
      return {};
    }
  }


  Future<Map<String, dynamic>> resendOtpUser() async {
    try {
      var parameter = {
        MOBILE: mobilennumberPara,
      };
      var result =
      await AuthRepository.resendfetchverificationData(parameter: parameter);
      return result;
    } catch (e) {
      errorMessage = e.toString();
      return {};
    }
  }

  Future<Map<String, dynamic>> senOtp() async {
    try {
      var parameter = {
        MOBILE: mobilennumberPara,
      };
      var result =
      await AuthRepository.fetchOtpData(parameter: parameter);
      return result;
    } catch (e) {
      errorMessage = e.toString();
      return {};
    }
  }

  //for singUp
  Future<Map<String, dynamic>> getSingUPData( String? mobile) async {
    try {
      var headers = {
        'Cookie': 'ci_session=e385397905c87228193b6d52283c2a83c33b72d4'
      };
      var request = http.MultipartRequest('POST', getUserSignUpApi);
      request.fields.addAll({
        MOBILE: mobile ?? '',
        NAME: name ?? '',
        EMAIL: singUPemail ?? '',
        PASSWORD: sinUpPassword ?? '',
        COUNTRY_CODE: countrycode ?? '',
        REFERCODE: referCode ?? '',
        FRNDCODE: friendCode ?? '',
        GSTKEY: gst ?? ''
      });

      print('=============${request.fields}');
      print('=============${request.url}');
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
       var result = await response.stream.bytesToString();
       var fainalResult = jsonDecode(result);
       return fainalResult ;
      }
      else {
        print(response.reasonPhrase);
        var result = await response.stream.bytesToString();
        var fainalResult = jsonDecode(result);
        return fainalResult ;
      }
      /*var result = await AuthRepository.fetchSingUpData(parameter: parameter);
      return result;*/
    } catch (e) {
      errorMessage = e.toString();
      return {

      };
    }
  }

  // for reset password
  Future<Map<String, dynamic>> getReset() async {
    try {
      var parameter = {
        MOBILENO: mobilennumberPara,
        NEWPASS: newPassword,
      };

      var result = await AuthRepository.fetchFetchReset(parameter: parameter);
      return result;
    } catch (e) {
      errorMessage = e.toString();
      return {};
    }
  }

  Future<void> generateReferral(
    BuildContext context,
    Function updateNow,
  ) async {
    String refer = getRandomString(8);
    context.read<AuthenticationProvider>().setreferCode(refer);

    try {
      var data = {
        REFERCODE: refer,
      };
      var result = await AuthRepository.validateReferal(parameter: data);

      bool error = result['error'];

      if (!error) {
        referCode = refer;
        context.read<AuthenticationProvider>().setreferCode(refer);
        updateNow();
      } else {
        if (count < 5) {
          generateReferral(context, updateNow);
        }
        count++;
      }
    } on TimeoutException catch (_) {}
  }

  String getRandomString(int length) => String.fromCharCodes(
        Iterable.generate(
          length,
          (_) => _chars.codeUnitAt(
            _rnd.nextInt(
              _chars.length,
            ),
          ),
        ),
      );
}
