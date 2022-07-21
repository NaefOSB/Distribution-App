import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:store/ui/helpers_widgets/constantHelpers.dart';
import 'package:store/ui/home/home_page.dart';

// ignore: must_be_immutable
class Login extends StatefulWidget {
  var comingFrom;
  Login({this.comingFrom});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  // For Focusing On TextFields when the error handle
  FocusNode myEmailFocusNode;
  FocusNode myPasswordFocusNode;

  logInProcess() async{
    try {
      if (_formKey.currentState.validate()) {
        setState(() => _isLoading = true);

        await FirebaseAuth.instance
            .signInWithEmailAndPassword(
            email: _emailController.text.replaceAll(' ', ''),
            password: _passwordController.text)
            .then((_) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage()));
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      String message = '';

      switch (e.code) {
        case 'ERROR_INVALID_EMAIL':
          {
            myEmailFocusNode.requestFocus();
            message =
            'صيغة البريد الإلكتروني الذي ادخلته خاطئة الرجاء تصحيح الصياغ بما يتناسب مع صياغة البريد، مثال shamel@gmail.com';
            errorMessage(
                title: 'خطأ في الصياغ',
                message: message);
            break;
          }
        case 'ERROR_WRONG_PASSWORD':
          {
            myPasswordFocusNode.requestFocus();
            message =
            'كلمة المرور التي ادخلتها خاطئة الرجاء ادخال كلمة المرور بشكل صحيح';
            errorMessage(
                title: 'خطأ في كلمة المرور',
                message: message);
            break;
          }
        case 'ERROR_USER_NOT_FOUND':
          {
            myEmailFocusNode.requestFocus();
            message =
            'البريد الإلكتروني الذي ادخلته غير مسجل لدينا، الرجاء ادخال بريد إلكتروني مسجل مسبقا';
            errorMessage(
                title: 'الحساب غير موجود',
                message: message);
            break;
          }
          case 'ERROR_NETWORK_REQUEST_FAILED':
          {
            message =
            'حصل خطأ في الوصول إلى الشبكة الرجاء التأكد من أتصالك في الانترنت';
            errorMessage(
                title: 'حصول خطأ في النت',
                message: message);
            break;
          }
        default:
          {
            errorMessage(
                title: 'تنبية', message: e.message);
            break;
          }
      }
    }
  }

  // ignore: missing_return
  Future<bool> _onBackButtonPressed() {
    if(widget.comingFrom =='PostsScreen'){
       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>HomePage()));
    }
    else{
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    myEmailFocusNode = FocusNode();
    myPasswordFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    myEmailFocusNode.dispose();
    myPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: WillPopScope(
        onWillPop:_onBackButtonPressed ,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            brightness: Brightness.dark,
            backgroundColor: Colors.white,
            actions: [
              IconButton(
                onPressed: () =>_onBackButtonPressed(),
                icon: Icon(
                  Icons.arrow_forward_ios_sharp,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height/10),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Text(
                                "تسجيل الدخول",
                                style: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: Column(
                              children: <Widget>[
                                inputFile(
                                    label: "البريد الإلكتروني",
                                    controller: _emailController,
                                    focusNode: myEmailFocusNode,
                                    errorMessage:
                                    'الرجاء ملء خانة البريد الإلكتروني'),
                                inputFile(
                                    label: "كلمة المرور",
                                    controller: _passwordController,
                                    focusNode: myPasswordFocusNode,
                                    errorMessage: 'الرجاء عدم ترك كلمة المرور فاضية',
                                    obscureText: true,
                                    action: 'done' ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: Container(
                              padding: EdgeInsets.only(top: 3, left: 3),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border(
                                    bottom: BorderSide(color: Colors.black),
                                    top: BorderSide(color: Colors.black),
                                    left: BorderSide(color: Colors.black),
                                    right: BorderSide(color: Colors.black),
                                  )),
                              child: MaterialButton(
                                minWidth: double.infinity,
                                height: 60,
                                onPressed: ()=> logInProcess(),
                                color: kSecondaryColorBG,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(
                                  "تسجيل الدخول",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height/9,),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  errorMessage({String title, String message}) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: Text(
                title,
                textDirection: TextDirection.rtl,
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text(message, textDirection: TextDirection.rtl),
                  ],
                ),
              ),
              actions: [
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('موافق', textDirection: TextDirection.rtl))
              ],
            ),
          );
        });
  }

  // we will be creating a widget for text field
  Widget inputFile({label, controller, errorMessage, obscureText = false,action ='next' , focusNode }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87,),
        ),
        SizedBox(
          height: 5,
        ),
        TextFormField(
          obscureText: obscureText,
          textAlign: TextAlign.center,
          controller: controller,
          focusNode: focusNode,
          // ignore: missing_return
          validator: (text) {
            if (text.isEmpty) {
              return errorMessage;
            }
          },
          textInputAction: (action == 'done')? TextInputAction.done :TextInputAction.next,
          keyboardType: (obscureText)? TextInputType.text :TextInputType.emailAddress,
          onFieldSubmitted: (_){
            if(action == 'done'){
              logInProcess();
            }
          },
          decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[400]),
              ),
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[400]))),
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }

}


