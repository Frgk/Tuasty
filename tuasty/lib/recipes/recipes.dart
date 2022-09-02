




import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:short_uuids/short_uuids.dart';



class Recipes {



  final String auteur, categories, difficulte,nom,nombre_commentaires,prix,temps,temps_cuisson,temps_preparation,temps_repose,url;
  final List<String> images,ingredients,processus,ustensiles;


  final double nombre_personnes,note;
  final String id;


  Recipes({

    required this.auteur,
  required this.categories,
  required this.difficulte,
  required this.nom,
  required this.nombre_commentaires,
  required this.prix,
  required this.temps,
  required this.temps_cuisson,
  required this.temps_preparation,
  required this.temps_repose,
  required this.url,
    required this.images,
    required this.ingredients,
    required this.processus,
    required this.ustensiles,
  required this.nombre_personnes,
  required this.note,
  required this.id,

  });

  Map<String, dynamic> toJson() =>{

    "auteur":auteur,
    "categories":categories,
    "difficulte":difficulte,
    "nom":nom,
    "nombre_commentaires":nombre_commentaires,
    "prix":prix,
    "temps":temps,
    "temps_cuisson":temps_cuisson,
    "temps_preparation":temps_preparation,
    "temps_repose":temps_repose,
    "url":url,
    "images":images,
    "ingredients":ingredients,
    "processus":processus,
    "ustensiles":ustensiles,
    "nombre_personnes":nombre_personnes,
    "note":note,
    "id":id,
  };

  factory Recipes.fromJson(dynamic json) {
    return Recipes(

      auteur : json['auteur'] as String,
      categories : json['categories'] as String,
      difficulte : json['difficulte'] as String,
      nom : json['nom'] as String,
      nombre_commentaires : json['nombre_commentaires'] as String,
      prix : json['prix'] as String,
      temps : json['temps'] as String,
      temps_cuisson : json['temps_cuisson'] as String,
      temps_preparation : json['temps_preparation'] as String,
      temps_repose : json['temps_repose'] as String,
      url : json['url'] as String,
      images : json['images'] as List<String>,
      ingredients: json['ingrediens'] as List<String>,
      processus: json['processus'] as List<String>,
      ustensiles: json['ustensiles'] as List<String>,
      nombre_personnes: json['nombre_personnes'] as double,
      note: json['note'] as double,


      id: json['id'] as String,


    );
  }





}

