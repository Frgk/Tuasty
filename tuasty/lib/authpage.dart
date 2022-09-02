import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tuasty/login.dart';
import 'package:tuasty/home.dart';
import 'package:tuasty/authpage.dart';
import 'package:email_validator/email_validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:tuasty/inventory/product.dart';
import 'package:tuasty/parameters/constant.dart';


class AuthPage extends StatefulWidget{
  @override
  _AuthPageState createState() => _AuthPageState();

}

class _AuthPageState extends State<AuthPage>{
  bool isLogin = true;

  void toggle() => setState(() => isLogin = !isLogin);

  @override
  Widget build(BuildContext context) =>
      isLogin ? LoginWidget(onClickedSignUp : toggle)
          : SignUpWidget(onClickedSignIn : toggle);
}


class SignUpWidget extends StatefulWidget {
  final Function() onClickedSignIn;


  const SignUpWidget({
    Key? key,
    required this.onClickedSignIn,
}) : super(key: key);

  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();

}

class _SignUpWidgetState extends State<SignUpWidget>{
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool exist = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }





  Future addUserDetails(String name,String email, String password) async {
  await FirebaseFirestore.instance.collection('users').doc(name).set({

    'email':email,
    "password":password,
    "uid": FirebaseAuth.instance.currentUser!.uid,
    "inventory":{},
    "shopping_list":{},
    "consumed_food":0,
    "discarded_food":0,
    "favorite_recipes":{},



    });




  }

  Future signUp() async {
    final isValid = formKey.currentState!.validate();
    final isDocExists = await FirebaseFirestore.instance.collection("users").doc(nameController.text).get();
    if(!isValid) return;


    else if ( isDocExists.exists) {

      displayToast(context, Colors.redAccent, Colors.white, Icons.close, "Ce nom est déjà choisit !");

    } else {
      try {
        //create user
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // add user details
        addUserDetails(
          nameController.text.trim(),
          emailController.text.trim(),
          passwordController.text.trim(),

        );

        displayToast(context, Colors.green, Colors.white, Icons.check, "Création du compte réussie !");
      } on FirebaseAuthException catch (e) {
        print(e.code);
        print(e);

        displayToast(context, Colors.redAccent, Colors.white, Icons.close, e.message!);
      }
    }




  }

  @override
  Widget build(BuildContext context) {
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



           SizedBox(height: 20,),





           Padding(
             padding: EdgeInsets.all(20),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: <Widget>[
                 Text("INSCRIPTION", style: TextStyle(color: Colors.white, fontSize: 40),),
                 SizedBox(height: 10,),
                 Text("Créez-vous un compte", style: TextStyle(color: Colors.white, fontSize: 20),)
               ],
             ),
           ),





           Expanded(


             child : SingleChildScrollView(
               padding: EdgeInsets.all(10),
               child: Form(
                 key: formKey,
                 child:

               Container(


                 decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.all(Radius.circular(30)),

                 ),
                 child: Padding(
                   padding: EdgeInsets.all(30),
                   child: Column(
                     children: <Widget>[
                       SizedBox(height: 20,),
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
                           padding: EdgeInsets.all(10),
                           decoration: BoxDecoration(
                               border: Border(bottom: BorderSide(color: Colors.grey.shade200))
                           ),
                           child: TextFormField(
                             controller: nameController,
                             textInputAction: TextInputAction.done,
                             autovalidateMode: AutovalidateMode.onUserInteraction,
                             validator: (value) {
                               if (value != null && value.length < 3) {
                                 return 'Entrer 3 caractères minimum';
                               }

                               else {
                                 return null;
                               }
                             },

                             decoration: InputDecoration(
                                 hintText: "Nom",
                                 hintStyle: TextStyle(color: Colors.grey),
                                 border: InputBorder.none,

                             ),

                           ),
                         ),





                       ),
                       SizedBox(height: 20,),
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
                           child: TextFormField(
                             controller: emailController,
                             decoration: InputDecoration(
                                 hintText: "Adresse mail",
                                 hintStyle: TextStyle(color: Colors.grey),
                                 border: InputBorder.none
                             ),

                             cursorColor: Colors.white,
                             textInputAction: TextInputAction.next,

                             autovalidateMode: AutovalidateMode.onUserInteraction,
                             validator: (email) =>
                             email != null && !EmailValidator.validate(email)
                                 ? 'Enter a valid email'
                                 : null,

                           ),
                         ),





                       ),
                       SizedBox(height: 20,),
                       Container(
                         padding: EdgeInsets.all(5),
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
                           child: TextFormField(
                             controller: passwordController,
                             decoration: InputDecoration(
                                 hintText: "Mot de passe",
                                 hintStyle: TextStyle(color: Colors.grey),
                                 border: InputBorder.none
                             ),

                             textInputAction: TextInputAction.done,

                             autovalidateMode: AutovalidateMode.onUserInteraction,
                             validator: (value) =>
                             value != null && value.length < 6
                                 ? 'Enter min. 6 characters'
                                 : null,
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

                           signUp();

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
                           text: "Vous avez déjà un compte ? ",
                           children: [
                             TextSpan(
                               recognizer: TapGestureRecognizer()
                                 ..onTap = widget.onClickedSignIn,
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
           ),


         ],
       ),
     ),
   );

     /*
     SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            SizedBox(height: 40),

            TextFormField(
              controller: nameController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(labelText: 'Enter name'),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value != null && value.length < 3) {
                  return 'Entrer 3 caractères minimum';
                }

                else {
                  return null;
                }
              },


            ),
            SizedBox(height: 4),
            TextFormField(
              controller: emailController,
              cursorColor: Colors.white,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: 'Enter email'),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (email) =>
              email != null && !EmailValidator.validate(email)
                  ? 'Enter a valid email'
                  : null,


            ),
            SizedBox(height: 4),
            TextFormField(
              controller: passwordController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(labelText: 'Enter password'),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) =>
              value != null && value.length < 6
                  ? 'Enter min. 6 characters'
                  : null,


            ),
            SizedBox(height: 20),
            TextButton.icon(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              onPressed: () {
                signUp();
              },
              icon: Icon(
                Icons.arrow_forward,
                size: 24,
              ),
              label: Text('SIGN UP'),
            ),
            SizedBox(height: 24),
            RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.blue),
                text: 'Already have an account ? ',
                children: [
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = widget.onClickedSignIn,
                    text: 'Login',
                    style: TextStyle(
                      decoration: TextDecoration.underline,

                    ),
                  ),

                ],

              ),

            )


          ],
        ),
      ),
    );
    */

  }

}