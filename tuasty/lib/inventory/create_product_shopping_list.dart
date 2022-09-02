import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:short_uuids/short_uuids.dart';
import 'package:tuasty/inventory/create_product.dart';
import 'package:tuasty/inventory/product.dart';
import 'package:tuasty/clientuser.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tuasty/parameters/constant.dart';

class add_aliment_to_shoplist extends StatefulWidget {
  const add_aliment_to_shoplist({Key? key}) : super(key: key);

  @override
  _add_aliment_to_shoplist createState() => _add_aliment_to_shoplist();
}

class _add_aliment_to_shoplist extends State<add_aliment_to_shoplist> {
  Product? aliment = null;
  String ScanResult = '';
  String DatePeremption = '';
  TextEditingController barcodeController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime date_choisie = DateTime.now();

  String result_barcode = '';

  bool entered_good_barcode = false;

  bool _isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }

  scanBarcodeReturn() async {
    String result;

    try {
      result = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Annuler", false, ScanMode.BARCODE);
    } on PlatformException {
      return "Rien trouvé";
    }
    if (!mounted) return;

    setState(() => this.result_barcode = result);
  }



/*
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
            child:Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  width: 500,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.lightBlueAccent,

                  ),
                  child : Column(
                    children: [
                      Text("Code barre : "),
                      TextFormField(
                        controller: _texEditingController,
                        onChanged: (value){
                          result_barcode=_texEditingController.text;
                          find_aliment();},
                        validator: (value){

                          if (value!.length != 13){
                            return "Votre chaîne doit faire 13 caractères";
                          }

                          if (_isNumeric(value)){
                            return null;
                          }else {
                            return "Ce n'est pas un code barre";
                          }

                        },
                        decoration: InputDecoration(hintText: "Entrez votre code barre !"),

                      ),
                      SizedBox(height:20),
                      CircleAvatar(
                          backgroundColor: Colors.blue,
                          child:IconButton(
                            onPressed: () async {
                              await scanBarcodeReturn();
                              _texEditingController.text=this.result_barcode;
                              find_aliment();
                            },

                            icon:Icon(Icons.photo_camera_outlined,color: Colors.red),
                          )),

                    ],
                  ),
                ),
                SizedBox(height:50),
                Container(
                  padding: EdgeInsets.all(20),
                  width: 500,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.lightBlueAccent,

                  ),
                  child: Column(
                    children: [
                      Text("Date de péremption : "),
                      ElevatedButton(
                          onPressed: (){
                            _selectDate(context);
                          },
                          child: Text("Séléctionnez une date !")),
                      ElevatedButton(
                          onPressed: (){
                            captureImageFromCamera();
                          },
                          child: Text("Scannez une date"))

                    ],
                  ),
                ),
                SizedBox(height: 50,),
                Container(
                  padding: EdgeInsets.all(20),
                  width: 500,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.lightBlueAccent,

                  ),
                  child: Column(
                    children: [
                      Text("Récapitulatif : ",
                        style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
                      SizedBox(height:20),
                      result_barcode==''? Text("Aucun code barre pour l'instant"):Text("Code barre : $result_barcode"),
                      SizedBox(height:20),
                      Text("Date de péremption du produit : "+display_formatted(date_choisie),
                        textAlign: TextAlign.center,),
                      SizedBox(height: 40,),
                      aliment==null?Text("Aucun produit trouvé associé"):Text("Produit : "+aliment!.nom),

                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    /*
                    if(_formKey.currentState!.validate()){
                      if(aliment?.nom !='') {

                        setState(() =>this.aliment!.date_peremption=date_choisie );

                        global.list_aliment.add(this.aliment!);
                        Navigator.of(context).pop();
                      }
                    }else{
                    }
                    */
                  } ,
                  child: Text("Ajouter ce produit dans mon frigo !"),
                ),


              ],
            )

        ),
      ),


      actions: [
        TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
            }
            ,
            child: Text('Fermer'))
      ],
    );
  }
}
*/

  @override
  void initState() {
    super.initState();
    barcodeController.addListener(() {
      final entered_good_barcode = _isNumeric(barcodeController.text) &&
          (barcodeController.text.length == 13);

      setState(() => this.entered_good_barcode = entered_good_barcode);

      print(barcodeController.text.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Ajouter un produit',
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.yellow.shade300,
      content: Text(
        'Etape 1/2',
        textAlign: TextAlign.center,
      ),
      actions: [
        Column(
          children: [
            const SizedBox(
              width: 100.0,
              height: 3.0,
              child: const DecoratedBox(
                decoration: const BoxDecoration(color: Colors.black),
              ),
            ),
            SizedBox(height: 10,),
            Text(
              "Avez-vous le code-barres du produit ?",
              textAlign: TextAlign.center,
              style : TextStyle(
                fontFamily: 'Oswald',
                fontWeight: FontWeight.normal,
                fontSize: 18,

              ),


            ),


            SizedBox(
              height: 10,
            ),
            ElevatedButton.icon(
              icon: Icon(
                Icons.photo_camera,
                color: Colors.white,
                size: 24.0,
              ),
              label: Text("J'ai le code-barres"),
              onPressed: () async {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) => enter_aliment_barcode(),
                );
                //find_aliment();
              },
            ),
            SizedBox(
              height: 2,
            ),
            Text(
              "OU",
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 2,
            ),
            ElevatedButton.icon(
              icon: Icon(
                Icons.note,
                color: Colors.white,
                size: 24.0,
              ),
              label: Text("J'ai le nom"),
              onPressed: () async {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) => enter_aliment_name(),
                );
                //find_aliment();
              },
            ),
            SizedBox(height: 20),


            const SizedBox(
              width: 100.0,
              height: 3.0,
              child: const DecoratedBox(
                decoration: const BoxDecoration(color: Colors.black),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // Background color
              ),
              icon: Icon(
                Icons.close,
                color: Colors.white,
                size: 24.0,
              ),
              label: Text('Annuler'),
              onPressed: () {
                Navigator.pop(context, 'Annuler');
              },
            ),
          ],
        ),
      ],
    );
  }
}

