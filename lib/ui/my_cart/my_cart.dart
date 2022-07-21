import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:store/ui/helpers_widgets/constantHelpers.dart';
import 'package:store/ui/my_cart/my_cart_body.dart';


class MyCart extends StatefulWidget {

  var store_id ;
  var state;
  var userLevel;
  MyCart({this.store_id,this.state,this.userLevel});

  @override
  _MyCartState createState() => _MyCartState();
}

class _MyCartState extends State<MyCart>  {

  var myCurrentUser;
  var userLevel;

  @override
  void initState() {
    getMyCurrentUser();
    getUserLevel();
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kSecondaryColorBG,
        appBar: AppBar(
          elevation: 0,
          title:Text( (widget.state.toString() == 'Manage_Cart')?'إدارة السلة': 'سلتي',style: TextStyle(
            fontWeight: FontWeight.bold,color: Colors.white
          ),),
          centerTitle: true,
          leading: IconButton(icon:Icon(Icons.arrow_back_ios,color: Colors.white,),onPressed: ()=>Navigator.pop(context),),
          brightness: Brightness.dark,
        ),

        body: Directionality(textDirection: TextDirection.ltr,child: MyCartBody(userLevel: widget.userLevel,store_id: widget.store_id,state: widget.state,)),


      ),
    );
  }

  getMyCurrentUser() async{
    var result = await FirebaseAuth.instance.currentUser();
    if(result != null  && result.uid != null){
      setState(() {
        myCurrentUser = result.uid;
      });
    }
  }

  getUserLevel() async{
    try{

      var currentUser = await FirebaseAuth.instance.currentUser();
      if(currentUser != null && currentUser.uid != null){
        var currentUserDoc = await Firestore.instance.collection('users').document(currentUser.uid).get();

        setState(() {
          userLevel = currentUserDoc.data['user_level'];
        });

      }
      else{
        userLevel = 5;//For Visitors
      }

    }catch(e){
      if(userLevel == null){
        userLevel = 5;//For Visitors
      }
    }


  }
}