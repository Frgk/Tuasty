


import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:tuasty/parameters/constant.dart';
import 'package:tuasty/recipes/favorite_recipes.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DebugPage extends StatefulWidget {





  @override
  _DebugPageState createState() => _DebugPageState();


}


class _DebugPageState extends State<DebugPage> {

  String docName = '';

  List<String> categories_inv = [];
  List<List<String>> n_categories_inv = [];

  ScrollController scrollController = ScrollController();
  int selected_index = 0;


  void initIngredient(var data){
    var temp_inv = data['inventory'];
    categories_inv = [];

    
    for(int i = 0; i< temp_inv.length;i++){
      List<String> categoriesList = List<String>.from(temp_inv[i]['categories'] as List);



      print(new List.from(categoriesList.reversed).sublist(0,3));
     // categories_inv.addAll(new List<String>.from(categoriesList.reversed).sublist(0,3));
      categories_inv = new List<String>.from(categoriesList.reversed);

    n_categories_inv.add(categories_inv);
    }
    print("NEW INV");
    print(categories_inv);
/*
    for(int i =0;i< categories_inv.length;i++){

      String st = categories_inv[i].trim().toLowerCase();
      n_categories_inv.add(st);
    }

 */



    print("NEW INV");
    print(n_categories_inv);


  }



  void ajoute_favorite(Map<String,dynamic> recette) async{


    var data = await FirebaseFirestore.instance
        .collection(
        'users')
        .doc(docName).get();

    List<dynamic> recipes_list = data['favorite_recipes'];




    if(recipes_list.length >= 10){

      displayToast(context, Colors.red, Colors.white, Icons.close, "Vous ne pouvez pas avoir plus de 10 recettes dans votre liste !");

    }
    else{

      if(recipes_list.contains(recette)){
        displayToast(context, Colors.red, Colors.white, Icons.close, "Vous avez déjà cette recette dans votre liste !");
      }
      else{


        await FirebaseFirestore.instance
            .collection('users')
            .doc(docName)
            .update({
          "favorite_recipes": FieldValue.arrayUnion([recette])
        });
    displayToast(context, Colors.green, Colors.white, Icons.check, "Recette ajoutée !");

      }


    }






  }

  Future _getUserData() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get()

        .then((value) {
      value.docs.forEach((element) {

        setState(()=> docName = element.id);
        // setState(()=> docRef = element.data());









      });
    });



  }

  @override
  void initState(){
    _getUserData();
    super.initState();


  }

  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance.collection('users').where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email).snapshots();

  List<String> ingredient_cat = [];



FirebaseFirestore db=FirebaseFirestore.instance;
late List<List<dynamic>> recipe_list;

List<String> items=['Accompagnement','Apéritif ou buffet','Confiserie','Dessert','Entrée','Plat Principal'];
String? dropdownvalue="Plat Principal";

/*
Future<List<List<dynamic>>> get_csv() async{
  var myData= await rootBundle.loadString("assets/recipe/recipe_test_3.csv");
  List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(myData);
  setState(()=>recipe_list=rowsAsListOfValues);
  return rowsAsListOfValues;
}
*/

