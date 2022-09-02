




import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:short_uuids/short_uuids.dart';



class Product {



 final String code_barre,nom,image,nutriscore,marque,generic_name,nova;
 final List<String>  nutrient_levels,analysis_ingredients,additifs,categories;
 DateTime date_peremption;
 final String id;


 Product({
  required this.code_barre,
  required this.nom,
  required this.image,
  required this.nutriscore,
  required this.nova,
  required this.analysis_ingredients,
  required this.additifs,
  required this.nutrient_levels,
  required this.date_peremption,
  required this.marque,
  required this.generic_name,
  required this.categories,
   required this.id,
 });

Map<String, dynamic> toJson() =>{
 "code-barre":code_barre,
 "nom":nom,
 "image":image,
 "nutriscore":nutriscore,
 "nova":nova,
 "analysis_ingredients":analysis_ingredients,
 "additifs":additifs,
 "nutrient-levels":nutrient_levels,
 "date-peremption":DateFormat('yyyy-MM-dd').format(date_peremption),
 "marque":marque,
 "generic-name":generic_name,
 "categories":categories,
  "id" : id,



};






 factory Product.fromJson(dynamic json) {
  return Product(
      code_barre:json['code-barre'] as String,
      nom : json['nom'] as String,
      image : json['image'] as String,
      nutriscore : json['nutriscore'] as String,
      nova : json['nova'] as String,
      analysis_ingredients : json['analysis_ingredients'] as List<String>,
      additifs: json['additifs'] as List<String>,
      nutrient_levels : json['nutrient-levels'] as List<String>,
      date_peremption: json["date-peremption"] as DateTime,
      marque: json['marque'] as String,
      generic_name: json['generic-name'] as String,
      categories: json['categories'] as List<String>,
      id: json['id'] as String,


  );
 }




















 /*
 set id(String newId) {
   this._id = newId;
 }

 set name(String newName) {
   if (newName.length <= 140) {
     this._name = newName;
   }
 }

*/


}