class enter_aliment_name extends StatefulWidget {
  const enter_aliment_name({Key? key}) : super(key: key);

  @override
  _enter_aliment_name createState() => _enter_aliment_name();
}

class _enter_aliment_name extends State<enter_aliment_name> {

  TextEditingController nameController = TextEditingController();
  String entered_name = "";
  String docName = "";


  Future _getUserData() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        setState(() => docName = element.id);

      });
    });
  }





@override
void initState(){
    super.initState();
    _getUserData();

}



  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Ajouter un produit',
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.yellow.shade300,
      content: Text(
        'Etape 2/2',
        textAlign: TextAlign.center,
      ),
      actions: [
        Column(
          children: [
            const SizedBox(
              width: 100.0,
              height: 3.0,
              child: const DecoratedBox(
                decoration: const BoxDecoration(color: Colors.black),
              ),
            ),
            SizedBox(height: 10,),
            Text(
                "Entrez le nom du produit",
              textAlign: TextAlign.center,
              style : TextStyle(
                fontFamily: 'Oswald',
                fontWeight: FontWeight.normal,
                fontSize: 18,

              ),


            ),




            SizedBox(height: 15),

            TextFormField(
              controller: nameController,
              onChanged: (value) {
                 entered_name = nameController.text;
              },
              validator: (value) {
                if (value!.length == 0) {
                  return "Votre nom doit comporter au moins 1 caractère";
                }


              },
              decoration: InputDecoration(
                  hintText:
                  "Entrez le nom de votre produit !"),
            ),

            SizedBox(height: 10,),
            const SizedBox(
              width: 100.0,
              height: 3.0,
              child: const DecoratedBox(
                decoration: const BoxDecoration(color: Colors.black),
              ),
            ),
            SizedBox(height: 5),

            Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red, // Background color
                  ),
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24.0,
                  ),
                  label: Text('Annuler'),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) => add_aliment_to_shoplist(),
                    );
                  },
                ),
      SizedBox(width: 15),
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          primary: Colors.green, // Background color
        ),
        icon: Icon(
          Icons.check,
          color: Colors.white,
          size: 24.0,
        ),
        label: Text('Ajouter'),
        onPressed: () async{

          if(nameController.text != "") {
            var prod = Product(
                code_barre: "",
                nom: nameController.text,
                image: "https://img.icons8.com/ios-glyphs/30/undefined/asian-street-food.png",
                nutriscore: "",
                nova: "",
                analysis_ingredients: [""],
                additifs: [""],
                nutrient_levels: [""],
                date_peremption: DateTime.now(),
                marque: "",
                generic_name: "",
                categories: [""],
                id: ShortUuid().generate());

            Map<String, dynamic> product = prod.toJson();

            product.addAll({"quantité": 1});

            await FirebaseFirestore.instance
                .collection('users')
                .doc(docName)
                .update({
              "shopping_list": FieldValue.arrayUnion([product])
            });

            Navigator.of(context).pop();
          }
          else{
            displayToast(context, Colors.red, Colors.white, Icons.close, "Votre produit doit avoir un nom !");
          }

        },
      ),



              ],

            ),


            SizedBox(height: 10),
            const SizedBox(
              width: 100.0,
              height: 3.0,
              child: const DecoratedBox(
                decoration: const BoxDecoration(color: Colors.black),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class enter_aliment_barcode extends StatefulWidget {
  const enter_aliment_barcode({Key? key}) : super(key: key);

  @override
  _enter_aliment_barcode createState() => _enter_aliment_barcode();
}

class _enter_aliment_barcode extends State<enter_aliment_barcode> {

  Product? aliment = null;


  String display_formatted(DateTime now) {
    return DateFormat('dd-MM-yyy').format(now);
  }

  Product process_request(String body, DateTime date) {
    final parsedJson = jsonDecode(body);
    print(parsedJson['status_verbose']);

    if (parsedJson['status_verbose'] != "product not found") {
      var nom_produit = (parsedJson['product']['product_name']);
      print("nom");
      var image_url = (parsedJson['product']['image_url']);
      print("image");
      var code_barre = (parsedJson['product']['_id']);
      print("code");
      var nutriscore = (parsedJson['product']['nutrition_grade_fr'])
          .toString()
          .toUpperCase();

      nutriscore = (parsedJson['product']['nutrition_grades_tags'])[0]
          .toString()
          .toUpperCase();

      print("nutriscore");

      var nova = (parsedJson['product']['nova_group']);

      nova = (parsedJson['product']['nova_groups_tags'])[0]
          .toString()
          .toUpperCase();
      nova = nova.toString()[3];
      print("nova");

      List<String> analysis_ingredients = [];

      try {
        var analysis_ingredients_list =
        (parsedJson['product']['ingredients_analysis_tags']);
        for (String k in analysis_ingredients_list) {
          k = k.replaceAll("en:", '');
          print("k :");
          print(k);
          k = traduction_analysis_ingredient(k);
          print("k :");
          print(k);
          analysis_ingredients.add(k);
        }
      } catch (e) {
        analysis_ingredients.add("Pas donné");
      }
      print(analysis_ingredients);

      List<String> additifs = [];

      try {
        var additifs_list = (parsedJson['product']['additives_original_tags']);
        print("additif");
        print(additifs_list);
        for (String k in additifs_list) {
          print(k);
          k = k.replaceAll("en:", "").toUpperCase();

          additifs.add(k);
        }
      } catch (e) {
        additifs.add("Pas donné");
      }

      if (additifs == "") {
        additifs.add("Pas donné");
      }

      var nutrient_levels_list =
      (parsedJson['product']['nutrient_levels_tags']);
      print("level");

      List<String> nutrient_levels = [];
      print(nutrient_levels_list);
      for (String k in nutrient_levels_list) {
        k = k.replaceAll("en:", "");
        var list_k = k.split("-in-");
        print("k list");
        print(list_k[0]);
        print(list_k[1]);
        var nutrient = traduction_nutrient(list_k[0]);
        var level = traduction_level(list_k[1].replaceAll("-", " "));

        print("TRADU");
        print(nutrient);
        print(level);

        nutrient_levels.add("" + nutrient + " : " + level + "\n");
      }

      var marque = (parsedJson['product']['brands']);
      var generic_name = "";
      //generic_name = (parsedJson['product']['generic_name_fr']);

      List<String> categories = [];
      var categories_list = (parsedJson['product']['categories_old']);

      /*
      for (String k in categories_list) {
        k = k.replaceAll("en:", "");
        categories.add(k);
      }

       */
      var l = categories_list.split(',');
      for (String k in l) {
        categories.add(k);
      }

      print("categories");
      print(categories);

      print("fin process");

      //Product produit = Product(code_barre, nom_produit, image_url, nutriscore, nova, analysis_ingredients, additifs, nutrient_levels,date,marque,generic_name,categories);

      return Product(
          code_barre: code_barre,
          nom: nom_produit,
          image: image_url,
          nutriscore: nutriscore,
          nova: nova,
          analysis_ingredients: analysis_ingredients,
          additifs: additifs,
          nutrient_levels: nutrient_levels,
          date_peremption: date,
          marque: marque,
          generic_name: generic_name,
          categories: categories,
          id: ShortUuid().generate());
      //return Product("3068320124537", "nom_produit", "image_url", "nutriscore", "nova", ["analysis_ingredients"], ["additifs"], ["nutrient_levels"],DateTime.now(),"marque","generic_name",["categories"]);

      //setState(() =>produitf = produit);
    } else {
      return Product(
          code_barre: "",
          nom: "null",
          image: "null",
          nutriscore: " nutriscore",
          nova: "nova",
          analysis_ingredients: [""],
          additifs: [""],
          nutrient_levels: [""],
          date_peremption: date,
          marque: "",
          generic_name: "",
          categories: [""],
          id: ShortUuid().generate());
    }
  }

  String traduction_analysis_ingredient(String ingredient) {
    switch (ingredient) {
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

  String traduction_nutrient(String nutrient) {
    switch (nutrient) {
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

  String traduction_level(String level) {
    switch (level) {
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

  Future<Product> find_aliment(String codebarre, DateTime date) async {
    final client = ClientWithUserAgent(http.Client());

    //if (codebarre.length !=13){

    //}else {
    var uri = Uri.http(
        "fr.openfoodfacts.org", "/api/v0/product/" + codebarre.toString());
    var response = await client.get(uri);

    // setState(() => produitf = process_request(response.body, date));

    //print(produitf!.additifs);
    return process_request(response.body, date);

    // }
  }
  String result_barcode = '';

  bool entered_good_barcode = false;

  final barcodeController = TextEditingController();

  bool _isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }

  scanBarcodeReturn() async {
    String result;

    try {
      result = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Annuler", false, ScanMode.BARCODE);
    } on PlatformException {
      return "Rien trouvé";
    }
    if (!mounted) return;

    setState(() => this.result_barcode = result);
  }
  String docName = "";


  Future _getUserData() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        setState(() => docName = element.id);

      });
    });
  }





  @override
  void initState(){
    super.initState();
    _getUserData();


      barcodeController.addListener(() {
        final entered_good_barcode = _isNumeric(barcodeController.text) &&
            (barcodeController.text.length == 13);

        setState(() => this.entered_good_barcode = entered_good_barcode);

        print(barcodeController.text.length);
    });

  }



  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Ajouter un produit',
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.yellow.shade300,
      content: Text(
        'Etape 2/2',
        textAlign: TextAlign.center,
      ),
      actions: [
        Column(
          children: [
            const SizedBox(
              width: 100.0,
              height: 3.0,
              child: const DecoratedBox(
                decoration: const BoxDecoration(color: Colors.black),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton.icon(
              icon: Icon(
                Icons.photo_camera,
                color: Colors.white,
                size: 24.0,
              ),
              label: Text('Scanner le code-barre'),
              onPressed: () async {
                await scanBarcodeReturn();
                barcodeController.text = this.result_barcode;
                //find_aliment();
              },
            ),
            SizedBox(
              height: 2,
            ),
            Text(
              "OU",
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 2,
            ),
            TextFormField(
              controller: barcodeController,
              onChanged: (value) {
                result_barcode = barcodeController.text;
              },
              validator: (value) {
                if (value!.length != 13) {
                  return "Votre chaîne doit faire 13 caractères";
                }

                if (_isNumeric(value)) {
                  return null;
                } else {
                  return "Ce n'est pas un code barre";
                }
              },
              decoration: InputDecoration(
                  hintText:
                  "Entrez le code-barre si vous ne pouvez pas prendre de photo !"),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(
                Icons.arrow_right_alt,
                color: Colors.white,
                size: 24.0,
              ),
              label: Text('Suivant'),
              onPressed: entered_good_barcode
                  ? () async {
                this.aliment = await find_aliment(
                    barcodeController.text, DateTime.now());

                if (this.aliment?.toJson()['nom'] == "null") {
                  print("ERROREOOREOEOEOEOEOEO");
                  Fluttertoast.showToast(
                      msg: "Le code-barre ne correspond à aucun produit",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                } else {


/*
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    createProductPage2(
                                        //product: data['inventory'][index]))
                                        product: this.aliment?.toJson())));

 */
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) => createProductPage2(
                      //product: data['inventory'][index]))
                        product: this.aliment?.toJson()),
                  );

                }
              }
                  : null,
            ),
            SizedBox(height: 10),
            const SizedBox(
              width: 100.0,
              height: 3.0,
              child: const DecoratedBox(
                decoration: const BoxDecoration(color: Colors.black),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // Background color
              ),
              icon: Icon(
                Icons.close,
                color: Colors.white,
                size: 24.0,
              ),
              label: Text('Annuler'),
              onPressed: () {
                Navigator.pop(context, 'Annuler');

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) => add_aliment_to_shoplist(),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}




class createProductPage2 extends StatefulWidget {
  final Map<String,dynamic>? product;

  const createProductPage2({Key? key, this.product}) : super(key: key);

  @override
  _createProductPage2 createState() => _createProductPage2();

}

class _createProductPage2 extends State<createProductPage2>{

  String docName = '';

  Future _getUserData() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        setState(() => docName = element.id);

      });
    });
  }





  @override
  void initState(){
    super.initState();
    _getUserData();

  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Ajouter un produit',
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.yellow.shade300,

      actions: [
        Column(
          children: [
            const SizedBox(
              width: 100.0,
              height: 3.0,
              child: const DecoratedBox(
                decoration: const BoxDecoration(color: Colors.black),
              ),
            ),
            SizedBox(height: 10,),
            Text(
              "Est-ce bien l'aliment que vous avez scanné ?",
              textAlign: TextAlign.center,
              style : TextStyle(
                fontFamily: 'Oswald',
                fontWeight: FontWeight.normal,
                fontSize: 18,

              ),


            ),


            Container(
              child: Column(
                children: [
                  Image.network(
                    widget.product?['image'],
                    height: 150,
                    width: 150,



                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child : Expanded(
                      child: Text(widget.product?['nom'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),

                      ),

                    ),
                  ),
                  SizedBox(height: 5,),

                  Text(widget.product?['marque'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),




                ],



              ),

            ),


            SizedBox(height: 15),
            const SizedBox(
              width: 100.0,
              height: 3.0,
              child: const DecoratedBox(
                decoration: const BoxDecoration(color: Colors.black),
              ),
            ),
            SizedBox(height: 5),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red, // Background color
                  ),
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24.0,
                  ),
                  label: Text('NON'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) => add_aliment_to_shoplist(),
                    );
                  },
                ),
                SizedBox(width: 15),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green, // Background color
                  ),
                  icon: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 24.0,
                  ),
                  label: Text('OUI'),
                  onPressed: () async {


    Map<String,dynamic>? product = widget.product;

    product?.addAll({"quantité" : 1});




    await FirebaseFirestore.instance
        .collection('users')
        .doc(docName)
        .update({
    "shopping_list": FieldValue.arrayUnion([product])
    },
    );

                    print(product);

    Navigator.of(context).pop();

    Navigator.of(context).pop();

    //Navigator.of(context).pop();


    },

            ),



          ],
        ),
            SizedBox(height: 10),
            const SizedBox(
              width: 100.0,
              height: 3.0,
              child: const DecoratedBox(
                decoration: const BoxDecoration(color: Colors.black),
              ),
            ),
      ],
    ),
    ],
    );
  }
}

