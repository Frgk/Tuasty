import 'dart:convert';

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:tuasty/inventory/product.dart';
import 'package:short_uuids/short_uuids.dart';
import 'package:http/http.dart' as http;

import 'package:tuasty/inventory/product.dart';

import 'package:intl/intl.dart';

import 'package:tuasty/inventory/detail_product.dart';
import 'package:tuasty/inventory/create_product.dart';
import 'package:tuasty/clientuser.dart';

import 'package:tuasty/parameters/constant.dart';

import 'package:tuasty/inventory/create_product_shopping_list.dart';












class ShoppingListPage extends StatefulWidget{
  @override
  _ShoppingListPageState createState() => _ShoppingListPageState();

}

class _ShoppingListPageState extends State<ShoppingListPage>  with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;


late Stream<QuerySnapshot> _innerStream;
  final user = FirebaseAuth.instance.currentUser!;
  final currentUser = FirebaseAuth.instance;
  final myUserId = FirebaseAuth.instance.currentUser?.uid;

  var docRef = Map<String,dynamic>();
  var docName='';
  var invSize = 0;

  Product? produitf;

  DateTime? _myDateTime;
  String time = '?';
  Map produitmap = {};

  final searchBarController = TextEditingController();

  String searching_text = "";

  List<bool> filterList = [true, false, false];





  Future _getUserData() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get()

        .then((value) {
      value.docs.forEach((element) {

        setState(()=> docName = element.id);
        setState(()=> docRef = element.data());







      });
    });



  }

  @override
  void initState() {

    super.initState();
    _getUserData();
    searchBarController.addListener(_onSearchChanged);
    _innerStream = FirebaseFirestore.instance.collection('users').where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email).snapshots();



  }

  _onSearchChanged(){
    print(searchBarController.text);
  }



  @override
  void dispose(){
    searchBarController.dispose();
    super.dispose();

  }

  void removeItem(data, index){
    FirebaseFirestore.instance.collection('users')
        .doc(docName)
        .update({"shopping_list":FieldValue.arrayRemove([data?["shopping_list"][index]])});


  }








  //final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance.collection('users').snapshots();
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance.collection('users').where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email).snapshots();

  Product process_request(String body, DateTime date) {
    final parsedJson=jsonDecode(body);
    var nom_produit=(parsedJson['product']['product_name']);
    print("nom");
    var image_url=(parsedJson['product']['image_url']);
    print("image");
    var code_barre=(parsedJson['product']['_id']);
    print("code");
    var nutriscore=(parsedJson['product']['nutrition_grade_fr']).toString().toUpperCase();

    nutriscore=(parsedJson['product']['nutrition_grades_tags'])[0].toString().toUpperCase();



    print("nutriscore");



    var nova=(parsedJson['product']['nova_group']);


    nova=(parsedJson['product']['nova_groups_tags'])[0].toString().toUpperCase();
    nova=nova.toString()[3];
    print("nova");


    List<String> analysis_ingredients=[];

    try {
      var analysis_ingredients_list= (parsedJson['product']['ingredients_analysis_tags']);
      for (String k in analysis_ingredients_list){
        k=k.replaceAll("en:",'');
        print("k :");
        print(k);
        k=traduction_analysis_ingredient(k);
        print("k :");
        print(k);
        analysis_ingredients.add(k);
      }
    }catch (e){
      analysis_ingredients.add("Pas donné");
    }
    print(analysis_ingredients);


    List<String> additifs=[];

    try {
      var additifs_list = (parsedJson['product']['additives_original_tags']);
      print("additif");
      print(additifs_list);
      for (String k in additifs_list){
        print(k);
        k=k.replaceAll("en:", "").toUpperCase();

        additifs.add(k);
      }
    }catch(e){
      additifs.add("Pas donné");
    }

    if (additifs==""){
      additifs.add("Pas donné");
    }




    var nutrient_levels_list=(parsedJson['product']['nutrient_levels_tags']);
    print("level");


    List <String>nutrient_levels=[];
    print(nutrient_levels_list);
    for (String k in nutrient_levels_list){
      k=k.replaceAll("en:", "");
      var list_k=k.split("-in-");
      print("k list");
      print(list_k[0]);
      print(list_k[1]);
      var nutrient = traduction_nutrient(list_k[0]);
      var level = traduction_level(list_k[1].replaceAll("-", " "));

      print("TRADU");
      print(nutrient);
      print(level);

      nutrient_levels.add(""+nutrient+" : "+level+"\n");
    }


    var marque=(parsedJson['product']['brands']);
    var generic_name=(parsedJson['product']['generic_name_fr']);

    List<String> categories=[];
    var categories_list=(parsedJson['product']['categories_hierarchy']);
    for (String k in categories_list){

      k=k.replaceAll("en:", "");
      categories.add(k);
    }
    print("categories");
    print(categories);


    print("fin process");



    //Product produit = Product(code_barre, nom_produit, image_url, nutriscore, nova, analysis_ingredients, additifs, nutrient_levels,date,marque,generic_name,categories);

    return Product(code_barre:code_barre, nom:nom_produit, image:image_url, nutriscore:nutriscore, nova:nova, analysis_ingredients:analysis_ingredients, additifs:additifs, nutrient_levels:nutrient_levels,date_peremption:date,marque:marque,generic_name:generic_name,categories:categories, id: ShortUuid().generate());
    //return Product("3068320124537", "nom_produit", "image_url", "nutriscore", "nova", ["analysis_ingredients"], ["additifs"], ["nutrient_levels"],DateTime.now(),"marque","generic_name",["categories"]);


    //setState(() =>produitf = produit);


  }


  String traduction_analysis_ingredient(String ingredient) {

    switch(ingredient){
      case 'palm-oil-content-unknown':
        return 'Contenu en huile de palme inconnu';
      case 'palm-oil-free':
        return "Sans huile de palme";
      case 'palm-oil':
        return "Présence d'huile de palme";

      case 'non-vegan':
        return 'Non végétalien';
      case 'vegan':
        return "Produit végétalien";
      case 'vegan-status-unknown':
        return "Statut végétalien inconnu";

      case 'vegetarian-status-unknown':
        return "Statut végétarien inconnu";
      case 'non-vegetarian':
        return 'Non végétarien';
      case 'vegetarian':
        return "Produit végétarien";
      default:
        return "Information pas connue/renseignée !";

    }
  }
  String traduction_nutrient(String nutrient){
    switch(nutrient){
      case 'fat':
        return "Gras";
      case 'saturated-fat':
        return "Acides gras saturé";
      case 'sugars':
        return "Sucres";
      case 'salt':
        return "Sel";
      default:
        return "Inconnu";
    }
  }
  String traduction_level(String level){
    switch (level){
      case 'moderate quantity':
        return "Quantité modérée";
      case 'high quantity':
        return "Quantité élevée";
      case 'low quantity':
        return "Faible quantité";
      default:
        return "Inconnu";
    }
  }


  Future<Product> find_aliment(String codebarre, DateTime date) async{
    final client = ClientWithUserAgent(http.Client());

    //if (codebarre.length !=13){


    //}else {
      var uri = Uri.http("fr.openfoodfacts.org",
          "/api/v0/product/" + codebarre.toString());
      var response = await client.get(uri);

     // setState(() => produitf = process_request(response.body, date));

      //print(produitf!.additifs);
        return process_request(response.body, date);

   // }

  }


 // var temp_inv = [];
 // var searched_inv = [];

 Future<Map<String,dynamic>> init_inventory() async{
    DocumentReference a= await FirebaseFirestore.instance.collection('users').doc(docName);
    var b=await a.get().then((value) => value.data() );

    b=b as Map<String,dynamic>;

   /* for(var k in b.keys){
      temp_inv.add(k);
    }*/

    return b;

 }

  List<String> categories=["Frais","Tous les produits","Sec"];

  int selected_index = 1;



  @override
  Widget build(BuildContext context){

/*
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: ListView(
        children: [
          SizedBox(height:20),


          Center(
          child :Text(
            "Vos idées de courses : ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          ),

          SizedBox(height:20),

          Container(
              padding: EdgeInsets.only(left: 30,right: 30,bottom: 0),
              width: 300,
              height: 50,
              decoration: BoxDecoration(
                  color: Color(0xfff2f2f2),
                  borderRadius: BorderRadius.circular(20),
                  border:Border.all(color: Colors.grey,width: 1)
              ),
              child: TextField(
controller: searchBarController,
                decoration: InputDecoration(
                    labelText: 'Vous recherchez quel aliment ?',
                  prefixIcon: Icon(Icons.search,size: 30,),
                ),
              )


          ),
/*
          TextField(
            controller: searchBarController,
            decoration: InputDecoration(
              labelText: 'Type what you are searching !',
              prefixIcon: Icon(Icons.search),

            ),
            onChanged: (val) {

              setState(() {
                searching_text = val;

              });
            },

          ),

 */
          SizedBox(height: 10,),
          ToggleButtons(
            renderBorder: false,
            selectedColor: Colors.black,
            disabledColor: Colors.black,
            highlightColor: Colors.green,
            fillColor: Colors.yellow,
            textStyle: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 12),
            isSelected: filterList,
            children: [
              SizedBox(
                  height: 20,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width / 3,
                  child: Center(child: Text('Tous les aliments')),
                ),

             SizedBox(
                  height: 20,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width / 3,
                  child: Center(child: Text('Frais')),
                ),

            SizedBox(
                  height: 20,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width / 3,
                  child: Center(child: Text('Secs')),
                ),

            ],
            onPressed: (int newIndex) {
              setState(() {
              /*  var cursor =  filterList.length - 1;
                while (cursor >= 0) {
                  if (cursor == newIndex) {
                    filterList[newIndex] = ! filterList[newIndex];
                  } else {
                    filterList[cursor] = false;
                  }

                  cursor--;
                }*/

                for(int index =0; index < filterList.length; index++){
                  if(index == newIndex){
                    filterList[index] = true;
                  } else {
                    filterList[index] = false;
                  }
                }

                print(filterList);
                // isSelected[index] = !isSelected[index];
              });
            },

          ),



        StreamBuilder<QuerySnapshot>(
    //stream: _usersStream,
          stream : (searching_text != "" && searching_text != null)
           // ? FirebaseFirestore.instance.collection('users').where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email).snapshots()
          // : FirebaseFirestore.instance.collection('users').where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email).snapshots(),
              ? _innerStream
              : _innerStream,
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasError) {
        return const Text('Something went wrong');
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Text("Loading");
      }
      else {



        return Column(
          children: snapshot.data!.docs
              .map((DocumentSnapshot document) {
            Map<String, dynamic> data =
            document.data()! as Map<String, dynamic>;

            var temp_inv = data['shopping_list'];
            var searched_inv = [];

            for(int i = 0; i < temp_inv.length; i++){

              if(temp_inv[i]['nom'].toString().toLowerCase().contains(searchBarController.text.toLowerCase())) {
               if(filterList[0] == true){
                 searched_inv.add(temp_inv[i]);
               }
               if(filterList[1] == true && (temp_inv[i]['categories'].indexWhere((e) => produitFrais.contains(e.toString().toLowerCase())) > -1)){
               //if(filterList[1] == true && temp_inv[i]['categories'].contains(['dairies','Viandes', 'Fromages'])){
                 searched_inv.add(temp_inv[i]);
               }
               if(filterList[2] == true && (temp_inv[i]['categories'].indexWhere((e) => produitSecs.contains(e.toString().toLowerCase())) > -1)){
               //if(filterList[2] == true && temp_inv[i]['categories'].contains(['groceries', 'Céréales', 'Biscuits'])){
                 searched_inv.add(temp_inv[i]);
               }
    }

            }

           searched_inv.sort((a, b){ //sorting in ascending order
             return DateTime.parse(a['date-peremption']).compareTo(DateTime.parse(b['date-peremption']));
            });



          if (temp_inv.isEmpty){
            return Align(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Text("Votre liste est vide !"),
                ],
              ),

            );
          } else if (searched_inv.isEmpty){
            return Align(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Text("Vous n'avez aucun aliment correspondant à la recherche !"),
                ],
              ),

            );
          } else {


/*
  return Center(
    child: Column(
      children: [
        SizedBox(height: 50),

        TextButton(
            onPressed: () async{


/*
              await FirebaseFirestore.instance.collection('users').doc(docName)
                  .update({
                "inventory.0.nom" : "eau2",
              });

 */
            var vmap = await data['inventory'];

              vmap[0]["date-peremption"] = "2022-22-22";
              //produitmap["date-peremption"] = "2022-22-22";

            print(vmap);


              await FirebaseFirestore.instance.collection('users')
            .doc(docName).set({"inventory" : vmap}, SetOptions(merge: true));


/*
              final batch = FirebaseFirestore.instance
                  .batch();
              final dbRef = FirebaseFirestore.instance
                  .collection('users').doc(docName);

              batch.update(
                  dbRef, {"inventory.0": produitmap});

              batch.commit().then((_) {
                // ...
              });
*/


            },
            child: Text('modify')
        ),
        TextButton(
            onPressed: () async{
              Random random = new Random();
              int randomNumber = random.nextInt(100);
              Product produitf = await find_aliment("3068320124537", DateTime.utc(random.nextInt(90) + 2010, 11, 9));

              print(produitf.toJson());

              print("");








              await FirebaseFirestore.instance.collection('users')
                  .doc(docName)
                  .update({"inventory":FieldValue.arrayUnion([produitf.toJson()])});







            },
            child: Text('add')),
        SizedBox(height : 50),


        TextButton(
            onPressed: () {
              print(data['inventory']['0']['nom']);
            },
            child: Text('print'))

      ],
    ),

  );
