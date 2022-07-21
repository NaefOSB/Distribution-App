import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:store/ui/reporting/pdf_api.dart';
import 'package:store/ui/reporting/pdf_invoice_api.dart';
import 'package:store/ui/reporting/models/customer.dart';
import 'package:store/ui/reporting/models/invoice.dart';
import 'package:store/ui/reporting/models/supplier.dart';
import 'package:store/ui/reporting/widget/button_widget.dart';
import 'package:store/ui/reporting/widget/title_widget.dart';

class PdfPages extends StatefulWidget {
  @override
  _PdfPageState createState() => _PdfPageState();
}

class _PdfPageState extends State<PdfPages> {
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      title: Text('gfgx'),
      centerTitle: true,
    ),
    body: Container(
      padding: EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TitleWidget(
              icon: Icons.picture_as_pdf,
              text: 'Generate Invoice',
            ),
            const SizedBox(height: 48),
            ButtonWidget(
              text: 'Invoice PDF',
              onClicked: () async {
                final date = DateTime.now();
                final dueDate = date.add(Duration(days: 7));
                final store_id = 'KmXWzTeJR6QJubAJxWBfIV71y6X2';
                var invoices ;
                List<InvoiceItem> items=new List<InvoiceItem>();

                var requests = await Firestore.instance.collection('shopping_cart').document(store_id).collection('Requests').where('is_accepted',isEqualTo: true).getDocuments();
                if(requests.documents.length>0){



                  requests.documents.map((e) {




                    items.add( InvoiceItem(
                      productName: e['pro_name'],
                      date: DateTime.now(),
                      quantity: e['pro_quantity'] ,
                      unitPrice: double.parse(e['pro_price']),


                    ));

                  }).toList();
                  print('out the loop-------------------------------------------------------');

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
                        number: '${DateTime.now().year}-9999',
                      ),
                      items:items
                  );
                  print('after assignment-------------------------------------------------------');

                  // to make to report
                  // final pdfFile = await PdfInvoiceApi.generate(invoice);

                  // to open pdf file
                  // PdfApi.openFile(pdfFile);


                }




              },
            ),
          ],
        ),
      ),
    ),
  );
}