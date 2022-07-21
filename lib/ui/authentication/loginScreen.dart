import 'package:store/ui/authentication/signup_administration.dart';
import 'package:store/ui/helpers_widgets/constantHelpers.dart';
import 'package:store/ui/authentication/login.dart';
import 'package:store/ui/home/home_page.dart';
import 'package:store/ui/authentication/signup.dart';
import 'package:flutter/material.dart';


// ignore: must_be_immutable
class LoginScreen extends StatefulWidget {
  var firstButton;
  var secondButton;

  LoginScreen({this.firstButton,this.secondButton});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  // ignore: missing_return
  Future<bool> _onBackButtonPressed(){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackButtonPressed,
      child: Scaffold(

        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white.withOpacity(0),
          actions: [
            IconButton(icon: Icon(Icons.arrow_forward_ios_sharp), onPressed: ()=>_onBackButtonPressed(),color: Colors.black,),
          ],
        ),

        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: MediaQuery
                .of(context)
                .size
                .height,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: MediaQuery
                      .of(context)
                      .size
                      .height / 3,
                  child: Center(child: Image.asset('assets/images/Novel-soft-logo.png',color: kSecondaryColorBG,)),
                ),

                Column(
                  children: <Widget>[
                    // the login button
                    MaterialButton(
                      minWidth: double.infinity,
                      height: 60,
                      onPressed: () {

                        if(widget.firstButton == 'إنشاء حساب فرعي'){
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SignupAdmin(state:"SignUp" , userLevel: 2,comingFrom: 'LoginScreen',)));
                        }else {
                          Navigator.pushReplacement(context, MaterialPageRoute(
                              builder: (context) => Login()));
                        }

                        },
                      // defining the shape
                      shape: RoundedRectangleBorder(
                          side: BorderSide(
                              color: Colors.black
                          ),
                          borderRadius: BorderRadius.circular(50)
                      ),
                      child: Text(
                        (widget.firstButton != null)? '${widget.firstButton}' :"تسجيل الدخول",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18
                        ),
                      ),
                    ),
                    // creating the signup button
                    SizedBox(height: 20),
                    MaterialButton(
                      minWidth: double.infinity,
                      height: 60,
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(
                            builder: (context) => Signup(state: "SingUp", comingFrom:'LoginScreen')));//to test
                      },
                      color: kSecondaryColorBG,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)
                      ),
                      child: Text(
                        (widget.secondButton != null) ? '${widget.secondButton}' :"إنشاء حساب",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18
                        ),
                      ),
                    )

                  ],
                )


              ],
            ),
          ),
        ),
      ),
    );
  }
}