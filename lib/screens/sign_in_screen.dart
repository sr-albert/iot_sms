import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:the_third/index.dart';
import 'package:the_third/layouts/view_has_loading.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final Storage _storage = new Storage();
  final StringHandler _stringHandler = new StringHandler();

  bool _isLoginFailed = false;
  String _errorMsg = "";

  bool _isLoading = false;

  TextEditingController _phoneNumberController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  _submitFormLogin() async {
    // Push phone number to verify screen
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
      var _phone = _phoneNumberController.value.text;
      var _pass = _passwordController.value.text;

      /// Get user from storage
      /// if has not => first time user install app on this device => required register new phone with OTP
      /// user info existed => compare user name and password to login
      SignInInfoType _storageInfo = await _storage.getInfo();

      if (_storageInfo == null) {
        setState(() {
          _isLoginFailed = true;
          _errorMsg = "Chưa đăng ký tài khoản trên thiết bị này";
        });
      } else {
        String _finalPhoneNo = _stringHandler.handlePhoneNo(_phone);
        print("Phone: $_finalPhoneNo === Password: $_pass}");

        if (_storageInfo.phoneNumber != _finalPhoneNo ||
            _storageInfo.password != _pass) {
          setState(() {
            _isLoginFailed = true;
            _errorMsg = "Thông tin đăng nhập không chính xác";
          });
        }
        if (_storageInfo.phoneNumber == _finalPhoneNo &&
            _storageInfo.password == _pass) {
          setState(() {
            _isLoginFailed = false;
            _errorMsg = "";
          });
          pushWithWidget(context, HomeScreen());
        }
      }
    }
//    setState(() {
//      _isLoading = false;
//    });
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewHasLoading(
      isLoading: _isLoading,
      loadingColor: mainColor,
      childrenWidget: Column(
        children: <Widget>[
          /// Logo
          Container(
              margin: EdgeInsets.only(top: 100, bottom: 30), child: Logo(300)),

          /// Login form
          Container(
            margin: EdgeInsets.only(left: 30, right: 30),
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  /// Input Phone number
                  CusInputWithLabel(
                    label: "Số điện thoại",
                    textEditingController: _phoneNumberController,
                    keyboardType: TextInputType.number,
                    onValidator: (value) {
                      if (value.isEmpty ||
                          (value.length < 9 && value.length > 12)) {
                        return 'Vui lòng kiểm tra số điện thoại';
                      }
                      return null;
                    },
                  ),

                  /// Input password
                  CusInputWithLabel(
                    label: "Mật khẩu",
                    textEditingController: _passwordController,
                    keyboardType: TextInputType.text,
                    isSecure: true,
                    onValidator: (value) {
                      if (value.isEmpty ||
                          (value.length < 9 && value.length > 12)) {
                        return 'Vui lòng kiểm tra mật khẩu';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),

          /// Show error message
          if (_isLoginFailed)
            Container(
              child: Center(
                child: Text(
                  _errorMsg,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            ),

          /// View show button forgot password and register
          Container(
            margin: EdgeInsets.only(left: 30, right: 30),
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: FlatButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  RegisterScreen(title: "Đặt lại mật khẩu")));
                    },
                    child: Text(
                      "Quên mật khẩu?",
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                  ),
                ),
                Container(
                  child: FlatButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => RegisterScreen(
                                    title: "Đăng ký tài khoản",
                                  )));
                    },
                    child: Text("Đăng ký"),
                  ),
                )
              ],
            ),
          ),

          /// Remember password
          // TODO: not yet

          /// Button submit
          Container(
            margin: EdgeInsets.only(left: 30, right: 30),
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.7),
                        border: Border.all(color: Colors.amber, width: 1),
                        borderRadius: BorderRadius.circular(5)),
                    child: FlatButton(
                      padding: EdgeInsets.all(0),
                      onPressed: _submitFormLogin,
                      child: Text(
                        "Nhận mã xác thực",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
