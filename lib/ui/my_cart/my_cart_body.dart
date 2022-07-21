import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:store/ui/helpers_widgets/constantHelpers.dart';
import 'package:store/ui/my_cart/bill_details.dart';
import 'package:store/ui/products/product_details.dart';
import 'package:store/ui/reporting/models/customer.dart';
import 'package:store/ui/reporting/models/invoice.dart';
import 'package:store/ui/reporting/models/supplier.dart';
import 'package:store/ui/reporting/pdf_api.dart';
import 'package:store/ui/reporting/pdf_invoice_api.dart';

class MyCartBody extends StatefulWidget {
  var userLevel;
  var store_id;
  var state;

  MyCartBody({this.store_id, this.userLevel, this.state});

  @override
  _MyCartBodyState createState() => _MyCartBodyState();
}

class _MyCartBodyState extends State<MyCartBody> {

  TextEditingController _searchController = new TextEditingController();
  final GlobalKey<ScaffoldState> snack = GlobalKey<ScaffoldState>();

  ScrollController _scrollController = new ScrollController();
  bool isFAB = false;

  var billNumberToConfirm;

  var floatingButtonTitle = 'تأكيد الكل';

  var searchCase;
  var searchedKey;

  // To get the content of all stages
  var stream;

  // For button titles

  // for end-user
  final confirmTitle = 'تأكيد الطلب';
  final deleteTitle = 'حذف';
  final cancelRequestTitle = 'إلغاء الطلب';
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

  // for Management of Carts
  var manage_title = 'قبول الطلب';
  var manage_title_after_accepted = '... إلغاء الطلب';

  bool _isSubTabsVisible = true;

  int selectedIndex = 0;

  int selectedIndexForSubTabs = 0;
  double marginNumber = 10;

  var sub_cate_id;
  var top_cate_id;

  bool _isLoading = false;

