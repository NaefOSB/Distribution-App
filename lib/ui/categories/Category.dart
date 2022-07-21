import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '../helpers_widgets/constantHelpers.dart';

class MyCategory extends StatefulWidget {

  var state;
  var category;
  MyCategory({this.state ='Add_Category',this.category});

  @override
  _MyCategoryState createState() => _MyCategoryState();
}

class _MyCategoryState extends State<MyCategory> {

  // ignore: non_constant_identifier_names
  TextEditingController _NameController;
  // ignore: non_constant_identifier_names
  TextEditingController _DescriptionController;
  final _formKey = GlobalKey<FormState>();
  var currentUser;
  bool _isLoading = false;


  @override
  void initState() {

    getCurrentUser();

    if(widget.state == 'Edit_Category'){
      _NameController =  TextEditingController(text: widget.category['cate_name']);
      _DescriptionController =  TextEditingController(text: widget.category['cate_description']);

    }else{
      _NameController =  TextEditingController();
      _DescriptionController =  TextEditingController();
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
            title: (widget.state == 'Edit_Category')? Text('تعديل قسم ${widget.category['cate_name']}',style: TextStyle(color: Colors.white),) : Text('واجهة أضافة قسم',style: TextStyle(color: Colors.white)),
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextFormField(

                      // ignore: missing_return
                      validator: (value){
                        if(value.isEmpty){
                          return 'الرجاء إدخال أسم القسم';
                        }
                      },

                      textAlign: TextAlign.center,
                      controller: _NameController,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),

                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[400]),
                          ),
                          labelText: 'أسم القسم',
                          hintText: 'الرجاء إدخال أسم القسم',
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[400]))),
                      textInputAction: TextInputAction.next,
                    ),
                    TextFormField(
                      // ignore: missing_return
                      validator: (value){
                        if(value.isEmpty){
                          return 'الرجاء إدخال وصف لهذا القسم';
                        }
                      },
                      onFieldSubmitted: (value){
                        creationProcess();
                      },

                      textAlign: TextAlign.center,

                      controller: _DescriptionController,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),

                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[400]),
                          ),
                          labelText: 'وصف القسم',
                          hintText: 'الرجاء كتابة وصف للقسم',
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[400]))),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
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
                          // UnComment This code
                          onPressed: ()=>creationProcess(),
                          // color: kPrimaryColor,
                          color: kSecondaryColorBG,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            (widget.state.toString() == 'Edit_Category')? 'تعديل القسم' :'حفظ القسم',
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

  getCurrentUser()async{
    var user = await FirebaseAuth.instance.currentUser();
    if(user != null && user.uid != null){
      setState(() {
        currentUser = user.uid;
      });
    }

  }

  creationProcess() async{
    try{

      if(_formKey.currentState.validate()){
        setState( ()=>_isLoading = true );

        if(widget.state.toString() == 'Edit_Category'){
        //  For Edit Category
          Firestore.instance.collection('categories').document(widget.category.documentID).updateData({
            'cate_name':_NameController.text,
            'cate_description':_DescriptionController.text,
            'updated_date':DateTime.now(),
            'updated_user': currentUser
          }).then((_) async{

            // for update all products that have the  category
            var allProductsHavingThis = await Firestore.instance.collection('products').where('top_cate_id',isEqualTo:widget.category.documentID ).getDocuments();
            if(allProductsHavingThis != null && allProductsHavingThis.documents.length>0){
              for(int i = 0; i < allProductsHavingThis.documents.length; i++){
                var product = allProductsHavingThis.documents[i];
                await Firestore.instance.collection('products').document(product.documentID).updateData({
                  'top_cate_name': _NameController.text,
                  'top_cate_id':widget.category.documentID

                });
              }
            }

            setState( ()=>_isLoading = false );
            await errorMessage(title: 'عملية تأكيديه', message: 'تمت عملية التعديل بنجاح');
            Navigator.pop(context);
          });

        }else{
        //  For Add Category

          await Firestore.instance.collection('categories').add({
            'cate_name':_NameController.text,
            'cate_description':_DescriptionController.text,
            'cate_level': 0,
            'created_date':DateTime.now(),
            'created_user': currentUser,
            'is_sub_cate': false
          });

          _NameController.clear();
          _DescriptionController.clear();
          setState( ()=>_isLoading = false );
          errorMessage(title: 'عملية تأكيديه', message: 'تمت عملية الأضافة بنجاح');

        }
      }

    }catch(e){
      setState(() => _isLoading=false);
      errorMessage(title: 'حدث خطأ',message: e.message);
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
