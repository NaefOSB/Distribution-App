import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:store/ui/helpers_widgets/constantHelpers.dart';

class ManageUsersSingleLevel extends StatefulWidget {
  var managed_level; // the level that will managed
  var store_id;
  var isAppBarShown;
  var appBarTitle;
  var userLevel;

  ManageUsersSingleLevel({this.managed_level, this.store_id,this.isAppBarShown=false,this.appBarTitle ='',this.userLevel});

  @override
  _ManageUsersSingleLevelState createState() => _ManageUsersSingleLevelState();
}

class _ManageUsersSingleLevelState extends State<ManageUsersSingleLevel> {

  bool _isLoading = false;
  final GlobalKey<ScaffoldState> snack = GlobalKey<ScaffoldState>();


  getStream() {
    var stream ;
    var firestore = Firestore.instance.collection('users');
    final managedLevel = widget.managed_level;
    switch(managedLevel){
      case 1:{
        stream = firestore.where('user_level',isEqualTo: 1).snapshots();
        break;
      }
      case 2:
        {
          stream = firestore.where('user_level',isEqualTo: 2).snapshots();
          break;
        }
      case 4:
        {
          stream = firestore.where('user_level', isEqualTo: 4)
              .where('store_id', isEqualTo: widget.store_id)
              .snapshots();
          break;
        }
    }
    return stream;
  }


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ModalProgressHUD(
        inAsyncCall: _isLoading,
        child: Scaffold(
          key: snack,
          appBar:(widget.isAppBarShown)? AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.group,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 15,
                ),
                Text('${widget.appBarTitle}',style: TextStyle(color: Colors.white),),
              ],
            ),
            leading: IconButton(

              onPressed: (){
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios,color: Colors.white,),
            ),
            brightness: Brightness.dark,
            centerTitle: true,
          ):null,
          body: StreamBuilder(
            stream: getStream(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData && snapshot.data.documents.length != 0) {
                    return ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index){
                        final userLevel = snapshot.data.documents[index];
                        return ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: Text('${userLevel['owner_name']}'),
                              ),
                              Container(
                                child: Row(
                                  children: [
                                    (widget.userLevel != null && widget.userLevel>=0 && widget.userLevel<2 || widget.userLevel != null && widget.userLevel == 3  )?IconButton(
                                        icon: Icon(Icons.delete_forever),
                                        iconSize: 18,
                                        color: Colors.red.shade300,
                                        onPressed: () async{
                                          var result = await alertMessage(title: 'عملية حذف مؤظف !!',message: 'هل فعلاً تريد حذف هذا المؤظف ؟',buttonText1: 'إلغاء',buttonText2:'حذف');
                                          if(result == 'buttonText2') {
                                            deleteUser(
                                                userId: userLevel.documentID,
                                                targetEmail: userLevel['email'],
                                                targetPassword: userLevel['password']);
                                          }
                                        }):Container(),
                                    // (widget.userLevel>=0 && widget.userLevel<2)? IconButton(
                                    //     icon: Icon(Icons.pause),
                                    //     iconSize: 18,
                                    //     color: Colors.black54,
                                    //     onPressed: () {}):Container(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          leading: Icon(Icons.person,color: kSecondaryColorBG,),
                          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),

                        );
                      },
                    );
                  } else {
                    // For if the store does not having a users

                    return Center(
                      child: Text('لاتوجد بيانات حالياً'),
                    );
                  }

            },
          ),
        ),
      ),
    );
  }

  deleteUser({userId, targetEmail, targetPassword}) async{


    try{
      setState(()=> _isLoading=true);
      var currentAdmin = await FirebaseAuth.instance.currentUser();
      if(currentAdmin != null && currentAdmin.uid.isNotEmpty){

        var adminDoc = await Firestore.instance.collection('users').document(currentAdmin.uid).get();

        if(adminDoc != null && adminDoc.data.length>0){

          var adminEmail = currentAdmin.email;
          var adminPassword = adminDoc['password'];


          await FirebaseAuth.instance.signInWithEmailAndPassword(email: '$targetEmail', password: '$targetPassword').then((value) async{

            await value.user.delete().then((_) async{
              await Firestore.instance.collection('users').document(userId).delete();
              FirebaseAuth.instance.signInWithEmailAndPassword(email: '$adminEmail', password: '$adminPassword').then((value) {
                getSnackBar(title: 'تم الحذف بنجاح',second:2,size: 15.0 );
              });
            });
          });

        }
      }
      setState(()=> _isLoading=false);

    }catch(e){
      setState(()=> _isLoading=false);
      getSnackBar(title: 'حدث خطأ من نوع ${e.message}',second:2,size: 15.5 );
    }

  }

  alertMessage({String title, String message,buttonText1,buttonText2}) {
    return showDialog(
        context: context,
        barrierDismissible: false,
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
                    onPressed: () =>Navigator.pop(context,'buttonText1'),
                    child: Text('$buttonText1', textDirection: TextDirection.rtl)),
                FlatButton(
                    onPressed: () =>Navigator.pop(context,'buttonText2'),
                    child: Text('$buttonText2', textDirection: TextDirection.rtl)),
              ],
            ),
          );
        });
  }
  getSnackBar({title,second,double size}){
    snack.currentState.showSnackBar(
        SnackBar(
          padding: EdgeInsets.symmetric(horizontal: size),
          content: Center(
            heightFactor: 1,
            child: Text('$title',style: TextStyle(
                fontFamily: 'ElMessiri'
            ),),
          ),
          duration: Duration(
              seconds: second
          ),


        )
    );
  }

}
