import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:store/ui/authentication/loginScreen.dart';
import 'package:store/ui/authentication/signup.dart';
import 'package:store/ui/helpers_widgets/constantHelpers.dart';
import 'package:store/ui/home/home_page.dart';

// ignore: must_be_immutable
class SignupAdmin extends StatefulWidget {
  var state;
  var userLevel;
  var comingFrom;
  SignupAdmin({this.state,this.userLevel,this.comingFrom});

  @override
  _SignupAdminState createState() => _SignupAdminState();
}

class _SignupAdminState extends State<SignupAdmin> {

  var currentUserId;
  bool _isLoading = false;

  TextEditingController _ownerNameController ;
  TextEditingController _usernameController ;
  TextEditingController _emailController ;
  TextEditingController _phoneNumberController ;
  TextEditingController _passwordController ;
  TextEditingController _confirmedPasswordController ;

  FocusNode _myFullNameFocusNode;
  FocusNode _myUsernameFocusNode;
  FocusNode _myPhoneNumberFocusNode;
  FocusNode _myEmailFocusNode;
  FocusNode _myPasswordFocusNode;
  FocusNode _myConfirmPasswordFocusNode;

  getCurrnetUser() async{
    var result = await FirebaseAuth.instance.currentUser();
    setState(() {
      if(result != null && result.uid != null){
        currentUserId = result.uid;
      }
    });
  }

  @override
  void initState() {
    getCurrnetUser();
    _myEmailFocusNode = FocusNode();
    _myPasswordFocusNode = FocusNode();
    _myFullNameFocusNode = FocusNode();
    _myUsernameFocusNode = FocusNode();
    _myPhoneNumberFocusNode = FocusNode();
    _myConfirmPasswordFocusNode = FocusNode();
    super.initState();

    if(widget.state == "EditAccount") { // for editing admin account
      FirebaseAuth.instance.currentUser().then((currentUser){
        Firestore.instance.collection('users').document(currentUser.uid).get().then((userInfo) {
          setState(() {
            _ownerNameController = new TextEditingController(text: userInfo['owner_name']);
            _usernameController  = new TextEditingController(text: userInfo['username']);
            _emailController = new  TextEditingController(text: currentUser.email);
            _phoneNumberController = new  TextEditingController(text: userInfo['phone_number']);
            _passwordController =  new TextEditingController();
            _confirmedPasswordController = new TextEditingController();
          });

        });

      });

    }
    else{
      // for add new admin
      _ownerNameController = new TextEditingController();
      _usernameController =  new TextEditingController();
      _emailController    =  new  TextEditingController();
      _phoneNumberController  = new  TextEditingController();
      _passwordController   =  new TextEditingController();
      _confirmedPasswordController = new TextEditingController();
    }

  }

  final _formKey = GlobalKey<FormState>();

