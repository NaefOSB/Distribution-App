import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:store/ui/helpers_widgets/ExpandedListAnimationWidget.dart';
import '../helpers_widgets/constantHelpers.dart';


class SubCategory extends StatefulWidget {

  var state;
  var obj;

  SubCategory({this.state = 'Add_SubCategory',this.obj});

  @override
  _SubCategoryState createState() => _SubCategoryState();
}

class _SubCategoryState extends State<SubCategory> {
  bool isStrechedDropDown = false;
  int groupValue;
  String title = 'الرجاء إختيار قسم لهذا الفرع';
  var selectedCategoryID;
  var currentUser;
  bool _isLoading = false;
  bool _isNeverChange = true;


  TextEditingController _subCateNameController;
  final _formKey = GlobalKey<FormState>();


  @override
  void initState() {
    getCurrentUser();

    if(widget.state.toString() == 'Edit_SubCategory'){
      _subCateNameController = TextEditingController(text: widget.obj['cate_name']);
      title = widget.obj['top_cate_name'];

    }else{
      _subCateNameController = TextEditingController();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white.withOpacity(0.9),
          appBar: AppBar(
            title: Text((widget.state.toString() == 'Edit_SubCategory') ? 'واجهة تعديل الفرع' :'واجهة أضافة فرع',style: TextStyle(color: Colors.white)),
            centerTitle: true,
            leading: IconButton(icon: Icon(Icons.arrow_back_ios,color: Colors.white,),onPressed: ()=>Navigator.pop(context),),
            brightness: Brightness.dark,
          ),


          body: Container(
            alignment: Alignment.center,
            child: Container(

              height: MediaQuery.of(context).size.height/2,
              margin: EdgeInsets.symmetric(horizontal: 30),
              padding: EdgeInsets.all(10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25)
              ),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [

                    // Sub Category Name
                    TextFormField(
                      // ignore: missing_return
                      validator: (value){
                        if(value.isEmpty){
                          return 'الرجاء إدخال أسم لهذا الفرع';
                        }
                      },
                      textAlign: TextAlign.center,
                      controller: _subCateNameController,

                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[400]),
                        ),
                        labelText: 'أسم الفرع',
                        hintText: 'الرجاء إدخال أسم الفرع',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[400]),
                        ),
                      ),
                    ),

                    // For Category
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          isStrechedDropDown =
                          !isStrechedDropDown;
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
                                            borderRadius: BorderRadius.all(Radius.circular(27))),
                                        child: Column(
                                          children: [
                                            Container(
                                                width: double.infinity,
                                                padding: EdgeInsets.only(right: 10),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Color(0xffbbbbbb),
                                                    ),
                                                    borderRadius:
                                                    BorderRadius.all(Radius.circular(25))),
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
                                                              title,style: TextStyle(
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
                                                                    groupValue: (widget.state.toString() == 'Edit_SubCategory')? getGroupValue(categories[index].documentID, index) : groupValue,
                                                                    onChanged: (val) {
                                                                      setState(() {

                                                                        //For Update Product and set the category to the chosen one
                                                                        if(widget.state.toString() == 'Edit_SubCategory'){
                                                                          _isNeverChange = false;
                                                                        }

                                                                        groupValue = val;
                                                                        title = categories[index]['cate_name'];
                                                                        selectedCategoryID = categories[index].documentID;

                                                                        isStrechedDropDown =
                                                                        !isStrechedDropDown;
                                                                      });
                                                                    });
                                                              },

                                                            );
                                                          }else{
                                                            return Center(child: Text('لايوجد اي اقسام حالياً'));
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

                    // Save Button
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
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
                          onPressed: ()=>_creationProcess(),
                          color: kSecondaryColorBG,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            (widget.state.toString() == 'Edit_SubCategory')? 'تعديل الفرع' : 'حفظ الفرع',
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

  int getGroupValue(categoryID, index){

    //For select the chosen value only

    if(categoryID.toString() == widget.obj['top_cate_id'].toString() && _isNeverChange){
      groupValue = index;
      selectedCategoryID = categoryID;
    }
    return groupValue;
  }


  _creationProcess() async{

    try{

      if(_formKey.currentState.validate() ){

        if(widget.state.toString() == 'Edit_SubCategory'){

            // For Update Sub Category
            setState(() =>_isLoading =true);
            if(currentUser ==null){
             await getCurrentUser();
            }

            await Firestore.instance.collection('categories').document( widget.obj.documentID).updateData({
              'cate_name':_subCateNameController.text,
              'top_cate_name':title,
              'top_cate_id':selectedCategoryID,
              'updated_date':DateTime.now(),
              'updated_user': currentUser,
            });
            
            // for update all products that have the sub category
            var allProductsHavingThis = await Firestore.instance.collection('products').where('sub_cate_id',isEqualTo:widget.obj.documentID ).getDocuments();
            if(allProductsHavingThis != null && allProductsHavingThis.documents.length>0){
              for(int i = 0; i < allProductsHavingThis.documents.length; i++){
                var product = allProductsHavingThis.documents[i];
                await Firestore.instance.collection('products').document(product.documentID).updateData({
                  'sub_cate_name': _subCateNameController.text,
                  'top_cate_name':title,
                  'top_cate_id':selectedCategoryID

                });
              }
            }

            setState(() =>_isLoading =false);
            await errorMessage(title: 'عملية تأكيدية', message: 'تمة عملية التعديل بنجاح');
            Navigator.pop(context);
        }else{
          // For Add SubCategory

          if(title != 'الرجاء إختيار قسم لهذا الفرع'){
            setState(() =>_isLoading =true);
            if(currentUser ==null){
              await getCurrentUser();
            }

            await Firestore.instance.collection('categories').add({
              'cate_name':_subCateNameController.text,
              'cate_level': 1,
              'top_cate_name':title,
              'top_cate_id':selectedCategoryID,
              'created_date':DateTime.now(),
              'created_user': currentUser,
              'is_sub_cate': true
            });

            setState(() =>_isLoading =false);
            errorMessage(title: 'عملية الأضافة', message: 'تمة عملية الأضافة بنجاح');
            _subCateNameController.clear();
            title= 'الرجاء إختيار قسم لهذا الفرع';
            groupValue = null;

          }else{
            errorMessage(title: 'نسيت أختيار قسم',message: 'الرجاء اختيار قسم لهذا الفرع');
          }
        }
      }

    }catch(e){
      setState(() => _isLoading=false);
      errorMessage(title: 'حدث خطأ',message: e.message);
    }

  }
  getCurrentUser()async{
    var user = await FirebaseAuth.instance.currentUser();
    if(user != null && user.uid != null){
      setState(() {
        currentUser = user.uid;
      });
    }

  }

  errorMessage({String title, String message}) {
    return showDialog(
        context: context,
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('موافق', textDirection: TextDirection.rtl))
              ],
            ),
          );
        });
  }
}