*/




            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,


              children: [


                SizedBox(height: 10),



               // SizedBox(height: 10),




                SingleChildScrollView(
                  child: Container(
                    height: MediaQuery
                        .of(context)
                        .size
                        .height / 2.5,


                    child: ListView.builder(

                        shrinkWrap: true,
                        physics: ScrollPhysics(),


                        itemCount: searched_inv.length,
                        //itemCount: data['inventory'].length ?? [],
                        itemBuilder: (context, index) {
                          /*
                          return GestureDetector(


                            child : Container(



                              // padding: EdgeInsets.all(2),
                              // width: 0.99 * MediaQuery.of(context).size.width,
                              width : double.infinity,
                              height: 100,

                              decoration: new BoxDecoration(
                                color: Colors.white,
                                // border : Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),



                              ),



                              child :Row(
                                mainAxisAlignment: MainAxisAlignment.center,

                                children: [
                                  Image.network(
                                    data['inventory'][index]['image'],
                                    height: 60,
                                    width: 60,
                                  ),
                                  SizedBox(width: 2,),
                                  Container(
                                    height: 40,
                                    width: 1,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(width: 15,),


                                  Expanded(

                                    child: Column(
                                      mainAxisAlignment:MainAxisAlignment.start,
                                      crossAxisAlignment:CrossAxisAlignment.start,

                                      children : [

                                        SizedBox(height: 12,),

                                        //  SingleChildScrollView(
                                        //    scrollDirection : Axis.horizontal,
                                        //  child :
                                        Text(
                                          data['inventory'][index]['nom'],
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,



                                          ),

                                        ),

                                        //  ),
                                        SizedBox(height: 7,),


                                        SizedBox(height: 1,),

                                    Text(
                                      "Quantité : " + searched_inv[index]["quantité"].toString(),

                                      style : TextStyle(
                                      fontSize: 14,

                                      color : Colors.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    textAlign: TextAlign.left,

                                  ),









                                      ],
                                    ) ,



                                  ),

Row(
                    children :[



                      IconButton(
                        icon: const Icon(Icons.plus_one),
                        color: Colors.green,
                        onPressed: () async {
                          print("appui");

                          List<dynamic> product = searched_inv;

                          product[index]['quantité'] += 1;

                          await FirebaseFirestore.instance
                              .collection(
                              'users')
                              .doc(docName).set(
                              {"shopping_list": searched_inv},
                              SetOptions(merge: true));




                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.exposure_minus_1),
                        color: Colors.red,
                        onPressed: () async {

                          List<dynamic> product = searched_inv;

                          product[index]['quantité'] -= 1;

                          await FirebaseFirestore.instance
                              .collection(
                              'users')
                              .doc(docName).set(
                              {"shopping_list": searched_inv},
                              SetOptions(merge: true));


                          if(product[index]['quantité'] == 0){

                            removeItem(data, index);

                          }


                        },
                      ),

                      SizedBox(width:2,),

                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.grey,
                      ),

                      SizedBox(width:2,),



                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.black38,
                        onPressed: () {

                          removeItem(data, index);



                        },
                      ),

                            ],
),



                                ],

                              ),
                            ),

                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder : (context) => DetailsProduct(product: data['inventory'][index],)),
                              );
                            },
                          );
                          */

                          return Padding(padding: EdgeInsets.symmetric(horizontal: 3,vertical: 5),
                            child:Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      colors: [
                                        Colors.yellow.shade800,
                                        Colors.yellow.shade700,
                                        Colors.yellow.shade600,
                                        Colors.yellow.shade500
                                      ],
                                      stops: [
                                        0.0,
                                        0.1,
                                        0.4,
                                        0.8,
                                      ]
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [BoxShadow(
                                      offset: Offset(0,0),
                                      blurRadius: 2,
                                      spreadRadius: 2,
                                      color: Colors.black26
                                  )]
                              ),
                              padding: EdgeInsets.only(left: 10,right: 10),
                              height: 110,
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child:  Image.network(
                                      searched_inv[index]['image'],
                                    width: 120,
                                      height : 100,
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  Expanded(

                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 10),
                                        child:Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [



                                            Expanded(

                                              child: Text(searched_inv[index]['nom'],
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold

                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 5,),
                                            Expanded(flex:0,child: Text("Quantité : " + searched_inv[index]["quantité"].toString(),style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 15,
                                                fontStyle: FontStyle.italic
                                            ),)),
                                            SizedBox(height: 7,),
                                            Container(
                                              width: 220,
                                              height: 1,
                                              decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius: BorderRadius.circular(40)
                                              ),

                                            ),
                                            SizedBox(height: 5,),
                                            Padding(padding:EdgeInsets.symmetric(horizontal: 20),
                                                child:Row(

                                                  children: [
                                                    SizedBox(
                                                        height:32,
                                                        width: 70,
                                                        child:ElevatedButton(
                                                            onPressed: () async {

                                                              List<dynamic> product = searched_inv;

                                                              product[index]['quantité'] += 1;

                                                              await FirebaseFirestore.instance
                                                                  .collection(
                                                                  'users')
                                                                  .doc(docName).set(
                                                                  {"shopping_list": searched_inv},
                                                                  SetOptions(merge: true));





                                                            },
                                                            style: ElevatedButton.styleFrom(
                                                                primary: Colors.yellow[200]
                                                            ),
                                                            child: Icon(Icons.add,color: Color(0xff403814),))),
                                                    SizedBox(width: 20,),
                                                    SizedBox(
                                                        height:32,
                                                        width: 70,
                                                        child:ElevatedButton(
                                                            onPressed: () async {

                                                              List<dynamic> product = searched_inv;

                                                              product[index]['quantité'] -= 1;

                                                              await FirebaseFirestore.instance
                                                                  .collection(
                                                                  'users')
                                                                  .doc(docName).set(
                                                                  {"shopping_list": searched_inv},
                                                                  SetOptions(merge: true));


                                                              if(product[index]['quantité'] == 0){

                                                                removeItem(data, index);

                                                              }


                                                            },
                                                            style: ElevatedButton.styleFrom(
                                                                primary: Colors.yellow[200]
                                                            ),
                                                            child: Icon(Icons.remove_circle_outline,color: Color(0xff403814),))),
                                                  ],)
                                            ),
                                          ],),
                                      ),


                                  ),

                                ],
                              ),
                            ),);

                        }
                    ),

                  ),
                ),


              ],
            );


          }

          })
              .toList()
              .cast(),



        );


        /*
          return ListView(
            children: snapshot.data!.docs
                .map((DocumentSnapshot document) {
              Map<String, dynamic> data =
              document.data()! as Map<String, dynamic>;
              return SingleChildScrollView(
                child: Center(
                  child: Column(

                    children: [

                      SizedBox(height: 50),

                      Text(
                        "INVENTORY OF " +
                            (snapshot.data!.docs[0].id).toString(),
                      ),


                      ListView.builder(
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          itemCount: data['inventory'].length ?? [],
                          itemBuilder: (context, index) {
                            return Card(

                              child: ExpansionTile(

                                title: Text(
                                    data["inventory"][index]["nom"]
                                ),
                                subtitle: Text("Date : " +
                                    data["inventory"][index]["date-peremption"]),
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      data["inventory"][index]["image"]),
                                  // onBackgroundImageError: ,

                                  child: Text(""),
                                ),
                                children: <Widget>[
                                  ListTile(
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        removeItem(data, index);
                                      },


                                    ),


                                  ),
                                  TextButton(
                                      onPressed: () async {
                                        _myDateTime = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.parse(
                                              data["inventory"][index]["date-peremption"]),
                                          firstDate: DateTime(2010),
                                          lastDate: DateTime(2025),
                                        );

                                        setState(() {
                                          time =
                                              DateFormat('yyyy-MM-dd').format(
                                                  _myDateTime!);
                                        });

                                        print("AVANT");
                                        print(data['inventory'][index]);


                                        produitmap =
                                        await data['inventory'][index];
                                        produitmap["date-peremption"] =
                                            time.toString();


                                        print("APRES");
                                        print(produitmap);

                                        print("TEST");

                                        final batch = FirebaseFirestore.instance
                                            .batch();
                                        final dbRef = FirebaseFirestore.instance
                                            .collection('users').doc(docName);

                                        batch.update(
                                            dbRef, {"inventory.0": produitmap});

                                        batch.commit().then((_) {
                                          // ...
                                        });

                                        /*

                                      await FirebaseFirestore.instance
                                          .collection('users')
                                      .doc(docName)
                                      .update({
                                        "inventory.0" : produitmap,
                                      });
*/
/*
                                      await FirebaseFirestore.instance.collection('users')
                                          .doc(docName)
                                          .update({
                                        "inventory."+(index.toString()) : produitmap,

                                      });


*/

                                      },
                                      child: Text("Change the date")),

                                  TextButton(
                                      onPressed: () =>
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      DetailsProduct(
                                                          product: data['inventory'][index]))
                                          ),
                                      child: Text("MORE INFORMATIONS")
                                  ),

                                ],
                              ),

                            );
                          }
                      ),


                      SizedBox(height: 20),
                      TextButton(onPressed: () async {
                        final product = {

                          "name": "produitdetest",
                          "code-barre": 0101,
                          "id": ShortUuid().generate(),
                          "date": "25/25/2525",


                        };


                        Product produitf = await find_aliment(
                            "3068320124537", new DateTime.now());

                        print(produitf.toJson());

                        print("");
                        print(jsonEncode(produitf.toJson()));


                        FirebaseFirestore.instance.collection('users')
                            .doc(docName)
                            .update({
                          "inventory": FieldValue.arrayUnion(
                              [produitf.toJson()])
                        });
                      },
                          child: Text('Add Item to Inventory')
                      ),
                      SizedBox(height: 40),

                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon( // <-- Icon
                          Icons.add,
                          size: 24.0,
                        ),
                        label: Text('Add a product'), // <-- Text
                      ),

                      SizedBox(height: 40),
                      TextButton(
                        onPressed: () => FirebaseAuth.instance.signOut(),
                        child: Text('SIGN OUT'),
                      ),


                    ],
                  ),


                ),
              );
            })
                .toList()
                .cast(),
          );


   */


        var userDatapath = snapshot.data?.docs[0];



