import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:store/ui/reporting/models/customer.dart';
import 'package:store/ui/reporting/models/invoice.dart';
import 'package:store/ui/reporting/models/supplier.dart';
import 'package:store/ui/reporting/pdf_api.dart';
import 'package:store/ui/reporting/utils.dart';

import 'package:flutter/material.dart' as mt;

class PdfInvoiceApi {
  static Future<File> generate(Invoice invoice,List<List<InvoiceItem>> itemsToPass) async {
    final pdf = Document();


    //new
    var arabicFont = Font.ttf(await rootBundle.load("assets/fonts/HacenTunisia.ttf"));
    var assetImage = MemoryImage(
      (await rootBundle.load('assets/images/novelsoft.jpeg'))
          .buffer
          .asUint8List(),
    );
    var assetImage2 = MemoryImage(
      (await rootBundle.load('assets/images/NovelSoftStamp.png'))
          .buffer
          .asUint8List(),
    );


    pdf.addPage(
      MultiPage(

        textDirection: TextDirection.rtl,
        theme: ThemeData.withFont(
          base: arabicFont,
        ),

        header:(context) => Directionality(textDirection: TextDirection.rtl,child: buildHeader(invoice,assetImage),),
        build: (context) => [
          for(int i = 0; i<itemsToPass.length;i++)...[
            getAll(invoice,itemsToPass[i],(i == itemsToPass.length-1)?true:false),
          ]

        ],


        footer: (context)=>buildFooter(invoice),

        // pageFormat: PdfPageFormat.roll57
        maxPages: 100,



      ),
    );


    return PdfApi.saveDocument(name: 'my_invoice.pdf', pdf: pdf);
  }

  static Widget getAll(invoice,List<InvoiceItem> itemToPass,isFinalPage){
    return Column(
        children: [



          SizedBox(height: 15),
          // the table
          Directionality(textDirection: TextDirection.rtl,child: Container(

            child:buildTitle(invoice),

          )),


          buildInvoice(invoice, itemToPass),

          (isFinalPage)? Divider():Container(),
          (isFinalPage)?buildTotal(invoice):Container(),
        ]
    );
  }



