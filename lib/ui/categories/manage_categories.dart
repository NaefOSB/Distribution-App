import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:store/ui/categories/Category.dart';
import 'package:store/ui/categories/sub_category.dart';
import 'package:store/ui/helpers_widgets/circular_button.dart';
import '../helpers_widgets/constantHelpers.dart';

class ManageCategories extends StatefulWidget {

  var userLevel;
  ManageCategories({this.userLevel});

  @override
  _ManageCategoriesState createState() => _ManageCategoriesState();
}

class _ManageCategoriesState extends State<ManageCategories> with SingleTickerProviderStateMixin {

  bool _isLoading=false;

  //For Floating Button
  AnimationController animationController;
  Animation degOneTranslationAnimation,degTwoTranslationAnimation;
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
    // TODO: implement initState
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
      TweenSequenceItem<double>(tween: Tween<double >(begin: 0.0,end: 1.4), weight: 55.0),
      TweenSequenceItem<double>(tween: Tween<double>(begin: 1.4,end: 1.0), weight: 45.0),
    ]).animate(animationController);
    //Third Button


    rotationAnimation = Tween<double>(begin: 180.0,end: 0.0).animate(CurvedAnimation(parent: animationController
        , curve: Curves.easeOut));
    animationController.addListener((){
      setState(() {

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group,color: Colors.white,),
                SizedBox(width: 15,),
                Text('إدارة الأقسام والأصناف',style: TextStyle(color: Colors.white)),
              ],
            ),

            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios,color: Colors.white,),
              onPressed: (){
                Navigator.pop(context);
              },
            ),
            brightness: Brightness.dark,

            centerTitle: true,
          ),

          body: StreamBuilder(
            stream: Firestore.instance.collection('categories').where('cate_level',isEqualTo: 0).snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
              if(snapshot.hasData && snapshot.data.documents.length != 0){

                return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (BuildContext context, int index){
                    final topCategory = snapshot.data.documents[index];
                    return StreamBuilder(
                      stream: Firestore.instance.collection('categories')
                          .where('cate_level',isEqualTo: 1)
                          .where('top_cate_id',isEqualTo: topCategory.documentID)
                          .snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot2){

                        if(snapshot2.hasData && snapshot2.data.documents.length != 0) {
                          return ExpansionTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(child: Text('${topCategory['cate_name']}'),),

                                Container(
                                  child: Row(
                                    children: [
                                      IconButton(icon: Icon(Icons.edit,color: Colors.teal,),iconSize: 18,color: Colors.black54, onPressed: (){
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => MyCategory(state:'Edit_Category',category:topCategory ,)));
                                      }),
                                      (widget.userLevel<2 && widget.userLevel>=0)? IconButton(icon: Icon(Icons.delete_forever),iconSize: 18,color: Colors.red.shade300, onPressed: () async{

                                        deleteCategoryProcess(typeId:topCategory.documentID );

                                      }):Container(),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            leading: Icon(Icons.home,color: kSecondaryColorBG,),
                            tilePadding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                            children: snapshot2.data.documents
                                .map((DocumentSnapshot document) {
                              return ListTile(
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(child: Text('${document['cate_name']}'),),

                                    Container(
                                      child: Row(
                                        children: [
                                          IconButton(icon: Icon(Icons.edit,color: Colors.teal,),iconSize: 18,color: Colors.black54, onPressed: (){
                                            Navigator.push(context, MaterialPageRoute(builder: (context) =>SubCategory(state: 'Edit_SubCategory',obj: document,)));
                                          }),
                                          (widget.userLevel<2 && widget.userLevel>=0)? IconButton(icon: Icon(Icons.delete_forever),iconSize: 18,color: Colors.red.shade300, onPressed: (){
                                            deleteSubCategoryProcess(typeId:document.documentID,hasSubCategory: false );
                                          }) :Container(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                leading: Icon(Icons.account_tree),
                                contentPadding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                              );
                            }).toList(),
                          );

                        }else{
                          // For if the category does not having a sub category
                          return ExpansionTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(child: Text('${topCategory['cate_name']}')),

                                Container(
                                  child: Row(
                                    children: [
                                      IconButton(icon: Icon(Icons.edit,color: Colors.teal,),iconSize: 18,color: Colors.black54, onPressed: (){
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => MyCategory(state:'Edit_Category',category:topCategory ,)));
                                      }),
                                      (widget.userLevel<2 && widget.userLevel>=0)? IconButton(icon: Icon(Icons.delete_forever),iconSize: 18,color: Colors.red.shade300, onPressed: (){
                                        deleteCategoryProcess(typeId:topCategory.documentID,hasSubCategory: false );
                                      }):Container(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            tilePadding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                            leading: Icon(Icons.home,color: kSecondaryColorBG,),

                            children: [
                              ListTile(
                                title: Text('عذراً لايوجد صنف لهذا الفرع، الرجاء أضافة صنف'),
                                contentPadding: EdgeInsets.symmetric(horizontal: 30,vertical: 3),
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
                  child: Text('لاتوجد حالياً اي بيانات',style: TextStyle(color: kIconColor, fontSize: 15),),
                );
              }
            },
          ),

          floatingActionButton: Container(

            child: Stack(
              children: <Widget>[
                Positioned(
                    right: 60,
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
                          offset: Offset.fromDirection(getRadiansFromDegree(250),
                              degOneTranslationAnimation.value * 100),
                          child: Transform(
                            transform: Matrix4.rotationZ(
                                getRadiansFromDegree(rotationAnimation.value))
                              ..scale(degOneTranslationAnimation.value),
                            alignment: Alignment.center,
                            child: CircularButton(
                              color: Colors.blue,
                              width: 50,
                              height: 50,
                              tooltip: 'أضافة قسم',
                              icon: Icon(
                                Icons.add_business,
                                color: Colors.white,
                              ),
                              onClick: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) =>MyCategory()));
                              },
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: Offset.fromDirection(getRadiansFromDegree(200),
                              degTwoTranslationAnimation.value * 100),
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
                              tooltip: 'أضافة فرع',
                              icon: Icon(
                                Icons.account_tree,
                                color: Colors.white,
                              ),
                              onClick: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) =>SubCategory()));
                              },
                            ),
                          ),
                        ),

                        Transform(
                          transform: Matrix4.rotationZ(
                              getRadiansFromDegree(rotationAnimation.value)),
                          alignment: Alignment.center,
                          child: CircularButton(
                            // color: kPrimaryColor,
                            color: kSecondaryColorBG,
                            width: 60,
                            height: 60,
                            icon: Icon(
                              Icons.add,
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
                        ),

                      ],
                    ))
              ],
            ),
          ),

        ),
      ),
    );
  }


  confirmDeletion({title,content,firstButton,secondButton,hasSecondButton=true}) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: Text('$title'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text('$content'),
                  ],
                ),
              ),
              actions: [
                FlatButton(
                    onPressed: () =>Navigator.pop(context,'$firstButton'),
                    child: Text('$firstButton',style: TextStyle(
                      color: Color(0xFF363636),
                    ),)),
                (hasSecondButton)?
                FlatButton(
                    onPressed: ()=> Navigator.pop(context,'$secondButton'),
                    child: Text('$secondButton',style: TextStyle(color: Colors.redAccent),)):Container(),
              ],
            ),
          );
        });
  }
  
  deleteCategoryProcess({typeId , hasSubCategory = true }) async{
    
    try{

      var result = await confirmDeletion(
          title: 'عملية حذف قسم',
          content:  'هل أنت متأكد من أنك تريد حذف هذا القسم؟',
          firstButton: 'إلغاء',
          secondButton: 'حذف');

      if(result.toString() == 'حذف'){

        setState(() =>_isLoading=true);

        // to check if this category have products which is the sub category have those products
        var isCategoryHavingsubCategries = await Firestore.instance.collection('categories')
            .where('cate_level',isEqualTo: 1 )
            .where('top_cate_id',isEqualTo: typeId )
            .getDocuments();

        if( isCategoryHavingsubCategries != null && isCategoryHavingsubCategries.documents.length>0){
          setState(() =>_isLoading=false);
          //If has sub categories
          confirmDeletion(
              title: 'تحذير',
              content: 'لايمكنك حذف هذا القسم لإحتوائة على  أصناف !!\n الرجاء حذف هذه الأصناف اولاً',
              firstButton: 'موافق',
              hasSecondButton: false
          );
        }else{
          // for if the category doesn't having any products
          
          setState(() =>_isLoading=false);
          var finalDecision = await confirmDeletion(
              title: 'تحذير',
              content: 'هل تريد حذف هذا القسم علماً بأنه لا يحتوي على اي صنف ؟',
              firstButton: 'إلغاء',
              secondButton: 'حذف'
          );
          if(finalDecision.toString() == 'حذف'){
          //  for delete category
            setState(() =>_isLoading=true);
              await Firestore.instance.collection('categories').document(typeId).delete();

            setState(() =>_isLoading=false);
            confirmDeletion(title: 'عملية تأكيدية',content: 'تمت عملية الحذف بنجاح',firstButton: 'موافق',hasSecondButton: false);
            
          }
        }

      }
      
      
    }catch(e){
      setState(() =>_isLoading=false);
      confirmDeletion(title: 'حدث خطأ ',content: '${e.message.toString()}',firstButton: 'موافق',hasSecondButton: false);
    }
    
  }

  deleteSubCategoryProcess({typeId , hasSubCategory = true }) async{
    try{

      var result = await confirmDeletion(
          title: 'عملية حذف صنف' ,
          content:  'هل أنت متأكد من أنك تريد حذف هذا الصنف؟' ,
          firstButton: 'إلغاء',
          secondButton: 'حذف');

      if(result.toString() == 'حذف'){

        setState(() =>_isLoading=true);

        // to check if this category have products which is the sub category have those products
        var isSubCategoryHavingProducts = await Firestore.instance.collection('products')
            .where('sub_cate_id' ,isEqualTo: typeId )
            .getDocuments();

        if( isSubCategoryHavingProducts != null && isSubCategoryHavingProducts.documents.length>0){
          setState(() =>_isLoading=false);
          //If has products
          var finalDecision = await confirmDeletion(
              title: 'تحذير',
              content: 'لايمكنك حذف هذا الصنف لإحتوائة على  منتجات !!\n الرجاء حذف هذه المنتجات اولاً  ',
              firstButton: 'موافق',
              hasSecondButton: false
          );
        }else{
          // for if the sub category doesn't having any products

          setState(() =>_isLoading=false);
          var finalDecision = await confirmDeletion(
              title: 'تحذير',
              content:  'هل تريد حذف هذا الصنف علماً بأنه لا يحتوي على اي منتج ؟',
              firstButton: 'إلغاء',
              secondButton: 'حذف'
          );
          if(finalDecision.toString() == 'حذف'){
            //  for delete category
            setState(() =>_isLoading=true);
            await Firestore.instance.collection('categories').document(typeId).delete();



            setState(() =>_isLoading=false);
            confirmDeletion(title: 'عملية تأكيدية',content: 'تمت عملية الحذف بنجاح',firstButton: 'موافق',hasSecondButton: false);

          }
        }

      }


    }catch(e){
      setState(() =>_isLoading=false);
      confirmDeletion(title: 'حدث خطأ ',content: '${e.message.toString()}',firstButton: 'موافق',hasSecondButton: false);
    }

  }
  
}


