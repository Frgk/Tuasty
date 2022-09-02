import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'recipes_page.dart';

class FavoriteRecipes extends StatefulWidget {
  @override
  _FavoriteRecipes createState() => _FavoriteRecipes();
}

class _FavoriteRecipes extends State<FavoriteRecipes> {
  String docName = "";
  ScrollController scrollController = ScrollController();



  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection('users')
      .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
      .snapshots();

  void removeItem(data, index){
    FirebaseFirestore.instance.collection('users')
        .doc(docName)
        .update({"favorite_recipes":FieldValue.arrayRemove([data?["favorite_recipes"][index]])});


  }

  Future _getUserData() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        setState(() => docName = element.id);
        // setState(()=> docRef = element.data());
      });
    });
  }

  @override
  void initState() {
    _getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
appBar: AppBar(
  leading: IconButton(
    icon: Icon(Icons.arrow_back_ios, color : Colors.black),
    onPressed: () => Navigator.of(context).pop(),

  ),

  centerTitle: true,
  automaticallyImplyLeading: true,
  shape: Border(
      bottom: BorderSide(
        color: Colors.black,
        width: 2,
      )
  ),

  flexibleSpace: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.yellow.shade500,
            Colors.yellow.shade400,
            Colors.yellow.shade300,
          ]),
    ),


  ),
),

      body :StreamBuilder<QuerySnapshot>(
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
                child :Container(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Column(
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
                                  child:Text("Vos recettes préférées !",style: TextStyle(
                                      fontSize: 25,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.bold
                                  ),)
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 10,),




                        data['favorite_recipes'].length==0?Text("Aucune recette trouvées !")
                            :ListView.separated(
                            separatorBuilder: (context,index){
                              return Divider(thickness: 1.5,indent: 20,endIndent: 20,);
                            },
                            itemCount: data['favorite_recipes'].length,
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                            itemBuilder: (context,index){

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
                                  Navigator.push(context,MaterialPageRoute(builder: (context)=>details_recette2( data['favorite_recipes'][index])));
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
                                            data['favorite_recipes'][index]['Images'].length>=3?Image.network(
                                              data['favorite_recipes'][index]['Images'][3],width: 300,
                                              errorBuilder: (context,Object excpetion,StackTrace? stackTrace){
                                                return Image.network("https://assets.afcdn.com/recipe/20100101/recipe_default_img_placeholder_w96h96c1.webp",width: 300,);
                                              },):Image.network("https://assets.afcdn.com/recipe/20100101/recipe_default_img_placeholder_w296h296c1.webp",width: 300,),

                                            Container(

                                                padding: EdgeInsets.only(top:15,left: 20,right: 20,bottom: 15),
                                                decoration: BoxDecoration(
                                                    color: Colors.grey.withOpacity(0.7),
                                                    borderRadius: BorderRadius.only(bottomRight: Radius.circular(30))
                                                ),
                                                child:Text(data['favorite_recipes'][index]["Difficulté"].toUpperCase(),style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    color: Colors.grey[200]
                                                ),)),

                                            Positioned(
                                                left: 220,
                                                child: RawMaterialButton(
                                                  onPressed: () async{

                                                    removeItem(data, index);

                                                  },
                                                  elevation: 2.0,
                                                  fillColor: Colors.white,
                                                  child: Icon(
                                                    Icons.delete,
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

                                            Text(data['favorite_recipes'][index]['Nom'],
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



                                          ],
                                        ),)
                                    ],
                                  ),

                                ),
                              );

                            }),








                      ],
                    ),
                  ),

                ),
              );
            })
                .toList()
                .cast(),
          );
        },
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
