import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ManageUsersMultiLevels extends StatefulWidget {

  var userLevel;
  var isAppBarShown;
  ManageUsersMultiLevels({this.isAppBarShown=false,this.userLevel});

  @override
  _ManageUsersMultiLevelsState createState() => _ManageUsersMultiLevelsState();
}

class _ManageUsersMultiLevelsState extends State<ManageUsersMultiLevels> {

  bool _isLoading =false;
  final GlobalKey<ScaffoldState> snack = GlobalKey<ScaffoldState>();


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ModalProgressHUD(
        inAsyncCall: _isLoading,
        child: Scaffold(
          key: snack,
          appBar: (widget.isAppBarShown)? AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group,),
                SizedBox(width: 15,),
                Text('إدارة المستخدمين'),
              ],
            ),

            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: (){
                Navigator.pop(context);
              },
            ),

            centerTitle: true,
          ):null,

          body: StreamBuilder(
            stream: Firestore.instance.collection('users').where('user_level',isEqualTo: 3).snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
              if(snapshot.hasData && snapshot.data.documents.length != 0){


                return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (BuildContext context, int index){
                    final userLevel3 = snapshot.data.documents[index];
                    return StreamBuilder(
                      stream: Firestore.instance.collection('users')
                          .where('user_level',isEqualTo: 4)
                          .where('store_id',isEqualTo: userLevel3.documentID)
                          .snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot2){
                        if(snapshot2.hasData && snapshot2.data.documents.length != 0) {
                          return ExpansionTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(child: Text('${userLevel3['owner_name']}'),),

                                Container(
                                  child: Row(
                                    children: [
                                      (widget.userLevel >=0 && widget.userLevel<2 )?IconButton(icon: Icon(Icons.delete_forever),iconSize: 18,color: Colors.red.shade300, onPressed: () async{

                                        var result = await alertMessage(title: 'حذف حساب',message: 'هل تريد حذف هذا الحساب نهائياً ؟\n علماً بأنة سيتم حذف كافة الحسابات التي تنطوي تحت هذا الحساب !! ',buttonText1: 'إلغاء',buttonText2: 'حذف');

                                        if(result == 'buttonText2'){
                                          deleteUserWithAccounts(userId: userLevel3.documentID,targetEmail:userLevel3['email'],targetPassword: userLevel3['password'] );
                                        }

                                            }
                                            ):Container(),
                                      // (widget.userLevel >=0 && widget.userLevel<2 )?IconButton(icon: Icon(Icons.pause),iconSize: 18,color: Colors.black54, onPressed: (){}):Container(),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(userLevel3['imgUrl']),
                            ),
                            tilePadding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                            children: snapshot2.data.documents
                                  .map((DocumentSnapshot document) {
                                    return ListTile(
                                      title: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(child: Text('${document['owner_name']}'),),

                                          Container(
                                            child: Row(
                                              children: [
                                                (widget.userLevel >=0 && widget.userLevel<2 )?IconButton(icon: Icon(Icons.delete_forever),iconSize: 18,color: Colors.red.shade300, onPressed: () async{
                                                  var result = await alertMessage(title: 'حذف حساب',message: 'هل تريد حذف هذا الحساب نهائياً ؟',buttonText1: 'إلغاء',buttonText2: 'حذف');

                                                  if(result == 'buttonText2'){
                                                    deleteUser(userId: document.documentID,targetEmail:document['email'],targetPassword: document['password'] );
                                                  }
                                                }):Container(),
                                                // (widget.userLevel >=0 && widget.userLevel<2 )?IconButton(icon: Icon(Icons.pause),iconSize: 18,color: Colors.black54, onPressed: (){}):Container(),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      leading: Icon(Icons.person),
                                      contentPadding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                                    );
                            }).toList(),
                          );

                        }else{
                          // For if the store does not having a users

                          return ExpansionTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(child: Text('${userLevel3['owner_name']}')),

                                Container(
                                  child: Row(
                                    children: [
                                      (widget.userLevel >=0 && widget.userLevel<2 )?IconButton(icon: Icon(Icons.delete_forever),iconSize: 18,color: Colors.red.shade300, onPressed: () async{
                                        var result = await alertMessage(title: 'حذف حساب',message: 'هل تريد حذف هذا الحساب نهائياً ؟',buttonText1: 'إلغاء',buttonText2: 'حذف');

                                        if(result == 'buttonText2'){
                                          deleteUser(userId: userLevel3.documentID,targetEmail:userLevel3['email'],targetPassword: userLevel3['password'] );
                                        }

                                      }):Container(),
                                      // (widget.userLevel >=0 && widget.userLevel<2 )?IconButton(icon: Icon(Icons.pause),iconSize: 18,color: Colors.black54, onPressed: (){}):Container(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            tilePadding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(userLevel3['imgUrl']),
                              // child: Icon(Icons.person),
                            ),

                            children: [
                              ListTile(
                                title: Text('لايوجد مستخدمون لدى هذا الحساب'),
                                contentPadding: EdgeInsets.symmetric(horizontal: 60,vertical: 3),
                              ),
                            ],
                          );


                        }
                      },
                    );
                  },
                );

              }else{
                return Center(
                  child: Text('لاتوجد حالياً اي بيانات'),
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

          var adminEmail = adminDoc['email'];
          var adminPassword = adminDoc['password'];


          await FirebaseAuth.instance.signInWithEmailAndPassword(email: '$targetEmail', password: '$targetPassword').then((value) async{

            await value.user.delete().then((_) async{
              await Firestore.instance.collection('users').document(userId).delete();
             await FirebaseAuth.instance.signInWithEmailAndPassword(email: '$adminEmail', password: '$adminPassword').then((value) {

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

  deleteUserWithAccounts({userId, targetEmail, targetPassword}) async{
    try{
      setState(()=> _isLoading=true);
      var currentAdmin = await FirebaseAuth.instance.currentUser();
      if(currentAdmin != null && currentAdmin.uid.isNotEmpty){

        var adminDoc = await Firestore.instance.collection('users').document(currentAdmin.uid).get();

        if(adminDoc != null && adminDoc.data.length>0){

          var adminEmail = adminDoc['email'];
          var adminPassword = adminDoc['password'];

          var storeID = userId;

          var storeAccounts = await Firestore.instance.collection('users').where('store_id',isEqualTo:storeID ).getDocuments();
          if(storeAccounts != null && storeAccounts.documents.length>0){

            // for sending the single store account to deleteUser method to delete it
            for(int i=0; i<storeAccounts.documents.length; i++){
              var singleUser = storeAccounts.documents[i];
              await deleteUserWithoutAdminSignIn(targetEmail: singleUser['email'],targetPassword: singleUser['password']);

              if(i== (storeAccounts.documents.length -1)){
                // for delete the store admin
                await deleteUserWithoutAdminSignIn(targetEmail: targetEmail,targetPassword: targetPassword);
              }

            }

            // for signIn The Admin again
            await FirebaseAuth.instance.signInWithEmailAndPassword(email: adminEmail, password: adminPassword);
          }
        }
      }



      print('tttttttttttttt');
      setState(()=> _isLoading=false);

    }catch(e){
      setState(()=> _isLoading=false);
      getSnackBar(title: 'حدث خطأ من نوع ${e.message}',second:2,size: 15.5 );
    }





  }

  deleteUserWithoutAdminSignIn({targetEmail,targetPassword}) async{

    try{

      await FirebaseAuth.instance.signInWithEmailAndPassword(email: targetEmail, password: targetPassword).then((targetUser) async{
        await Firestore.instance.collection('users').document(targetUser.user.uid).delete();
        await targetUser.user.delete();
      });

    }catch(e){
      setState(()=> _isLoading=false);
      getSnackBar(title: 'حدث خطأ من نوع ${e.message}',second:2,size: 15.5 );
    }

  }

  getSnackBar({title,second,size}){
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

}


