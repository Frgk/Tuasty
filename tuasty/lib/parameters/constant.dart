



import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:short_uuids/short_uuids.dart';

import '../inventory/delete_product.dart';
import '../inventory/detail_product.dart';
import 'package:dart_random_choice/dart_random_choice.dart';

List<String> produitSecs = ['groceries', 'céréales', 'biscuits','waters','sauces', 'spreads','confiseries','conserves'];
List<String> produitFrais = ['dairies','viandes', 'fromages','surgelés','poissons'];


void displayToast(BuildContext context, Color toastColor,Color contentColor, IconData icon, String toastText){
  FToast fToast = FToast();
  fToast.init(context);


  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: toastColor,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
          color: contentColor,
        ),
        SizedBox(

          width: 12.0,
        ),
        Flexible(
        child :Text(toastText,
        overflow: TextOverflow.visible,
        style : TextStyle(
        color: contentColor,

        ),
        ),
        ),
      ],
    ),
  );
  fToast.showToast(
    child: toast,
    gravity: ToastGravity.TOP,
    toastDuration: Duration(seconds: 2),
  );


}

Color getColorComparingDate(DateTime productDate, DateTime comparisonDate){
  DateTime compdate = DateTime(comparisonDate.year, comparisonDate.month, comparisonDate.day);

  if(productDate.isBefore(compdate)) return Colors.red;
  else if (productDate.isAtSameMomentAs(compdate)) return Colors.orange;
  else return Colors.green;
}

Widget productWidget(BuildContext context, Map<String,dynamic> data, String docName, int index, DateTime? myDate, List<dynamic> searched_inv) {
  return GestureDetector(


    child : Container(



      // padding: EdgeInsets.all(2),
      // width: 0.99 * MediaQuery.of(context).size.width,
      width : double.infinity,
      height: 75,

      decoration: new BoxDecoration(
        color: Colors.white,
        // border : Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5),



      ),



      child :Row(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Image.network(
            searched_inv[index]['image'],
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
                  searched_inv[index]['nom'],
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

                Row(
                  children: [
                    Text(
                      "Date : ",
                      style :TextStyle(
                        fontSize: 14,
                        color : Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.left,

                    ),
                    Text(
                      searched_inv[index]["date-peremption"],
                      style : TextStyle(
                        fontSize: 14,

                        color : getColorComparingDate(DateTime.parse(searched_inv[index]["date-peremption"]), DateTime.now()),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.left,

                    ),




                  ],
                ),



                SizedBox(height: 1,),







              ],
            ) ,



          ),

          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            color: Colors.black45,
            onPressed: () async {
              myDate = await showDatePicker(
                context: context,
                initialDate: DateTime.parse(
                  // data['inventory'][index]["date-peremption"]),
                    searched_inv[index]["date-peremption"]),
                firstDate: DateTime(2000),
                lastDate: DateTime(2250),
              );


              String time =
              await DateFormat('yyyy-MM-dd').format(
                  myDate!);


/*
                          produitmap = await snapshot.data?.docs[0]['inventory'][index];
                          produitmap["nom"] = "Eau 2";
*/


              searched_inv[index]["date-peremption"] =
                  time;
              //produitmap["date-peremption"] = "2022-22-22";


              await FirebaseFirestore.instance
                  .collection(
                  'users')
                  .doc(docName).set(
                  {"inventory": searched_inv},
                  SetOptions(merge: true));


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
/*
                          batch.update(
                              dbRef, {'inventory':{
                                '0':p.toJson()}});


 */


              batch.commit().then((_) {
                // ...
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.black38,
            onPressed: () {

              showDialog<String>(
                  context: context,
                  builder : (BuildContext context) => delete_aliment(data: searched_inv,index: index));



            },
          ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            color: Colors.black38,
            onPressed: () async{

              Map<String,dynamic> product = searched_inv[index];

              product['id'] = ShortUuid().generate();
              product.addAll({"quantité" : 1});


                await FirebaseFirestore.instance.collection('users')
                    .doc(docName)
                    .update({"shopping_list":FieldValue.arrayUnion([product])});


                displayToast(context, Colors.green, Colors.white, Icons.check, "Produit ajouté à votre liste d'idées !");




            },
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
}

String getRandomHomeMessage(){

  List<String> message = [
    "L'objectif d'aujourd'hui : zéro gaspi !",
    "Evitez le gâchis et faites des économies !",
    "Qu'allez-vous cuisiner aujourd'hui ?",
    "C'est une bonne journée pour éviter de gaspiller !",







  ];

  return randomChoice(message);




}











