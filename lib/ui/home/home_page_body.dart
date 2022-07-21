import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:store/ui/helpers_widgets/constantHelpers.dart';
import 'package:store/ui/products/product_details.dart';

class HomePageBody extends StatefulWidget {
  var userLevel;
  HomePageBody({this.userLevel});
  @override
  _HomePageBodyState createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  TextEditingController _searchController = new TextEditingController();

  var searchCase;
  var searchedKey;
  bool _isVisible = false;
  int selectedIndex;
  int selectedIndexForSubTabs = 545454;
  double marginNumber = 10;

  var sub_cate_id;
  var top_cate_id;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // Fot Search Box ==> TextField
          Container(
            margin: EdgeInsets.all(kDefaultPadding),
            padding: EdgeInsets.symmetric(
                horizontal: kDefaultPadding, vertical: kDefaultPadding / 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  searchedKey = value;
                });
              },
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                suffixIcon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                prefixIcon: IconButton(icon: Icon(Icons.close,color: Colors.white,),onPressed: (){
                  setState(() {
                    searchedKey = '';
                    _searchController.clear();
                  });
                },),
                hintText: "ابـحـث هـنـا",
                hintStyle: TextStyle(color: Colors.white),
              ),
              textAlign: TextAlign.right,
            ),
          ),

          // For Tabs
          Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
              height: 30,

              child: StreamBuilder(
                stream: Firestore.instance
                    .collection('categories')
                    .where('cate_level', isEqualTo: 0)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData && snapshot.data.documents.length>0) {
                    final tabs = snapshot.data.documents;
                    return ListView.builder(
                      itemCount: tabs.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {

                              if(_isVisible && selectedIndex != index){
                                _isVisible = true;
                              }else{
                                _isVisible=!_isVisible;
                              }

                              selectedIndex = index;
                              top_cate_id = tabs[index].documentID;

                              // when i click on the tap it brings all products that contains in the specific tap
                              sub_cate_id = null;
                              selectedIndexForSubTabs = null;
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(
                              left: kDefaultPadding,
                              right: (index == tabs.length - 1)
                                  ? kDefaultPadding
                                  : 0,
                            ),
                            padding:
                                EdgeInsets.symmetric(horizontal: kDefaultPadding),
                            decoration: BoxDecoration(
                              color: (index == selectedIndex)
                                  ? Colors.white.withOpacity(0.4)
                                  : Colors.transparent,

                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tabs[index]['cate_name'],
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        );
                      },

                    );
                  } else {
                    return Text('');
                  }
                },
              ),
            ),
          ),

          // For Sub Tabs
          Visibility(
            visible: _isVisible,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
                height: 30,

                child: StreamBuilder(
                  stream: (top_cate_id != null)
                      ? Firestore.instance
                          .collection('categories')
                          .where('is_sub_cate', isEqualTo: true)
                          .where('top_cate_id', isEqualTo: top_cate_id)
                          .snapshots()
                      : null,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshotSubTaps) {
                    if (snapshotSubTaps.hasData && snapshotSubTaps.data.documents.length>0 ) {
                      final subTaps = snapshotSubTaps.data.documents;
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: subTaps.length,
                        itemBuilder: (BuildContext context, int position) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndexForSubTabs = position;
                                sub_cate_id = subTaps[position].documentID;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(
                                left: kDefaultPadding,
                                right: (position == subTaps.length - 1)
                                    ? kDefaultPadding
                                    : 0,
                              ),
                              padding:
                                  EdgeInsets.symmetric(horizontal: kDefaultPadding),
                              decoration: BoxDecoration(
                                color: (position == selectedIndexForSubTabs)
                                    ? Colors.white.withOpacity(0.4)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${subTaps[position]['cate_name']}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return Text('');
                    }
                  },
                ),
              ),
            ),
          ),

          //For Space Between the tabs and the content

          // For the rest of the screen
          Expanded(
            child: Stack(
              children: [
                // The background from under the tabs until the bottom of the page
                Container(
                  margin: EdgeInsets.only(top: marginNumber,),
                  decoration: BoxDecoration(
                    color: kBackgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                ),

                // The Content
                StreamBuilder(
                    stream: Firestore.instance
                        .collection('products')
                        .where('top_cate_id', isEqualTo: top_cate_id)
                        .where('sub_cate_id', isEqualTo: sub_cate_id)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData && snapshot.data.documents.length>0) {
                        return ListView(
                          children: snapshot.data.documents
                              .map((DocumentSnapshot document) {
                            if (document['pro_name'].toString().contains(_searchController.text)) {
                              return InkWell(
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: kDefaultPadding,
                                      vertical: 5),
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
                                            // color: Colors.redAccent,
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
                                          // height: 160,
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
                                              imageUrl: document['pro_imgUrl'].toString(),
                                              placeholder:(context, url) => Center(child: CircularProgressIndicator(),),
                                            ),
                                          ),
                                        ),
                                      ),

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
                                                width: MediaQuery.of(context).size.width/2.6,
                                                alignment: Alignment.center,
                                                child: Text(
                                                  '${document['pro_name']}',
                                                  overflow: TextOverflow.ellipsis,
                                                  softWrap: false,
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
                                                  '${document['pro_description']}',
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
                                                  color: kThirdColorBG,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(22),
                                                    topRight:
                                                        Radius.circular(22),
                                                  ),
                                                ),
                                                child: Text(
                                                  '${document['unit_price1']} \$',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold
                                                  ),
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
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ProductDetails(obj: document,userLevel: widget.userLevel,)));
                                },
                              );
                            } else {
                              return Text("");
                            }
                          }).toList(),
                        );
                      } else {
                        return Center(child: Text("لاتوجد اي منتجات حالياً",style: TextStyle(color: kIconColor, fontSize: 15),));
                      }
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
