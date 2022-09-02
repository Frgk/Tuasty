

import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tuasty/news/article.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:tuasty/parameters/constant.dart';

class NewsPage extends StatefulWidget{
  @override
  _NewsPageState createState() => _NewsPageState();


}


class _NewsPageState extends State<NewsPage> with AutomaticKeepAliveClientMixin{

  @override
  bool get wantKeepAlive => true;

  late final prefs;


  Future<void>initializeParameter() async{

    prefs = await SharedPreferences.getInstance();



  }



  Future<List> get_article ()async {
    String url="https://newsapi.org/v2/everything?q=Alimentation%20AND%20nourriture%20ANS%20sant%C3%A9&sortBy=publishedAt&pageSize=100&language=fr&apiKey=f11d6b6aeab54e3bbe8a4216bbe1a659&page=1";
    final request_made =await http.get(Uri.parse(url));
    if (request_made.statusCode==200){
      var body=jsonDecode(request_made.body)['articles'];
      //print("BODY");
      //print(body);
      List list_article=await process_article(body);
      print("Processed");
      return list_article;
    }else{
      throw Exception('Failed to load');
    }
  }

  Future<List<Article>> process_article(var body) async{
    List<Article> list_article=[];
    int a=0;
    for(var k in body){
      //print("K : ");
      //print(k);
      var article=new Article(k['source']['name'],k['author'], k['title'], k['description'], k['url'], k['urlToImage'], k['publishedAt'], k['content']);
      //print("Article :");
      //print(article.titre);
      list_article.add(article);

    }
    print("fin");
    return list_article;
  }

  int daysBetween(DateTime from, String to) {
    var to_Date=DateTime.parse(to);
    from = DateTime(from.year, from.month, from.day);
    to_Date = DateTime(to_Date.year, to_Date.month, to_Date.day);
    return (from.difference(to_Date).inHours / 24).round();
  }

  @override
  void initState(){
    super.initState();
    initializeParameter();


  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: get_article(),
        builder: (context,snapshot){
          if(snapshot.hasData){
            List list_article=snapshot.data as List<Article>;
            return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment(0.8, 1),
                    colors: <Color>[
                      Colors.white,
                      Colors.yellow.shade100,
                      Colors.yellow.shade200,
                    ], // Gradient from https://learnui.design/tools/gradient-generator.html
                    tileMode: TileMode.mirror,
                  ),
                ),
                child:


              GridView.builder(
                  physics: ScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisExtent: 460,
                      childAspectRatio: 0.6,
                      mainAxisSpacing: 10),
                  padding: EdgeInsets.all(10),
                  itemCount: 10,//list_article.length ,
                  shrinkWrap: true,

                  itemBuilder: (context,index){
                    Article article=list_article[index];
                    return Container(

                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        //border: Border.all(color: Colors.yellow[200]!),
                        border : Border.all(color : Colors.yellow),
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.yellow[400]!,
                                Colors.yellow[500]!,


                              ]

                          ),
                         borderRadius: BorderRadius.circular(20)
                      ),

                      child:
                      Column(

                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [


                          SizedBox(height: 5,),
                          Align(

                            alignment: Alignment.center,
                            child:Text(article.titre==null? "Inconnu":article.titre!,textAlign: TextAlign.center,style: TextStyle(
                                fontSize:13,
                                fontWeight: FontWeight.bold,
                              fontFamily: 'Raleway',
                            ),),),
                          SizedBox(height: 20,),

                          article.url_image==null?
                          Text("Pas d'images"):
                          Image.network(article.url_image!,
                            height: 200,
                              fit:BoxFit.fill,
                          ),
                          SizedBox(height: 5),
                          Align(
                            alignment:
                            Alignment.bottomLeft,
                            child: Text("Paru sur : "+article.nom_source!,
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),

                          Align(
                            alignment: Alignment.bottomLeft,
                            child:Text(article.auteur==null? "Auteur : inconnu":"Auteur : "+article.auteur!,
                              style: TextStyle(
                              fontSize: 12,
                            ),
                            ),),
                          SizedBox(height: 10,),

                          Padding(
                          padding:  EdgeInsets.fromLTRB(7, 2, 2, 7),
                         child: RichText(
                              text: TextSpan(
                                  children: <TextSpan>[

                                    TextSpan(text:article.contenu!.split('[+')[0],
                                    style : TextStyle(
                                      color: Colors.black,
                                    ),
                                    ),
                                    TextSpan(

                                        text: "Voir plus !",
                                        style: TextStyle(color:Colors.red,fontWeight:FontWeight.bold,decoration: TextDecoration.underline),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap=(){
                                            launchUrlString(article.url!);
                                          }
                                    )

                                  ]

                              )),

                          ),

                          SizedBox(height: 20),
                          Align(
                            alignment:
                            Alignment.bottomRight,
                            child: Text("Publié il y a "+daysBetween(DateTime.now(),article.date! ).toString()+" jours",
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),


                        ],
                      ),
                    );
                  }),);

          }else if (snapshot.hasError){
            print(snapshot.error);
            print(snapshot.data);
            return Text("Error");
          }
          return  SizedBox(
            height: 100,
            width: 100,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
  }
}