  // ignore: missing_return
  Future<bool> _onBackButtonPressed() {
    if(widget.comingFrom == 'signup'){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Signup(state: 'SingUp',comingFrom: 'LoginScreen',)));
    }else if(widget.comingFrom == 'homePage') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
    }
    else if(widget.comingFrom == 'LoginScreen') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen(firstButton: 'إنشاء حساب فرعي', secondButton: 'إنشاء حساب عادي',)));
    }

  }

  @override
  void dispose() {
    _myEmailFocusNode.dispose();
    _myPasswordFocusNode.dispose();
    _myFullNameFocusNode.dispose();
    _myUsernameFocusNode.dispose();
    _myPhoneNumberFocusNode.dispose();
    _myConfirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: WillPopScope(
        onWillPop: _onBackButtonPressed,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
            actions: [
              IconButton(
                onPressed: () =>_onBackButtonPressed(),
                icon: Icon(
                  Icons.arrow_forward_ios_sharp,
                  color: Colors.black,
                ),
              )
            ],
          ),
          body: Container(
            padding: EdgeInsets.symmetric(horizontal: 30 ,vertical: 010),
            width: double.infinity,
            child:ListView(
              padding: EdgeInsets.symmetric(horizontal: 10),
              children: [
                Padding(padding: EdgeInsets.only(top: 30.0)),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text( (widget.state == "EditAccount")?'تعديل الحساب' : "إنشاء حساب",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),),
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(top:10)),
                      Column(
                        children: <Widget>[
                          inputFile(label: "الاسم الكامل",controller: _ownerNameController,message: "الرجاء إدخال الاسم بالكامل",focusNode :_myFullNameFocusNode),
                          inputFile(label: "اسم المستخدم",controller: _usernameController, message: "الرجاء إدخال أسم المستخدم",focusNode :_myUsernameFocusNode),
                          inputFile(label: "البريد الإلكتروني",controller: _emailController,message: "الرجاء إدخال البريد الإلكتروني", type: 'email',focusNode :_myEmailFocusNode),
                          inputFile(label: "رقم الموبايل",controller: _phoneNumberController,message: "الرجاء إدخال رقم الموبايل ",type: 'phone',focusNode :_myPhoneNumberFocusNode),
                          inputFile(label:(widget.state == "EditAccount")?"كلمة السر الجديدة" : "كلمة السر",controller: _passwordController, obscureText: true ,message: "الرجاء إدخال كلمة السر" ,
                              hintText: (widget.state == "EditAccount")?'دعها فارغة اذا لاتريد تغييرها':'',focusNode :_myPasswordFocusNode),
                          inputFile(label: (widget.state == "EditAccount")?"تأكيد كلمة السر الجديدة": "تأكيد كلمة السر",controller: _confirmedPasswordController, obscureText: true,message: "الرجاء تأكيد كلمة السر",
                              hintText: (widget.state == "EditAccount")?'دعها فارغة اذا لاتريد تغييرها': '',action: 'done' ,focusNode :_myConfirmPasswordFocusNode),
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(top: 10)),
                      Container(
                        padding: EdgeInsets.only(top: 2, left: 2),
                        decoration:
                        BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border(
                              bottom: BorderSide(color: Colors.black),
                              top: BorderSide(color: Colors.black),
                              left: BorderSide(color: Colors.black),
                              right: BorderSide(color: Colors.black),
                            )
                        ),
                        child: MaterialButton(
                          minWidth: double.infinity,
                          height: 60,
                          onPressed: () =>signUpProcess(),
                          // color: Color(0xff0095FF),
                          // color: kPrimaryColor,
                          color: kSecondaryColorBG,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),

                          ),
                          child: Text(
                            (widget.state == "EditAccount")? "تعديل الحساب" : "إنشاء حساب",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.only(bottom: 30.0)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  signUpProcess() async{

    try{

      if(_formKey.currentState.validate()){
        setState(() =>_isLoading = true);

        if(widget.state == "EditAccount"){ // for edit admin
          if(currentUserId == null) {
            await getCurrnetUser();
          }

          await Firestore.instance.collection('users').document(currentUserId).updateData({
            'owner_name': _ownerNameController.text,
            'username' : _usernameController.text,
            'phone_number' : _phoneNumberController.text,
          });

          // to reset email and password
          await FirebaseAuth.instance.currentUser().then((value) async{
            var email = value.email;
            if(_emailController.text != email){
              value.updateEmail(_emailController.text);
              await Firestore.instance.collection('users').document(currentUserId).updateData({
                'email' : _emailController.text
              });
            }

            if(_passwordController.text.isNotEmpty) {
              value.updatePassword(_passwordController.text);
              await Firestore.instance.collection('users').document(currentUserId).updateData({
                'password' : _passwordController.text
              });
            }

          });

          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));

        }
        else{ // for Addition

          if(currentUserId == null){
            await getCurrnetUser();
          }

          var adminInfo;
          if(currentUserId != null){
            adminInfo = await Firestore.instance.collection('users').document(currentUserId).get();

          }

          var result = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
          if(adminInfo != null && adminInfo['email'] != null && adminInfo['password'] != null ){
            await FirebaseAuth.instance.signInWithEmailAndPassword(email: adminInfo['email'].toString(), password: adminInfo['password'].toString());
          }

          if(result.user.uid != null) {

            if(widget.userLevel == 1 ){
              await Firestore.instance.collection('users').document(result.user.uid).setData({
                'owner_name': _ownerNameController.text,
                'user_level' :  1,
                'username' : _usernameController.text,
                'phone_number' : _phoneNumberController.text,
                'created_date':DateTime.now(),
                'email':_emailController.text,
                'password':_passwordController.text

              }).then((_) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>HomePage() ));
              });
            }
            else if(widget.userLevel == 2){ // for adding sub admin account => level 2
              await Firestore.instance.collection('users').document(result.user.uid).setData({
                'owner_name': _ownerNameController.text,
                'user_level' :  2,
                'username' : _usernameController.text,
                'phone_number' : _phoneNumberController.text,
                'created_date':DateTime.now(),
                'who_created':currentUserId,
                'email':_emailController.text,
                'password':_passwordController.text

              }).then((_) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>HomePage() ));
              });
            }
            else if(widget.userLevel == 3){ // for adding an employees for the store => level 4

              var storeAccount = await Firestore.instance.collection('users').document(currentUserId).get();
              if(storeAccount != null && storeAccount.data.length>0){
                final storeName = storeAccount['store_name'];
                await Firestore.instance.collection('users').document(result.user.uid).setData({
                  'owner_name': _ownerNameController.text,
                  'user_level' :  4,
                  'username' : _usernameController.text,
                  'phone_number' : _phoneNumberController.text,
                  'created_date':DateTime.now(),
                  'store_id':currentUserId,
                  'store_name' : storeName,
                  'store_location' : storeAccount['location'],
                  'email':_emailController.text,
                  'password':_passwordController.text

                }).then((_) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>HomePage() ));
                });
              }

            }



          }

        }
      }
    }catch(e){
      setState(() =>_isLoading = false);
      switch (e.code) {
        case 'ERROR_WEAK_PASSWORD':
          {
            _myPasswordFocusNode.requestFocus();
            showError('كلمة المرور ضعيفة',
                'كلمة المرور التي ادخلتها ضعيفة الرجاء كتابة كلمة مرور قوية');
            break;
          }
        case 'ERROR_INVALID_EMAIL':
          {
            _myEmailFocusNode.requestFocus();
            if(_emailController.text.contains(' ')){
              showError('خطا في الصياغ',
                  'صيغة البريد الإلكتروني الذي ادخلته خاطئة الرجاء التأكد من عدم وجود فراغات في البريد الإلكتروني سواء في بدايته او نهايته، مثال offers@gmail.com');
            }else{
              showError('خطا في الصياغ',
                  'صيغة البريد الإلكتروني الذي ادخلته خاطئة الرجاء تصحيح الصياغ بما يتناسب مع صياغة البريد، مثال offers@gmail.com');
            }
            break;
          }
        case 'ERROR_EMAIL_ALREADY_IN_USE':
          {
            _myEmailFocusNode.requestFocus();
            showError('البريد موجود مسبقاً',
                'البريد الإلكتروني الذي ادخلته مسجل مسبقاً، الرجاء اختيار بريد اخر');
            break;
          }
        case 'ERROR_NETWORK_REQUEST_FAILED':
          {
            showError('حصول خطأ في النت',
                'حصل خطأ في الوصول إلى الشبكة الرجاء التأكد من أتصالك في الانترنت');
            break;
          }
        default:
          {
            showError('تنبية', e.message);
            break;
          }
      }
    }

  }

  // we will be creating a widget for text field
  Widget inputFile({label, controller,message,obscureText = false, type = 'text', hintText = '' , action = 'next' , focusNode})
  {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          label,textAlign: TextAlign.right,
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color:Colors.black87
          ),

        ),
        SizedBox(
          height: 2,
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          textInputAction: (action == 'done') ?TextInputAction.done :TextInputAction.next,
          onFieldSubmitted: (_){
            if(action == 'done'){
              signUpProcess();
            }
          },
          // ignore: missing_return
          validator: (value) {
            // For Addition
            if(widget.state == 'SignUp'){

              if(value.isEmpty){ return message;}
              else if(_passwordController.text != _confirmedPasswordController.text && label == 'تأكيد كلمة السر'){
                return 'كلمة السر التي ادخلتها غير متطابقة';
              }
              else if (_passwordController.text == _confirmedPasswordController.text && _passwordController.text.length <7 && label == 'تأكيد كلمة السر')
              {
                return 'الرجاء ادخال كلمة سر اكبر من 7 رموز';
              }

            }
            else {

              if(_passwordController.text.isEmpty && _confirmedPasswordController.text.isEmpty ){// for if the password doesn't changed
                if(value.isEmpty && label != 'كلمة السر الجديدة' && label != 'تأكيد كلمة السر الجديدة'){ return message;}
              }
              else{//If the user change his password
                if(value.isEmpty){ return message;}
                else if(_passwordController.text != _confirmedPasswordController.text && label == 'تأكيد كلمة السر الجديدة'){
                  return 'كلمة السر التي ادخلتها غير متطابقة';
                }
                else if (_passwordController.text == _confirmedPasswordController.text && _passwordController.text.length <7 && label == 'تأكيد كلمة السر الجديدة')
                {
                  return 'الرجاء ادخال كلمة سر اكبر من 7 رموز';
                }
              }
            }
          },

          keyboardType: getTextInputType(type),
          decoration: InputDecoration(
              hintText: hintText,
              contentPadding: EdgeInsets.symmetric(vertical: 10,
                  horizontal: 10),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.grey[400]
                ),

              ),
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[400])
              )
          ),
        ),
        SizedBox(height: 2,)
      ],
    );
  }

  // ignore: missing_return
  TextInputType getTextInputType(type){
    switch(type){
      case 'phone':
        {
          return TextInputType.phone;
        }
      case 'text':
        {
          return TextInputType.text;
        }
      case 'email':
        {
          return TextInputType.emailAddress;
        }
    }

  }

  showError(title, message) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: Text(title,textDirection: TextDirection.rtl,),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text(message , textDirection: TextDirection.rtl),
                  ],
                ),
              ),
              actions: [
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('إغلاق')),
              ],
            ),
          );
        });
  }

}


