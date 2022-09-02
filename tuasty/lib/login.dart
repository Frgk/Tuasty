import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tuasty/parameters/constant.dart';


class LoginWidget extends StatefulWidget{

  final VoidCallback onClickedSignUp;

  const LoginWidget({
    Key? key,
    required this.onClickedSignUp,
}): super(key:key);


  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final idController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    idController.dispose();
    super.dispose();
}

Future signIn(String email, String password) async {

    try {


      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e){
      Fluttertoast.showToast(
        msg: e.message!,
        gravity: ToastGravity.TOP,
        backgroundColor:Colors.red[900],
        textColor: Colors.white,
        fontSize: 13.0,

      );




      print(e.code);
      print(e);
    }




}

Future signIn2(String documentID) async{


  var collection = FirebaseFirestore.instance.collection('users');


  if(documentID != "") {
    var docSnapshot = await collection.doc(documentID).get();

    if (!(docSnapshot.exists) || docSnapshot == null) {
      displayToast(context, Colors.red, Colors.white, Icons.close, "Cet identifiant n'existe pas !");
    }

    else {
      Map<String, dynamic>? data = docSnapshot.data();
      var email = data?['email'];
      var password = data?['password'];

      signIn(email, password);
    }
  } else{
    displayToast(context, Colors.red, Colors.white, Icons.close, "Cet identifiant n'existe pas !");
  }


  }


@override
Widget build(BuildContext context) {
  /*
  return SingleChildScrollView(
    padding: EdgeInsets.all(16),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 40),
/*
TextField(
controller: emailController,
cursorColor: Colors.white,
textInputAction: TextInputAction.next,
decoration: InputDecoration(labelText: 'Enter email'),

),
SizedBox(height: 4),
TextField(
controller: passwordController,
textInputAction: TextInputAction.done,
decoration: InputDecoration(labelText: 'Enter password'),
),
SizedBox(height:40),
*/

        TextField(
          controller: idController,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(labelText: 'Enter ID'),
        ),
        SizedBox(height: 20),


        TextButton.icon(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.blue),
            foregroundColor: MaterialStateProperty.all(Colors.white),
          ),

          onPressed: () {
            //signIn();
            signIn2(idController.text);
          },
          icon: Icon(
            Icons.lock,
            size: 24,
          ),
          label: Text('LOGIN'),

        ),


        SizedBox(height: 24),
        RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.blue),
            text: 'You does not have a code ? ',
            children: [
              TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = widget.onClickedSignUp,
                text: 'Sign up',
                style: TextStyle(
                  decoration: TextDecoration.underline,

                ),
              ),

            ],

          ),

        )


      ],
    ),
  );

   */
  return Scaffold(
    resizeToAvoidBottomInset: false,

    body: Container(
      padding: EdgeInsets.symmetric(vertical: 30),
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              colors: [

                Colors.yellow.shade800,
                Colors.yellow.shade700,
                Colors.yellow.shade600,
                Colors.yellow.shade500


               // Colors.yellow,
               // Colors.yellow[200]!,
              ]
          )
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[



          SizedBox(height: 80,),





          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("LOGIN", style: TextStyle(color: Colors.white, fontSize: 40),),
                SizedBox(height: 10,),
                Text("Connectez-vous", style: TextStyle(color: Colors.white, fontSize: 20),)
              ],
            ),
          ),





      Expanded(

          child : SingleChildScrollView(
            padding: EdgeInsets.all(10),


            child: Container(

              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 60,),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(
                              color: Color.fromRGBO(205, 75, 7, .1),
                              blurRadius: 20,
                              offset: Offset(0, 10)
                          )]
                      ),
                      child:

                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.grey.shade200))
                            ),
                            child: TextField(
                              controller: idController,
                              decoration: InputDecoration(
                                  hintText: "Identifiant",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none
                              ),
                            ),
                          ),




                    ),

                    SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(0.0),
                      elevation: 5,
                    ),
                    onPressed: () {

                      signIn2(idController.text);

                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Colors.yellow.shade800,
                          Colors.yellow.shade700,
                          Colors.yellow.shade600,
                          Colors.yellow.shade500


                        ]),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        constraints: const BoxConstraints(minWidth: 88.0),
                        child: const Text('Connexion',
                            textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                        ),
                      ),


                    ),

                  ),

                    SizedBox(height: 60),

                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,

                    ),
                    text: "Vous n'avez pas de compte ? ",
                    children: [
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = widget.onClickedSignUp,
                        text: "Cliquez ici !",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,

                        ),
                      ),



                      //SizedBox(height: 20,),

                  ],
                ),
              ),





        ],
      ),
    ),
  ),
  ),
  ),


  ],
  ),
  ),
  );

}

}