/*
    return Scaffold(
       // appBar: AppBar(title: Text('Home')),
        body: SingleChildScrollView(
          child: Center(




                  //print("inv nom " + data?['inventory'][0]["nom"]);




                    child: Column(

                      children: [

                        SizedBox(height:50),

                        Text(
                          "INVENTORY OF "+(userDatapath?.id).toString(),
                        ),






                        ListView.builder(
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                            itemCount: userDatapath?['inventory'].length ?? [],
                            itemBuilder: (context, index) {


                                return Card(

                                  child: ExpansionTile(

                                    title: Text(
                                        userDatapath?['inventory.'+(index.toString())]['nom']),
                                    subtitle: Text("Date : " +
                                        userDatapath?['inventory.'+(index.toString())]["date-peremption"]),
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(userDatapath?['inventory.'+(index.toString())]["image"]),
                                     // onBackgroundImageError: ,

                                      child: Text(""),
                                    ),
                                    children: <Widget>[
                                      ListTile(
                                        trailing: IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            removeItem(userDatapath, index);
                                          },


                                        ),


                                      ),
                                      TextButton(
                                          onPressed: () async{

                                            _myDateTime = await showDatePicker(
                                                context: context,
                                                initialDate: DateTime.parse(userDatapath?['inventory'+(index.toString())]["date-peremption"]),
                                                firstDate: DateTime(2010),
                                                lastDate: DateTime(2025),
                                            );

                                            setState(() {
                                              time = DateFormat('yyyy-MM-dd').format(_myDateTime!);
                                            });



                                            produitmap = await snapshot.data?.docs[0]['inventory'+(index.toString())];
                                            produitmap["date-peremption"] = time.toString();

                                            /*

                                            await FirebaseFirestore.instance.collection('users')
                                                .doc(docName)
                                                .update({
                                                  "inventory."+(index.toString()) : produitmap,

                                            });


                                             */

                                            final batch = FirebaseFirestore.instance
                                                .batch();
                                            final dbRef = FirebaseFirestore.instance
                                                .collection('users').doc(docName);

                                            batch.update(
                                                dbRef, {'inventory'+(index.toString()): produitmap});

                                            batch.commit().then((_) {
                                              // ...
                                            });



                                          },
                                          child: Text("Change the date")),

                                      TextButton(
                                          onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => DetailsProduct(
                                                    product : userDatapath?['inventory'+(index.toString())]))
                                          ),
                                          child: Text("MORE INFORMATIONS")
                                      ),

                                    ],
                                  ),

                                );

                            }
                        ),



                        SizedBox(height: 20),
                        TextButton(onPressed: () async{

                          final product = {

                            "name":"produitdetest",
                            "code-barre": 0101,
                            "id" : ShortUuid().generate(),
                            "date":"25/25/2525",


                          };


                          Product produitf = await find_aliment("3068320124537", new DateTime.now());

print(produitf.toJson());

                          print("");
                          print(jsonEncode(produitf.toJson()));





                          FirebaseFirestore.instance.collection('users')
                              .doc(docName)
                              .update({"inventory":FieldValue.arrayUnion([produitf.toJson()])});





                        },
                            child: Text('Add Item to Inventory')
                        ),
                        SizedBox(height:40),

                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon( // <-- Icon
                            Icons.add,
                            size: 24.0,
                          ),
                          label: Text('Add a product'), // <-- Text
                        ),

                        SizedBox(height : 40),
                        TextButton(
                          onPressed: () => FirebaseAuth.instance.signOut(),
                          child: Text('SIGN OUT'),
                        ),



                      ],
                    ),


                  ),




          ),



    );
