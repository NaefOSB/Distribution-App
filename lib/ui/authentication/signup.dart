import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:store/ui/authentication/loginScreen.dart';
import 'package:store/ui/helpers_widgets/constantHelpers.dart';
import 'package:store/ui/home/home_page.dart';
import 'dart:io';
import 'package:store/ui/authentication/signup_administration.dart';

// ignore: must_be_immutable
class Signup extends StatefulWidget {
  String state;
  var comingFrom;
  Signup({this.state,this.comingFrom});

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  var currentUserId;
  var userLevel = 5;

  TextEditingController _alertPassword = new TextEditingController();
  TextEditingController _storeNameController;
  TextEditingController _ownerNameController;
  TextEditingController _usernameController;
  TextEditingController _emailController;
  TextEditingController _phoneNumberController;
  TextEditingController _passwordController;
  TextEditingController _confirmedPasswordController;
  TextEditingController _locationController;
  FocusNode _myEmailFocusNode;
  FocusNode _myPasswordFocusNode;

  getCurrnetUser() async{
    var result = await FirebaseAuth.instance.currentUser();
      if(result != null && result.uid != null){
        // to get the user level for admin registration link
        var currentUserDoc = await Firestore.instance.collection('users').document(result.uid).get();
        setState(() {
        currentUserId = result.uid;
        if(currentUserDoc != null && currentUserDoc.data.length>0){
          userLevel = currentUserDoc['user_level'];
        }
        });
      }
  }

  @override
  void initState() {
    getCurrnetUser();
    super.initState();

    if (widget.state == "EditAccount") {
      // for editing user account
      FirebaseAuth.instance.currentUser().then((currentUser) {
        Firestore.instance
            .collection('users')
            .document(currentUser.uid)
            .get()
            .then((userInfo) {
          setState(() {
            editedImage = userInfo['imgUrl']; // for getting the old image
            _storeNameController =
                new TextEditingController(text: userInfo['store_name']);
            _ownerNameController =
                new TextEditingController(text: userInfo['owner_name']);
            _usernameController =
                new TextEditingController(text: userInfo['username']);
            _emailController =
                new TextEditingController(text: currentUser.email);
            _phoneNumberController =
                new TextEditingController(text: userInfo['phone_number']);
            _passwordController = new TextEditingController();
            _confirmedPasswordController = new TextEditingController();
            _locationController =
                new TextEditingController(text: userInfo['location']);
          });
        });
      });
    } else {
      _storeNameController = new TextEditingController();
      _ownerNameController = new TextEditingController();
      _usernameController = new TextEditingController();
      _emailController = new TextEditingController();
      _phoneNumberController = new TextEditingController();
      _passwordController = new TextEditingController();
      _confirmedPasswordController = new TextEditingController();
      _locationController = new TextEditingController();
    }

    _myEmailFocusNode = FocusNode();
    _myPasswordFocusNode = FocusNode();

  }

  File image;
  String imgUrl;
  String editedImage = "";

