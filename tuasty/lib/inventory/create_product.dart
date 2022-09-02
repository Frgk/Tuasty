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
import 'package:tuasty/inventory/product.dart';
import 'package:tuasty/clientuser.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class add_aliment extends StatefulWidget {
  const add_aliment({Key? key}) : super(key: key);

  @override
  _add_aliment createState() => _add_aliment();
}

class _add_aliment extends State<add_aliment> {
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
        'Etape 1/3',
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

            const SizedBox(
              width: 100.0,
              height: 3.0,
              child: const DecoratedBox(
                decoration: const BoxDecoration(color: Colors.black),
              ),
            ),
            SizedBox(height: 10),

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
                Navigator.pop(context, 'Annuler');
              },
            ),
                SizedBox(width: 20),

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

class createProductPage2 extends StatelessWidget {
  final Map? product;

  const createProductPage2({Key? key, this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Ajouter un produit',
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.yellow.shade300,
      content: Text(
        'Etape 2/3',
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
        product?['image'],
      height: 150,
      width: 150,



    ),
    SingleChildScrollView(
scrollDirection: Axis.horizontal,

                    //child : Expanded(
                    child: Text(product?['nom'],
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      ),

                    ),

                  ),
                //  ),
                  SizedBox(height: 5,),

                  Text(product?['marque'],
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
                    Navigator.of(context, rootNavigator: true).pop();
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
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => createProductPage3(
              //product: data['inventory'][index]))
                product: this.product),
          );
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

class createProductPage3 extends StatefulWidget {
  const createProductPage3({Key? key, this.product}) : super(key: key);

  final Map? product;

  @override
  createProductPage3State createState() => createProductPage3State();
}

class createProductPage3State extends State<createProductPage3> {
  DateTime date_choisie = DateTime.now();
  String time = DateFormat("yyyy-MM-dd").format(DateTime.now());
  File? _image;
  InputImage? inputImage;
  final picker = ImagePicker();
  String result_ocr = '';
  var docRef = Map<String, dynamic>();
  var docName = '';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2050));
    if (pickedDate != null)
      setState(() {
        //date_choisie= pickedDate;
        time = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
  }

  Future imageToText(inputImage) async {
    result_ocr = '';
    RegExp regex = RegExp("[0-3]?[0-9]/[0-3]?[0-9]/(?:[0-9]{2})?[0-9]{2}");
    RegExp regex2 = RegExp("[0-3]?[0-9]-[0-3]?[0-9]-(?:[0-9]{2})?[0-9]{2}");

    final textDetector = GoogleMlKit.vision.textDetector();
    final RecognisedText recognisedText =
        await textDetector.processImage(inputImage);

    setState(() {
      String text = recognisedText.text;
      for (TextBlock block in recognisedText.blocks) {
        //each block of text/section of text
        final String text = block.text;
        print("block of text: ");

        print(text);
        for (TextLine line in block.lines) {
          //each line within a text block

          print("Ligne " + line.text);
          var match = regex.allMatches(line.text);
          for (final m in match) {
            result_ocr += m[0]!;
          }

          //result += "\n Detected text \n"+match.toList().toString();

          for (TextElement element in line.elements) {
            //each word within a line
            //result += element.text + " ";
          }
        }
      }
      if (result_ocr == []) {
      } else {
        print('result !!!!');
        print(result_ocr);
        List result_list = result_ocr.split("/");
        print(result_list);
        DateTime date = DateFormat("dd/MM/yy").parse(result_ocr);
        print("DATE " + date.toString());

        //date_choisie=date;
        time = DateFormat('yyyy-MM-dd').format(date);
        print("time " + time);
      }
    });
  }

  Future captureImageFromCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        inputImage = InputImage.fromFilePath(pickedFile.path);
        result_ocr = '';
        imageToText(inputImage);
      } else {
        print('No image selected.');
      }
    });
  }

  Future _getUserData() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        setState(() => docName = element.id);
        setState(() => docRef = element.data());
      });
    });
  }

  @override
  void initState() {
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
        'Etape 3/3',
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
            Text("Veuillez prendre en photo la date de péremption",
          textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,


            ),

            ),
            SizedBox(height: 10),
            Image.network(
              widget.product?['image'],
              height: 150,
              width: 150,



            ),


            Column(
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Date de péremption : ",
                      style: TextStyle(
                      fontSize: 15,

                      ),

                    ),

                    Text(
                        time.toString(),

                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,

                      ),

                    ),


                  ],

                ),
                //Text("Date de péremption : " + time.toString()),


                SizedBox(height: 10),
                const SizedBox(
                  width: 100.0,
                  height: 3.0,
                  child: const DecoratedBox(
                    decoration: const BoxDecoration(color: Colors.black),
                  ),
                ),
                SizedBox(height: 10),

                ElevatedButton(
                    onPressed: () async {
                      await captureImageFromCamera();
                      //time = DateFormat('yyyy-MM-dd').format(date_choisie);
                    },
                    child: Text("Scannez la date")
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
                ElevatedButton(
                    onPressed: () {
                      _selectDate(context);
                      time = DateFormat('yyyy-MM-dd').format(date_choisie);
                    },
                    child: Text("Sélectionnez la date")),

SizedBox(height: 10,),
                const SizedBox(
                  width: 100.0,
                  height: 3.0,
                  child: const DecoratedBox(
                    decoration: const BoxDecoration(color: Colors.black),
                  ),
                ),

                SizedBox(height: 10,),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children :[

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

            SizedBox(width: 15,),

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
              onPressed: () async {
                var prod = widget.product;

                prod!['date-peremption'] = time;

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(docName)
                    .update({
                  "inventory": FieldValue.arrayUnion([prod])
                });

/*
                await FirebaseFirestore.instance
                    .collection(
                    'users')
                    .doc(docName).set(
                    {"inventory": [prod]},
                    SetOptions(merge: true));

 */

                Navigator.of(context, rootNavigator: true).pop();
                Navigator.of(context, rootNavigator: true).pop();
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),





    ],
            ),

            SizedBox(height: 10,),
            const SizedBox(
              width: 100.0,
              height: 3.0,
              child: const DecoratedBox(
                decoration: const BoxDecoration(color: Colors.black),
              ),
            ),

            SizedBox(height: 10,),

          ],
        ),
      ],
    );
  }
}