*/

      }
    },
    ),


          Divider(thickness: 2,indent: 20,endIndent: 20,color: Colors.black,),
          SizedBox(height:20),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(

                child: Text(
                  "Ajouter un produit",
                  style : TextStyle(
                      fontStyle: FontStyle.italic

                  ),
                ),
              ),
              SizedBox(height : 10),

              RawMaterialButton(
                onPressed: () async {
                  showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => add_aliment_to_shoplist());
                },
                elevation: 2.0,
                fillColor: Colors.yellow[600]!,
                child: Icon(
                  Icons.add,
                  size: 30,
                  color: Colors.black,
                ),
                padding: EdgeInsets.all(15),
                shape: CircleBorder(),
              ),
            ],
          ),



      
    ],


      ),

    )
    */


    return Scaffold(
      backgroundColor: Colors.white,



      body: Center(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 50,left: 15),
              height: 80,
              color: Colors.amber.withOpacity(0.6),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children:[
                    Icon(Icons.arrow_back_ios_sharp),
                    SizedBox(width: 50,),
                    Text("Votre liste de courses",style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold
                    ),)
                  ]
              ),
            ),
            Container(
              height: 180,
              child:Stack(
                children: [
                  Opacity(opacity: 0.5,
                    child: ClipPath(
                      clipper: WaveClipper(),
                      child: Container(
                        color: Colors.yellow,
                        height: 180,
                      ),
                    ),),
                  Opacity(opacity: 0.5,
                    child: ClipPath(
                      clipper: WaveClipper(),
                      child: Container(
                        color: Colors.amber,
                        height: 160,
                      ),
                    ),),
                  Align(
                    alignment: Alignment.center,
                    child:Column(
                        children:[
                          SizedBox(height: 20,),
                          Container(
                              padding: EdgeInsets.only(left: 15,right: 15,bottom: 0.5),
                              width: 300,
                              height: 50,
                              decoration: BoxDecoration(
                                  color: Color(0xfff2f2f2),
                                  borderRadius: BorderRadius.circular(20),
                                  border:Border.all(color: Colors.grey,width: 1)
                              ),
                              child: TextField(
                                onChanged: (val) {
                                  setState(() {
                                    searching_text = val;
                                  });
                                },

                                decoration: InputDecoration(
                                    hintText: "Vous recherchez quel aliment ?",
                                    suffixIcon: Icon(Icons.search,color: Colors.black,size: 30,)
                                ),
                              )


                          ),
                          SizedBox(height: 10,),
                          SizedBox(
                            height: 30,
                            child: ListView.separated(
                                separatorBuilder: (context,index){
                                  return VerticalDivider(
                                    thickness: 1,
                                    color: Colors.grey[600],
                                  );
                                },
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: categories.length,
                                itemBuilder: (context,index){
                                  return GestureDetector(
                                    onTap: (){

                                      setState(() => selected_index = index);
                                      print(selected_index);

                                    },
                                    child : Container(
                                        padding: EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: Colors.transparent,
                                          //border: Border.all(color: Colors.black,width: 0.1),

                                        ),
                                        child:Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 20),
                                            child:Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children:[Text(categories[index]),
                                                  Container(
                                                    width: categories[index].length<6?25:110,
                                                    height: 3,
                                                    decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        borderRadius: BorderRadius.circular(20)
                                                    ),
                                                  )])
                                        )),

                                  );
                                }),
                          ),
                        ]
                    ),
                  ),
                ],
              ),
            ),
            Align(
                alignment: Alignment.topLeft,
                child:Padding(
                  padding: EdgeInsets.only(left: 10),
                  child:Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      Text("Produits à acheter : ",style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 23
                      ),),
                      SizedBox(height: 3,),
                      Container(
                        height: 5,
                        width: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                              begin: Alignment.bottomLeft,
                              colors: [
                                Colors.yellow.shade800,
                                Colors.yellow.shade700,
                                Colors.yellow.shade600,
                                Colors.yellow.shade500
                              ],
                              stops: [
                                0.0,
                                0.1,
                                0.4,
                                0.8,
                              ]
                          ),
                        ),
                      ),
                    ],
                  ),
                )),

            SizedBox(height: 10,),


        StreamBuilder<QuerySnapshot>(
          //stream: _usersStream,
          stream : (searching_text != "" && searching_text != null)
          // ? FirebaseFirestore.instance.collection('users').where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email).snapshots()
          // : FirebaseFirestore.instance.collection('users').where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email).snapshots(),
              ? _innerStream
              : _innerStream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading");
            }

            return Stack(
            children: snapshot.data!.docs
        .map((DocumentSnapshot document) {
    Map<String, dynamic> data =
    document.data()! as Map<String, dynamic>;

    var temp_inv = data['shopping_list'];
    var searched_inv = [];

    for(int i = 0; i < temp_inv.length; i++){

      if(temp_inv[i]['nom'].toString().toLowerCase().contains(searching_text.toLowerCase())) {

        print("TESTTTT");

        if(selected_index == 1){
          searched_inv.add(temp_inv[i]);
        }
        if(selected_index == 0 && (temp_inv[i]['categories'].indexWhere((e) => produitFrais.contains(e.toString().toLowerCase())) > -1)){
          //if(filterList[1] == true && temp_inv[i]['categories'].contains(['dairies','Viandes', 'Fromages'])){
          searched_inv.add(temp_inv[i]);
        }
        if(selected_index == 2 && (temp_inv[i]['categories'].indexWhere((e) => produitSecs.contains(e.toString().toLowerCase())) > -1)){
          //if(filterList[2] == true && temp_inv[i]['categories'].contains(['groceries', 'Céréales', 'Biscuits'])){
          searched_inv.add(temp_inv[i]);
        }
      }

    }

    searched_inv.sort((a, b){ //sorting in ascending order
    return DateTime.parse(a['date-peremption']).compareTo(DateTime.parse(b['date-peremption']));
    });



    if (temp_inv.isEmpty){
    return Align(
    child: Column(
    children: [
    SizedBox(height: 20),
    Text("Votre liste est vide !"),
    ],
    ),

    );
    } else if (searched_inv.isEmpty){
    return Align(
    child: Column(
    children: [
    SizedBox(height: 20),
    Text("Vous n'avez aucun aliment correspondant à la recherche !"),
    ],
    ),

    );
    } else {


    return

      Container(
          height: 200,
          child: RawScrollbar(
            thumbVisibility: true,
            thumbColor: Colors.amber,
            thickness: 8,
            radius: Radius.circular(50),
            child: ListView.separated(
                scrollDirection: Axis.vertical,
                physics: BouncingScrollPhysics(),
                separatorBuilder: (context,index){
                  return SizedBox(height: 5,);
                },
                shrinkWrap: true,
                itemCount: searched_inv.length,
                itemBuilder: (context,index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                    child:Container(
                        height: 110,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                            boxShadow: [BoxShadow(
                                offset: Offset(0, 0),
                                blurRadius: 1.5,
                                spreadRadius: 1.5,
                                color: Colors.black26
                            )
                            ]
                        ),

                        padding: EdgeInsets.all(10),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: Image.network(

                                searched_inv[index]['image'],
                                fit: BoxFit.cover,
                                height: 70.0,
                                width: 100.0,
                              ),
                            ),
                            SizedBox(width: 30,),
                            Column(
                              children: [


                                Container(
                                  padding: EdgeInsets.only(top:8),
                                  height: 40,
                                  width: 170,
                                  color:Colors.white,
                                  child: Text(searched_inv[index]['nom'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14

                                    ),
                                  ),
                                ),
                                SizedBox(height: 0,),
                                Align(
                                  alignment: Alignment.center,
                                  child: Row(
                                    children: [

                                      IconButton(
                                        icon: Icon(Icons.add_circle_outline_rounded,size: 28,color: Colors.amber[800],),

                                        onPressed: () async {
                                          print("appui");

                                          List<dynamic> product = searched_inv;

                                          product[index]['quantité'] += 1;

                                          await FirebaseFirestore.instance
                                              .collection(
                                              'users')
                                              .doc(docName).set(
                                              {"shopping_list": searched_inv},
                                              SetOptions(merge: true));




                                        },
                                      ),


                                      Text(searched_inv[index]['quantité'].toString(),style: TextStyle(
                                          fontWeight:FontWeight.bold,
                                          fontSize: 22
                                      ),),

                                      IconButton(
                                        icon: Icon(Icons.remove_circle_outline_rounded,size: 28,color: Colors.amber[800],),

                                        onPressed: () async {

                                          List<dynamic> product = searched_inv;

                                          product[index]['quantité'] -= 1;

                                          await FirebaseFirestore.instance
                                              .collection(
                                              'users')
                                              .doc(docName).set(
                                              {"shopping_list": searched_inv},
                                              SetOptions(merge: true));


                                          if(product[index]['quantité'] == 0){

                                            removeItem(data, index);

                                          }


                                        },
                                      ),


                                    ],),
                                )

                              ],),

                          ],
                        )
                    ),);
                }
            ),
          )
      );
              }})
                  .toList()
                  .cast(),
            );
          },
        ),

            /*
            Container(
                height: 200,
                child: RawScrollbar(
                  thumbVisibility: true,
                  thumbColor: Colors.amber,
                  thickness: 8,
                  radius: Radius.circular(50),
                  child: ListView.separated(
                      scrollDirection: Axis.vertical,
                      physics: BouncingScrollPhysics(),
                      separatorBuilder: (context,index){
                        return SizedBox(height: 5,);
                      },
                      shrinkWrap: true,
                      itemCount: 10,
                      itemBuilder: (context,index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                          child:Container(
                              height: 100,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.white,
                                  boxShadow: [BoxShadow(
                                      offset: Offset(0, 0),
                                      blurRadius: 1.5,
                                      spreadRadius: 1.5,
                                      color: Colors.black26
                                  )
                                  ]
                              ),

                              padding: EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: Image.network(

                                      "https://www.aquaportail.com/pictures2001/nourriture-saine-fruits-legumes.jpg",
                                      fit: BoxFit.cover,
                                      height: 70.0,
                                      width: 100.0,
                                    ),
                                  ),
                                  SizedBox(width: 30,),
                                  Column(
                                    children: [


                                      Container(
                                        padding: EdgeInsets.only(top:8),
                                        height: 40,
                                        width: 170,
                                        color:Colors.white,
                                        child: Text("Nom produit",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14

                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10,),
                                      Align(
                                        alignment: Alignment.center,
                                        child: Row(
                                          children: [
                                            Icon(Icons.add_circle_outline_rounded,size: 28,color: Colors.amber[800],),
                                            SizedBox(width: 20,),
                                            Text("2",style: TextStyle(
                                                fontWeight:FontWeight.bold,
                                                fontSize: 22
                                            ),),
                                            SizedBox(width: 20,),
                                            Icon(Icons.remove_circle_outline_rounded,size: 28,color: Colors.amber[800],)
                                          ],),
                                      )

                                    ],),

                                ],
                              )
                          ),);
                      }
                  ),
                )
            ),

             */
            SizedBox(height: 20,),


            SizedBox(
              height: 80,
              width: 80,
              child:
              Container(decoration:BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  boxShadow:[BoxShadow(
                      offset: Offset(0,0),
                      blurRadius: 1.5,
                      spreadRadius: 1.5,
                      color: Colors.black26
                  )]
              ),
                child:RawMaterialButton(
                  onPressed: () async {
                    showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => add_aliment_to_shoplist());
                  },
                  elevation: 2.0,
                  fillColor: Colors.yellow[600]!,
                  child: Icon(
                    Icons.add,
                    size: 30,
                    color: Colors.black,
                  ),
                  padding: EdgeInsets.all(15),
                  shape: CircleBorder(),
                ),
              ),
            ),
          ],

        ),
      ),
    );

















  }


}

class WaveClipper extends CustomClipper<Path>{
  @override
  Path getClip(Size size) {
    debugPrint(size.width.toString());
    var path=new Path();
    path.lineTo(0, size.height-10);
    var firstStart=Offset(size.width/6,size.height-40);
    var firstEnd=Offset(size.width/2+10,size.height-30);

    path.quadraticBezierTo(firstStart.dx, firstStart.dy,firstEnd.dx, firstEnd.dy);

    var secondStart=Offset(size.width-60,size.height-30);
    var secondEnd=Offset(size.width,size.height-50);

    path.quadraticBezierTo(secondStart.dx, secondStart.dy,secondEnd.dx, secondEnd.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;

  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }



}