import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:store/ui/helpers_widgets/constantHelpers.dart';
import 'package:store/ui/reporting/models/customer.dart';
import 'package:store/ui/reporting/models/invoice.dart';
import 'package:store/ui/reporting/models/supplier.dart';
import 'package:store/ui/reporting/pdf_api.dart';
import 'package:store/ui/reporting/pdf_invoice_api.dart';


class BillDetails extends StatefulWidget {

  var userLevel;
  var store_id;
  var billNumber;
  var state;

  BillDetails({this.store_id, this.userLevel,this.billNumber, this.state});

  @override
  _BillDetailsState createState() => _BillDetailsState();
}

class _BillDetailsState extends State<BillDetails> {

  TextEditingController _searchController = new TextEditingController();
  bool _isFloatingButtonShown = true;
  ScrollController _scrollController = new ScrollController();
  bool isFAB = false;
  var floatingButtonTitle;
  var searchCase;
  var searchedKey;
  // To get the content of all stages
  var stream;
  // For button titles
  // for end-user
  final confirmTitle = 'تأكيد الطلب';
  final cancelRequestTitle = 'إلغاء الطلب';
  final cancelAllTitle = 'إلغاء الكل';
  final deliveringTitle = 'جاري التسليم';
  final doneDeliveringTitle = 'تم التسليم';
  final requestAgainTitle = 'إعادة الطلب';
  // for admins
  final acceptRequestTitle = 'قبول الطلب';
  final deleteFromScreen = 'حذف من القائمة';
  List<InvoiceItem> items;
  final subTaps = ['منتظرة', 'جاري التسليم', 'تم التسليم', 'المرفوضات'];

  // to determined wheather the subtitle is cart or my requests
  int categoryIndex = 0;

  // for Managemet of Carts
  var manage_title = 'قبول الطلب';
  var manage_title_after_accepted = '... إلغاء الطلب';

  int selectedIndex = 0;
  int selectedIndexForSubTabs = 0;
  double marginNumber = 10;
  bool _isLoading = false;
  final GlobalKey<ScaffoldState> snack = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    // to load all waiting in the first time
    stream = Firestore.instance
        .collection('shopping_cart')
        .document(widget.store_id)
        .collection('Requests')
        .document('${widget.billNumber}')
        .collection('${widget.billNumber}')
        .where('is_confirm',isEqualTo: true )
        .where('state',isEqualTo: 'waiting')
        .where('is_accepted',isEqualTo: false )
        .where('has_delivered',isEqualTo: false)
        .snapshots();