List<String> categories_valide=['plat principal','dessert','apéritif ou buffet','entrée','confiserie','amuse-geule','accompagnement','sauce'];
void ajouter_recette(){
  int nb_rows=recipe_list.length;

  for(var k=0;k<100;k++){
    print("Recipe n°"+k.toString());


    if(k%1000==0){
      print("Pause");
      sleep(Duration(seconds: 10 ));
    }


    var recipe_info=recipe_list[k];

    String titre =recipe_info[0];
    var note=recipe_info[1];
    String temps=recipe_info[2];
    String difficulte=recipe_info[3];
    String prix=recipe_info[4];
    var nb_personne=recipe_info[5];
    var ingredients=recipe_info[6];
    var ustensiles=recipe_info[7];
    String temps_prepa=recipe_info[8];
    String temps_repos=recipe_info[9];
    String temps_cuisson=recipe_info[10];
    var processus=recipe_info[11];
    String url=recipe_info[12];
    var images=recipe_info[13];
    var categories=recipe_info[14];
    var auteur=recipe_info[15];
    var nb_commentaire=recipe_info[16];


    var list_ingredients=ingredients.split("], [");
    var final_list=[];
    for (String k in list_ingredients){
      k=k.replaceAll("[", "");
      k=k.replaceAll("]", "");
      //print(k);
      final_list.add(k.toString());
    }


    var list_ustensile=ustensiles.split("], [");
    var final_list_ustensile=[];
    for (String k in list_ustensile){
      k=k.replaceAll("[", "");
      k=k.replaceAll("]", "");
      //print(k);
      final_list_ustensile.add(k);
    }

    var list_etapes=processus.split("], [");
    var final_list_process=[];
    for (String k in list_etapes){
      k=k.replaceAll("[", "");
      k=k.replaceAll("]", "");
      //print(k);
      final_list_process.add(k);
    }


    var list_photos=images.split(" ");
    var final_list_photo=[];
    //print(list_photos);
    for(var k=0;k<list_photos.length/2;k=k+2){
      //print(" element : "+list_photos[k]);
      final_list_photo.add(list_photos[k]);
    }

    var real_categorie=categories.split(",")[0].toLowerCase();
    print(real_categorie);

    titre = titre.replaceAll("/", "_");

    if(categories_valide.contains(real_categorie)) {
      try {
        db.collection("recipes").doc("Recettes")
            .collection(real_categorie)
            .doc(titre)
            .set({
          "Nom": titre,
          "Note": note,
          "Temps": temps,
          "Difficulté": difficulte,
          "Prix": prix,
          "Nombre de personnes": nb_personne,
          "Ingrédient": final_list,
          "Ustensiles": final_list_ustensile,
          "Temps préparation": temps_prepa,
          "Temps repos": temps_repos,
          "Temps Cuisson": temps_cuisson,
          "Processus": final_list_process,
          "URL": url,
          "Images": final_list_photo,
          "Catégories": categories,
          "Auteur": auteur,
          "Nombre de commentaires":nb_commentaire.toString()
        });
      }catch(e){

      }
    }else{

    }

  }

}

