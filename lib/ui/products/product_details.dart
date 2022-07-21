import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:store/ui/helpers_widgets/helper2.dart';
import 'package:store/ui/home/home_page.dart';
import 'package:store/ui/my_cart/my_cart.dart';
import 'package:store/ui/products/manage_products.dart';
import 'package:store/ui/products/show_image.dart';

class ProductDetails extends StatefulWidget {
  var obj;
  var userLevel;
  var comingFrom;
  var store_ID; // only for back to my Cart

  ProductDetails({this.obj, this.userLevel,this.comingFrom,this.store_ID});

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  var currentUser;
  bool _isLoading = false;
  List dropdownList=[];
  var title = 'أختر الوحدة';
  int unitIndex;
  String state='';
  var priceWithQuantity;
  var factorNumber=1.0;

  TextEditingController _quantityController;

  double unitPrice=0.0;

  var price;
  double multiple= 1;
  double finalResult;

  final GlobalKey<ScaffoldState> snack = GlobalKey<ScaffoldState>();

  Future<bool>_onBackButtonPressed() async{
    Navigator.pushReplacement(context, MaterialPageRoute(builder:(widget.comingFrom =='MyCart')? (context) => MyCart(userLevel: widget.userLevel,store_id: widget.store_ID,) : (context) => HomePage()));
  }


  @override
  void initState() {
    price = widget.obj['unit_price1'].toString();
    finalResult = double.parse(price);

    // to load the data to list for dropdownlist for units
    for(int i = 1;i<=3;i++){
      if(widget.obj['unit_name$i'].toString().isNotEmpty && widget.obj['unit_name$i'].toString().length>0){
        dropdownList.add('${widget.obj['unit_name$i']}');
      }else{
        state +='${i-1}';
      }
    }

    _quantityController = new TextEditingController();


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: WillPopScope(
        onWillPop: _onBackButtonPressed,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
              key: snack,

              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  onPressed: () =>_onBackButtonPressed(),
                  icon: Icon(
                    Icons.arrow_forward_ios_sharp,
                    // color: kIconColor,
                    color: Color(0xFF03A9F4),
                  ),
                ),
                brightness: Brightness.dark,

                // the title will be the sub category
                title: Text("${(widget.obj['sub_cate_name'].toString().isNotEmpty)?widget.obj['sub_cate_name'].toString() : 'التفاصيل'}",
                    style: TextStyle(fontSize: 18.0, color: Color(0xFF03A9F4),fontWeight: FontWeight.w700)),
                centerTitle: true,
              ),


