import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:store/ui/about_us/pages/character_listing_screen.dart';
import 'package:store/ui/authentication/login.dart';
import 'package:store/ui/categories/manage_categories.dart';
import 'package:store/ui/helpers_widgets/constantHelpers.dart';
import 'package:store/ui/home/home_page_body.dart';
import 'package:store/ui/my_cart/manage_carts.dart';
import 'package:store/ui/my_cart/my_cart.dart';
import 'package:store/ui/users/manage_users_all.dart';
import 'package:store/ui/users/manage_users_multi_levels.dart';
import 'package:store/ui/users/manage_users_single_level.dart';
import '../authentication/loginScreen.dart';
import '../authentication/signup.dart';
import '../authentication/signup_administration.dart';
import 'package:store/ui/helpers_widgets/circular_button.dart';
import '../products/manage_products.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final beforeLogin = ['تسجيل الدخول', 'عن التطبيق'];
  final users_level_0_1_2 = ['إنشاء مستخدم','إعدادات الحساب','تسجيل الخروج','عن التطبيق'];
  final users_level_3 = ['إنشاء موظف','إدارة الموظفين','إعدادات الحساب','تسجيل الخروج','عن التطبيق'];
  final users_level_4 = ['إعدادات الحساب','تسجيل الخروج','عن التطبيق'];
  var myCurrentUser=null;
  var userLevel=5;
  var store_id;


  //For Floating Button
  AnimationController animationController;
  Animation degOneTranslationAnimation,degTwoTranslationAnimation,degThreeTranslationAnimation,degFourTranslationAnimation;
  Animation rotationAnimation;


  double getRadiansFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getMyCurrentUser();
    getUserLevel();
    super.initState();

    //For Floating Button
    animationController = AnimationController(vsync: this,duration: Duration(milliseconds: 250));
    //First Button
    degOneTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(tween: Tween<double >(begin: 0.0,end: 1.2), weight: 75.0),
      TweenSequenceItem<double>(tween: Tween<double>(begin: 1.2,end: 1.0), weight: 25.0),
    ]).animate(animationController);
    //Second Button
    degTwoTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(tween: Tween<double >(begin: 0.0,end: 1.3), weight: 55.0),
      TweenSequenceItem<double>(tween: Tween<double>(begin: 1.3,end: 1.0), weight: 45.0),
    ]).animate(animationController);
    //Third Button
    degThreeTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(tween: Tween<double >(begin: 0.0,end: 1.40), weight: 35.0),
      TweenSequenceItem<double>(tween: Tween<double>(begin: 1.40,end: 1.0), weight: 65.0),
    ]).animate(animationController);

    //Fourth Button
    degFourTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(tween: Tween<double >(begin: 0.0,end: 1.60), weight: 30.0),
      TweenSequenceItem<double>(tween: Tween<double>(begin: 1.60,end: 1.0), weight: 70.0),
    ]).animate(animationController);

    rotationAnimation = Tween<double>(begin: 180.0,end: 0.0).animate(CurvedAnimation(parent: animationController
        , curve: Curves.easeOut));
    animationController.addListener((){
      setState(() {

      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSecondaryColorBG,
      appBar: AppBar(
        elevation: 0,
        title: StreamBuilder(
          stream: Firestore.instance.collection('users').document(myCurrentUser).snapshots(),
          builder:(BuildContext context, AsyncSnapshot snapshot) {
            try{
              if(snapshot.hasData && myCurrentUser != null && myCurrentUser != ''){
                if( snapshot.data['username'] != null){
                  return Text('${snapshot.data['username']}',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),);
                }
                else{
                  return Text('صن لايت للكهربائيات',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),);
                }
              }
              else{
                return Text('صن لايت للكهربائيات',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),);
              }
            }catch(e){
              if(myCurrentUser != null && userLevel != null) {
                checkIfTheUserDeleted();
              }
              return Text('صن لايت للكهربائيات',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),);
            }


          },
        ),
        brightness: Brightness.dark,
        centerTitle: true,
        actions: [
          getMenu(),
        ],
      ),

      body: HomePageBody(userLevel: userLevel,),

      floatingActionButton: getFloatingButton(),

    );
  }

  checkIfTheUserDeleted() async{
    if(myCurrentUser != null && userLevel != null) {
      var user = await Firestore.instance.collection('users').document(myCurrentUser).get();
      if(user == null && user.data == null ){
        FirebaseAuth.instance.signOut();
        myCurrentUser = null;
        userLevel = 5 ;
      }
    }
  }

  Widget getFloatingButton() {

    if(userLevel != null && userLevel != 5) {
      if (userLevel >= 0 && userLevel <= 2) {
        return Container(

          child: Stack(
            children: <Widget>[
              Positioned(
                  right: 30,
                  bottom: 30,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: <Widget>[
                      IgnorePointer(
                        child: Container(
                          color: Colors.transparent,
                          height: 150.0,
                          width: 150.0,
                        ),
                      ),
                      Transform.translate(
                        offset: Offset.fromDirection(getRadiansFromDegree(270),
                            degOneTranslationAnimation.value * 120),
                        child: Transform(
                          transform: Matrix4.rotationZ(
                              getRadiansFromDegree(rotationAnimation.value))
                            ..scale(degOneTranslationAnimation.value),
                          alignment: Alignment.center,
                          child: CircularButton(
                            color: Colors.blue,
                            width: 50,
                            height: 50,
                            tooltip: 'إدارة المنتجات',
                            icon: Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                            onClick: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>ManageProducts(state: 'Add_Product',)));
                              closeCircles();
                            },
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset.fromDirection(getRadiansFromDegree(240),
                            degTwoTranslationAnimation.value * 120),
                        child: Transform(
                          transform: Matrix4.rotationZ(
                              getRadiansFromDegree(rotationAnimation.value))
                            ..scale(degTwoTranslationAnimation.value),
                          alignment: Alignment.center,
                          child: CircularButton(
                            // color: Colors.black,
                            color: Color(0xFF363636),
                            width: 50,
                            height: 50,
                            tooltip: 'إدارة الأقسام',
                            icon: Icon(
                              Icons.account_tree,
                              color: Colors.white,
                            ),
                            onClick: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> ManageCategories(userLevel:userLevel)));
                              closeCircles();
                            },
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset.fromDirection(getRadiansFromDegree(210),
                            degThreeTranslationAnimation.value * 120),
                        child: Transform(
                          transform: Matrix4.rotationZ(
                              getRadiansFromDegree(rotationAnimation.value))
                            ..scale(degThreeTranslationAnimation.value),
                          alignment: Alignment.center,
                          child: CircularButton(
                            // color: Colors.black,
                            color: Colors.indigo,
                            width: 50,
                            height: 50,
                            tooltip: 'إدارة المستخدمين',
                            icon: Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                            onClick: () {

                              switch(userLevel){
                                case 0:{
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ManageUsersAll(length: 3,userLevel:userLevel ,)));
                                  break;
                                }
                                case 1:{
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ManageUsersAll(length: 2,userLevel: userLevel,)));
                                  break;
                                }
                                case 2:{
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ManageUsersMultiLevels(isAppBarShown: true,userLevel: userLevel,)));
                                  break;
                                }
                              }
                              closeCircles();

                            },
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset.fromDirection(getRadiansFromDegree(180),
                            degFourTranslationAnimation.value * 120),
                        child: Transform(
                          transform: Matrix4.rotationZ(
                              getRadiansFromDegree(rotationAnimation.value))
                            ..scale(degFourTranslationAnimation.value),
                          alignment: Alignment.center,
                          child: CircularButton(
                            color: Colors.teal.shade500,
                            width: 50,
                            height: 50,
                            tooltip: 'طلبات العملاء',
                            icon: Icon(
                              Icons.shopping_cart,
                              color: Colors.white,
                            ),
                            onClick: () {
                             Navigator.push(context, MaterialPageRoute(builder: (context) => ManageCarts()));
                             closeCircles();
                            },
                          ),
                        ),
                      ),
                      Transform(
                        transform: Matrix4.rotationZ(
                            getRadiansFromDegree(rotationAnimation.value)),
                        alignment: Alignment.center,
                        child: CircularButton(
                          // color: Color(0xFFC42470),
                          color: Colors.lightBlue.shade400,
                          width: 60,
                          height: 60,
                          icon: Icon(
                            Icons.menu,
                            color: Colors.white,
                          ),
                          onClick: () {
                            if (animationController.isCompleted) {
                              animationController.reverse();
                            } else {
                              animationController.forward();
                            }
                          },
                        ),
                      )

                    ],
                  ))
            ],
          ),
        );
      }
      else if(userLevel >=3 && userLevel<=4) {
        return FloatingActionButton(
          // backgroundColor: Color(0xFFD42470),
          backgroundColor: Colors.lightBlue.shade500,
          tooltip: 'سلتي',
          onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>MyCart(store_id : store_id,userLevel:userLevel))),
          child: Icon(Icons.add_shopping_cart_outlined,color: Colors.white,),
        );
      }
    }
    else {
      return Container();
    }

  }

  closeCircles(){
    if (animationController.isCompleted) {
      animationController.reverse();
    } else {
      animationController.forward();
    }
  }

  getMyCurrentUser() async{
    var result = await FirebaseAuth.instance.currentUser();
    if(result != null && result.uid != null){
      setState(() {
        myCurrentUser = result.uid;
      });
    }else{
      setState(() {
        myCurrentUser = null;
      });
    }
  }

  getUserLevel() async{
    try{

      var currentUser = await FirebaseAuth.instance.currentUser();
      // var currentUser = (myCurrentUser != null)? myCurrentUser: await getMyCurrentUser() ;
      if(currentUser != null && currentUser.uid != null){
        var currentUserDoc = await Firestore.instance.collection('users').document(currentUser.uid).get();
        var level = currentUserDoc.data['user_level'];
        setState(() {
          //For My Cart To Pass the store id to MyCartBody
          if(level == 3){
            store_id = currentUser.uid;
          }else if(level == 4){
            store_id = currentUserDoc['store_id'];
          }

          userLevel = currentUserDoc.data['user_level'];
        });

      }
      else{
        setState(() {
          userLevel = 5;//For Visitors
        });

      }


    }catch(e){
      setState(() {
        userLevel = 5;//For Visitors
      });
    }

  }

  // For PopupMenuButton
  Widget getMenu() {

    return PopupMenuButton(
      icon: Icon(FontAwesomeIcons.ellipsisV,size: 18,color: Colors.white,),
      padding: EdgeInsets.symmetric(
        horizontal: 30,
      ),
      itemBuilder: (BuildContext context) {
        // getCurrentUser();
        if (userLevel != null) {

          if(userLevel >=0 && userLevel<=2){
            return users_level_0_1_2.map((menu) {
              return PopupMenuItem(
                child: Container(
                    alignment: Alignment.center,
                    child: Text("$menu")),
                value: menu,
              );
            }).toList();
          }
          else if(userLevel == 3){
            return users_level_3.map((menu) {
              return PopupMenuItem(
                child: Container(
                    alignment: Alignment.center,
                    child: Text("$menu")),
                value: menu,
              );
            }).toList();
          }
          else if(userLevel == 4){
            return users_level_4.map((menu) {
              return PopupMenuItem(
                child: Container(
                    alignment: Alignment.center,
                    child: Text("$menu")),
                value: menu,
              );
            }).toList();
          }


        }

        return beforeLogin.map((menu) {
          return PopupMenuItem(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                "$menu",
              ),
            ),
            value: menu,
          );
        }).toList();
      },
      onSelected: (value) async {
        switch (value) {
          case 'تسجيل الدخول':
            {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => Login(comingFrom: 'PostsScreen',)));
              break;
            }
          case 'إنشاء مستخدم':
            {
              final level= userLevel ;
              if(level >=0 && level<=1){
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginScreen(firstButton: 'إنشاء حساب فرعي', secondButton: 'إنشاء حساب عادي',)));
              }
              else if(level == 2){
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Signup(state: 'SingUp',comingFrom: 'PostsScreen',) ));
              }

              break;
            }
          case 'إنشاء موظف':{
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignupAdmin(state: '',userLevel:userLevel,comingFrom: 'homePage',)));
            break;
          }
          case 'إدارة الموظفين':{
            Navigator.push(context, MaterialPageRoute(builder: (context) => ManageUsersSingleLevel(managed_level: 4,store_id: store_id,isAppBarShown: true,appBarTitle: 'إدارة الموظفين',userLevel: userLevel,) ));
            break;
          }
          case 'تسجيل الخروج':
            {
              await FirebaseAuth.instance.signOut();
              setState(() {
                userLevel =5;
                myCurrentUser = null;
              });
              break;
            }
          case 'إعدادات الحساب':
            {
              final user_level  = userLevel;

              if(user_level >=0 && user_level<=2 ||userLevel==4){
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            SignupAdmin(state: "EditAccount",userLevel: user_level,comingFrom: 'homePage',)));
              }
              else if(user_level == 3){
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Signup(state: "EditAccount",comingFrom: "PostsScreen",)));
              }

              break;
            }
          case 'عن التطبيق':
            {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CharacterListingScreen()));
              break;
            }
        }
      },
    );
  }

}
