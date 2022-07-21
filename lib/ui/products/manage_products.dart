import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:store/ui/helpers_widgets/ExpandedListAnimationWidget.dart';
import 'package:store/ui/helpers_widgets/constantHelpers.dart';
import 'package:store/ui/home/home_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:store/ui/products/product_details.dart';



class ManageProducts extends StatefulWidget {
  var state;
  var obj;
  var userLevel;

  ManageProducts({this.state,this.obj,this.userLevel});

  @override
  _ManageProductsState createState() => _ManageProductsState();
}

class _ManageProductsState extends State<ManageProducts> {
  bool _isLoading = false;
  bool _isAll = false;

  // to return the obj when updated
  var objs;

  // For Dropdown
  bool isStrechedDropDown = false;
  bool isStrechedDropDownSub = false;

  String categoryName = 'أختر قسم هذا المنتج';
  String subCategory = 'أختر صنف هذا المنتج';

  int groupValue;
  int groupValue2;

  var top_cate_id ;
  var sub_cate_id ;
  var currentUser;

  bool _isNeverChange = true;
  bool _isNeverChange2 = true;

  bool _isVisible ;

  String unitOneLabel = 'كمية الوحدة الأولى';

  final markFocus = FocusNode();
  final DescriptionFocus = FocusNode();
  final testFocus = FocusNode();


  TextEditingController _productNameController;
  TextEditingController _productMarkController;
  TextEditingController _descriptionController;

  TextEditingController _unitNameController1;
  TextEditingController _unitNameController2;
  TextEditingController _unitNameController3;

  TextEditingController _unit1PriceController;
  TextEditingController _unit2PriceController;
  TextEditingController _unit3PriceController;

  TextEditingController _unit1QuantityController;
  TextEditingController _unit2QuantityController;
  TextEditingController _unit3QuantityController;

  TextEditingController _unit2Fact;
  TextEditingController _unit3Fact;

  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> snack = GlobalKey<ScaffoldState>();

  File image;
  String imgUrl;
  String networkImage='';

  @override
  void initState() {

    super.initState();

    if (widget.state.toString() == 'Update_Product') {
      objs = widget.obj;

      // ==> for update post
      networkImage = widget.obj['pro_imgUrl'].toString();
      _productNameController = new TextEditingController(text: widget.obj['pro_name']);
      _productMarkController = new TextEditingController(text: widget.obj['pro_mark']);
      _descriptionController = new TextEditingController(text: widget.obj['pro_description']);
      _isVisible = false;
      unitOneLabel = 'الكمية النهائية';


      _unitNameController1= new TextEditingController(text: widget.obj['unit_name1']);
      _unitNameController2= new TextEditingController(text: widget.obj['unit_name2']);
      _unitNameController3= new TextEditingController(text: widget.obj['unit_name3']);
      _unit1PriceController= new TextEditingController(text: widget.obj['unit_price1']);
      _unit2PriceController= new TextEditingController(text: widget.obj['unit_price2']);
      _unit3PriceController= new TextEditingController(text: widget.obj['unit_price3']);
      _unit1QuantityController= new TextEditingController(text: widget.obj['all_quantity'].toString());

      _unit2Fact= new TextEditingController(text: widget.obj['unit_fact2']);
      _unit3Fact= new TextEditingController(text: widget.obj['unit_fact3']);

      categoryName = widget.obj['top_cate_name'];
      subCategory  = widget.obj['sub_cate_name'];
      top_cate_id  = widget.obj['top_cate_id'];
      sub_cate_id  = widget.obj['sub_cate_id'];

    //  to prevent error in validator on update
      _unit2QuantityController = new TextEditingController();
      _unit3QuantityController = new TextEditingController();

    }
    else if(widget.state.toString() == 'Add_Product') {
      //For Create Product
      _productNameController = new TextEditingController();
      _productMarkController = new TextEditingController();
      _descriptionController = new TextEditingController();

      _isVisible = true;

      _unitNameController1 = TextEditingController();
      _unitNameController2 = TextEditingController();
      _unitNameController3 = TextEditingController();
      _unit1PriceController = TextEditingController();
      _unit2PriceController = TextEditingController();
      _unit3PriceController = TextEditingController();
      _unit1QuantityController = TextEditingController();
      _unit2QuantityController = TextEditingController();
      _unit3QuantityController  = TextEditingController();

      _unit2Fact = TextEditingController();
      _unit3Fact = TextEditingController();

    }
    getCurrentUser();
  }