              body: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),

                child:Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Product Name
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          '${widget.obj['pro_name']}',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            color: kIconColor
                          ),
                        ),
                      ),

                      SizedBox(height: kDefaultPadding),

                      // Product Image
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ShowImage(imgUrl: widget.obj['pro_imgUrl'].toString(),))),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(kDefaultPadding),
                          child: CachedNetworkImage(
                            width: size.width - (kDefaultPadding * 2),
                            height: MediaQuery.of(context).size.height * 0.60,
                            fit: BoxFit.fill,
                            imageUrl: widget.obj['pro_imgUrl'].toString(),
                            placeholder:(context, url) => Center(child: CircularProgressIndicator(),),
                          ),
                        ),
                      ),

                      SizedBox(height: kDefaultPadding),

                      // Price
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "\$" +'${double.parse(price) * multiple}',

                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: kTextColor
                              ),
                            ),
                            Text(
                              'الكمية في المخزن : ${widget.obj['all_quantity']}',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: kTextColor
                              ),
                            ),

                          ],
                        ),
                      ),

                      SizedBox(height: kDefaultPadding),

                      // Description
                      Text(
                        '${widget.obj['pro_description']}',
                        style: TextStyle(
                            color: kTextLightColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w700
                        ),
                      ),

                      SizedBox(height: 30),

                      // Dropdown List
                      Row(
                        children: [

                          // for unit
                          Expanded(
                            flex: 3,
                            child:Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(kDefaultPadding * 2.5),
                                  border: Border.all(color: kIconColor)
                              ),
                              padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
                              alignment: Alignment.center,
                              child:  DropdownButton(
                                underline: Container(),
                                hint: Center(child: Text('$title')),
                                items: dropdownList.map((unit_name) {

                                  if(unit_name!=0){
                                    return new DropdownMenuItem(
                                      value: unit_name,
                                      child: new Text('$unit_name'),
                                    );
                                  }


                                }).toList(),
                                onChanged: (v) {
                                  setState(() {
                                    title = v;
                                    unitIndex = dropdownList.indexOf(v);
                                    switch(unitIndex){
                                      case 0:{
                                        price = widget.obj['unit_price1'].toString();
                                        // to get the selected unit price
                                        unitPrice = double.parse(widget.obj['unit_price1'].toString());
                                        factorNumber =1.0;
                                        break;
                                      }
                                      case 1:{
                                        // for unit 2
                                        if(state == '' || state =='2') {
                                          price = widget.obj['unit_price2'].toString();
                                          // to get the selected unit price
                                          unitPrice = double.parse(widget.obj['unit_price2'].toString());
                                          factorNumber = double.parse(widget.obj['unit_fact2']);
                                        }
                                        else if( state == '1'){
                                          factorNumber = double.parse(widget.obj['unit_fact3']);
                                          price = widget.obj['unit_price3'].toString();
                                          // to get the selected unit price
                                          unitPrice = double.parse(widget.obj['unit_price3'].toString());

                                        }
                                        break;
                                      }
                                      case 2:{
                                        price = widget.obj['unit_price3'].toString();
                                        factorNumber = double.parse(widget.obj['unit_fact3']);
                                        // to get the selected unit price
                                        unitPrice = double.parse(widget.obj['unit_price3'].toString());
                                        break;
                                      }
                                    }
                                  });

                                },

                              ),
                            ),


                          ),

                          SizedBox(width: kDefaultPadding),

                          // for quantity of request
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(kDefaultPadding * 2.5),
                                  border: Border.all(color: kIconColor)
                              ),
                              padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
                              child: TextField(
                                controller: _quantityController,
                                maxLength: 4,
                                onChanged: (value){
                                  if(value.toString() == '0'){
                                    _quantityController.clear();
                                  }else {
                                    double result = (value.isNotEmpty) ? double
                                        .parse(value) : 1;
                                    setState(() {
                                      multiple = result;
                                      finalResult =
                                          double.parse(price) * multiple;
                                    });
                                  }
                                },
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'عدد الكمية',
                                  border: InputBorder.none,
                                  counterText: '',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: kDefaultPadding),

                      // Cart Button

                      getButton(quantity:widget.obj['all_quantity']),

                    ],
                  ),
                ),



              )),
        ),
      ),
    );
  }


  getSnackBar({title,second,size}){
    snack.currentState.showSnackBar(
        SnackBar(
          padding: EdgeInsets.only(right: 20),
          content: Text('$title',style: TextStyle(
              fontFamily: 'ElMessiri'
          ),),
          duration: Duration(
              seconds: second
          ),

        )
    );
  }

  Widget getButton({quantity}) {
    final user_level = widget.userLevel;

    // for admins
    if (user_level >= 0 && user_level <= 1) {
      return Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(
          top: 10,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: kDefaultPadding,
          vertical: kDefaultPadding / 2,
        ),
        decoration: BoxDecoration(
          color: Color(0xFF03A9F4),
          // color: Color(0xFFA42470),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              //Delete Button
              FlatButton(
                onPressed: () async {

                  // for only admin
                  if(user_level>=0 && user_level <=1) {
                    var result = await confirmDeletion();

                    if (result == 'delete') {
                      setState(() => _isLoading = true);
                      await Firestore.instance
                          .collection('products')
                          .document(widget.obj.documentID)
                          .delete();
                      setState(() => _isLoading = false);
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => HomePage()));
                    }
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("حذف"),
                    Padding(padding: EdgeInsets.only(left: 15)),
                    Icon(Icons.delete_forever),
                  ],
                ),
                textColor: Colors.white,
              ),
              Spacer(),

              //Update Button
              FlatButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ManageProducts(state:'Update_Product' ,obj: widget.obj,userLevel: widget.userLevel,)));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("تعديل"),
                    Padding(padding: EdgeInsets.only(left: 15)),
                    Icon(Icons.edit),
                  ],
                ),
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      );
    }

    else if(user_level == 2){ // for employee admin level 2
      return InkWell(
        onTap: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ManageProducts(state:'Update_Product' ,obj: widget.obj,userLevel: widget.userLevel,)));
        },
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            // color: Color(0xFFA42470),
            color: Color(0xFF03A9F4),
          ),

          padding: EdgeInsets.symmetric(vertical: 20),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit,color: Colors.white),
              Padding(padding: EdgeInsets.only(left: 15)),
              Text("تعديل",style: TextStyle(
                  color: Colors.white,
                  fontSize: 16
              ),),


            ],
          ),
        ),
      );
    }
    else  {
      // For  Stores & Visitors

      return InkWell(
        onTap: () async{
          try{
            requestedButtonProcess(quantity: quantity);
          }catch(e){
            setState(() =>_isLoading =false);
          }
        },
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            // color: kPrimaryColor,
            color: Color(0xFF03A9F4),
          ),

          padding: EdgeInsets.symmetric(vertical: 20),
          alignment: Alignment.center,
          child: Text(
            (user_level >= 3 && user_level <= 4)
                ? 'أضف إلى سلتي'
                : "الرجوع الى الصفحة الرئيسية",
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
      );

    }
  }
  
  // for request a single product and navigated into the cart 
  requestedButtonProcess({quantity}) async{
    // for level 3,4 and 5

    try{
      final user_level = widget.userLevel;

      if (user_level >= 3 && user_level <= 4) {
        // For Store Admins & Employees to add to cart

        if(title != 'أختر الوحدة'){


          var allQuntity = double.parse(quantity.toString());

          var quantityOfUnit = factorNumber;
          var requestedNumber = (_quantityController.text.isNotEmpty)?double.parse(_quantityController.text):1.0;

          // to make the request in the unit one it mean with 1 piece  
          var requestedQuantity = double.parse(quantityOfUnit.toString())  * requestedNumber;


          // to check the quantity is it allowed or not 
          if(requestedQuantity<=allQuntity && allQuntity != 0 && requestedQuantity>0){

            setState(()=>_isLoading=true);

            var user = await FirebaseAuth.instance.currentUser();
            var userInfo = await Firestore.instance.collection('users').document(user.uid).get();
            var storeId = (user_level==3)? userInfo.documentID:userInfo['store_id'];
            var storeLocation = (user_level == 3) ? userInfo['location']:userInfo['store_location'] ;
            var store_imgUrl = '';
            var store_phone_number = '';
            var requestedQuntity=1.0;
            var numberOfQuntity= _quantityController.text.isNotEmpty? double.parse(_quantityController.text.toString()): 1.0;

            requestedQuntity = factorNumber * numberOfQuntity;


            // for store imgUrl
            if(user_level == 3){
              store_imgUrl = userInfo['imgUrl'];
              store_phone_number = userInfo['phone_number'];
            }
            else if(user_level == 4){
              var storeAccount = await Firestore.instance.collection('users').document(storeId).get();
              store_imgUrl = storeAccount['imgUrl'];
              store_phone_number = storeAccount['phone_number'];
            }

            // to add it to shopping cart
            // -------------- To check if the cart bill is exist or not --------------------

            var checkingCart = await Firestore.instance.collection('shopping_cart').document(storeId).collection('Requests').where('is_bill',isEqualTo: false).getDocuments();

            if(checkingCart != null && checkingCart.documents.length>0){

              // to prevent the repetition of request
              var theBillID = checkingCart.documents[0].documentID;
              var isRepetition = await Firestore.instance.collection('shopping_cart')
                  .document(storeId).collection('Requests').document('$theBillID')
                  .collection('$theBillID').where('pro_id',isEqualTo: widget.obj.documentID)
                  .where('unit_name',isEqualTo: title)
                  .where('unit_fact',isEqualTo: factorNumber).getDocuments();

              // to check if the request is already in the cart
              if(isRepetition != null && isRepetition.documents.length>0){
                // when the request is already in the cart
                setState(() =>_isLoading=false);
                getSnackBar(title: 'هذا الطلب موجود مسبقا في السلة، سيتم زيادة الكمية لهذا المنتج في السلة',second: 2,size: 10.0);
                // notification(title: 'الطلب موجود مسبقا',message: 'هذا الطلب موجود مسبقا في السلة، سيتم زيادة الكمية لهذا المنتج في السلة',firstButton: 'موافق');
                setState(() =>_isLoading=true);

                await Firestore.instance.collection('shopping_cart')
                    .document(storeId).collection('Requests').document('$theBillID')
                    .collection('$theBillID').document(isRepetition.documents[0].documentID).get().then((repeatedRequest) {

                      var oldRequestedQuantity = repeatedRequest['requested_quantity'];
                      var oldTotalPrice = repeatedRequest['total_price'];

                      var newRequestedQuantity = oldRequestedQuantity + requestedQuntity;
                      var newTotalPrice = oldTotalPrice + finalResult;


                       Firestore.instance.collection('shopping_cart')
                          .document(storeId).collection('Requests').document('$theBillID')
                          .collection('$theBillID').document(isRepetition.documents[0].documentID).updateData({
                         'requested_quantity': newRequestedQuantity,
                         'total_price':newTotalPrice

                       }).then((_) {
                         setState(() =>_isLoading=false);
                         getSnackBar(title: 'تم زيادة هذا المنتج إلى سلتك ؛ الرجاء تأكيد الطلب من واجهة سلتي',second: 2,size: 10.0);
                       });



                });

              }
              else{
              //  when the request is not in the cart it could be in the cart but not in the same unit

                // for add new request
                if(checkingCart.documents.length == 1){
                  var billName = checkingCart.documents[0].documentID;
                  await  Firestore.instance.collection('shopping_cart')
                      .document(storeId).collection('Requests')
                      .document('$billName')
                      .collection('$billName')
                      .add({
                    'pro_id'   : widget.obj.documentID,
                    'pro_name' : widget.obj['pro_name'],
                    'pro_mark' : widget.obj['pro_mark'],
                    'unit_price1': widget.obj['unit_price1'],
                    'requested_date': DateTime.now(),
                    'requested_user': user.uid,
                    'pro_imgUrl' : widget.obj['pro_imgUrl'],
                    'top_cate_id' : widget.obj['top_cate_id'],
                    'sub_cate_id' : widget.obj['sub_cate_id'],
                    'sub_cate_name' : widget.obj['sub_cate_name'],
                    'unit_name' : title,
                    'unit_fact' : factorNumber,
                    'unit_price' : unitPrice,
                    'requested_quantity' : requestedQuntity,
                    'total_price':finalResult,
                    'state': 'notConfigured',
                    'has_delivered':false,
                    'is_confirm' : false,
                    'is_accepted': false
                  });
                  setState(() =>_isLoading =false);
                  getSnackBar(title: 'تم تحويل هذا المنتج إلى سلتك ؛ الرجاء تأكيد الطلب من واجهة سلتي',second: 2,size: 10.0);
                }

              }

              



            }
            else{
              // when the cart doesn't exist
              var billNumber = await getBillNumber();
              billNumber++;

              await Firestore.instance.collection('shopping_cart').document(storeId).setData({
                'store_name': userInfo['store_name'],
                'store_location':storeLocation,
                'store_imgUrl' : store_imgUrl,
                'store_phone_number' : store_phone_number,
                'is_active' : true,
                'is_completed' : false,
              }).then((value) {

                Firestore.instance.collection('shopping_cart').document(storeId).collection('Requests').document('$billNumber').collection('$billNumber').add({
                  'pro_id'   : widget.obj.documentID,
                  'pro_name' : widget.obj['pro_name'],
                  'pro_mark' : widget.obj['pro_mark'],
                  'unit_price1': widget.obj['unit_price1'],
                  'requested_date': DateTime.now(),
                  'requested_user': user.uid,
                  'pro_imgUrl' : widget.obj['pro_imgUrl'],
                  'top_cate_id' : widget.obj['top_cate_id'],
                  'sub_cate_id' : widget.obj['sub_cate_id'],
                  'sub_cate_name' : widget.obj['sub_cate_name'],
                  'unit_name' : title,
                  'unit_fact' : factorNumber,
                  'unit_price' : unitPrice,
                  'requested_quantity' : requestedQuntity,
                  'total_price':finalResult,
                  'state': 'notConfigured',
                  'has_delivered':false,
                  'is_confirm' : false,
                  'is_accepted': false
                });

              }).then((_) {
                // to make the cart collection not visible to the admin until i finish the request
                Firestore.instance.collection('shopping_cart').document(storeId).collection('Requests').document('$billNumber').setData({
                  'is_bill':false
                });
              });

              setState(() =>_isLoading =false);
              getSnackBar(title: 'تم تحويل هذا المنتج إلى سلتك ؛ الرجاء تأكيد الطلب من واجهة سلتي',second: 2,size: 10.0);


            }
            setState(() =>_isLoading =false);
          }
          else{
            // for if there's any wrongs with qouantity
            if(requestedQuantity>allQuntity && allQuntity != 0 ){
              // for if the quantity is bigger that the exist quantity
              notification(title: 'الكمية اكبر من الموجود',message: 'الكمية التي ادخلتها أكبر من الموجود لدينا الرجاء تقليل الكمية\nالكمية المدخلة : $requestedQuantity \n الكمية المتوفرة : $allQuntity',firstButton: 'موافق');
            }else if(allQuntity == 0){
              notification(title: 'الكمية اكملت',message:'لاتتوفر كمية لهذا المنتج الرجاء الطلب لاحقاً',firstButton: 'موافق');
            }else if(requestedQuantity<=0){
              notification(title: 'الكمية غير صالحة',message:'الكمية المدخلة غير صالحة الرجاء إدخال كمية اكبر من الصفر !!',firstButton: 'موافق');
            }

          }
        //  end of checking quantity
          
          

        }
        else{
          notification(title: 'لم تحدد الوحدة',message: 'الرجاء تحديد الوحدة المراد الطلب بها',firstButton: 'موافق');
        }

      }
      else {
        //For Visitors
        _onBackButtonPressed();
      }


    }catch(e){
      setState(() =>_isLoading =false);
      notification(title: 'حصل خطأ',message: e,firstButton: 'موافق');
    }
    
  }

  getBillNumber() async {
    var billNumber = 0000;
    int numberOfBills;
    var result =
    await Firestore.instance.collection('bill_number').getDocuments();

    if (result != null && result.documents.length > 0) {
      billNumber = result.documents[0]['billNumber'];
      numberOfBills = result.documents[0]['numberOfBills'];
      billNumber++;
      numberOfBills++;

      Firestore.instance
          .collection('bill_number')
          .document('AUKjX5qGTikqas0SbXNy')
          .updateData({
        'billNumber': billNumber,
        'numberOfBills': numberOfBills,
      });
    }
    return billNumber;
  }

  confirmDeletion() async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: Text("تأكيد عملية الحذف"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text("هل أنت متأكد من انك تريد حذف هذا المنتج"),
                  ],
                ),
              ),
              actions: [
                FlatButton(
                    onPressed: () =>Navigator.pop(context,'cancel'),
                    child: Text("إلغاء",style: TextStyle(
                      color: Color(0xFF363636),
                    ),)),
                FlatButton(
                    onPressed: ()=> Navigator.pop(context,'delete'),
                    child: Text("حذف",style: TextStyle(color: Colors.redAccent),)),
              ],
            ),
          );
        });
  }

  notification({title,message,firstButton}) async {
    return showDialog(
        context: context,
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: Text('$title'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text('$message'),
                  ],
                ),
              ),
              actions: [
                FlatButton(
                    onPressed: () =>Navigator.pop(context,'firstButton'),
                    child: Text("$firstButton",style: TextStyle(
                      color: Color(0xFF363636),
                    ),)),
              ],
            ),
          );
        });
  }


}