  @override
  void initState() {
    if (widget.state.toString() == 'Manage_Cart') {
      items = new List<InvoiceItem>();
      stream = Firestore.instance // for manage carts
          .collection('shopping_cart')
          .document(widget.store_id)
          .collection('Requests')
          .where('is_confirm', isEqualTo: true)
          .where('is_accepted', isEqualTo: false)
          .where('state', isEqualTo: 'waiting')
          .snapshots();
    } else {
      stream = Firestore.instance // for my carts
          .collection('shopping_cart')
          .document(widget.store_id)
          .collection('Requests')
          .where('is_confirm', isEqualTo: false)
          .where('is_accepted', isEqualTo: false)
          .snapshots();
    }

    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.offset > 50) {
        setState(() {
          isFAB = true;
        });
      } else {
        setState(() {
          isFAB = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ModalProgressHUD(
      key: snack,
      inAsyncCall: _isLoading,
      child: SafeArea(
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
                  prefixIcon: IconButton(
                    icon: Icon(Icons.clear,color: Colors.white,),
                    onPressed: (){
                      setState(() {
                        searchedKey ='';
                        _searchController.clear();
                      });
                    },
                  ),
                  hintText: "ابـحـث هـنـا",
                  hintStyle: TextStyle(color: Colors.white),
                ),
                textAlign: TextAlign.right,
              ),
            ),

            // For Tabs
            (widget.state.toString() == 'Manage_Cart')
                ? Container()
                : Directionality(
                    textDirection: TextDirection.rtl,
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
                      height: 30,
                      child: ListView.builder(
                        itemCount: 2,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                //to determine which top tap is selected
                                categoryIndex = index;
                                // to take the index of the selected tap
                                selectedIndex = index;

                                if (widget.state.toString() != 'Manage_Cart' &&
                                    categoryIndex == 0) {
                                  getStream();
                                }
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(
                                left: kDefaultPadding,
                                right: (index == 1) ? kDefaultPadding : 0,
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: kDefaultPadding),
                              decoration: BoxDecoration(
                                color: (index == selectedIndex)
                                    ? Colors.white.withOpacity(0.4)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              width: MediaQuery.of(context).size.width / 2,
                              child: Text(
                                (index == 0) ? 'سلتي' : 'طلباتي',
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

            // For the rest of the screen
            Expanded(
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
                  (widget.state.toString() == 'Manage_Cart')
                      ? getBills()
                      : (categoryIndex == 0)
                          ? StreamBuilder(
                              // stream: stream,
                              stream: Firestore.instance // for manage carts
                                  .collection('shopping_cart')
                                  .document(widget.store_id)
                                  .collection('Requests')
                                  .where('is_bill', isEqualTo: false)
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasData && snapshot.data.documents.length > 0) {
                                  final docID = snapshot.data.documents[0].documentID;
                                  billNumberToConfirm = docID;
                                  return StreamBuilder(
                                    stream: Firestore.instance // for manage carts
                                        .collection('shopping_cart')
                                        .document(widget.store_id)
                                        .collection('Requests')
                                        .document('$docID')
                                        .collection('$docID')
                                        .where('is_confirm', isEqualTo: false)
                                        .where('is_accepted', isEqualTo: false)
                                        .where('has_delivered', isEqualTo: false)
                                        .where('state', isEqualTo: 'notConfigured')
                                        .snapshots(),
                                    builder: (context,AsyncSnapshot<QuerySnapshot> snapshot2){
                                      if(snapshot2.hasData && snapshot2.data.documents.length>0){
                                        return ListView(
                                          controller: _scrollController,
                                          children: snapshot2.data.documents
                                              .map((DocumentSnapshot document) {
                                            if (document['pro_name'].toString().contains(_searchController.text)) {
                                              final showedTitle =
                                              getTitle(document).toString();
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
                                                          BorderRadius.circular(
                                                              22),
                                                          boxShadow: [kDefaultShadow],
                                                        ),
                                                        child: Container(
                                                          margin: EdgeInsets.only(
                                                              right: 10),
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                            BorderRadius.circular(
                                                                22),
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
                                                      // Posts title & price
                                                      Positioned(
                                                        bottom: 0,
                                                        left: 0,
                                                        child: SizedBox(
                                                          height: 136,
                                                          width: size.width - 200,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: [
                                                              Spacer(),
                                                              // request name
                                                              Container(
                                                                width: MediaQuery.of(context).size.width/2.6,
                                                                alignment:
                                                                Alignment.center,
                                                                child: Text(
                                                                  '${document['pro_name']}',
                                                                  overflow: TextOverflow.ellipsis,
                                                                  softWrap: false,
                                                                  style: Theme.of(
                                                                      context)
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
                                                                  ' السعر : ${document['unit_price1']}',
                                                                  style: TextStyle(
                                                                      fontSize: 10
                                                                  ),
                                                                ),
                                                              ),
                                                              // For Confirm Button
                                                              Spacer(),
                                                              InkWell(
                                                                onTap: () async {
                                                                  if (showedTitle
                                                                      .toString() == deleteTitle.toString()) {

                                                                    // to delete the requests
                                                                    Firestore.instance
                                                                        .collection('shopping_cart')
                                                                        .document(widget.store_id)
                                                                        .collection('Requests')
                                                                        .document('$docID')
                                                                        .collection('$docID')
                                                                        .document(document.documentID)
                                                                        .delete();

                                                                  }
                                                                },
                                                                child: Container(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                    horizontal:
                                                                    kDefaultPadding *
                                                                        1.5,
                                                                    vertical:
                                                                    kDefaultPadding /
                                                                        4,
                                                                  ),
                                                                  decoration:
                                                                  BoxDecoration(
                                                                    color: Colors
                                                                        .redAccent,
                                                                    borderRadius:
                                                                    BorderRadius
                                                                        .only(
                                                                      bottomLeft: Radius
                                                                          .circular(
                                                                          22),
                                                                      topRight: Radius
                                                                          .circular(
                                                                          22),
                                                                    ),
                                                                  ),

                                                                  // for title
                                                                  child: Text(
                                                                    '$showedTitle',
                                                                    style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                    ),
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
                                                onTap: () {
                                                  // this code will perform when you click on any request

                                                  Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ProductDetails(
                                                                obj: document,
                                                                userLevel:
                                                                widget.userLevel,
                                                                comingFrom: 'MyCart',
                                                                store_ID: widget.store_id,
                                                              )));
                                                },
                                              );
                                            } else {
                                              return Text("");
                                            }
                                          }).toList(),
                                        );
                                      }else{
                                        return Center(child: Text("لاتوجد اي طلبات حالياً",style: TextStyle(color: kIconColor, fontSize: 15),));
                                      }
                                    },
                                  );
                                }
                                else {

                                  return Center(
                                      child: Text(
                                    (categoryIndex == 0 &&
                                            widget.state.toString() !=
                                                'Manage_Cart')
                                        ? 'لاتوجد لديك اي طلبات في سلتك'
                                        : getText(selectedIndexForSubTabs),
                                    style: TextStyle(
                                        color: kIconColor, fontSize: 15),
                                  ));
                                }
                              }) : getBills(),

                  StreamBuilder(
                    stream: Firestore.instance // for manage carts
                        .collection('shopping_cart')
                        .document(widget.store_id)
                        .collection('Requests')
                        .where('is_bill', isEqualTo: false)
                        .snapshots(),
                    builder: (context,AsyncSnapshot<QuerySnapshot> floatingSnap){
                      if(floatingSnap.hasData && floatingSnap.data.documents.length>0){
                        var myBillID = floatingSnap.data.documents[0].documentID;
                        return FutureBuilder(
                          future: Firestore.instance // for manage carts
                              .collection('shopping_cart')
                              .document(widget.store_id)
                              .collection('Requests')
                              .document('$myBillID')
                              .collection('$myBillID')
                              .where('is_confirm', isEqualTo: false)
                              .where('is_accepted', isEqualTo: false)
                              .where('has_delivered', isEqualTo: false)
                              .where('state', isEqualTo: 'notConfigured')
                              .getDocuments(),
                          builder: (context,AsyncSnapshot<QuerySnapshot>snapshot){

                            if(widget.state.toString() != 'Manage_Cart' && categoryIndex == 0 && snapshot.hasData && snapshot.data.documents.length>0){
                              if(snapshot.data.documents.length>0){
                                return Positioned(
                                  bottom: 10,
                                  right: 20,
                                  child: Container(
                                    child: isFAB
                                        ? Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: buildFAB())
                                        : Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: buildExtendedFAB()),
                                  ),
                                );
                              }else{
                                return Container();
                              }

                            }else{
                              return Container();
                            }
                          },
                        );
                      }
                      return Container();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget buildExtendedFAB() => AnimatedContainer(
        // color: kPrimaryColor,

        duration: Duration(milliseconds: 200),
        curve: Curves.linear,
        width: 150,
        height: 50,
        child: InkWell(
          onTap: () => createBill(),
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
                Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 10,
                ),
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
            onPressed: () => createBill(),
            icon: Icon(
              Icons.edit,
              color: Colors.white,
            ),
          ),
        ),
      );

  getQuantityWithoutDots(number){
    var regex = RegExp(r"([.]*0)(?!.*\d)");

    String finalQuantityResult = number.toString().replaceAll(regex, "");

    return finalQuantityResult;

  }

  createBill() async {
    // to confirm the requests
    if (categoryIndex == 0 && widget.state.toString() != 'Manage_Cart') {
      var result = await confirmCancelling(
          title: 'تأكيد الكل',
          content: 'هل أنت متأكد من أنك تريد طلب كل هذه المنتجات',
          firstButton: 'إلغاء',
          secondButton: 'طلب الكل');

      if (result == 'secondButton') {
        setState(() => _isLoading = true);

        // to check if the bill is exist or not

        if(billNumberToConfirm != null && billNumberToConfirm.toString().isNotEmpty){
        //  when the bill is exist
          
        }else{
          var toGetTheBill = await Firestore.instance.collection('shopping_cart').document(widget.store_id).collection('Requests').where('is_bill',isEqualTo: false).getDocuments();
          if(toGetTheBill != null && toGetTheBill.documents.length>0){
            setState(() => billNumberToConfirm = toGetTheBill.documents[0].documentID);
          }else{
            billNumberToConfirm = null;
          }
        }

        // to confirm the  bill
        if(billNumberToConfirm !=null){

          await toConfirmAllRequests();

        }
        

        setState(() => _isLoading = false);
      }
    }
  }

  toConfirmAllRequests() async{
    var requests = await Firestore.instance.collection('shopping_cart').document(widget.store_id).collection('Requests').document('$billNumberToConfirm').collection('$billNumberToConfirm').getDocuments();

    if(requests !=null && requests.documents.length>0){
      requests.documents.map((request)  {

        Firestore.instance.collection('shopping_cart')
            .document(widget.store_id)
            .collection('Requests')
            .document('$billNumberToConfirm')
            .collection('$billNumberToConfirm')
            .document('${request.documentID}')
            .updateData({
          'state':'waiting',
          'is_confirm':true,
          'is_accepted':false,
          'has_delivered':false

        });
      }).toList();

      await Firestore.instance.collection('shopping_cart').document(widget.store_id).collection('Requests').document('$billNumberToConfirm').updateData({
        'is_bill':true,
        'date_of_confirm':DateTime.now(),
        'is_delivered' : false// => for filter the stores for if they are deliverey or still waiting
      });



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

  getText(index) {
    switch (index) {
      case 0:
        {
          return 'لاتوجد لديك اي طلبات منتظرة';
        }
      case 1:
        {
          return 'لاتوجد لديك اي طلبات جارية التسليم';
        }
      case 2:
        {
          return 'لاتوجد لديك اي طلبات مستلمة';
        }
      case 3:
        {
          return 'لاتوجد لديك اي طلبات مرفوضة';
        }
    }
  }

  getTitle(document) {
    var isConfirm = document['is_confirm'];
    var isAccepted = document['is_accepted'];
    var state = document['state'];
    var hasDelivered = document['has_delivered'];
    var buttonTitle = '';

    if (widget.state.toString() != 'Manage_Cart') {
      if (!isConfirm && state.toString() == 'notConfigured') {
        buttonTitle = deleteTitle;
      }
    }

    // for the waiting,delivering,done,decline tabs
    if (isConfirm) {
      switch (document['state']) {
        case 'waiting':
          {
            buttonTitle = (widget.state.toString() != 'Manage_Cart')
                ? cancelRequestTitle
                : acceptRequestTitle;
            break;
          }
        case 'delivering':
          {
            buttonTitle = (widget.state.toString() != 'Manage_Cart')
                ? deliveringTitle
                : doneDeliveringTitle;
            break;
          }
        case 'done':
          {
            buttonTitle = (widget.state.toString() != 'Manage_Cart')
                ? doneDeliveringTitle
                : deleteFromScreen;
            break;
          }
        case 'declined':
          {
            buttonTitle = (widget.state.toString() != 'Manage_Cart')
                ? requestAgainTitle
                : acceptRequestTitle;
            break;
          }
      }
    }

    return buttonTitle;
  }

  getStream() {
    setState(() {
      if (widget.state.toString() != 'Manage_Cart' && categoryIndex == 0) {
        //   for my cart
        stream = Firestore.instance
            .collection('shopping_cart')
            .document(widget.store_id)
            .collection('Requests')
            .where('is_confirm', isEqualTo: false)
            .where('state', isEqualTo: 'notConfigured')
            .where('is_accepted', isEqualTo: false)
            .snapshots();
      }
    });
  }

  getState() {
    switch (selectedIndexForSubTabs) {
      case 0:
        {
          return 'waiting';
        }
      case 1:
        {
          return 'delivering';
        }
      case 2:
        {
          return 'done';
        }
      case 3:
        {
          return 'declined';
        }
    }
  }

  confirmCancelling(
      {String title,
      String content,
      String firstButton,
      String secondButton,
      String thirdButton,
      showButton2 = true,
      showButton3 = false,
      }) {
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
                (showButton2)
                    ? FlatButton(
                        onPressed: () => Navigator.pop(context, 'secondButton'),
                        child: Text(secondButton))
                    : Container(),
                (showButton3)
                    ? FlatButton(
                    onPressed: () => Navigator.pop(context, 'thirdButton'),
                    child: Text(thirdButton))
                    : Container(),
              ],
            ),
          );
        });
  }

  getBills() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: StreamBuilder(
          stream: Firestore.instance
              .collection('shopping_cart')
              .document(widget.store_id)
              .collection('Requests')
              .where('is_bill', isEqualTo: true)
              .orderBy('date_of_confirm',descending: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData && snapshot.data.documents.length > 0) {
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (BuildContext context, int position) {
                  final singleBill = snapshot.data.documents[position];
                  return ListTile(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (Context) => BillDetails(
                                  state: widget.state,
                                  store_id: widget.store_id,
                                  billNumber: singleBill.documentID,
                                  userLevel: widget.userLevel,
                                ))),

                    title: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Text('فاتورة رقم ${singleBill.documentID}'),
                          ),
                          Container(
                            child: Row(
                              children: [
                                //to print this bill
                                IconButton(
                                    icon: Icon(Icons.print),
                                    iconSize: 18,
                                    color: Colors.black54,
                                    onPressed: ()=>printBill(singleBill.documentID),
                                    ),
                                //to recover this bill
                                (widget.userLevel>1)?Container():IconButton(
                                    icon: Icon(Icons.threesixty),
                                    iconSize: 18,
                                    color: Colors.black54,
                                  onPressed: () =>recoverBill(singleBill.documentID),
                                    ),
                                //to delete this bill
                                (widget.userLevel>1)?Container():IconButton(
                                    icon: Icon(Icons.delete_forever),
                                    iconSize: 18,
                                    color: Colors.red.shade300,
                                    onPressed: () =>deleteBill(singleBill.documentID),
                                ),

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    leading:  Icon( (singleBill['is_delivered'] == true)?Icons.fact_check_outlined :Icons.article_sharp,color: kSecondaryColorBG,),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  );
                },
              );
            } else {
              return Center(
                child: Text('لاتوجد اي طلبات حالياً'),
              );
            }
          },
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
  
