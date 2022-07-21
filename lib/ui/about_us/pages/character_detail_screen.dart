import 'package:store/ui/about_us/models/characters.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class CharacterDetailScreen extends StatefulWidget {
  final Character character;

  const CharacterDetailScreen({Key key, this.character}) : super(key: key);

  @override
  _CharacterDetailScreenState createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Hero(
            tag: "background-${characters[0].name}",
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.character.colors,
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 16),
                  child: IconButton(
                    iconSize: 40,
                    icon: Icon(Icons.close),
                    color: Colors.white.withOpacity(0.9),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Hero(
                      tag: "image-{$characters[0].name}",
                      child: Image.asset(widget.character.imagePath, height: screenHeight * 0.45,color: Colors.white,)),
                ),
                Directionality(textDirection: TextDirection.rtl,
                    child: Container(

                      margin: EdgeInsets.symmetric(horizontal: 25.0),
                      padding: EdgeInsets.only(right: 10.0),
                      child: RichText(
                        text: TextSpan(
                          text: 'تم  تطوير هذا التطبيق من قبل شركة نوفل سوفت للبرمجيات  تحت إشراف المطور نائف عمر بافرج من قسم تطوير تطبيقات الموبايل. ',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,

                          ),
                          children: <TextSpan>[


                            TextSpan(
                              text: 'حساباتنا على مواقع التواصل الأجتماعي',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    )
                ),


                Padding(
                  padding: const EdgeInsets.only(top:10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      // IconButton(icon: Icon(Icons.info_outline,color: Colors.white,), onPressed: (){}),
                      // IconButton(icon: Icon(Icons.info_outline,color: Colors.white,), onPressed: (){}),
                      // IconButton(icon: Icon(Icons.info_outline,color: Colors.white,), onPressed: (){}),


                      IconButton(icon: Icon(FontAwesomeIcons.instagram,color: Colors.white,), onPressed: () async{

                        var url = 'https://www.instagram.com/novelsoft22?utm_medium=copy_link/';

                        if (await canLaunch(url)) {
                          await launch(
                            url,
                            universalLinksOnly: true,
                          );
                        } else {
                          throw 'There was a problem to open the url: $url';
                        }

                      }),
                      IconButton(icon: Icon(FontAwesomeIcons.facebookF,color: Colors.white,), onPressed: ()async{
                        // var fbUrl = 'https://fb.me/Novelsoft-101663398960736';

                        // var fbUrl = "fb://facewebmodal/f?href=https://m.facebook.com/Novelsoft-101663398960736/";
                        var fbUrl = "https://www.facebook.com/Novelsoft-101663398960736/";

                        await launch(fbUrl);





                      }),
                      IconButton(icon: Icon(FontAwesomeIcons.whatsapp,color: Colors.white,), onPressed: () async{
                        var whatsappUrl ="whatsapp://send?phone=+967730011440";
                        await canLaunch(whatsappUrl)? launch(whatsappUrl):print("open whatsapp app link or do a snackbar with notification that there is no whatsapp installed");
                      }),
                    ],
                  ),
                ),



              ],
            ),
          ),

         Positioned(
             bottom: 2,
             // right: 10,
             child: Container(
               width: MediaQuery.of(context).size.width,
               alignment: Alignment.center,
               child: Text('جميع الحقوق محفوظة لدى شركة نوفل سوفت ',style: TextStyle(color: Colors.white),),
             )
         ),

        ],
      ),
    );
  }
}