var liste_recette_correspondante=[];
var display_result_found={};
var nb_ingredient_recipe={};
double loading_value=0;
Future<List> recherche_ingredient_opti(String ingredient,var _collec) async{
  Stopwatch stopwatch=new Stopwatch()..start();
  print('Debut fnction executed in ${stopwatch.elapsed}');

  List list_recette=[];
  int counter=0;
  print('debut get executed in ${stopwatch.elapsed}');

  //var get_coll= await _collec.get();
  //print('fin get) executed in ${stopwatch.elapsed}');
  //print('get all docs executed in ${stopwatch.elapsed}');

  List document=_collec.docs;

  //print('debut boucle de recherche executed in ${stopwatch.elapsed}');

  for(var k in document){
    //print(k.data()['ingrédient'].contains(ingredient));

    /*
      if(k.data()['Ingrédient'].contains(ingredient)){
        print("yaaaaaaa");
        list_recette.add(k.data()['Nom']);
      }

       */



    for(var ingr in k.data()['Ingrédient']){
      if(ingr.contains(ingredient)){
        list_recette.add(k.data()['Nom']);
        break;
      }
    }


  }
  print('fin fctn executed in ${stopwatch.elapsed}');

  return list_recette;
}
void recherche_ingredients_opti(List<List<String>> ingredients) async {
  Stopwatch stopwatch = new Stopwatch()
    ..start();
  print('Debut executed in ${stopwatch.elapsed}');
  setState(() => loading_value = 0);
  //String categorie_selected=formatted_category(_categorie_recette);
  //String categorie_selected = formatted_category_str(dropdownvalue);

  // Nouvelle valeur correspodant aux categories
  String categorie_selected = formatted_category_str(items[selected_index]);

  print('cate choisie executed in ${stopwatch.elapsed}');
  setState(() => loading_value = 0.01);
  CollectionReference selected_collection = await db.collection("recipes").doc(
      "Recettes").collection(categorie_selected);
  setState(() => loading_value = 0.05);
  var selected_collection2 = await selected_collection.where("")
      .limit(10)
      .get();
  print('Connexion faite executed in ${stopwatch.elapsed}');
  setState(() => loading_value = 0.1);
  var liste_recette = [];

for(var categorie_ingredient in ingredients){

  for (var ingredient in categorie_ingredient) {

    ingredient = ingredient.toLowerCase();

    print('Ingrédient in ${stopwatch.elapsed}');
    print(ingredient);
    print('début recherche executed in ${stopwatch.elapsed}');
    List result = await recherche_ingredient_opti(
        ingredient, selected_collection2);
    print('fin recherche executed in ${stopwatch.elapsed}');


    print("RES");
    print(result);

    setState(() => loading_value += (1 / ingredients.length) * 0.5);

    print('Debut ajout liste executed in ${stopwatch.elapsed}');
    if(result.isNotEmpty) {
      print("MAMAAAAADOOOO");
      for (var k in result) {
        liste_recette.add(k);
      }
      break;
    }
    print('fin ajout liste executed in ${stopwatch.elapsed}');


    /*
      print(liste_recette);
      print('');
      print(liste_recette.indexOf("Encornets farcis au poisson et légumes"));
      print(liste_recette[670]);
      print(liste_recette[671]);
      print(liste_recette[672]);
      print(liste_recette[673]);
      print('');

       */

  }
}

  setState(()=>loading_value=0.7);

  print('debut itération executed in ${stopwatch.elapsed}');

  var map=Map();
  liste_recette.forEach((element) {
    if(!map.containsKey(element)){
      map[element]=1;
    }else{
      map[element] +=1;
    }
  });
  print('fin itération executed in ${stopwatch.elapsed}');


  setState(()=>loading_value=0.8);

  print('début tri executed in ${stopwatch.elapsed}');

  //print(map);
  //var sorted_map=new SplayTreeMap<String,dynamic>.from(map,(a,b) => map[a]>map[b]? -1 : 1);
  var sorted_map=Map.fromEntries(map.entries.toList()..sort((e1,e2)=>e2.value.compareTo(e1.value)));
  //print(sorted_map);
  setState(()=> this.display_result_found=sorted_map);
  print('fin tri executed in ${stopwatch.elapsed}');


  setState(()=>loading_value=1.0);
  setState(()=>loading_value=0);

  print('debut ajout final executed in ${stopwatch.elapsed}');


  //Ajout des recettes dans la liste
  setState(()=> liste_recette_correspondante=[]);
  var final_list_recette=[];
  for(var k in sorted_map.keys){

    for(var i in selected_collection2.docs){
      if (i['Nom']==k){
        setState(()=> liste_recette_correspondante.add(i.data()));

      }
    }
    //var recette_serveur=await selected_collection.doc(k).get().then((value) => value.data());
    //setState(()=> liste_recette_correspondante.add(recette_serveur));
  }
  print('DEBUT TRI ${stopwatch.elapsed}');

  tri_complex();

  print('fin ajout final executed in ${stopwatch.elapsed}');





}

void tri_complex(){
  var map=display_result_found;
  var map2={};
  int counter=0;
  for(var i in map.values){
    var recipe_corresp=liste_recette_correspondante[counter];
    var nb_ingr_recipe=recipe_corresp['Ingrédient'].length;

    map2.addAll({recipe_corresp['Nom']:i});


    var ration_ingredient=i/nb_ingr_recipe;
    print("ration $ration_ingredient");

    map.update(map.keys.elementAt(counter), (value) => ration_ingredient);

    counter +=1;
  }
  setState(()=>nb_ingredient_recipe=map2);
  print(nb_ingredient_recipe);

  var sorted_map=Map.fromEntries(map.entries.toList()..sort((e1,e2)=>e2.value.compareTo(e1.value)));
  setState(()=>display_result_found=sorted_map);

  var final_list_recette=[];


  for(var k in sorted_map.keys){
    var right_recipe=liste_recette_correspondante.where((element) => element['Nom']==k).first;
    print("RIGHT RECIPE");
    //final_list_recette.add(liste_recette_correspondante[index]);
    final_list_recette.add(right_recipe);
  }
  print(final_list_recette);



  setState(()=>liste_recette_correspondante=final_list_recette);




}

