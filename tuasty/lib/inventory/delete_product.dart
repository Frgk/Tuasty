import 'dart:convert';import 'dart:io';



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:short_uuids/short_uuids.dart';
import 'package:tuasty/inventory/product.dart';
import 'package:tuasty/clientuser.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';


class delete_aliment extends StatefulWidget{

  final int index;
  final List<dynamic> data;



  const delete_aliment({Key? key, required this.index, required this.data}) : super(key: key);

  @override
  _delete_aliment createState() => _delete_aliment();
}

class _delete_aliment  extends State<delete_aliment> {

  var docRef = Map<String,dynamic>();
  var docName='';

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

  void removeItem(data, index){
    FirebaseFirestore.instance.collection('users')
        .doc(docName)
        .update({"inventory":FieldValue.arrayRemove([data[index]])});


  }

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(

      title: const Text('Supprimer un produit'),

      backgroundColor: Colors.white,
      content: const Text("Qu'avez-vous fait de l'aliment ?"),
      actions: [
        Row(
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // Background color
              ),
              icon: Icon(Icons.delete),
              onPressed: () async{

                await FirebaseFirestore.instance.collection('users').doc(docName).update({
                  "discarded_food": FieldValue.increment(1),

                });

                removeItem(widget.data, widget.index);

                Navigator.pop(context);

              },
              label: Text(
                  "Jeter"
              ),
            ),
            SizedBox(width: 10,),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // Background color
              ),
              icon: Icon(Icons.check),
              onPressed: () async{

                await FirebaseFirestore.instance.collection('users').doc(docName).update({
                  "consumed_food": FieldValue.increment(1),

                });
                removeItem(widget.data, widget.index);

                Navigator.pop(context);

              },
              label: Text(
                  "Consommer"
              ),
            ),




          ],



        ),

      ],
    );
  }
}