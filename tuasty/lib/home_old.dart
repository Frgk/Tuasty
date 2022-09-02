import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:tuasty/inventory/product.dart';
import 'package:short_uuids/short_uuids.dart';
import 'package:tuasty/screen/blue_screen.dart';





class HomePage extends StatefulWidget{
  @override
  _HomePageState createState() => _HomePageState();

}

class _HomePageState extends State<HomePage>{
  final user = FirebaseAuth.instance.currentUser!;

  final currentUser = FirebaseAuth.instance;

  final myUserId = FirebaseAuth.instance.currentUser?.uid;


  var docRef;
  var docName;



 Future _getUserData() async {
   FirebaseFirestore.instance
       .collection('users')
       .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
       .get()

       .then((value) {
     value.docs.forEach((element) {
       docRef = element.data();
        docName = element.id;

     });
   });

 }



  @override
  void initState() {
      _getUserData();
      super.initState();

  }













  //final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance.collection('users').snapshots();
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance.collection('users').where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email).snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        return Text("");

        /*
        return Center(
          child: Column(

            children: [
              SizedBox(height:50),

              Text(
                "INVENTORY OF "+docName,
              ),

              /*
              ListView.builder(itemBuilder: itemBuilder
              ),

              */

              SizedBox(height: 20),
              TextButton(onPressed: () {

                FirebaseFirestore.instance.collection('users')
                    .doc(docRef['name']).collection("inventory")
                    .add({
                  "code-barre" : 0001,
                  "name":"test",


                });


              },
                  child: Text('Add Item to Inventory')
              ),
              SizedBox(height:40),
              TextButton(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  child: Text('SIGN OUT'),
              ),



            ],
          ),


        );

        */
/*
        return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            shrinkWrap: true,
            itemBuilder: (context,i){
              var data = snapshot.data!.docs[i];
              return Column(
                children: [
                  //Text("Name : " + data['name']),
                  SizedBox(height:10),
                  Text("ID : " +snapshot.data!.docs[i].id),
                  SizedBox(height:10),
                  Text('Inventory : '),

                  TextButton(onPressed: () {
                    print(docRef);
                  },
                      child: Text('print inv'),
                  ),













                  SizedBox(height:40),

                  TextButton(
                      onPressed: () async{



                      final product = {
                        'name': 'nametestproduct',
                        'code-barre': 001,
                        "id" : ShortUuid().generate(),
                      };



                      /*


                     await FirebaseFirestore.instance.collection('users')
                          .withConverter(
                          fromFirestore: Product.fromFirestore,
                          toFirestore: (Product obj, options) => obj.toFirestore())
                      .doc(snapshot.data!.docs[i].id+"/inventory").set(obj);


                        FirebaseFirestore.instance.collection('users')
                            .doc(snapshot.data!.docs[i].id).collection("inventory")
                            .add({
                                  "code-barre" : 0001,
                                "name":"test",


                        })
                        */

                      FirebaseFirestore.instance.collection('users')
                          .doc(snapshot.data!.docs[i].id)
                      .update({"inventory":FieldValue.arrayUnion([product])});






                      },
                      child: Text('Add item to inventory')
                  ),

                  TextButton(onPressed: () => FirebaseAuth.instance.signOut(),
                      child: Text('SIGN OUT')),


                ],
            );
      },
    );

        */
  }
    );
  }









/*



  @override
  Widget build(BuildContext context){
    return Scaffold(

      appBar: AppBar(
        title: Text('HOME'),
      ),



      body:


      Container(

        child: Column(
          children: [

          Text(
          'Signed in as',
          style :  TextStyle(fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
          user.email!,
          style : TextStyle(fontSize: 20),
        ),
        SizedBox(height:40),
        TextButton(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
          ),
          onPressed: () => FirebaseAuth.instance.signOut(),
          child: Text('Logout'),
        ),

            SizedBox(height:40),
            TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
              onPressed: () => FirebaseAuth.instance.signOut(),
              child: Text('Add Item'),
            ),


      ],
        ),





      ),

      drawer: Drawer(

        child:Column(

          children: [


           StreamBuilder(
             stream : FirebaseFirestore.instance
                 .collection('users')
                 //.doc(FirebaseAuth.instance.currentUser!.uid)
             .where("uid", isEqualTo: currentUser.currentUser!.uid)
                 .snapshots(),
               builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){

        if(snapshot.hasData){
                 return ListView.builder(
                     itemCount: snapshot.data!.docs.length,
                     shrinkWrap: true,
                     itemBuilder: (context,i){
                       var data = snapshot.data!.docs[i];
                   return Column(
                     children: [
                       Text("Name : " + data['name']),
                       Text("ID : " +snapshot.data!.docs[i].id),


                     ],

                   );
                 });

    } else{
                 return CircularProgressIndicator();
               }
    }





           ),

          ],

        ),



      ),
    );


  }
*/
}