String formatted_category_str(String? _catego){
  switch(_catego){
    case "Accompagnement":
      return 'accompagnement';
    case "Apéritif ou buffet":
      return 'apéritif ou buffet';
    case "Confiserie":
      return 'confiserie';
    case "Dessert":
      return 'dessert';
    case "Entrée":
      return 'entrée';
    case "Plat principal":
      return 'plat principal';
    default:
      return 'plat principal';
  }
}



  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }

        return Column(
          children: snapshot.data!.docs
              .map((DocumentSnapshot document) {
            Map<String, dynamic> data =
            document.data()! as Map<String, dynamic>;
            return Expanded(


             child : SingleChildScrollView(

                child :

                Column(
                  children: [

                    Container(
                      height: 120,
                      child:Stack(
                        children: [
                          Opacity(opacity: 0.5,
                            child: ClipPath(
                              clipper: WaveClipper(),
                              child: Container(
                                color: Colors.yellow,
                                height: 120,
                              ),
                            ),),
                          Opacity(opacity: 0.5,
                            child: ClipPath(
                              clipper: WaveClipper(),
                              child: Container(
                                color: Colors.amber,
                                height: 100,
                              ),
                            ),),
                          Padding(padding: EdgeInsets.only(top:20,left:20),
                              child:Text("Trouvez une recette !",style: TextStyle(
                                  fontSize: 25,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold
                              ),)
                          ),
                          Positioned(
                              left: 300,
                              top:0,
                              child: RawMaterialButton(
                                onPressed: (){

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => FavoriteRecipes()),
                                  );

                                },
                                elevation: 2.0,
                                fillColor: Colors.yellow,
                                child: Icon(
                                  Icons.bookmark,
                                  color : Colors.black,
                                  size: 35.0,
                                ),
                                padding: EdgeInsets.all(5.0),
                                shape: CircleBorder(),
                              )


                          ),

                        ],
                      ),
                    ),
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                        height: 140,
                        child:RawScrollbar(
                          controller: scrollController,
                          thumbVisibility: true,
                          thickness: 4,
                          thumbColor: Colors.grey[500],
                          radius: Radius.circular(20),
                          child:ListView.separated(
                              controller: scrollController,
                              separatorBuilder: (context,index){
                                return SizedBox(width: 25,);
                              },
                              physics: BouncingScrollPhysics(),
                              itemCount: 6,
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context,index){
                                return GestureDetector(
                                  onTap: (){
                                    setState(()=> selected_index=index);
                                  },
                                  child:Container(
                                      width: 80,
                                      child:Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                              radius: selected_index==index?38:36.5,
                                              backgroundColor: selected_index==index?Colors.black:Colors.grey[400],
                                              child: CircleAvatar(
                                                radius: 36,
                                                backgroundColor: selected_index==index?Colors.yellow[600]:Colors.white,
                                                child:Icon(items_icons[index],color: selected_index==index?Colors.black:Colors.grey[400],),
                                              )
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(items[index],
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: selected_index==index?Colors.black:Colors.grey[400],
                                                  fontWeight: selected_index==index?FontWeight.bold:FontWeight.normal,
                                                  fontStyle: FontStyle.italic,
                                                  fontSize: 15
                                              ),
                                            ),)
                                        ],
                                      )


                                  ),);


                              }),
                        )
                    ),
                    SizedBox(height: 10,),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RawMaterialButton(
                            onPressed: () {

                              initIngredient(data);

                              recherche_ingredients_opti(n_categories_inv);

                            },
                            elevation: 2.0,
                            fillColor: Colors.yellow[600],
                            child: Icon(
                              Icons.search_outlined,
                              size: 50.0,
                            ),
                            padding: EdgeInsets.all(15.0),
                            shape: CircleBorder(),
                          ),
                          /*
                  Container(
                    decoration: BoxDecoration(
                    ),
                    padding: EdgeInsets.only(top:30),
                  child:Container(
                    padding: EdgeInsets.only(left: 5,right: 5,top: 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.black,width: 1.2)
                      ),
                      child:DropdownButtonHideUnderline(
                      child:DropdownButton(
                      value: dropdownvalue2,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                      ),
                      dropdownColor: Colors.white,
                      icon: Icon(Icons.arrow_downward_sharp,color: Colors.black,),
                      items: nb_showing.map((int value) {
                        return DropdownMenuItem(value:value, child: Text(value.toString()));
                      }).toList(),
                      onChanged: (int? newValue){
                        setState(()=>dropdownvalue2=newValue);
                      })
                  ),
                  ),
                  ),

                   */
                        ],
                      ),
                    ),
                    loading_value==0?Text(""):CircularProgressIndicator(
                      value: loading_value,
                    ),


                    display_result_found.length==0?Text("Aucune recette trouvées !")
                        :ListView.separated(
                        separatorBuilder: (context,index){
                          return Divider(thickness: 1.5,indent: 20,endIndent: 20,);
                        },
                        itemCount: display_result_found.length>10?10:display_result_found.length,
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        itemBuilder: (context,index){
                          var nom_recette=display_result_found.keys.elementAt(index);
                          double nombre_ingredient=display_result_found.values.elementAt(index);
                          var recette_correspondante=liste_recette_correspondante[index];
                          var nb_ingredient_recette=recette_correspondante['Ingrédient'].length;
                          /*
                  return GestureDetector(
                  onTap: (){
                  print("Taper");
                  Navigator.push(context,MaterialPageRoute(builder: (context)=>details_recette2(recette_correspondante)));
                  },
                      child:Container(
                    padding: EdgeInsets.all(15),
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.blue,
                        border: Border.all(color: Colors.yellow,width: 5)
                      ),

                        child:Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Recette : "+nom_recette,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                          Text("Avis : "+recette_correspondante['Note'].toString()+"/5"),
                          Image.network(recette_correspondante['Images'][0],
                            errorBuilder: (context,Object excpetion,StackTrace? stackTrace){
                                  return Image.network("https://assets.afcdn.com/recipe/20100101/recipe_default_img_placeholder_w96h96c1.webp");
                            },),
                          SizedBox(height: 10,),
                          Text("Nombre ingrédients possédés : "+nombre_ingredient.toString()),
                          Text("Nombre ingrédient dans la recette : "+nb_ingredient_recette.toString())
                        ],
                      ),

                  )
                  );

                   */
                          return GestureDetector(
                            onTap: (){
                              print("Taper");
                              Navigator.push(context,MaterialPageRoute(builder: (context)=>details_recette2(recette_correspondante)));
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 22,vertical: 22),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children:[

                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: Stack(
                                      children:[
                                        recette_correspondante['Images'].length>=3?Image.network(
                                          recette_correspondante['Images'][3],width: 300,
                                          errorBuilder: (context,Object excpetion,StackTrace? stackTrace){
                                            return Image.network("https://assets.afcdn.com/recipe/20100101/recipe_default_img_placeholder_w96h96c1.webp",width: 300,);
                                          },):Image.network("https://assets.afcdn.com/recipe/20100101/recipe_default_img_placeholder_w296h296c1.webp",width: 300,),

                                        Container(

                                            padding: EdgeInsets.only(top:15,left: 20,right: 20,bottom: 15),
                                            decoration: BoxDecoration(
                                                color: Colors.grey.withOpacity(0.7),
                                                borderRadius: BorderRadius.only(bottomRight: Radius.circular(30))
                                            ),
                                            child:Text(recette_correspondante["Difficulté"].toUpperCase(),style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: Colors.grey[200]
                                            ),)),

                                        Positioned(
                                          left: 220,
                                            child: RawMaterialButton(
                                              onPressed: () async{

                                                ajoute_favorite(recette_correspondante);

                                              },
                                              elevation: 2.0,
                                              fillColor: Colors.white,
                                              child: Icon(
                                                Icons.bookmark,
                                                color : Colors.amber[800],
                                                size: 35.0,
                                              ),
                                              padding: EdgeInsets.all(5.0),
                                              shape: CircleBorder(),
                                            )


                                        ),

                                      ],),),
                                  SizedBox(height: 10,),
                                  Padding(
                                    padding: EdgeInsets.only(right: 70),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [

                                        Text(recette_correspondante['Nom'],
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,

                                          ),),
                                        /*
                              SizedBox(height: 8,),
                              Text("Recette "+recette_correspondante['Difficulté'],
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                fontSize: 15,
                                fontStyle: FontStyle.italic

                              ),),

                              */
                                        Text("Nombre ingrédients possédés : "+nb_ingredient_recipe[recette_correspondante['Nom']].toString(),style: TextStyle(
                                            fontSize: 15,
                                            fontStyle: FontStyle.italic
                                        ),),



                                      ],
                                    ),)
                                ],
                              ),

                            ),
                          );

                        }),







                    /*
                    SizedBox(height: 200,),
                    ElevatedButton(
                        onPressed: () {
                          print("appuyé");
                          ajouter_recette();
                        },
                        child: Text("ajouter rectte")
                    ),

                    /*
          FutureBuilder(
              future: get_csv(),
              builder: (context,snapshot){
                if(snapshot.hasError){
                  print(snapshot.error.toString());
                  return Text("Error");
                }else if (snapshot.hasData){
                  return Text("Document chargé !");
                }else{
                  return Column(
                    children: [
                      CircularProgressIndicator(),
                      Text("Chargment en cours")
                    ],
                  );
                }
              }),

           */


                    Container(
                      decoration:BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),

                      ),
                      padding: EdgeInsets.only(left:10,right: 10),
                      child:DropdownButton(
                          value: dropdownvalue,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black
                          ),
                          dropdownColor: Colors.white,
                          icon: Icon(Icons.arrow_downward_sharp,color: Colors.black,),
                          items: items.map((String value) {
                            return DropdownMenuItem(value:value, child: Text(value));
                          }).toList(),
                          onChanged: (String? newValue){
                            setState(()=>dropdownvalue=newValue);
                          }),),
                    SizedBox(width: 20,),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.white)
                        ),
                        onPressed: ()async {
                           initIngredient(data);

                          //recherche_ingredients_opti(["tomate","persil","beurre","comté","emmental","lait","oeufs","câpre","cornichon","jambon","rôti","crème frâiche","nouille","curry"]);
                           recherche_ingredients_opti(n_categories_inv);

                           //recherche_ingredients_opti(["jambon"]);

                           print("FAIITT");
                          //tri_complex();
                          print("FAITTTT222222");
                        },
                        child: Text("Rechercher recette ! ",style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black
                        ),)),

                     loading_value==0?Text(""):CircularProgressIndicator(
                      value: loading_value,
                    ),

                    display_result_found.length==0?Text("Aucune recette trouvées !")
                        :ListView.separated(
                        separatorBuilder: (context,index){
                          return Divider(thickness: 1.5,indent: 20,endIndent: 20,);
                        },
                        itemCount: display_result_found.length>10?10:display_result_found.length,
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        itemBuilder: (context,index){
                          var nom_recette=display_result_found.keys.elementAt(index);
                          double nombre_ingredient=display_result_found.values.elementAt(index);
                          var recette_correspondante=liste_recette_correspondante[index];
                          var nb_ingredient_recette=recette_correspondante['Ingrédient'].length;
                          /*
                  return GestureDetector(
                  onTap: (){
                  print("Taper");
                  Navigator.push(context,MaterialPageRoute(builder: (context)=>details_recette2(recette_correspondante)));
                  },
                      child:Container(
                    padding: EdgeInsets.all(15),
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.blue,
                        border: Border.all(color: Colors.yellow,width: 5)
                      ),

                        child:Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Recette : "+nom_recette,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                          Text("Avis : "+recette_correspondante['Note'].toString()+"/5"),
                          Image.network(recette_correspondante['Images'][0],
                            errorBuilder: (context,Object excpetion,StackTrace? stackTrace){
                                  return Image.network("https://assets.afcdn.com/recipe/20100101/recipe_default_img_placeholder_w96h96c1.webp");
                            },),
                          SizedBox(height: 10,),
                          Text("Nombre ingrédients possédés : "+nombre_ingredient.toString()),
                          Text("Nombre ingrédient dans la recette : "+nb_ingredient_recette.toString())
                        ],
                      ),

                  )
                  );

                   */
                          return GestureDetector(
                            onTap: (){
                              print("Taper");
                              Navigator.push(context,MaterialPageRoute(builder: (context)=>details_recette2(recette_correspondante)));
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 22,vertical: 22),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children:[ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: recette_correspondante['Images'].length>=3?Image.network(
                                      recette_correspondante['Images'][3],height: 250,
                                      errorBuilder: (context,Object excpetion,StackTrace? stackTrace){
                                        return Image.network("https://assets.afcdn.com/recipe/20100101/recipe_default_img_placeholder_w96h96c1.webp");
                                      },):Image.network("https://assets.afcdn.com/recipe/20100101/recipe_default_img_placeholder_w296h296c1.webp",height: 250,)),
                                  SizedBox(height: 10,),
                                  Padding(
                                    padding: EdgeInsets.only(right: 70),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Recette : "+recette_correspondante['Nom'],style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold
                                        ),),
                                        SizedBox(height: 8,),
                                        Text("Vous possédez "+(nombre_ingredient*100.round()).toStringAsFixed(0)+"% des ingrédients",style: TextStyle(
                                            fontSize: 15
                                        ),),
                                        Text("Nombre ingrédients possédés : "+nb_ingredient_recipe[recette_correspondante['Nom']].toString(),style: TextStyle(
                                            fontSize: 15
                                        ),),


                                      ],
                                    ),)
                                ],
                              ),

                            ),
                          );

                        }),
