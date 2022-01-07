

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xml/xml.dart';
import 'package:share_plus/share_plus.dart';

class DH extends StatefulWidget {


  @override
  _DHState createState() => _DHState();
}

class _DHState extends State<DH>
{
  List haberler = [];

  @override
  void initState() {

    getData();
  }

  Future<bool> getData() async
  {
    var url = "https://www.donanimhaber.com/rss/tum";
    Response r = await Dio().get(url);
    var xml = XmlDocument.parse(r.data);
    haberler = xml.findAllElements("item").toList();
    print("Haber Sayısı : ${haberler.length}");
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "DonanımHaber",
          style: TextStyle(color: Colors.white,
              fontWeight:FontWeight.bold, fontSize: 25),),
      ),
      body : Container(
        width: double.maxFinite,
        child: FutureBuilder(
          future: getData(),
          builder: (context, snapshot)
          {
            // getData Sonuclanmadiysa
            if (snapshot.connectionState != ConnectionState.done)
              {
                return Center(
                  child: SizedBox(
                    height: 150,
                    width: 150,
                    child: CircularProgressIndicator(
                      strokeWidth: 10,
                    ),
                  ),
                );
              }
            else
              {
                return ListView.builder(
                    itemCount: haberler.length,
                    itemBuilder: (context, index)
                    {

                      var baslik = haberler[index].getElement("title").text;
                      var link = haberler[index].getElement("guid").text;
                      var imgUrl = haberler[index]
                          .getElement("enclosure").getAttribute("url");
                      print("Başlık : ${baslik}");
                      print("Haber Linki : ${link}");
                      print("Resim URL : ${imgUrl}");
                      return Card(
                        elevation: 6,
                        margin: EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                        child: InkWell(
                          onTap: () async
                          {
                            print("Tapped @ ${index}");
                            await launch(link);
                          },
                          onLongPress: ()
                          {
                            print("Long Pressed @ ${index}");
                            Share.share(link, subject: baslik);
                            },
                          child: Container(
                            width: double.maxFinite,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                /*
                                Image.network(
                                  imgUrl, fit: BoxFit.fitWidth ,),

                                 */
                                CachedNetworkImage(
                                    imageUrl: imgUrl,
                                  placeholder: (context, url)
                                  {
                                    return Image.asset("assets/dh_loader.png", fit: BoxFit.fitWidth,);
                                  },
                                ),
                                Container(
                                  padding: EdgeInsets.all(12),
                                  color: Colors.black54,
                                  alignment: Alignment.center,
                                  child: Text(
                                    baslik,
                                    style: TextStyle(fontSize: 20, color: Colors.white),
                                    //maxLines: 1,
                                    //overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },);
              }
          },
        ),
      ),
    );
  }


}