  Future getImage() async {
    // to pick the image from the gallery
    // ignore: deprecated_member_use
    var img = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      image = img;
    });
  }

  // ignore: missing_return
  Future<bool> _onBackButtonPressed(){
    if(widget.comingFrom == 'LoginScreen'){
      Navigator.pushReplacement(context, MaterialPageRoute(builder:  (context)=>LoginScreen(firstButton: 'إنشاء حساب فرعي', secondButton: 'إنشاء حساب عادي',) ));
    }else if(widget.comingFrom == 'PostsScreen'){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage() ));
    }
    // Navigator.pushReplacement(context, MaterialPageRoute(builder:  (widget.comingFrom == 'PostsScreen')? (context)=>HomePage()  : (context)=>LoginScreen(firstButton: 'إنشاء حساب فرعي', secondButton: 'إنشاء حساب عادي',) ));
  }

  @override
  void dispose() {
    _myEmailFocusNode.dispose();
    _myPasswordFocusNode.dispose();
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
            brightness: Brightness.dark,

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
            padding: EdgeInsets.symmetric(horizontal: 40,vertical: 30),
            width: double.infinity,
            child: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                        (widget.state == "EditAccount")
                            ? "تعديل حسابي"
                            : "إنشاء حساب",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // Image_Picker
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: InkWell(
                      child: CircleAvatar(
                        radius: 100,
                        backgroundImage: (image != null)
                            ? FileImage(image)
                            : NetworkImage(editedImage),
                      ),
                      onTap: () => getImage(),
                    ),
                  ),

                  // To call TextFormFields
                  Column(
                    children: <Widget>[
                      inputFile(
                          label: "أسم المحل",
                          controller: _storeNameController,
                          message: "الرجاء ادخال أسم المحل"),
                      inputFile(
                          label: "أسم المالك",
                          controller: _ownerNameController,
                          message: "الرجاء ادخال اسم مالك المحل"),
                      inputFile(
                          label: "اسم المستخدم",
                          controller: _usernameController,
                          message: "الرجاء ادخال اسم المستخدم"),
                      inputFile(
                          label: "البريد الألكتروني",
                          controller: _emailController,
                          type: 'email',
                          focusNode: _myEmailFocusNode,
                          message: "الرجاء ادخال البريد الإلكتروني"),
                      inputFile(
                          label: "رقم الجوال",
                          controller: _phoneNumberController,
                          type: 'phone',
                          message: "الرجاء ادخال رقم الجوال",
                          ),
                      inputFile(
                        focusNode: _myPasswordFocusNode,
                          label: (widget.state == "EditAccount")
                              ? "كلمة السر الجديدة"
                              : "كلمة السر",
                          controller: _passwordController,
                          message: "الرجاء ادخال كلمة السر",
                          obscureText: true,
                          hintText: (widget.state == "EditAccount")
                              ? 'دعها فارغة اذا لاتريد تغييرها'
                              : ''),
                      inputFile(
                          label: (widget.state == "EditAccount")
                              ? "تأكيد كلمة السر الجديدة"
                              : "تأكيد كلمة السر",
                          controller: _confirmedPasswordController,
                          message: "الرجاء ادخال كلمة السر",
                          obscureText: true,
                          hintText: (widget.state == "EditAccount")
                              ? 'دعها فارغة اذا لاتريد تغييرها'
                              : ''),
                      inputFile(
                        label: "موقع المحل",
                        controller: _locationController,
                        message: "الرجاء ادخال موقع المحل",
                        action: 'done',
                      ),
                    ],
                  ),
                  Padding(padding: EdgeInsets.only(bottom: 20.0)),
                  Container(
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
                      onPressed: () => signUpProcess(),
                      color: kSecondaryColorBG,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        (widget.state == "EditAccount")
                            ? "تعديل الحساب"
                            : "إنشاء حساب",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(top:10)),
                  (userLevel <2 && userLevel>=0)?Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FlatButton(
                          onPressed: () => adminRegistration(),
                          child: Text(
                            "إنـشـاء حـسـاب كـمـديـر",
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w700,
                                color: Colors.lightBlue.shade700,
                            ),
                          ))
                    ],
                  ):Container(),
                  Padding(padding: EdgeInsets.only(bottom: 20.0)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  signUpProcess() async {
    try {
      if (_formKey.currentState.validate()) {

        if (image == null && widget.state == 'SingUp') {
          imageNotified();
        }
        else {
          setState(() =>_isLoading=true);
          if (widget.state == "EditAccount") {
            // for update account
            var currentUser = await FirebaseAuth.instance.currentUser();
            // For if the image changed or not
            if (image != null) {
              var storageImage =
                  FirebaseStorage.instance.ref().child(image.path);
              var task = storageImage.putFile(image);
              imgUrl = await (await task.onComplete).ref.getDownloadURL();
            } else {
              imgUrl = editedImage;
            }

            await Firestore.instance
                .collection('users')
                .document(currentUser.uid)
                .updateData({
              'store_name': _storeNameController.text,
              'owner_name': _ownerNameController.text,
              'username': _usernameController.text,
              'phone_number': _phoneNumberController.text,
              'location': _locationController.text,
              'imgUrl': imgUrl.toString(),
              'email':_emailController.text,
              'password':_passwordController.text
            });

            // to reset email and password
            await FirebaseAuth.instance.currentUser().then((value) {
              var email = value.email;
              if (_emailController.text != email) {
                value.updateEmail(_emailController.text);
              }

              if (_passwordController.text.isNotEmpty) {
                value.updatePassword(_passwordController.text);
              }
            });

            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => HomePage()));
          } else {
            // For create a new user


            // for let the admin stay at his account not login into the new account
            var adminInfo;
            if(currentUserId != null){
               adminInfo = await Firestore.instance.collection('users').document(currentUserId).get();
            }else{
              var userId = await FirebaseAuth.instance.currentUser();
              if(userId != null && userId.uid != null){
                adminInfo = await Firestore.instance.collection('users').document(userId.uid).get();
              }
            }



            var result = await FirebaseAuth.instance
                .createUserWithEmailAndPassword(
                    email: _emailController.text,
                    password: _passwordController.text);

            var storageImage = FirebaseStorage.instance.ref().child(image.path);
            var task = storageImage.putFile(image);
            imgUrl = await (await task.onComplete).ref.getDownloadURL();

            if (result.user.uid != null) {
              await Firestore.instance
                  .collection('users')
                  .document(result.user.uid)
                  .setData({
                'store_name': _storeNameController.text,
                'owner_name': _ownerNameController.text,
                'user_level': 3,
                'username': _usernameController.text,
                'phone_number': _phoneNumberController.text,
                'location': _locationController.text,
                'imgUrl': imgUrl.toString(),
                'created_date' : DateTime.now(),
                'who_created': currentUserId.toString(),
                'email':_emailController.text,
                'password':_passwordController.text
              }).then((_) async{
                if(adminInfo != null && adminInfo['email'] != null && adminInfo['password'] != null ){
                  await FirebaseAuth.instance.signInWithEmailAndPassword(email: adminInfo['email'].toString(), password: adminInfo['password'].toString());
                }
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => HomePage()));
              });
            }
          }
        }
      }
    } catch (e) {
      setState(() =>_isLoading=false);
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
        default:
          {
            showError('تنبية', e.message);
            break;
          }
      }
    }
  }

  imageNotified() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: Text("مطلوب إدخال الصورة"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text("الرجاء أضافة صورة لهذا المحل"),
                  ],
                ),
              ),
              actions: [
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("موافق")),
              ],
            ),
          );
        });
  }

  adminRegistration() async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: Text(
                "التحقق من الهوية",
                textDirection: TextDirection.rtl,
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text(
                      "الرجاء إدخال كلمة المرور للدخول إلى واجهة الأضافة : ",
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextField(
                      controller: _alertPassword,
                      obscureText: true,
                      onSubmitted:(value){
                        adminSingInProcess();
                      },
                      decoration: InputDecoration(
                          hintText: 'اكتب كلمة المرور',
                          labelText: 'كلمة المرور',
                          icon: Icon(Icons.lock_open)),
                    ),
                  ],
                ),
              ),
              actions: [
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("إلغاء", textDirection: TextDirection.rtl)),
                FlatButton(
                  onPressed: () =>adminSingInProcess(),
                  child: Text(
                    "موافق",
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ],
            ),
          );
        });
  }

  adminSingInProcess() async{
    try{

      if (_alertPassword.text.isNotEmpty) {
        setState(() => _isLoading=true);
        var passwordChecker = await Firestore.instance
            .collection('ownerSetting')
            .document('administrationcheckingfield')
            .get();

        if(passwordChecker != null && passwordChecker.data.length>0){
          if (_alertPassword.text == passwordChecker['password']) {
            _alertPassword.clear();
            Navigator.pop(context);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => SignupAdmin(state: 'SignUp',userLevel: 1,comingFrom: 'signup',)));
          } else {
            Navigator.of(context).pop();
            _alertPassword.clear();
            showError('خطأ في كلمة المرور',
                'كلمة المرور التي ادخلتها غير صحيحة الرجاء عدم الدخول إلى هذه الواجهة مرة اخرى إلا اذا كنت تملك كلمة المرور');
          }
        }
        setState(() => _isLoading=false);
      }

    }catch(e){
      setState(() => _isLoading=false);
      showError('حدث خطأ', e.message);
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
                    child: Text('إغلاق')),
              ],
            ),
          );
        });
  }

  Widget inputFile(
      {label,
      controller,
      message,
      obscureText = false,
        type = 'text',
      action = 'next',
        focusNode ,
      hintText = ''}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(4),
          child: Text(
            label,textAlign: TextAlign.right,
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87),
          ),
        ),
        SizedBox(
          height: 0,
        ),
        TextFormField(

          // ignore: missing_return
          validator: (value) {
            // For Addition
            if (widget.state == 'SignUp') {
              if (value.isEmpty) {
                return message;
              } else if (_passwordController.text !=
                      _confirmedPasswordController.text &&
                  label == 'تأكيد كلمة السر') {
                return 'كلمة السر التي ادخلتها غير متطابقة';
              } else if (_passwordController.text ==
                      _confirmedPasswordController.text &&
                  _passwordController.text.length < 7 &&
                  label == 'تأكيد كلمة السر') {
                return 'الرجاء ادخال كلمة سر اكبر من 7 رموز';
              }
            } else {
              if (_passwordController.text.isEmpty &&
                  _confirmedPasswordController.text.isEmpty) {
                // for if the password doesn't changed
                if (value.isEmpty &&
                    label != 'كلمة السر الجديدة' &&
                    label != 'تأكيد كلمة السر الجديدة') {
                  return message;
                }
              } else {
                //If the user change his password
                if (value.isEmpty) {
                  return message;
                } else if (_passwordController.text !=
                        _confirmedPasswordController.text &&
                    label == 'تأكيد كلمة السر الجديدة') {
                  return 'كلمة السر التي ادخلتها غير متطابقة';
                } else if (_passwordController.text ==
                        _confirmedPasswordController.text &&
                    _passwordController.text.length < 7 &&
                    label == 'تأكيد كلمة السر الجديدة') {
                  return 'الرجاء ادخال كلمة سر اكبر من 7 رموز';
                }
              }
            }
          },

          focusNode: focusNode,
          obscureText: obscureText,
          controller: controller,
          textInputAction:
              (action == 'done') ? TextInputAction.done : TextInputAction.next,
          onFieldSubmitted: (_) {
            if (action == 'done') {
              signUpProcess();
            }
          },

          keyboardType: getKeyboardType(type),
          decoration: InputDecoration(
              hintText: hintText,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[400]),
              ),
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[400]))),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 0,
        )
      ],
    );
  }

  // ignore: missing_return
  TextInputType getKeyboardType(type){

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

}