*/

                  ],


                ),

              ),


            );


          })
              .toList()
              .cast(),
        );
      },
    );


  }
}


class details_recette2 extends StatelessWidget{
  details_recette2(this.recette);

  final Map<String,dynamic> recette;

  String price_convert(String price){
    switch(price) {
      case 'bon marché':
        return '€';
      case 'moyen':
        return '€€';
      case 'assez cher':
        return '€€€';
      default:
        return '€';
    }
  }

  List<IconData> difficulty_convert(String difficulty){
    switch(difficulty){
      case 'facile':
        return [Icons.cookie_outlined,Icons.cookie_outlined];
      case 'très facile':
        return[Icons.cookie_outlined];
      case 'moyenne':
        return [Icons.cookie_outlined,Icons.cookie_outlined,Icons.cookie_outlined];
      case 'difficile':
        return [Icons.cookie_outlined,Icons.cookie_outlined,Icons.cookie_outlined,Icons.cookie_outlined];
      default:
        return[Icons.cookie_outlined];



    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        brightness: Brightness.light,
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },child: Icon(Icons.arrow_back_ios_sharp),
        ),
        actions: [
          Padding(padding: EdgeInsets.only(right: 20)),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20,),
                  Text(recette['Nom'],style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold
                  ),),
                  Text(recette['Catégories'].split(',')[0])
                ],
              ),
            ),
            SizedBox(height: 0,),
            Divider(
              indent: 20,
              endIndent: 0,
              thickness: 2,
            ),
            Container(
              height: 400,
              padding: EdgeInsets.only(left: 20),
              decoration: BoxDecoration(
                //border: Border.all(color: Colors.black,width:3),
                  borderRadius: BorderRadius.circular(40)
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Text("Informations : ",style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),),
                      SizedBox(height: 20,),
                      Container(
                        height: 60,
                        width: 212,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: Colors.black,width: 1)
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(5),
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  color:Colors.yellow,
                                  shape: BoxShape.circle
                              ),
                              child: Center(
                                child: Text(recette['Temps'].replaceAll('min',''),style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                ),),
                              ),
                            ),
                            SizedBox(width: 20,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Temps total",style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                ),),
                                Text("min",style: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic
                                ),)
                              ],

                            )
                          ],
                        ),

                      ),
                      SizedBox(height: 10,),

                      Container(
                        height: 60,
                        width: 186,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: Colors.black,width: 1)
                        ),
                        child: Row(
                          children: [
                            Container(
                              height:45,
                              width: 45,
                              padding: EdgeInsets.all(5),

                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color:Colors.yellow,
                              ),
                              child: Center(
                                child: Text(price_convert(recette['Prix']),style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                ),),
                              ),
                            ),
                            SizedBox(width: 20,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Coût total",style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                ),),
                                Text(recette['Prix'],style: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic
                                ),)

                              ],

                            )
                          ],
                        ),

                      ),
                      SizedBox(height: 10,),

                      Container(
                        height: 60,
                        width: 186,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: Colors.black,width: 1)
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding:EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: Colors.yellow,
                                  borderRadius: BorderRadius.circular(30)
                              ),
                              width: 80,
                              child:GridView(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    crossAxisSpacing:5,childAspectRatio:1),
                                shrinkWrap: true,
                                children: difficulty_convert(recette['Difficulté']).map((icon) => Icon(icon,size: 15,)).toList(),
                              ),
                            ),



                            SizedBox(width: 20,),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                Text("Difficulté",style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                ),),
                                Text(recette['Difficulté'],style: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic
                                ),)


                              ],

                            )
                          ],
                        ),

                      ),
                      SizedBox(height: 10,),
                      Container(
                        height: 60,
                        width: 210,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: Colors.black,width: 1)
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(5),
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  color:Colors.yellow,
                                  shape: BoxShape.circle
                              ),
                              child: Center(
                                child: RichText(
                                  text:TextSpan(
                                      children:[TextSpan(text:recette['Note'].toString(),style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold
                                      ),),
                                        TextSpan(text:"\n /5",style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12
                                        ))]
                                  ),),),
                            ),
                            SizedBox(width: 20,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Avis Global",style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                ),),
                                Text("Sur "+recette['Nombre de commentaires']+" commentaires",style: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 12
                                ),)
                              ],

                            )
                          ],
                        ),

                      ),


                    ],
                  ),
                  Positioned(
                    top: 60,
                    right: -135,
                    child: CircleAvatar(
                        radius: 162,
                        backgroundColor: Colors.white,
                        child:CircleAvatar(
                          radius: 160,
                          backgroundImage: NetworkImage(recette['Images'].length<=3?"https://assets.afcdn.com/recipe/20100101/recipe_default_img_placeholder_w296h296c1.webp":recette['Images'][6],),
                        )
                    ),

                  ),
                ],
              ),
            ),

            SizedBox(height: 20,),
            Padding(
              padding:EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    height: 30,
                    thickness: 2,
                  ),
                  Text("Ingrédients : ",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                  SizedBox(height: 3,),
                  Text("Nombres de personnes : "+recette['Nombre de personnes'].toString(),style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic
                  ),),
                  SizedBox(height: 10,),

                  ListView.separated(
                      physics: ScrollPhysics(),
                      separatorBuilder: (context,index){return SizedBox(height: 10,);},
                      shrinkWrap: true,
                      itemCount: recette['Ingrédient'].length,
                      itemBuilder: (context,index){
                        return Text(" ● "+recette['Ingrédient'][index].replaceAll("'","").replaceAll('"',""),style: TextStyle(fontSize:15),);
                      }),


                  SizedBox(height: 20,),
                  Divider(
                    height: 30,
                    thickness: 2,
                  ),
                  Text("Préparation",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                  SizedBox(height: 20,),
                  ListView.separated(
                      physics: ScrollPhysics(),
                      separatorBuilder: (context,index){return SizedBox(height: 10,);},
                      shrinkWrap: true,
                      itemCount: recette['Processus'].length,
                      itemBuilder: (context,index){
                        return Text("● "+recette['Processus'][index].replaceAll("'","").replaceAll('"',"")+'\n',
                          style: TextStyle(
                            fontSize:18,

                          ),);
                      })
                ],
              ),
            ),
            SizedBox(height: 15,),
            Divider(thickness: 2,),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child:Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(text: TextSpan(children: [
                    TextSpan(text:"Auteur : ",style: TextStyle(color: Colors.black,fontSize: 20)),
                    TextSpan(text:recette['Auteur'],style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold))
                  ])),
                  SizedBox(height: 10,),
                  RichText(
                      text: new TextSpan(
                          children: [
                            TextSpan(text:"La recette est trouvable : ",style: TextStyle(color: Colors.black,fontSize: 20)),
                            TextSpan(
                                text: "ICI",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap=(){launchUrlString(recette["URL"])
                                  ;})

                          ]
                      )),
                  SizedBox(height: 30,),
                ],
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
    var firstStart=Offset(size.width/6,size.height-10);
    var firstEnd=Offset(size.width/2+10,size.height-40);

    path.quadraticBezierTo(firstStart.dx, firstStart.dy,firstEnd.dx, firstEnd.dy);

    var secondStart=Offset(size.width-60,size.height-60);
    var secondEnd=Offset(size.width,size.height-30);

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
List<String> items=['Accompagnement','Apéritif ou buffet','Confiserie','Dessert','Entrée','Plat Principal'];
String? dropdownvalue="Plat Principal";
List<IconData> items_icons=[Icons.blender_outlined,Icons.breakfast_dining_outlined,Icons.icecream_outlined,Icons.cake_outlined,Icons.liquor_outlined,Icons.kebab_dining_outlined];