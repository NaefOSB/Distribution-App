import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:photo_view/photo_view.dart';

class ShowImage extends StatefulWidget {
  var imgUrl;

  ShowImage({this.imgUrl});

  @override
  _ShowImageState createState() => _ShowImageState();
}

class _ShowImageState extends State<ShowImage> {

  _downLoadImageToRealDevice(imgURL) {
    try {
      if (imgURL
          .toString()
          .isNotEmpty) {

        ImageDownloader.downloadImage(imgURL,
            destination: AndroidDestinationType.custom(
                directory: 'My Store'));

      }
    }catch(e){
      print(e);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(

        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,color: Colors.white,),
            onPressed: ()=> Navigator.pop(context),
          ),
          actions: [
            IconButton(icon: Icon(FontAwesomeIcons.download,size: 20,color: Colors.white,), onPressed: () =>_downLoadImageToRealDevice(widget.imgUrl),
            ),
          ],
        ),

        body: GestureDetector(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Hero(
                tag: 'imageHero',
                child:PhotoView(
                  loadingChild: Center(child: CircularProgressIndicator()),
                  imageProvider: CachedNetworkImageProvider(widget.imgUrl),
                  // enableRotation: true,

                )
            ),
          ),
        ),

      ),
    );
  }
}