    (widget.state.toString() != 'Manage_Cart')?floatingButtonTitle = cancelAllTitle:floatingButtonTitle = acceptRequestTitle;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: SafeArea(
        bottom: false,
        child: Directionality(
          textDirection:TextDirection.rtl ,
          child: Scaffold(
            key: snack,
            backgroundColor: kSecondaryColorBG,
            appBar: AppBar(
              elevation: 0,
              title:Text( 'تفاصيل الفاتورة ${widget.billNumber}',style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),),

              centerTitle: true,
              leading: IconButton(icon:Icon(Icons.arrow_back_ios,color: Colors.white,),onPressed: ()=>Navigator.pop(context),),
            ),

            body: Column(
              children: [
                // for total bill price
                StreamBuilder(
                  stream: Firestore.instance.collection('shopping_cart').document(widget.store_id).collection('Requests').document('${widget.billNumber}').collection('${widget.billNumber}').snapshots(),
                  builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snap){
                    if(snap.hasData && snap.data.documents.length>0){
                      var allP =0.0;
                      for(int i = 0; i < snap.data.documents.length; i++){
                        allP += (double.parse(snap.data.documents[i]['unit_price'].toString()) * double.parse(snap.data.documents[i]['requested_quantity'].toString()));
                      }
                      return Text('إجمالي سعر الفاتورة : $allP',style: TextStyle(color: Colors.white),);
                    }else{
                      return Text('');
                    }
                  },
                ),

                // Fot Search Box ==> TextField
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Container(
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
                        hintText: "ابـحـث هـنـا",
                        prefixIcon: IconButton(
                          icon: Icon(Icons.clear,color: Colors.white,),
                          onPressed: (){
                            setState(() {
                              _searchController.clear();
                            });
                          },
                        ),
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),


                // For Tabs

                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
                    height: 30,
                    child: getSubCategory(),
                  ),
                ),

                // For the rest of the screen
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Expanded(
                    child: Stack(
                      children: [
                        // The background from under the tabs until the bottom of the page
                        Container(
                          margin: EdgeInsets.only(top: marginNumber),
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
                            stream: stream,
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data.documents.length > 0) {
                                return ListView(
                                  controller: _scrollController,
                                  children: snapshot.data.documents
                                      .map((DocumentSnapshot document) {
                                    if (document['$searchCase']
                                        .toString()
                                        .contains(_searchController.text)) {
                                      final showedTitle = getTitle(document).toString();
                                      final allPrice = double.parse(document['unit_price'].toString()) * double.parse(document['requested_quantity'].toString());
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

                                              // to delete the order
                                              getDeletedIcon(document),

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

                                                      // request name
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


                                                      // request quntity
                                                      Container(
                                                        alignment: Alignment.center,
                                                        margin: EdgeInsets.only(top: 10),
                                                        child: Text(
                                                          'عدد الكمية : ${getQuantityWithoutDots(document['requested_quantity'])}',
                                                          style: TextStyle(
                                                            fontSize: 10
                                                          ),
                                                        ),
                                                      ),

                                                      // for price
                                                      Container(
                                                        alignment: Alignment.center,
                                                        child: Text(
                                                          ' السعر : $allPrice',
                                                          style: TextStyle(
                                                              fontSize: 10
                                                          ),
                                                        ),
                                                      ),



                                                      // For Confirm Button
                                                      Spacer(),
                                                      InkWell(
                                                        onTap: () =>confirmButtonProcess(document),
                                                        child: Container(
                                                          padding: EdgeInsets.symmetric(
                                                            horizontal:
                                                            kDefaultPadding * 1.5,
                                                            vertical:
                                                            kDefaultPadding / 4,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            // color: kSecondaryColor,
                                                            color: Colors.redAccent,
                                                            borderRadius:
                                                            BorderRadius.only(
                                                              bottomLeft:
                                                              Radius.circular(22),
                                                              topRight:
                                                              Radius.circular(22),
                                                            ),
                                                          ),

                                                          // for title

                                                          child: Text('${getConfirmButtonText(allPrice)}',style: TextStyle(
                                                            color: Colors.white,
                                                          ),),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        onTap: () {
                                          // this code will perform when you click on any product

                                        },
                                      );
                                    } else {
                                      return Text("");
                                    }
                                  }).toList(),
                                );
                              } else {
                                return Center(
                                    child: Text(
                                      getText(selectedIndexForSubTabs),
                                      style: TextStyle(color: kIconColor, fontSize: 15),
                                    ));
                              }
                            }),

                        (_isFloatingButtonShown)?Positioned(
                          bottom: 10,
                          right: 20,
                          child: Container(
                            child: isFAB ? Directionality(textDirection: TextDirection.rtl,child: buildFAB()) : Directionality(textDirection: TextDirection.rtl,child: buildExtendedFAB()),
                          ),
                        ):Container(),
                      ],
                    ),
                  ),
                ),




              ],
            ),
          ),
        ),
      ),
    );
  }
  
  getQuantityWithoutDots(number){
    var regex = RegExp(r"([.]*0)(?!.*\d)");

    String finalQuantityResult = number.toString().replaceAll(regex, "");

    return finalQuantityResult;

  }

  Widget buildExtendedFAB() => AnimatedContainer(
    // color: kPrimaryColor,

    duration: Duration(milliseconds: 200),
    curve: Curves.linear,
    width: 150,
    height: 50,
    child: InkWell(
      onTap: () => allFloatingButton(),
      child: Container(

        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          // color: kPrimaryColor,
          color: kSecondaryColorBG,
        ),
        padding: EdgeInsets.symmetric(vertical: 10),
        width: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit,color: Colors.white,),
            SizedBox(width: 10,),
            Center(
              child: Text(
                '$floatingButtonTitle',
                style: TextStyle(fontSize: 15, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  Widget buildFAB() => AnimatedContainer(

    duration: Duration(milliseconds: 200),

    curve: Curves.linear,
    width: 50,
    height: 50,
    child: Container(

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        // color: kPrimaryColor,
        color: kSecondaryColorBG,
      ),
      child: IconButton(
        onPressed: () =>allFloatingButton(),
        icon: Icon(Icons.edit,color: Colors.white,),

      ),
    ),
  );

  confirmButtonProcess(document) async{
    //  for declined requests for admin
    if(widget.state.toString() =='Manage_Cart' && selectedIndexForSubTabs==3 && widget.userLevel<=1){
      var result = await confirmCancelling(
          title: 'التراجع عن الرفض',
          content: 'هل تريد فعلاً التراجع عن الرفض ؟',
          firstButton: 'لا',
          secondButton: 'نعم');


      if(result.toString() == 'secondButton'){
        setState(() =>_isLoading=true);
        await Firestore.instance.collection('shopping_cart').document(widget.store_id)
            .collection('Requests').document('${widget.billNumber}')
            .collection('${widget.billNumber}')
            .document(document.documentID).updateData({
          'is_confirm':true,
          'is_accepted':false,
          'state':'waiting',
          'has_delivered':false
        });
        setState(() =>_isLoading=false);
      }

    }
    else if(widget.state.toString() == 'Manage_Cart' && selectedIndexForSubTabs==1){
      var result = await confirmCancelling(
          title: 'تم تسليم الطلب',
          content: 'هل  فعلاً تم تسليم هذا الطلب ؟\n إذا كان كذلك سيتم ترحيل هذا الطلب إلى قائمة تم التسليم',
          firstButton: 'إلغاء',
          secondButton: 'تم التسليم');
      if(result.toString() == 'secondButton'){
        setState(() =>_isLoading=true);
        await Firestore.instance.collection('shopping_cart').document(widget.store_id)
            .collection('Requests').document('${widget.billNumber}').collection('${widget.billNumber}')
            .document(document.documentID).updateData({
          'state':'done',
          'has_delivered':true

        }).then((_) async{
          await isBillCompleted();
        });
        setState(() => _isLoading = false);
      }
    }
  }

  cancelButtonForRequest(document) async{

    var db = Firestore.instance
        .collection('shopping_cart')
        .document(widget.store_id)
        .collection('Requests')
        .document('${widget.billNumber}')
        .collection('${widget.billNumber}')
        .document(document.documentID);
    var result ='';


    if(widget.state.toString() == 'Manage_Cart'){
      if(selectedIndexForSubTabs == 0 ){
        result = await confirmCancelling(
            title: 'رفض الطلب',
            content: 'هل تريد فعلاً رفض هذا الطلب ؟',
            firstButton: 'إلغاء',
            secondButton: 'رفض الطلب');
      }else if(selectedIndexForSubTabs == 1 ){
        result = await confirmCancelling(
            title: 'إسترجاع الطلب',
            content: 'هل تريد فعلاً إسترجاع هذا الطلب ؟\nعلماً بأنة سيتم إرجاع الكمية الى المخزن!!',
            firstButton: 'إلغاء',
            secondButton: 'إسترجاع الطلب');
      }else if(selectedIndexForSubTabs == 2 ){
        result = await confirmCancelling(
            title: 'رجوع إلى قائمة جاري التسليم',
            content: 'هل تريد فعلاً إرجاع هذا الطلب إلى قائمة جاري التسليم؟',
            firstButton: 'إلغاء',
            secondButton: 'إرجاع');
      }else if(selectedIndexForSubTabs == 3 ){
        result = await confirmCancelling(
            title: 'رجوع إلى قائمة جاري التسليم',
            content: 'هل تريد فعلاً إرجاع هذا الطلب إلى قائمة جاري التسليم؟',
            firstButton: 'إلغاء',
            secondButton: 'إرجاع');
      }

      if (result == 'secondButton') {

        if(selectedIndexForSubTabs == 0){
         await  db.updateData({
            'state':'declined',
            'is_accepted':false,
            'has_delivered': false
          }).then((_) => isBillCompleted());
        }else if(selectedIndexForSubTabs == 1){
          setState(() =>_isLoading=true);

          var requestedQuantity = document['requested_quantity'];
          var product = await Firestore.instance.collection('products').document(document['pro_id']).get();
          if(product != null){
            var allProductQuantity = product['all_quantity'];
            var finalQuntity = allProductQuantity + requestedQuantity;
            db.delete();
            Firestore.instance.collection('products').document(document['pro_id']).updateData({
              'all_quantity':finalQuntity
            });
          }
          setState(() =>_isLoading=false);
        }else if(selectedIndexForSubTabs == 2){
          db.updateData({
            'state':'delivering',
            'is_accepted':true,
            'has_delivered': false
          });
        }else if(selectedIndexForSubTabs == 3){
          db.delete();
        }
      }

    }

  }

  toRemoveRepetitionAfterCancelingRequest({QuerySnapshot oldBill,newBillID,oldBillID}) async {
  //   when the new bill have requests

    if(oldBill!= null && oldBill.documents.length>0){
      setState(() =>_isLoading = true);
      bool isDone = false;


      for(int i = 0; i<oldBill.documents.length; i++){
        var request = oldBill.documents[i];

        // to check if the request exist
        var isDuplicated = await Firestore.instance.collection('shopping_cart').document('${widget.store_id}')
            .collection('Requests').document('${newBillID}').collection('${newBillID}')
            .where('pro_id',isEqualTo: request['pro_id'])
            .where('unit_name',isEqualTo: request['unit_name'])
            .where('unit_fact',isEqualTo: request['unit_fact']).getDocuments();

        if(isDuplicated != null && isDuplicated.documents.length>0){
          //  if the request is exist
          var finalRequestsQuantity = request['requested_quantity'] + isDuplicated.documents[0]['requested_quantity'];
          var finalTotalPrice = request['total_price'] + isDuplicated.documents[0]['total_price'];

          await Firestore.instance.collection('shopping_cart').document(widget.store_id)
              .collection('Requests').document('$newBillID').collection('$newBillID')
              .document(isDuplicated.documents[0].documentID).updateData({
            'requested_quantity' : finalRequestsQuantity,
            'total_price' : finalTotalPrice
          });
          isDone = true;

        }else{
          //  if the request is not exist in the new bill
          await Firestore.instance.collection('shopping_cart').document(widget.store_id)
              .collection('Requests').document('$newBillID').collection('$newBillID')
              .add(request.data).then((value) {
            value.updateData({
              'is_confirm' : false,
              'state' : 'notConfigured'
            });
          });

          isDone = true;

        }

        if(i== oldBill.documents.length - 1){
          if(isDone) {
            await removeCanceledBill(oldBillID);
          }
        }


      }


      setState(() =>_isLoading = false);
    }
  }

  removeCanceledBill(oldBillID)async{
    await Firestore.instance.collection('shopping_cart').document(widget.store_id)
        .collection('Requests').document('$oldBillID').delete();
  }

  allFloatingButton() async{

    try{
      if(widget.state.toString() == 'Manage_Cart'){
        // for admins
        var result ;
        var hasQuantity = false;

        if(selectedIndexForSubTabs == 0 && widget.state.toString() == 'Manage_Cart'){
          result = await confirmCancelling(title: 'قبول الكل',content: 'هل أنت متأكد من أنك تريد قبول كل هذه الطلبات',firstButton: 'إلغاء',secondButton: 'قبول الكل');
        }
        else if(selectedIndexForSubTabs == 1 && widget.state.toString() == 'Manage_Cart'){
          result = await confirmCancelling(title: 'تسليم الكل',content: 'هل أنت متأكد من أنك تريد تسليم كل هذه الطلبات',firstButton: 'إلغاء',secondButton: 'تسليم الكل');
        }
        else if(selectedIndexForSubTabs == 2 && widget.state.toString() == 'Manage_Cart'){
          result = await confirmCancelling(title: 'حذف الكل',content: 'هل أنت متأكد من أنك تريد حذف كل هذه الطلبات',firstButton: 'إلغاء',secondButton: 'حذف الكل');
        }
        else if(selectedIndexForSubTabs == 3 && widget.state.toString() == 'Manage_Cart'){
          result = await confirmCancelling(title: 'قبول الكل',content: 'هل أنت متأكد من أنك تريد قبول كل هذه الطلبات',firstButton: 'إلغاء',secondButton: 'قبول الكل');
        }

        //if he confirm the process
        if (result == 'secondButton') {
          setState(() =>_isLoading=true);

          // to get all requests of the all states
          var requests= await Firestore.instance.collection('shopping_cart')
              .document(widget.store_id)
              .collection('Requests')
              .document('${widget.billNumber}')
              .collection('${widget.billNumber}')
              .where('is_confirm',isEqualTo:true )
              .where('state',isEqualTo: getState())
              .where('is_accepted',isEqualTo: (selectedIndexForSubTabs == 0 || selectedIndexForSubTabs == 3 ) ? false : true)
              .where('has_delivered',isEqualTo: (selectedIndexForSubTabs == 2)?true : false)
              .getDocuments();


          if(requests != null && requests.documents.length>0){

            if(selectedIndexForSubTabs == 1 || selectedIndexForSubTabs == 2){

              if(selectedIndexForSubTabs == 1){
                setState(() =>_isLoading=true);

                for(int i = 0; i<requests.documents.length; i++){
                  var request = requests.documents[i];
                 await Firestore.instance.collection('shopping_cart').document(widget.store_id).collection('Requests')
                      .document('${widget.billNumber}').collection('${widget.billNumber}')
                      .document(request.documentID).updateData({
                    'is_confirm':true,
                    'is_accepted':true,
                    'state':'done',
                    'has_delivered':true
                  });

                 if(i== requests.documents.length -1){


                   await Firestore.instance.collection('shopping_cart').document(widget.store_id).collection('Requests')
                       .document('${widget.billNumber}').updateData({
                     'is_delivered' : true
                   });
                 }
                }

                await isStoreCompleted();

              }
              else{
                setState(() =>_isLoading=true);
                requests.documents.map((request){
                  Firestore.instance.collection('shopping_cart').document(widget.store_id).collection('Requests').document(request.documentID).delete();
                }).toList();
              }
              setState(() =>_isLoading=false);
            }
            else if(selectedIndexForSubTabs == 0 ){
              

              await acceptAllRequests(requests);
              printAcceptedBill(widget.store_id, widget.billNumber);

            }

          }

        }

      }
      else{
        
        //   for single end-user
        // for cancel button
        if(selectedIndexForSubTabs == 0 && widget.state.toString() != 'Manage_Cart'){

          var result = await confirmCancelling(title: 'إلغاء الكل',content: 'هل أنت متأكد من أنك تريد إلغاء كل هذه المنتجات',firstButton: 'لا',secondButton: 'إلغاء الكل');
          if(result == 'secondButton'){

            setState(()=> _isLoading=true);

            // to load all waiting requests
            var requests = await Firestore.instance
                .collection('shopping_cart')
                .document(widget.store_id)
                .collection('Requests')
                .document('${widget.billNumber}')
                .collection('${widget.billNumber}')
                .where('is_confirm',isEqualTo: true)
                .where('state',isEqualTo: 'waiting')
                .where('is_accepted',isEqualTo: false)
                .where('has_delivered',isEqualTo: false)
                .getDocuments();


            // to check if there's a collection where is_bill field is false to but the deleted requests on it
            // if there's any is_bill => false it will add all these requests on it
            // if there's no  is_bill => false it will change the current collection is_bill = false & will change the states of the requests to fit the cart

            var isThereAnyNewCart = await Firestore.instance.collection('shopping_cart').document(widget.store_id).collection('Requests').where('is_bill',isEqualTo: false).getDocuments();

            if(isThereAnyNewCart != null && isThereAnyNewCart.documents.length == 1){
              //  there's a new bill exist

              // to get all requests that will navigate to the cart => the old requests
              var allRequests = await Firestore.instance.collection('shopping_cart').document(widget.store_id)
                  .collection('Requests').document('${widget.billNumber}').collection('${widget.billNumber}')
                  .getDocuments();

              // to get the requests in the new bill to prevent repetition
              var newBillRequests = await Firestore.instance.collection('shopping_cart').document(widget.store_id)
                  .collection('Requests').document('${isThereAnyNewCart.documents[0].documentID}').collection('${isThereAnyNewCart.documents[0].documentID}')
                  .getDocuments();
              bool isNewBillHaveRequests = (newBillRequests != null && newBillRequests.documents.length>0)?true:false;

              if(allRequests!=null && allRequests.documents.length>0){
                var newBillID = isThereAnyNewCart.documents[0].documentID;



                // here the main process either exists requests or not

                if(isNewBillHaveRequests){
                  await toRemoveRepetitionAfterCancelingRequest(oldBill:allRequests,oldBillID: widget.billNumber,newBillID:isThereAnyNewCart.documents[0].documentID);

                }
                else{
                  allRequests.documents.map((request){
                    // to add the single request in the collection that the is_bill => false
                    Firestore.instance.collection('shopping_cart').document(widget.store_id)
                        .collection('Requests').document('$newBillID').collection('$newBillID')
                        .add(request.data).then((value) {
                      value.updateData({
                        'is_confirm' : false,
                        'state' : 'notConfigured'
                      });
                    });
                  }).toList();

                  // to delete the bill
                  await Firestore.instance.collection('shopping_cart').document(widget.store_id)
                      .collection('Requests').document('${widget.billNumber}').delete();
                }

              }

              getSnackBar(title: 'تمت إلغاء هذا الطلب سيتم ترحيل هذه الطلبات الى السلة',second: 2);


            }
            else if(isThereAnyNewCart == null || isThereAnyNewCart.documents.length == 0)
            {
              //  there's no cart with is_bill => false
              //  it mean that it will change this bill into is_bill => false


              Firestore.instance.collection('shopping_cart').document(widget.store_id).collection('Requests').document('${widget.billNumber}').updateData({
                'is_bill':false
              }).then((_) async {

                var allRequests = await Firestore.instance.collection('shopping_cart')
                    .document(widget.store_id).collection('Requests')
                    .document('${widget.billNumber}').collection('${widget.billNumber}').getDocuments();

                if(allRequests!=null && allRequests.documents.length>0){
                  allRequests.documents.map((request) {
                    Firestore.instance.collection('shopping_cart').document(widget.store_id).collection('Requests').document('${widget.billNumber}').collection('${widget.billNumber}').document('${request.documentID}').updateData({
                      'is_confirm':false,
                      'is_accepted':false,
                      'has_delivered':false,
                      'state':'notConfigured'
                    });
                  }).toList();
                }


              });

              setState(()=> _isLoading=false);
              getSnackBar(title: 'تمت إلغاء هذا الطلب سيتم ترحيل هذه الطلبات الى السلة',second: 2);


            }


            setState(()=> _isLoading=false);
          }

        }
      }

      
      setState(() =>_isLoading=false);
    }catch(e){
      setState(() =>_isLoading=false);
      print('error');
    }


  }

  alertDialog(title,content) {
    return showDialog(
      context: context,
      builder: (context){
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
              FlatButton(onPressed: (){
                Navigator.pop(context);
              }, child: Text('موافق')),
            ],
          ),
        );
      }
    );
  }


  // it should check it on three states
  // 1- when submit deliver all floating button
  // 2- when submit single delivered button
  // 3- when click the cancel button x
  isBillCompleted() async{

    var result = await Firestore.instance.collection('shopping_cart')
        .document(widget.store_id).collection('Requests')
        .document('${widget.billNumber}').collection('${widget.billNumber}').getDocuments();

    // to check if the single bill is completed or not if completed it will change the is_delivering into true and will called checkIfTheStoreIsComplete function
    if(result != null && result.documents.length>0){
      bool _isCompleted = true;
      for(int i=0; i<result.documents.length;i++){
        var request = result.documents[i];

        // request['has_delivered'] == false && request['state'].toString() == 'waiting' => if in  waiting stage
        // request['has_delivered'] == false && request['state'].toString() == 'delivering' => if in  delivering stage

        if(request['has_delivered'] == false && request['state'].toString() == 'waiting' || request['has_delivered'] == false && request['state'].toString() == 'delivering'){
          _isCompleted = false;
        }
      }

      if(_isCompleted){
        await Firestore.instance.collection('shopping_cart')
            .document(widget.store_id).collection('Requests')
            .document('${widget.billNumber}').updateData({
          'is_delivered' : true
        }).then((_) => isStoreCompleted() );
      }
    }

  }

  isStoreCompleted() async{

    var result = await Firestore.instance.collection('shopping_cart').document(widget.store_id).collection('Requests').where('is_delivered',isEqualTo: false).getDocuments();
    if(result != null && result.documents.length>0){

    }else{
      Firestore.instance.collection('shopping_cart').document(widget.store_id).updateData({
        'is_completed' : true,
      });
    }
  }

  acceptAllRequests(QuerySnapshot requests) async{
    bool hasQuantity = false;

    for(int i=0; i<requests.documents.length; i++){
      // the product of the single request
      var request = requests.documents[i];

      var productID = request['pro_id'];
      var product = await Firestore.instance.collection('products').document(productID).get();
      if(product != null && product.data.length>0){
        var allQuantityOfProduct = double.parse(product['all_quantity'].toString());
        var requestedQuantity = double.parse(request['requested_quantity'].toString());
        var finalQuntity = allQuantityOfProduct-requestedQuantity;
        hasQuantity = true;

        if(hasQuantity && finalQuntity>=0){
          await Firestore.instance
              .collection(
              'shopping_cart')
              .document(
              widget.store_id)
              .collection(
              'Requests').document('${widget.billNumber}')
              .collection('${widget.billNumber}')
              .document(request
              .documentID)
              .updateData({
            'is_accepted': true,
            'state':'delivering'
          });

          // to reduce from products quntity
          await Firestore.instance.collection('products').document(productID).updateData({
            'all_quantity':finalQuntity,
          });
        }
        else if(finalQuntity<0){
          alertDialog('تخطى الكمية', 'المنتج ${product['pro_name']} قد تخطى الكمية الموجودة في المخزن !!');
        }

      }
    }
    setState(()=>_isLoading=false);

  }

  getConfirmButtonText(finalPrice){


    switch(selectedIndexForSubTabs){
      case 0:{
        return '$finalPrice';
      }
      case 1:{
        return 'تم التسليم';
      }
      case 2:{
        return '$finalPrice';
      }
      case 3:{
        return (widget.state.toString() == 'Manage_Cart' && widget.userLevel<=1)?'إعادة الطلب':'$finalPrice';
      }
    }

  }


  getText(index){
    switch(index){
      case 0:{
        return 'لاتوجد لديك اي طلبات منتظرة';
      }
      case 1:{
        return 'لاتوجد لديك اي طلبات جارية التسليم';
      }
      case 2:{
        return 'لاتوجد لديك اي طلبات مستلمة';
      }
      case 3:{
        return 'لاتوجد لديك اي طلبات مرفوضة';
      }
    }
  }


  getTitle(document){

    var isConfirm = document['is_confirm'];
    var isAccepted = document['is_accepted'];
    var state = document['state'];
    var hasDelivered = document['has_delivered'];
    var buttonTitle = '';

    if(widget.state.toString() != 'Manage_Cart'){
      if(!isConfirm && state.toString() =='notConfigured'){
        buttonTitle =confirmTitle;
      }
    }

    // for the waiting,delivering,done,decline tabs
    if(isConfirm){
      switch(document['state']){
        case 'waiting':{
          buttonTitle=(widget.state.toString() != 'Manage_Cart')?cancelRequestTitle : acceptRequestTitle;
          break;
        }
        case 'delivering':{
          buttonTitle = (widget.state.toString() != 'Manage_Cart')?deliveringTitle:doneDeliveringTitle;
          break;
        }
        case 'done':{
          buttonTitle = (widget.state.toString() != 'Manage_Cart')?doneDeliveringTitle:deleteFromScreen;
          break;
        }
        case 'declined':{
          buttonTitle = (widget.state.toString() != 'Manage_Cart')?requestAgainTitle:acceptRequestTitle;
          break;
        }
      }
    }


    return buttonTitle;
  }

  getStream() {

    setState(() {

        // for the bill requests
        stream = Firestore.instance
            .collection('shopping_cart')
            .document(widget.store_id)
            .collection('Requests')
            .document('${widget.billNumber}')
            .collection('${widget.billNumber}')
            .where('is_confirm',isEqualTo: true )
            .where('state',isEqualTo: getState())
            .where('is_accepted',isEqualTo: (selectedIndexForSubTabs == 0 || selectedIndexForSubTabs == 3 ) ? false : true)
            .where('has_delivered',isEqualTo: (selectedIndexForSubTabs == 2 ) ? true : false)
            .snapshots();

    });

  }

  getState(){
    switch(selectedIndexForSubTabs){
      case 0:{
        return 'waiting';
      }
      case 1:{
        return 'delivering';
      }
      case 2:{
        return 'done';
      }
      case 3:{
        return 'declined';
      }
    }
  }

  confirmCancelling({String title, String content, String firstButton, String secondButton,showButton2=true}) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text(content),
                  ],
                ),
              ),
              actions: [
                FlatButton(
                    onPressed: () => Navigator.pop(context, 'firstButton'),
                    child: Text(firstButton)),
                (showButton2)?FlatButton(
                    onPressed: () => Navigator.pop(context, 'secondButton'),
                    child: Text(secondButton)):Container(),
              ],
            ),
          );
        });
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

  getSubCategory() {

    // for my requests
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: subTaps.length,
      itemBuilder: (BuildContext context, int position) {
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedIndexForSubTabs = position;
              getStream();

                switch (selectedIndexForSubTabs) {
                  case 0:
                    {
                      floatingButtonTitle = (widget.state.toString() == 'Manage_Cart')? 'قبول كل الطلبات' : 'إلغاء الكل';
                      _isFloatingButtonShown = true;
                      break;
                    }
                  case 1:
                    {
                      floatingButtonTitle = 'تسليم الكل';
                      _isFloatingButtonShown =(widget.state.toString() == 'Manage_Cart')?true : false;
                      break;
                    }
                  case 2:
                    {
                      _isFloatingButtonShown =  false;
                      break;
                    }
                  case 3:
                    {
                      floatingButtonTitle ='إعادة طلب الكل';
                      _isFloatingButtonShown = (widget.state.toString() == 'Manage_Cart' && widget.userLevel<=1)? true : false;
                      break;
                    }
                }


            });
          },
          child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(
              left: kDefaultPadding,
              right: (position == subTaps.length - 1) ? kDefaultPadding : 0,
            ),
            padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
            decoration: BoxDecoration(
              color: (position == selectedIndexForSubTabs)
                  ? Colors.white.withOpacity(0.4)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${subTaps[position].toString()}',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );

  }

  getDeletedIcon(document){

    switch(selectedIndexForSubTabs){
      case 0:
        {
          return (widget.state.toString() == 'Manage_Cart')?Positioned(
            height: 136,
            bottom: 0,
            left: 0,
            child: Container(
              child: IconButton(
                // padding: EdgeInsets.all(10),
                alignment: Alignment.topLeft,
                color: Colors.red,
                icon: Icon(Icons.close_rounded),
                iconSize: 18,
                onPressed: () => cancelButtonForRequest(document),
              ),
            ),
          ):Container();
        }
      case 3:
        {
          return Container();
        }
      default:
        {
          return (widget.state.toString() == 'Manage_Cart' && widget.userLevel<=1)?Positioned(
            height: 136,
            bottom: 0,
            left: 0,
            child: Container(
              child: IconButton(
                // padding: EdgeInsets.all(10),
                alignment: Alignment.topLeft,
                color: Colors.red,
                icon: Icon(Icons.close_rounded),
                iconSize: 18,
                onPressed: () => cancelButtonForRequest(document),
              ),
            ),
          ):Container();
        }
    }


  }

  printAcceptedBill(storeID,billID) async{

    final date = DateTime.now();
    List<InvoiceItem> items=new List<InvoiceItem>();
    List<InvoiceItem> itemsToAssignment=new List<InvoiceItem>();
    List<List<InvoiceItem>> itemsToPass=new List<List<InvoiceItem>>();


    var bill = await Firestore.instance.collection('shopping_cart')
        .document('$storeID')
        .collection('Requests')
        .document('$billID')
        .collection('$billID')
        .where('is_accepted',isEqualTo: true)
        .getDocuments();

    if(bill !=null && bill.documents.length>0){

      int count = bill.documents.length;

      var divided = count/8;


      double multipleTotalPrice = 0.0;
      for(int i = 0,jj=8; i<divided; i++,jj +=8){

        itemsToAssignment=new List<InvoiceItem>();
        for(int j = 8*i; j< jj  && j<count; j++){
          itemsToAssignment.add(InvoiceItem(
              productName: '${bill.documents[j]['pro_name']}',
              productMark: '${bill.documents[j]['pro_mark']}',
              unitName: '${bill.documents[j]['unit_name']}',
              quantity: bill.documents[j]['requested_quantity'],
              unitPrice: bill.documents[j]['unit_price'],
              rowNumber: j+1
          ));

          multipleTotalPrice += (double.parse(bill.documents[j]['requested_quantity'].toString()) * double.parse(bill.documents[j]['unit_price'].toString()));
        }

        itemsToPass.add(itemsToAssignment);

      }
      items = itemsToAssignment;


      final invoice = Invoice(
          supplier: Supplier(
            name: 'محلات الشامل',
            address: 'المكلا، الديس، مقابل محطة بلخشر',
            paymentInfo: '734-127-459  05310109',
          ),
          customer: Customer(
            name: 'نوفل سوفت',
            address: 'المكلا - الديس - مقابل محطة بلحمر',
          ),
          info: InvoiceInfo(
            date: date,
            description: 'محتويات الطلب',
            number: '${billID}',
            count: count,
            multiTotalPrice: multipleTotalPrice

          ),
          isMultiPages: (count<9)?false:true,
          items:items
      );

      // to make to report
      final pdfFile = await PdfInvoiceApi.generate(invoice,itemsToPass);

      // to open pdf file
      PdfApi.openFile(pdfFile);

    }else{
      print('no data');
    }

  }



}
