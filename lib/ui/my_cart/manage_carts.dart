import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:store/ui/helpers_widgets/constantHelpers.dart';
import 'package:store/ui/my_cart/my_cart.dart';


class ManageCarts extends StatefulWidget {

  @override
  _ManageCartsState createState() => _ManageCartsState();
}

class _ManageCartsState extends State<ManageCarts> {

  var selectedIndexForSubTabs = 0;
  var userLevel=5;
  TextEditingController _searchController = new TextEditingController();
  final snack = new  GlobalKey<ScaffoldState>();

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
        setState(() {
          userLevel = 5;//For Visitors
        });
      }

    }catch(e){
      setState(() {
        if(userLevel ==null){
          userLevel = 5;//For Visitors
        }
      });
    }

  }

  @override
  void initState() {
    getUserLevel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kSecondaryColorBG,
        key: snack,

        appBar: AppBar(
          elevation: 0,
          title: Text("إدارة الطلبات",style: TextStyle(
            color: Colors.white
          ),),
          centerTitle: true,
          leading: IconButton(
            onPressed: ()=>Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios,color: Colors.white,),
          ),
          brightness: Brightness.dark,

        ),

        body: Directionality(
          textDirection: TextDirection.ltr,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [

                // Fot Search Box ==> TextField
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Container(
                    margin: EdgeInsets.all(kDefaultPadding),
                    padding: EdgeInsets.symmetric(horizontal: kDefaultPadding, vertical: kDefaultPadding / 4 ),


                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: TextField(
                      controller: _searchController,
                      onChanged: (value){
                        setState(() {

                        });

                      },
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: (){
                            _searchController.clear();

                          },
                          icon: Icon(Icons.clear,color: Colors.white,),
                        ),
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        icon: Icon(Icons.search,color: Colors.white,),
                        hintText: "ابـحـث هـنـا",
                        hintStyle: TextStyle(color: Colors.white),
                      ),

                    ),

                  ),
                ),

                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
                    height: 30,
                    // color: Colors.black38,

                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 2,
                      itemBuilder: (BuildContext context, int position) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndexForSubTabs = position;


                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width/2.5,
                            margin: EdgeInsets.only(
                              left: (position == 1) ? kDefaultPadding : 0,
                              right: kDefaultPadding,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
                            decoration: BoxDecoration(
                              color: (position == selectedIndexForSubTabs)
                                  ? Colors.white.withOpacity(0.4)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              (position == 0)? 'قيد التنفيذ' : 'تم الأستلام',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                //For Space Between the tabs and the content
                SizedBox(height: kDefaultPadding/2,),

                // For the rest of the screen
                Expanded(
                  child: Stack(
                    children: [
                      // The background from under the tabs until the bottom of the page
                      Container(
                        margin: EdgeInsets.only(top: 70),
                        decoration: BoxDecoration(
                          color: kBackgroundColor,
                          borderRadius: BorderRadius.only(
                            topLeft:  Radius.circular(40),
                            topRight: Radius.circular(40),

                          ),
                        ),
                      ),

                      // The Content
                      StreamBuilder(
                          stream: Firestore.instance.collection('shopping_cart').where('is_active',isEqualTo: true).where('is_completed',isEqualTo: (selectedIndexForSubTabs==0)?false:true).snapshots(),
                          builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

                            if(snapshot.hasData && snapshot.data.documents.length>0){

                              return ListView(
                                children: snapshot.data.documents.map((DocumentSnapshot document) {


                                  if(document['store_name'].toString().contains(_searchController.text)){

                                    return InkWell(
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: kDefaultPadding,
                                            vertical: kDefaultPadding / 2),
                                        height: 160,

                                        // widgets in this container
                                        child: Stack(
                                          alignment: Alignment.bottomCenter,
                                          children: [
                                            // Posts Card

                                            Container(
                                              height: 136,
                                              decoration: BoxDecoration(
                                                color: kSecondaryColorBG.withOpacity(0.2),
                                                borderRadius:
                                                BorderRadius.circular(22),
                                                boxShadow: [kDefaultShadow],
                                              ),
                                              child: Container(
                                                margin: EdgeInsets.only(right: 10),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                  BorderRadius.circular(22),
                                                ),
                                              ),
                                            ),

                                            // Post Image
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              top: 24.5,
                                              child: Container(

                                                padding: EdgeInsets.only(
                                                    right: 10,left: 20),
                                                height: 130,
                                                width: 200,
                                                child: ClipRRect(
                                                  borderRadius:
                                                  BorderRadius.only(
                                                      bottomRight: Radius.circular(20),
                                                      topRight: Radius.circular(20)
                                                  ),
                                                  child: CachedNetworkImage(
                                                    fit: BoxFit.fill,
                                                    imageUrl: document['store_imgUrl'].toString(),
                                                    placeholder:(context, url) => Center(child: CircularProgressIndicator(),),
                                                  ),

                                                ),

                                              ),
                                            ),

                                            // Posts title & price
                                            Positioned(
                                              bottom: 0,
                                              left: 0,
                                              child: SizedBox(
                                                height: 136,
                                                width: size.width - 200,
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Spacer(),
                                                    Container(
                                                      alignment: Alignment.center,
                                                      child: Text(
                                                        '${document['store_name']}',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .button,
                                                      ),
                                                    ),

                                                    //For Description
                                                    Spacer(),
                                                    Container(
                                                      alignment: Alignment.center,
                                                      margin: EdgeInsets.symmetric(
                                                          horizontal: 30),
                                                      child: Text(
                                                        '${document['store_location']}',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors
                                                              .blueGrey.shade600,
                                                        ),
                                                        overflow:
                                                        TextOverflow.ellipsis,
                                                      ),
                                                    ),

                                                    // For Price
                                                    Spacer(),
                                                    Container(
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal:
                                                        kDefaultPadding * 1.5,
                                                        vertical: kDefaultPadding / 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: kSecondaryColor,
                                                        borderRadius:
                                                        BorderRadius.only(
                                                          bottomLeft:
                                                          Radius.circular(22),
                                                          topRight:
                                                          Radius.circular(22),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        '${document['store_phone_number']}',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .button,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      onTap: ()  {
                                        // this code will perform when you click on any store
                                        Navigator.push(context, MaterialPageRoute(builder: (context) =>MyCart(state: 'Manage_Cart',store_id: document.documentID,userLevel: userLevel,)));


                                      },
                                    );
                                  }
                                  else{
                                    return Text("");
                                  }

                                }).toList(),
                              );
                            }else{
                              return Center(child: Text("لاتوجد حالياً أي بيانات"));
                            }

                          }
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