  static Widget buildHeader(Invoice invoice,assetImage) => Directionality(
    textDirection:TextDirection.rtl,
    child: Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [

          // for icon & name of base store
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                // width: 80
                // width: 110
                  width: 30
              ),
              Container(

                height: 60,
                width: 100,
                // height: 60,
                // width: 150,
                // child: Image(assetImage,fit: BoxFit.fill,width: 80,height: 60,alignment: Alignment.center),
                child: Image(assetImage,),
              ),

              Expanded(
                child: buildSupplierAddress(invoice.supplier),
              ),

            ],
          ),

          SizedBox(height: 1 * PdfPageFormat.cm),


          // bill number and date & customer name and location
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  width: 170,
                  child:buildCustomerAddress(invoice.customer),

              ),
              buildInvoiceInfo(invoice.info),



            ],

          ),




        ],
      ),
    ),

  );

  static Widget buildCustomerAddress(Customer customer) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      RichText(text: TextSpan(text:customer.name, )),
      // Text(customer.name, style: TextStyle(fontWeight: FontWeight.bold)),
      RichText(text: TextSpan(text:customer.address, )),
      // Text(customer.address),
    ],
  );

  static Widget buildInvoiceInfo(InvoiceInfo info) {
    // final paymentTerms = '${info.dueDate.difference(info.date).inDays} days';
    final titles = <String>[
      'رقم الفاتورة:',
      'تاريخ الفاتورة :',

    ];
    final data = <String>[
      info.number,
      Utils.formatDate(info.date),

    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(titles.length, (index) {
        final title = titles[index];
        final value = data[index];

        return buildText3(title: title, value: value, width: 200);
      }),
    );
  }

  static Widget buildSupplierAddress(Supplier supplier) => Directionality(
    textDirection: TextDirection.rtl,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        RichText(text: TextSpan(text: supplier.name, )),
        // Text(supplier.name, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 1 * PdfPageFormat.mm),
        RichText(text: TextSpan(text: supplier.address,)),
      ],
    ),
  );

  static Widget buildTitle(Invoice invoice) => Directionality(
    textDirection: TextDirection.rtl,
    child: Container(
      margin: EdgeInsets.only(top: 30),
      child: Row(
          crossAxisAlignment:CrossAxisAlignment.end ,
          children: [
            Expanded(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                RichText(
                  text: TextSpan(text: 'فاتورة طلب شراء',style:TextStyle(fontSize: 24, ),
                  ),
                ),

                SizedBox(height: 0.8 * PdfPageFormat.cm),
                RichText(text: TextSpan(text:invoice.info.description )),

                SizedBox(height: 0.8 * PdfPageFormat.cm),
              ],
            ),
          ]
      ),
    ),
  );

  static Widget buildInvoice(Invoice invoice,List<InvoiceItem> itemToPass) {
    final headers = [
      'الإجمالي',
      'السعر',
      'الكمية',
      'الوحدة',
      'أسم المنتج',
      'رمز المادة',
      'م'

    ];
    final data = itemToPass.map((item) {
      // final total = item.unitPrice * item.quantity * (1 + item.vat);
      final total = item.unitPrice * item.quantity;

      return [
        '\$ ${total.toStringAsFixed(2)}',
        '\$ ${item.unitPrice}',
        // Utils.formatDate(item.date),
        '${item.quantity}',
        '${item.unitName}',
        item.productName.toString(),
        item.productMark.toString(),
        '${item.rowNumber}'
      ];
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Table.fromTextArray(
        headers: headers,
        data: data,
        // border: null,
        border: TableBorder(
          horizontalInside: BorderSide(color: PdfColors.grey500),
          left: BorderSide(color: PdfColors.grey500),
          right: BorderSide(color: PdfColors.grey500),
          top: BorderSide(color: PdfColors.grey500),
          bottom: BorderSide(color: PdfColors.grey500),
          // verticalInside: BorderSide(color: PdfColors.grey500),
          // right: BorderSide(color: PdfColors.grey500),
          // left: BorderSide(color: PdfColors.grey500),
        ),
        // headerStyle: TextStyle(fontWeight: FontWeight.bold),
        headerDecoration: BoxDecoration(color: PdfColors.grey300),
        cellHeight: 30,
        cellAlignments: {

          0: Alignment.center,
          1: Alignment.center,
          2: Alignment.center,
          3: Alignment.center,
          4: Alignment.center,
          5: Alignment.center,
          6: Alignment.center,

          // 0: Alignment.centerLeft,
          // 1: Alignment.centerRight,
          // 2: Alignment.centerRight,
          // 3: Alignment.centerRight,
          // 4: Alignment.centerRight,
          // 5: Alignment.centerRight,
        },
      ),
    );
  }
  static Widget buildInvoice2( invoice) {
    final headers = [
      'الإجمالي',
      'السعر',
      'الكمية',
      'الوحدة',
      'أسم المنتج',
      'رمز المادة'

    ];
    final data = invoice.items.map((item) {
      // final total = item.unitPrice * item.quantity * (1 + item.vat);
      final total = item.unitPrice * item.quantity;

      return [
        '\$ ${total.toStringAsFixed(2)}',
        '\$ ${item.unitPrice}',
        // Utils.formatDate(item.date),
        '${item.quantity}',
        '${item.unitName}',
        item.productName.toString(),
        'م'
      ];
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Table.fromTextArray(
        headers: headers,
        data: data,
        border: null,
        // headerStyle: TextStyle(fontWeight: FontWeight.bold),
        headerDecoration: BoxDecoration(color: PdfColors.grey300),
        cellHeight: 30,
        cellAlignments: {

          0: Alignment.center,
          1: Alignment.center,
          2: Alignment.center,
          3: Alignment.center,
          4: Alignment.center,
          5: Alignment.center,

          // 0: Alignment.centerLeft,
          // 1: Alignment.centerRight,
          // 2: Alignment.centerRight,
          // 3: Alignment.centerRight,
          // 4: Alignment.centerRight,
          // 5: Alignment.centerRight,
        },
      ),
    );
  }

  static Widget buildTotal(Invoice invoice) {
    final netTotal = (invoice.isMultiPages)? 0 : invoice.items
        .map((item) => item.unitPrice * item.quantity)
        .reduce((item1, item2) => item1 + item2);


    return Container(

      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildText2(
                  title: invoice.info.count.toString(),
                  value: 'عدد المنتجات ',
                  unite: true,
                ),




                Divider(),
                buildText2(
                  title: Utils.formatPrice((invoice.isMultiPages)?invoice.info.multiTotalPrice : netTotal),
                  value: 'إجمالي السعر ',
                  unite: true,
                  size: 14,
                ),

                SizedBox(height: 2 * PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
                SizedBox(height: 0.5 * PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
              ],
            ),

          ),
          Spacer(flex: 6),


        ],
      ),
    );
  }

  static Widget buildFooter(Invoice invoice) => Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Divider(),
      SizedBox(height: 2 * PdfPageFormat.mm),
      buildSimpleText(title: 'العنوان', value: invoice.supplier.address),
      SizedBox(height: 1 * PdfPageFormat.mm),
      buildSimpleText(title: 'للتواصل ', value: invoice.supplier.paymentInfo),
    ],
  );

  static buildSimpleText({
    String title,
    String value,
  }) {
    final style = TextStyle(fontWeight: FontWeight.bold);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [

        // Text(title, style: style),

        RichText(text: TextSpan(text:value, )),
        SizedBox(width: 2 * PdfPageFormat.mm),
        RichText(text: TextSpan(text:title, )),
        // Text(value),
      ],
    );
  }

  static buildText({
    String title,
    String value,
    double width = double.infinity,
    TextStyle titleStyle,
    bool unite = false,
  }) {
    final style = titleStyle ?? TextStyle(fontWeight: FontWeight.bold);

    return Container(
      width: width,
      child: Row(
        children: [
          Expanded(child: Text(title, style: style)),
          RichText(text: TextSpan(text:value, )),
          // Text(value, style: unite ? style : null),
        ],
      ),
    );
  }

  static buildText2({
    String title,
    String value,
    double width = double.infinity,
    double size,
    TextStyle titleStyle,
    bool unite = false,
  }) {
    // final style = titleStyle ?? TextStyle(fontWeight: FontWeight.bold);

    return Container(
      width: width,
      child: Row(
        mainAxisAlignment:MainAxisAlignment.center ,
        children: [
          Expanded(child: RichText(text: TextSpan(text:title,),textDirection: TextDirection.rtl)),
          RichText(text: TextSpan(text:value,style: TextStyle(
            fontSize: size,
          ) ),textDirection: TextDirection.rtl),
          // Text(value, style: unite ? style : null),
        ],
      ),

    );
  }

  static buildText3({
    String title,
    String value,
    double width = double.infinity,
    double size,
    TextStyle titleStyle,
    bool unite = false,
  }) {
    // final style = titleStyle ?? TextStyle(fontWeight: FontWeight.bold);

    return Container(
      width: 150,
      child: Row(
        // mainAxisAlignment:MainAxisAlignment.center ,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: RichText(text: TextSpan(text:value,),textDirection: TextDirection.rtl),),
          SizedBox(
              width: 10
          ),
          RichText(text: TextSpan(text:title,style: TextStyle(
            fontSize: size,
          ) ),textDirection: TextDirection.rtl),
          // Text(value, style: unite ? style : null),
        ],
      ),

    );
  }
}

// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart';
// import 'package:store/ui/reporting/models/customer.dart';
// import 'package:store/ui/reporting/models/invoice.dart';
// import 'package:store/ui/reporting/models/supplier.dart';
// import 'package:store/ui/reporting/pdf_api.dart';
// import 'package:store/ui/reporting/utils.dart';
//
// import 'package:flutter/material.dart' as mt;
//
// class PdfInvoiceApi {
//   static Future<File> generate(Invoice invoice,List<List<InvoiceItem>> itemsToPass) async {
//     final pdf = Document();
//
//
//     //new
//     var arabicFont = Font.ttf(await rootBundle.load("assets/fonts/HacenTunisia.ttf"));
//     var assetImage = MemoryImage(
//       (await rootBundle.load('assets/images/novelsoft.jpeg'))
//           .buffer
//           .asUint8List(),
//     );
//     var assetImage2 = MemoryImage(
//       (await rootBundle.load('assets/images/NovelSoftStamp.png'))
//           .buffer
//           .asUint8List(),
//     );
//
//
//     pdf.addPage(
//       MultiPage(
//
//         textDirection: TextDirection.rtl,
//         theme: ThemeData.withFont(
//           base: arabicFont,
//         ),
//
//         header:(context) => Directionality(textDirection: TextDirection.rtl,child: buildHeader(invoice,assetImage),),
//         build: (context) => [
//           for(int i = 0; i<itemsToPass.length;i++)...[
//             getAll(invoice,itemsToPass[i],(i == itemsToPass.length-1)?true:false),
//           ]
//
//         ],
//
//
//         footer: (context)=>buildFooter(invoice),
//
//         // pageFormat: PdfPageFormat.roll57
//         maxPages: 100,
//
//
//
//       ),
//     );
//
//
//     return PdfApi.saveDocument(name: 'my_invoice.pdf', pdf: pdf);
//   }
//
//   static Widget getAll(invoice,List<InvoiceItem> itemToPass,isFinalPage){
//     return Column(
//         children: [
//
//
//
//           SizedBox(height: 15),
//           // the table
//           Directionality(textDirection: TextDirection.rtl,child: Container(
//
//             child:buildTitle(invoice),
//
//           )),
//
//
//           buildInvoice(invoice, itemToPass),
//
//           (isFinalPage)? Divider():Container(),
//           (isFinalPage)?buildTotal(invoice):Container(),
//         ]
//     );
//   }
//
//
//
//   static Widget buildHeader(Invoice invoice,assetImage) => Directionality(
//     textDirection:TextDirection.rtl,
//     child: Container(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//
//           // SizedBox(height: 1 * PdfPageFormat.cm),
//           // for icon & name of base store
//           Row(
//             // mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Container(
//                   // width: 80
//                   // width: 110
//                 width: 30
//               ),
//               Container(
//
//                 height: 60,
//                 width: 100,
//                 // height: 60,
//                 // width: 150,
//                 // child: Image(assetImage,fit: BoxFit.fill,width: 80,height: 60,alignment: Alignment.center),
//                 child: Image(assetImage,),
//               ),
//
//               Expanded(
//                 child: buildSupplierAddress(invoice.supplier),
//               ),
//
//             ],
//           ),
//           // Row(
//           //   // mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           //   children: [
//           //     Container(
//           //         width: 110
//           //     ),
//           //     Container(
//           //       height: 50,
//           //       width: 50,
//           //       child: BarcodeWidget(
//           //         barcode: Barcode.qrCode(),
//           //         data: invoice.info.number,
//           //       ),
//           //     ),
//           //
//           //     Expanded(
//           //       child: buildSupplierAddress(invoice.supplier),
//           //     ),
//           //
//           //   ],
//           // ),
//           SizedBox(height: 1 * PdfPageFormat.cm),
//
//
//           // bill number and date & customer name and location
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               buildCustomerAddress(invoice.customer),
//               buildInvoiceInfo(invoice.info),
//
//
//
//             ],
//
//           ),
//
//
//
//         ],
//       ),
//     ),
//
//   );
//
//   static Widget buildCustomerAddress(Customer customer) => Column(
//     crossAxisAlignment: CrossAxisAlignment.end,
//     children: [
//       RichText(text: TextSpan(text:customer.name, )),
//       // Text(customer.name, style: TextStyle(fontWeight: FontWeight.bold)),
//       RichText(text: TextSpan(text:customer.address, )),
//       // Text(customer.address),
//     ],
//   );
//
//   static Widget buildInvoiceInfo(InvoiceInfo info) {
//     // final paymentTerms = '${info.dueDate.difference(info.date).inDays} days';
//     final titles = <String>[
//       'رقم الفاتورة:',
//       'تاريخ الفاتورة :',
//
//     ];
//     final data = <String>[
//       info.number,
//       Utils.formatDate(info.date),
//
//     ];
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: List.generate(titles.length, (index) {
//         final title = titles[index];
//         final value = data[index];
//
//         return buildText3(title: title, value: value, width: 200);
//       }),
//     );
//   }
//
//   static Widget buildSupplierAddress(Supplier supplier) => Directionality(
//     textDirection: TextDirection.rtl,
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         RichText(text: TextSpan(text: supplier.name, )),
//         // Text(supplier.name, style: TextStyle(fontWeight: FontWeight.bold)),
//         SizedBox(height: 1 * PdfPageFormat.mm),
//         RichText(text: TextSpan(text: supplier.address,)),
//       ],
//     ),
//   );
//
//   static Widget buildTitle(Invoice invoice) => Directionality(
//     textDirection: TextDirection.rtl,
//     child: Container(
//       margin: EdgeInsets.only(top: 30),
//       child: Row(
//           crossAxisAlignment:CrossAxisAlignment.end ,
//           children: [
//             Expanded(),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//
//               children: [
//                 RichText(
//                   text: TextSpan(text: 'فاتورة طلب شراء',style:TextStyle(fontSize: 24, ),
//                   ),
//                 ),
//
//                 SizedBox(height: 0.8 * PdfPageFormat.cm),
//                 RichText(text: TextSpan(text:invoice.info.description )),
//
//                 SizedBox(height: 0.8 * PdfPageFormat.cm),
//               ],
//             ),
//           ]
//       ),
//     ),
//   );
//
//   static Widget buildInvoice(Invoice invoice,List<InvoiceItem> itemToPass) {
//     final headers = [
//       'الإجمالي',
//       'السعر',
//       'الكمية',
//       'الوحدة',
//       'أسم المنتج',
//       'رمز المادة',
//       'م'
//
//     ];
//     final data = itemToPass.map((item) {
//       // final total = item.unitPrice * item.quantity * (1 + item.vat);
//       final total = item.unitPrice * item.quantity;
//
//       return [
//         '\$ ${total.toStringAsFixed(2)}',
//         '\$ ${item.unitPrice}',
//         // Utils.formatDate(item.date),
//         '${item.quantity}',
//         '${item.unitName}',
//         item.productName.toString(),
//         item.productMark.toString(),
//         '${item.rowNumber}'
//       ];
//     }).toList();
//
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Table.fromTextArray(
//         headers: headers,
//         data: data,
//         // border: null,
//         border: TableBorder(
//           horizontalInside: BorderSide(color: PdfColors.grey500),
//           left: BorderSide(color: PdfColors.grey500),
//           right: BorderSide(color: PdfColors.grey500),
//           top: BorderSide(color: PdfColors.grey500),
//           bottom: BorderSide(color: PdfColors.grey500),
//           // verticalInside: BorderSide(color: PdfColors.grey500),
//           // right: BorderSide(color: PdfColors.grey500),
//           // left: BorderSide(color: PdfColors.grey500),
//         ),
//         // headerStyle: TextStyle(fontWeight: FontWeight.bold),
//         headerDecoration: BoxDecoration(color: PdfColors.grey300),
//         cellHeight: 30,
//         cellAlignments: {
//
//           0: Alignment.center,
//           1: Alignment.center,
//           2: Alignment.center,
//           3: Alignment.center,
//           4: Alignment.center,
//           5: Alignment.center,
//           6: Alignment.center,
//
//           // 0: Alignment.centerLeft,
//           // 1: Alignment.centerRight,
//           // 2: Alignment.centerRight,
//           // 3: Alignment.centerRight,
//           // 4: Alignment.centerRight,
//           // 5: Alignment.centerRight,
//         },
//       ),
//     );
//   }
//   static Widget buildInvoice2( invoice) {
//     final headers = [
//       'الإجمالي',
//       'السعر',
//       'الكمية',
//       'الوحدة',
//       'أسم المنتج',
//       'رمز المادة'
//
//     ];
//     final data = invoice.items.map((item) {
//       // final total = item.unitPrice * item.quantity * (1 + item.vat);
//       final total = item.unitPrice * item.quantity;
//
//       return [
//         '\$ ${total.toStringAsFixed(2)}',
//         '\$ ${item.unitPrice}',
//         // Utils.formatDate(item.date),
//         '${item.quantity}',
//         '${item.unitName}',
//         item.productName.toString(),
//         'م'
//       ];
//     }).toList();
//
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Table.fromTextArray(
//         headers: headers,
//         data: data,
//         border: null,
//         // headerStyle: TextStyle(fontWeight: FontWeight.bold),
//         headerDecoration: BoxDecoration(color: PdfColors.grey300),
//         cellHeight: 30,
//         cellAlignments: {
//
//           0: Alignment.center,
//           1: Alignment.center,
//           2: Alignment.center,
//           3: Alignment.center,
//           4: Alignment.center,
//           5: Alignment.center,
//
//           // 0: Alignment.centerLeft,
//           // 1: Alignment.centerRight,
//           // 2: Alignment.centerRight,
//           // 3: Alignment.centerRight,
//           // 4: Alignment.centerRight,
//           // 5: Alignment.centerRight,
//         },
//       ),
//     );
//   }
//
//   static Widget buildTotal(Invoice invoice) {
//     final netTotal = (invoice.isMultiPages)? 0 : invoice.items
//         .map((item) => item.unitPrice * item.quantity)
//         .reduce((item1, item2) => item1 + item2);
//
//
//     return Container(
//
//       alignment: Alignment.centerLeft,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Spacer(flex: 6),
//           Expanded(
//             flex: 4,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 buildText2(
//                   title: invoice.info.count.toString(),
//                   value: 'عدد المنتجات ',
//                   unite: true,
//                 ),
//                 // buildText2(
//                 //   title: 'Net total',
//                 //   value: Utils.formatPrice(netTotal),
//                 //   unite: true,
//                 // ),
//
//
//
//                 Divider(),
//                 buildText2(
//                   // title: Utils.formatPrice(netTotal),
//                   title: Utils.formatPrice((invoice.isMultiPages)?invoice.info.multiTotalPrice : netTotal),
//                   value: 'إجمالي السعر ',
//                   unite: true,
//                   size: 14,
//                 ),
//                 // buildText(
//                 //   title: 'Total amount due',
//                 //   titleStyle: TextStyle(
//                 //     fontSize: 14,
//                 //     fontWeight: FontWeight.bold,
//                 //   ),
//                 //   value: Utils.formatPrice(total),
//                 //   unite: true,
//                 // ),
//                 SizedBox(height: 2 * PdfPageFormat.mm),
//                 Container(height: 1, color: PdfColors.grey400),
//                 SizedBox(height: 0.5 * PdfPageFormat.mm),
//                 Container(height: 1, color: PdfColors.grey400),
//               ],
//             ),
//
//           ),
//
//
//         ],
//       ),
//     );
//   }
//
//   static Widget buildFooter(Invoice invoice) => Column(
//     crossAxisAlignment: CrossAxisAlignment.center,
//     children: [
//       Divider(),
//       SizedBox(height: 2 * PdfPageFormat.mm),
//       buildSimpleText(title: 'العنوان', value: invoice.supplier.address),
//       SizedBox(height: 1 * PdfPageFormat.mm),
//       buildSimpleText(title: 'للتواصل ', value: invoice.supplier.paymentInfo),
//     ],
//   );
//
//   static buildSimpleText({
//     String title,
//     String value,
//   }) {
//     final style = TextStyle(fontWeight: FontWeight.bold);
//
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//
//         // Text(title, style: style),
//
//         RichText(text: TextSpan(text:value, )),
//         SizedBox(width: 2 * PdfPageFormat.mm),
//         RichText(text: TextSpan(text:title, )),
//         // Text(value),
//       ],
//     );
//   }
//
//   static buildText({
//     String title,
//     String value,
//     double width = double.infinity,
//     TextStyle titleStyle,
//     bool unite = false,
//   }) {
//     final style = titleStyle ?? TextStyle(fontWeight: FontWeight.bold);
//
//     return Container(
//       width: width,
//       child: Row(
//         children: [
//           Expanded(child: Text(title, style: style)),
//           RichText(text: TextSpan(text:value, )),
//           // Text(value, style: unite ? style : null),
//         ],
//       ),
//     );
//   }
//
//   static buildText2({
//     String title,
//     String value,
//     double width = double.infinity,
//     double size,
//     TextStyle titleStyle,
//     bool unite = false,
//   }) {
//     // final style = titleStyle ?? TextStyle(fontWeight: FontWeight.bold);
//
//     return Container(
//       width: width,
//       child: Row(
//         mainAxisAlignment:MainAxisAlignment.center ,
//         children: [
//           Expanded(child: RichText(text: TextSpan(text:title,),textDirection: TextDirection.rtl)),
//           RichText(text: TextSpan(text:value,style: TextStyle(
//             fontSize: size,
//           ) ),textDirection: TextDirection.rtl),
//           // Text(value, style: unite ? style : null),
//         ],
//       ),
//
//     );
//   }
//
//   static buildText3({
//     String title,
//     String value,
//     double width = double.infinity,
//     double size,
//     TextStyle titleStyle,
//     bool unite = false,
//   }) {
//     // final style = titleStyle ?? TextStyle(fontWeight: FontWeight.bold);
//
//     return Container(
//       width: 150,
//       child: Row(
//         // mainAxisAlignment:MainAxisAlignment.center ,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(child: RichText(text: TextSpan(text:value,),textDirection: TextDirection.rtl),),
//           SizedBox(
//               width: 10
//           ),
//           RichText(text: TextSpan(text:title,style: TextStyle(
//             fontSize: size,
//           ) ),textDirection: TextDirection.rtl),
//           // Text(value, style: unite ? style : null),
//         ],
//       ),
//
//     );
//   }
// }