  deleteBill(billID) async{
    
    try{

      var result = await confirmCancelling(
          title: 'حذف فاتورة نهائياً',
          content: 'هل أنت متأكد من أنك تريد حذف هذه الفاتورة نهائياً؟\n علماً بأنك لن تسترجع منتجات هذه الفاتورة!!',
          firstButton: 'إلغاء',
          secondButton: 'حذف');

      if(result.toString() == 'secondButton'){
        setState(() => _isLoading=true);
        await Firestore.instance.collection('shopping_cart').document(widget.store_id).collection('Requests').document('$billID').delete();
        setState(() => _isLoading=false);
        confirmCancelling(title: 'تم الحذف بنجاح',content: 'تمت عملية الحذف بنجاح!!',firstButton: 'موافق',showButton2: false);
      }
      
      
    }catch(e){
      setState(() => _isLoading=false);
    }
    
    
  }
  recoverBill(billID) async{

    try{

      var result = await confirmCancelling(
          title: 'إسترجاع هذه الفاتورة',
          content: 'هل أنت متأكد من أنك تريد إسترجاع هذه الفاتورة ؟\n علماً بأن الفاتورة سيتم حذفها !!',
          firstButton: 'إلغاء',
          secondButton: 'إسترجاع');

      if(result.toString() == 'secondButton'){
        setState(() => _isLoading=true);
        var allDoc = await Firestore.instance.collection('shopping_cart')
            .document(widget.store_id).collection('Requests')
            .document('$billID').collection('$billID')
            .where('is_accepted',isEqualTo: true).getDocuments();

        if(allDoc!=null && allDoc.documents.length>0){
          allDoc.documents.map((document) async {

            var requestQuantity = double.parse(document['requested_quantity'].toString());
          //  for the product of this request
            var product = await Firestore.instance.collection('products').document(document['pro_id']).get();
            if(product!= null && product.data.length>0){
              var theProductQuantity = double.parse(product['all_quantity'].toString());
              final finalQuantity = theProductQuantity + requestQuantity;

              await Firestore.instance.collection('products').document(product.documentID).updateData({
                'all_quantity' : finalQuantity
              });
            }

          }).toList();
        }

        await Firestore.instance.collection('shopping_cart')
            .document(widget.store_id).collection('Requests').document('$billID').delete();



        setState(() => _isLoading=false);
        confirmCancelling(title: 'تم الإسترجاع بنجاح',content: 'تمت عملية إسترجاع الفاتورة بنجاح!!',firstButton: 'موافق',showButton2: false);
      }


    }catch(e){
      setState(() => _isLoading=false);
    }

  }
  printBill(billID) async{

    var result = await confirmCancelling(
        title: 'طباعة فاتورة',
        content: 'هل تريد طباعة كل الفاتورة او الطلبات التي قبلت؟!!',
        firstButton: 'إلغاء',
        secondButton: 'المقبولة',
        thirdButton: 'الكل',
      showButton3: true
    );

    if(result == 'secondButton'){
    //  printing accepted bills
      printAcceptedBill(widget.store_id, billID);

    }else if(result == 'thirdButton'){
    //  printing all bills
      printAllBill(widget.store_id, billID);

    }

  }


  printAllBill(storeID,billID) async{
    
    //to print all the bill requests

    final date = DateTime.now();
    final dueDate = date.add(Duration(days: 7));

    var invoices ;
    List<InvoiceItem> items=new List<InvoiceItem>();
    List<InvoiceItem> itemsToAssignment=new List<InvoiceItem>();
    List<List<InvoiceItem>> itemsToPass=new List<List<InvoiceItem>>();


    var bill = await Firestore.instance.collection('shopping_cart')
        .document('$storeID')
        .collection('Requests')
        .document('$billID')
        .collection('$billID')
        .getDocuments();

    if(bill !=null && bill.documents.length>0){
      var storeDetails = await Firestore.instance.collection('shopping_cart').document(storeID).get();

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
              rowNumber: j+1,

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
            name: storeDetails['store_name'],
            address: storeDetails['store_location'],
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

      var storeDetails = await Firestore.instance.collection('shopping_cart').document(storeID).get();


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
          // customer: Customer(
          //   name: 'نوفل سوفت',
          //   address: 'المكلا - الديس - مقابل محطة بلحمر',
          // ),
          customer: Customer(
            name: storeDetails['store_name'],
            address: storeDetails['store_location']
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

    }

  }
  
}