  Future getImage() async {
    // to pick the image from the gallery
    var img = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      image = img;
    });
  }

  Future<bool> _onBackButtonPressed() {
    if(widget.state =='Update_Product'){
      if(objs !=null){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>ProductDetails(obj: objs,userLevel: widget.userLevel,)));
      }
      else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>HomePage() ));
      }

    }
    else{
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: WillPopScope(
        onWillPop: _onBackButtonPressed,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            key: snack,
            appBar: AppBar(
              title: Text((widget.state.toString() == 'Add_Product')
                  ? "إضافة منتج"
                  : "تعديل المنتج",style: TextStyle(color: Colors.white),),
              centerTitle: true,
              leading: IconButton(
                onPressed: ()=>_onBackButtonPressed(),
                icon: Icon(Icons.arrow_back_ios,color: Colors.white,),

              ),
              brightness: Brightness.dark,
            ),
            body: Container(
              margin: EdgeInsets.all(33.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(25.0),
                      child: InkWell(
                        child: CircleAvatar(
                          radius: 100,
                          backgroundImage: (image != null)
                              ? FileImage(image)
                              : NetworkImage(networkImage),
                        ),
                        onTap: () => getImage(),
                      ),
                    ),

                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // product name
                          inputFile(label: 'أسم المنتج',hintText: 'الرجاء كتابة أسم المنتج',
                              message: 'الرجاء إدخال أسم المنتج',controller: _productNameController,number: 0,),
                          // product Mark
                          inputFile(label: 'رمز المنتج',hintText: 'الرجاء كتابة رمز المنتج',
                              message: 'الرجاء إدخال رمز المنتج',controller: _productMarkController,focusNode: markFocus,number: 1),

                          // product description
                          inputFile(label: 'وصف المنتج',hintText: 'الرجاء كتابة وصف لهذا المنتج',
                              maxLines: 3,message: 'الرجاء إدخال وصف لهذا المنتج',controller: _descriptionController,focusNode: DescriptionFocus),
                        ],
                      ),
                    ),

                    // For Categories
                    GestureDetector(
                      onTap: (){

                        setState(() {
                          isStrechedDropDown =
                          !isStrechedDropDown;

                          //For If The Sub Category & Unit Streched down it should be closed
                          isStrechedDropDownSub  = false;
                        });

                      },
                      child: Container(

                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                        child: SafeArea(
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Color(0xffbbbbbb)),
                                          // borderRadius: BorderRadius.all(Radius.circular(27))
                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              // height: 45,
                                                width: double.infinity,
                                                padding: EdgeInsets.only(right: 10),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Color(0xffbbbbbb),
                                                    ),

                                                    borderRadius:
                                                    BorderRadius.all(Radius.circular(3))),
                                                constraints: BoxConstraints(
                                                  minHeight: 45,
                                                  minWidth: double.infinity,
                                                ),
                                                alignment: Alignment.center,
                                                child: Directionality(
                                                  textDirection: TextDirection.rtl,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(
                                                              horizontal: 20, vertical: 10),
                                                          child: Center(
                                                            child: Text(
                                                              categoryName,style: TextStyle(
                                                                color: Colors.grey[700]
                                                            ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(left:10),
                                                        child: Icon(isStrechedDropDown
                                                            ? Icons.arrow_upward
                                                            : Icons.arrow_downward,
                                                            color: Colors.black54),
                                                      )
                                                    ],
                                                  ),
                                                )),
                                            Directionality(
                                              textDirection: TextDirection.rtl,
                                              child: ExpandedSection(
                                                expand: isStrechedDropDown,
                                                height: 100,
                                                child:
                                                StreamBuilder(
                                                  stream: Firestore.instance.collection('categories').where('cate_level' ,isEqualTo: 0).snapshots(),
                                                  builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                                    if(snapshot.hasData && snapshot.data.documents.length>0){
                                                      final categories = snapshot.data.documents;

                                                      return ListView.builder(
                                                        itemCount: snapshot.data.documents.length,
                                                        padding: EdgeInsets.all(0),
                                                        shrinkWrap: true,
                                                        itemBuilder: (BuildContext context, int index){
                                                          return RadioListTile(

                                                              title: Text('${categories[index]['cate_name']}'),
                                                              value: index,
                                                              groupValue:(widget.state.toString() == 'Update_Product' )? getGroupValue(categories[index].documentID.toString(),index) : groupValue,
                                                              onChanged: (val) {
                                                                setState(() {

                                                                  //For Update Product and set the category to the chosen one
                                                                  if(widget.state.toString() == 'Update_Product'){
                                                                    _isNeverChange = false;
                                                                  }

                                                                  groupValue = val;
                                                                  categoryName = categories[index]['cate_name'];
                                                                  top_cate_id = categories[index].documentID;
                                                                  subCategory = 'أختر صنف هذا المنتج';

                                                                  isStrechedDropDown =
                                                                  !isStrechedDropDown;
                                                                });
                                                              });
                                                        },

                                                      );
                                                    }else{
                                                      return ListView.builder(
                                                        itemCount: 1,
                                                        padding: EdgeInsets.all(0),
                                                        shrinkWrap: true,
                                                        itemBuilder: (BuildContext context, int index){
                                                          return ListTile(


                                                            title: Center(
                                                              child:  Text('لايوجد قسم حالياً الرجاء أضافة قسم جديد',style: TextStyle(
                                                                color: Colors.grey[700],
                                                                fontSize: 13,
                                                              ),),
                                                            ),

                                                          );
                                                        },

                                                      );
                                                    }

                                                  },
                                                ),
                                                // ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),

                    //Sub Category
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          isStrechedDropDownSub =
                          !isStrechedDropDownSub;
                          // For If The Category & Units sections are Streched down it should be closed
                          isStrechedDropDown     = false;
                        });
                      },
                      child: Container(

                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                        child: SafeArea(
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Color(0xffbbbbbb)),
                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              // height: 45,
                                                width: double.infinity,
                                                padding: EdgeInsets.only(right: 10),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Color(0xffbbbbbb),
                                                    ),

                                                    borderRadius:
                                                    BorderRadius.all(Radius.circular(3))),
                                                constraints: BoxConstraints(
                                                  minHeight: 45,
                                                  minWidth: double.infinity,
                                                ),
                                                alignment: Alignment.center,
                                                child: Directionality(
                                                  textDirection: TextDirection.rtl,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(
                                                              horizontal: 20, vertical: 10),
                                                          child: Center(
                                                            child: Text(
                                                              subCategory,style: TextStyle(
                                                                color: Colors.grey[700]
                                                            ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(left:10),
                                                        child: Icon(isStrechedDropDownSub
                                                            ? Icons.arrow_upward
                                                            : Icons.arrow_downward,
                                                            color: Colors.black54),
                                                      )
                                                    ],
                                                  ),
                                                )),
                                            Directionality(
                                              textDirection: TextDirection.rtl,
                                              child: ExpandedSection(
                                                expand: isStrechedDropDownSub,
                                                height: 100,
                                                child: StreamBuilder(
                                                  stream: Firestore.instance.collection('categories').where('cate_level' ,isEqualTo: 1).where('top_cate_id' , isEqualTo: top_cate_id ).snapshots(),
                                                  builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                                    if(snapshot.hasData && snapshot.data.documents.length>0){
                                                      final categories = snapshot.data.documents;

                                                      return ListView.builder(
                                                        itemCount: snapshot.data.documents.length,
                                                        padding: EdgeInsets.all(0),
                                                        shrinkWrap: true,
                                                        itemBuilder: (BuildContext context, int index){
                                                          return RadioListTile(

                                                              title: Text('${categories[index]['cate_name']}'),
                                                              value: index,
                                                              groupValue: (widget.state.toString() == 'Update_Product' )? getGroupValue2(categories[index].documentID.toString(),index) : groupValue2,
                                                              onChanged: (val) {
                                                                setState(() {

                                                                  //For Update Product and set the sub category to the chosen one
                                                                  if(widget.state.toString() == 'Update_Product'){
                                                                    _isNeverChange2 = false;
                                                                  }

                                                                  groupValue2 = val;
                                                                  //To Select The Id and The Name Of Sub Category
                                                                  subCategory = categories[index]['cate_name'];
                                                                  sub_cate_id = categories[index].documentID;


                                                                  isStrechedDropDownSub =
                                                                  !isStrechedDropDownSub;
                                                                });
                                                              });
                                                        },

                                                      );
                                                    }else{
                                                      return ListView.builder(
                                                        itemCount: 1,
                                                        padding: EdgeInsets.all(0),
                                                        shrinkWrap: true,
                                                        itemBuilder: (BuildContext context, int index){
                                                          return ListTile(


                                                            title: Center(
                                                              child: (categoryName == 'أختر قسم هذا المنتج')?Text('الرجاء أختيار قسم من القائمة العليا'):
                                                              Text('لايوجد صنف حالياً لهذا القسم الرجاء أضافة صنف جديد',style: TextStyle(
                                                                color: Colors.grey[700],
                                                                fontSize: 13,
                                                              ),),
                                                            ),

                                                          );
                                                        },

                                                      );
                                                    }

                                                  },
                                                ),
                                                // ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),


                    // Units
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: kIconColor)

                      ),

                      child: Container(
                        padding: EdgeInsets.all(10),

                        margin: EdgeInsets.all(5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // First Unit
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: kIconColor)

                              ),
                              child: Container(
                                padding: EdgeInsets.only(top: 5,left: 10,right: 10,bottom: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    inputFile(label: 'الوحدة الأولى',hintText: 'الرجاء أضافة الوحدة الأولى',
                                        message: 'الرجاء إدخال أسم الوحدة الأولى',controller: _unitNameController1),


                                    inputFile(label: 'سعر الوحدة',hintText: 'الرجاء أضافة سعر الوحدة',
                                        type: 'number',message: 'الرجاء إدخال السعر لهذه الوحدة',controller: _unit1PriceController),

                                    inputFile(label: unitOneLabel,hintText:'االرجاء إدخال كمية هذه الوحدة',
                                        type: 'quantity', message: 'الرجاء إدخال كمية الوحدة',controller: _unit1QuantityController,elementNumber: 1,isNecessary: false),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20,),

                            // Second Unit
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: kIconColor)

                              ),
                              child: Container(
                                padding: EdgeInsets.only(top: 5,left: 10,right: 10,bottom: 10),
                                child: Column(
                                  children: [
                                    inputFile(label: 'الوحدة الثانية',hintText: 'الرجاء أضافة الوحدة الثانية',
                                        isNecessary: false,controller: _unitNameController2,elementNumber: 2,
                                        message: 'الرجاء إدخال أسم الوحدة الثانية'),


                                    inputFile(label: 'سعر الوحدة',hintText: 'الرجاء أضافة سعر الوحدة',
                                        type: 'number',isNecessary: false,controller: _unit2PriceController,elementNumber: 3,
                                        message: 'الرجاء إدخال السعر لهذه الوحدة'),

                                    inputFile(label: 'عامل التحويل',hintText:'االرجاء إدخال عامل التحويل',
                                        type: 'quantity', isNecessary: false,controller: _unit2Fact,elementNumber: 4,
                                        message: 'الرجاء إدخال عامل التحويل'),

                                    Visibility(
                                      visible: _isVisible,
                                      child: inputFile(label: 'كمية الوحدة الثانية',hintText:'االرجاء إدخال كمية هذه الوحدة',
                                          type: 'quantity', isNecessary: false,controller: _unit2QuantityController),
                                    ),

                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20,),
                            // Third Unit
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: kIconColor)

                              ),
                              child: Container(
                                padding: EdgeInsets.only(top: 5,left: 10,right: 10,bottom: 10),
                                child: Column(
                                  children: [
                                    inputFile(label: 'الوحدة الثالثة',hintText: 'الرجاء أضافة الوحدة الثالثة',
                                        isNecessary: false,controller: _unitNameController3,elementNumber: 5,
                                        message: 'الرجاء إدخال أسم الوحدة الثالثة'),


                                    inputFile(label: 'سعر الوحدة',hintText: 'الرجاء أضافة سعر الوحدة',
                                        type: 'number',isNecessary: false,controller: _unit3PriceController,elementNumber: 6,
                                        message: 'الرجاء إدخال السعر لهذه الوحدة',),

                                    inputFile(label: 'عامل التحويل',hintText:'االرجاء إدخال عامل التحويل',
                                        type: 'quantity', isNecessary: false,controller: _unit3Fact,elementNumber: 7,
                                        message: 'الرجاء إدخال عامل التحويل'),

                                    Visibility(
                                      visible: _isVisible,
                                      child: inputFile(label: 'كمية الوحدة الثالثة',hintText:'االرجاء إدخال كمية هذه الوحدة',
                                        type: 'quantity', isNecessary: false,controller: _unit3QuantityController),),

                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),


                    Padding(
                      padding: EdgeInsets.only(top: 20),
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
                          onPressed: ()=> creationProcess(),
                          color: kSecondaryColorBG,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            (widget.state.toString() == 'Add_Product')? "إضافة المنتج":"تعديل المنتج",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),



                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  getSnackBar({title,second,size}){
    snack.currentState.showSnackBar(
        SnackBar(
          padding: EdgeInsets.only(right: size),
          content: Text('$title',style: TextStyle(
              fontFamily: 'ElMessiri'
          ),),
          duration: Duration(
              seconds: second
          ),

        )
    );
  }

  int getGroupValue(categoryID, index){
    //For select the chosen value only
    if(categoryID == widget.obj['top_cate_id'] && _isNeverChange){
      groupValue = index;
    }
    return groupValue;
  }

  int getGroupValue2(subCategoryID, index){

    //For select the chosen value only
    if(subCategoryID == widget.obj['sub_cate_id'] && _isNeverChange2){
      groupValue2 = index;
    }
    return groupValue2;
  }

  getCurrentUser() async{
    var user = await FirebaseAuth.instance.currentUser();
    if(user != null && user.uid != null){
      currentUser = user.uid;
    }

  }

  creationProcess() async{
    try {

      if(_formKey.currentState.validate() && categoryName != 'أختر قسم هذا المنتج' && subCategory != 'أختر صنف هذا المنتج'){

          if (widget.state.toString() == 'Add_Product') {
            // for add post

            //To Ensure That The Image Is Uploaded To image variable
            if(image == null && widget.state.toString() == 'Add_Product'){
              var result = await errorMessage(title: 'أنت لم تختار أي صورة',message: 'الرجاء إختيار صورة لهذا المنتج ليتم عرضه',buttonText: 'إلغاء', buttonText2: 'إختيار صورة' ,);
              if(result == 'addImage'){
                await getImage();
              }
            }
            if(image != null){
              setState(() =>_isLoading=true);

              if(currentUser == null){
                await getCurrentUser();
              }

              //To Upload The Image Into Firebase Storage
              var storageImage = FirebaseStorage.instance
                  .ref()
                  .child(image.path);
              var task = storageImage.putFile(image);
              imgUrl = await (await task.onComplete)
                  .ref
                  .getDownloadURL();


              // to calculate the quantity

              // quantities
              var firstUnitQuntity = _unit1QuantityController.text.isNotEmpty? double.parse(_unit1QuantityController.text):0;
              var secondUnitQuntity = _unit2QuantityController.text.isNotEmpty? double.parse(_unit2QuantityController.text):0;
              var thirdUnitQuntity = _unit3QuantityController.text.isNotEmpty? double.parse(_unit3QuantityController.text):0;

              var unit2FactorQuantity = _unit2Fact.text.isNotEmpty?double.parse(_unit2Fact.text):0;
              var unit3FactorQuantity = _unit3Fact.text.isNotEmpty?double.parse(_unit3Fact.text):0;

              var finalSecondQuantity = unit2FactorQuantity * secondUnitQuntity;
              var finalThirdQuantity = unit3FactorQuantity * thirdUnitQuntity;

              var allQuantity = (firstUnitQuntity + finalSecondQuantity + finalThirdQuantity);

              // To Add The Product

              var product = await Firestore.instance
                  .collection('products')
                  .add({

                'pro_name': _productNameController.text,
                'pro_mark': _productMarkController.text,
                'pro_description': _descriptionController.text,
                'unit_name1': _unitNameController1.text,
                'unit_name2': _unitNameController2.text,
                'unit_name3': _unitNameController3.text,
                'unit_price1': _unit1PriceController.text,
                'unit_price2': _unit2PriceController.text,
                'unit_price3': _unit3PriceController.text,
                'unit_fact2' : _unit2Fact.text,
                'unit_fact3' : _unit3Fact.text,
                'unit1Q':_unit1QuantityController.text,
                'unit2Q':_unit2QuantityController.text,
                'unit3Q':_unit3QuantityController.text,
                'pro_imgUrl': imgUrl.toString(),
                'top_cate_id' : top_cate_id,
                'sub_cate_id' : sub_cate_id,
                'top_cate_name' : categoryName,
                'sub_cate_name' : subCategory,
                'all_quantity':allQuantity,
                'created_date': DateTime.now(),
                'created_user': currentUser

              }).then((_) {

                image = null;
                _productNameController.clear();
                _productMarkController.clear();
                _descriptionController.clear();
                //to clear top category
                categoryName = 'أختر قسم هذا المنتج';
                isStrechedDropDown = false;
                groupValue = null;
                top_cate_id  = null;
                // to clear sub category
                subCategory = 'أختر صنف هذا المنتج';
                isStrechedDropDownSub = false;
                groupValue2 = null;
                sub_cate_id  = null;

                // to clear units
                _unitNameController1.clear();
                _unitNameController2.clear();
                _unitNameController3.clear();

                _unit1PriceController.clear();
                _unit2PriceController.clear();
                _unit3PriceController.clear();

                _unit1QuantityController.clear();
                _unit2QuantityController.clear();
                _unit3QuantityController.clear();

                _unit2Fact.clear();
                _unit3Fact.clear();

                setState(() =>_isLoading=false);

                getSnackBar(title: 'تمت عملية الأضافة بنجاح',second: 3,size: MediaQuery.of(context).size.width/3);

              });

            }

          }
          else {
            // for update post
            setState(() =>_isLoading=true);
            if(currentUser == null){
              await getCurrentUser();
            }

            if(image != null){
              await uploadImageIntoStorage();
            }


            // quantities
            var firstUnitQuntity = _unit1QuantityController.text.isNotEmpty? double.parse(_unit1QuantityController.text):0;

            var allQuantity = firstUnitQuntity;

            await Firestore.instance
                .collection('products')
                .document(widget.obj.documentID)
                .updateData({
              'pro_name': _productNameController.text,
              'pro_mark': _productMarkController.text,
              'pro_description': _descriptionController.text,
              'pro_imgUrl': (imgUrl == null)? networkImage.toString() : imgUrl.toString(),
              'top_cate_id' : top_cate_id,
              'sub_cate_id' : sub_cate_id,
              'top_cate_name' : categoryName,
              'sub_cate_name' : subCategory,
              'updated_date': DateTime.now(),
              'unit_name1': _unitNameController1.text,
              'unit_name2': _unitNameController2.text,
              'unit_name3': _unitNameController3.text,
              'unit_price1': _unit1PriceController.text,
              'unit_price2': _unit2PriceController.text,
              'unit_price3': _unit3PriceController.text,
              'unit_fact2' : _unit2Fact.text,
              'unit_fact3' : _unit3Fact.text,
              'unit1Q':_unit1QuantityController.text,
              'all_quantity':allQuantity
            }).then((_) async{

              // to return obj after updated
              var updatedObj = await Firestore.instance.collection('products').document(widget.obj.documentID).get();

              setState(() {
                objs = updatedObj;
                _isLoading=false;
              });
              getSnackBar(title: 'تمت عملية التعديل بنجاح',second: 2,size: MediaQuery.of(context).size.width/3);
            });
          }
        }
      else if ((_formKey.currentState.validate() && categoryName == 'أختر قسم هذا المنتج' && subCategory == 'أختر صنف هذا المنتج')){
        errorMessage(title: 'لم تختار اي قسم او صنف',message: 'الرجاء إختيار قسم وصنف هذا المنتج',buttonText: 'إختيار قسم وصنف');
        setState(() => isStrechedDropDown = true);
      }
      else if ((_formKey.currentState.validate() && categoryName == 'أختر قسم هذا المنتج' && subCategory != 'أختر صنف هذا المنتج')){
        errorMessage(title: 'لم تختار اي قسم',message: 'الرجاء إختيار قسم لهذا المنتج',buttonText: 'إختيار قسم');
        setState(() => isStrechedDropDown = true);
      }
      else if ((_formKey.currentState.validate() && categoryName != 'أختر قسم هذا المنتج' && subCategory == 'أختر صنف هذا المنتج')){
        errorMessage(title: 'لم تختار اي صنف',message: 'الرجاء إختيار صنف لهذا المنتج',buttonText: 'إختيار صنف');
        setState(() => isStrechedDropDownSub = true);
      }


    } catch (e) {
      setState(() => _isLoading = false);
      errorMessage(title: 'حدث خطأ', message: e.toString(),buttonText: 'موافق');
    }
  }

  uploadImageIntoStorage() async{
    if(image != null){
      //To Upload The Image Into Firebase Storage
      var storageImage = FirebaseStorage.instance
          .ref()
          .child(image.path);
      var task = storageImage.putFile(image);
      imgUrl = await (await task.onComplete)
          .ref
          .getDownloadURL();
    }
  }

  errorMessage({String title, String message,buttonText,buttonText2=''}) {
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
                    onPressed: () =>Navigator.pop(context,'cancel'),
                    child: Text('$buttonText', textDirection: TextDirection.rtl)),
                (buttonText2 == '' )?Container():FlatButton(
                    onPressed: () =>Navigator.pop(context,'addImage'),
                    child: Text('$buttonText2', textDirection: TextDirection.rtl)),
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
        hintText = '',
        maxLines = 1,
        number = 3,
        isNecessary = true,
        elementNumber=0
      }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[

        Padding(
          padding: const EdgeInsets.only(top:10.0),
          child: TextFormField(

            // ignore: missing_return
            validator: (value){

             try{
               if(value.isEmpty){
                 var result;
                 // elementNumber starts at unit1Quantity
                 switch(elementNumber){

                   case 0:{
                     (isNecessary)?result= message:result=null;
                     break;
                   }
                   case 1:
                     { // for unit 1 quantity
                       (_unit2QuantityController.text.isEmpty && _unit3QuantityController.text.isEmpty)?  result = message : result = null;
                       break;
                     }
                   case 2:
                     { // for unit 2 Name
                       (_unit2PriceController.text.isNotEmpty || _unit2Fact.text.isNotEmpty || _unit2QuantityController.text.isNotEmpty)?  result = message : result = null;
                       break;
                     }
                   case 3:
                     { // for unit 2 price
                       ( _unitNameController2.text.isNotEmpty || _unit2Fact.text.isNotEmpty)?  result = message : result = null;
                       break;
                     }
                   case 4:
                     { // for unit 2 Fact
                       ( _unitNameController2.text.isNotEmpty || _unit2PriceController.text.isNotEmpty)?  result = message : result = null;
                       break;
                     }
                   case 5:
                     {  // for unit 3 Name
                       (_unit3PriceController.text.isNotEmpty || _unit3Fact.text.isNotEmpty || _unit3QuantityController.text.isNotEmpty)?  result = message : result = null;
                       break;
                     }
                   case 6:
                     { // for unit 3 price
                       ( _unitNameController3.text.isNotEmpty || _unit3Fact.text.isNotEmpty)?  result = message : result = null;
                       break;
                     }
                   case 7:
                     { // for unit 3 Fact
                       ( _unitNameController3.text.isNotEmpty || _unit3PriceController.text.isNotEmpty)?  result = message : result = null;
                       break;
                     }
                 }
                 return result;
               }
             }catch(e){
               return null;
             }

            },



            focusNode: focusNode,
            onFieldSubmitted: (v){
              switch(number){
                case 0:{
                  markFocus.requestFocus();
                  break;
                }
                case 1:{
                  DescriptionFocus.requestFocus();
                  break;
                }
              }
            },

            maxLines: maxLines,

            obscureText: obscureText,
            controller: controller,
            textInputAction:
            (action == 'done') ? TextInputAction.done : TextInputAction.next,


            keyboardType: getKeyboardType(type),
            decoration: InputDecoration(
                labelText: label,
                // labelStyle: TextStyle(
                //     fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87),

                hintText: hintText,
                contentPadding:
                EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[400]),
                ),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[400]))),
            // textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          height: 0,
        )
      ],
    );
  }

  getKeyboardType(type){

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
      case 'number':
        {
          return TextInputType.number;
        }
      case 'quantity':
        {
          return TextInputType.numberWithOptions();

        }
    }
  }

}