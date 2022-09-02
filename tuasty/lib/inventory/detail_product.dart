import 'package:flutter/material.dart';
import 'package:tuasty/inventory/product.dart';

class DetailsProduct extends StatelessWidget {
  final Map? product;


  String getImageNutriscore(final product){
    if (product?['nutriscore'] == 'A') return 'assets/pictures/nutriscore-a.png';
    else if (product?['nutriscore'] == 'B') return 'assets/pictures/nutriscore-b.png';
    else if (product?['nutriscore'] == 'C') return 'assets/pictures/nutriscore-c.png';
    else if (product?['nutriscore'] == 'D') return 'assets/pictures/nutriscore-d.png';
    else if (product?['nutriscore'] == 'E') return 'assets/pictures/nutriscore-e.png';
    else return 'assets/pictures/nutriscore-unknown.png';
  }

  String getImageNova(final product){
    if (product?['nutriscore'] == '1') return 'assets/pictures/nova-group-1.png';
    else if (product?['nutriscore'] == '2') return 'assets/pictures/nova-group-2.png';
    else if (product?['nutriscore'] == '3') return 'assets/pictures/nova-group-3.png';
    else if (product?['nutriscore'] == '4') return 'assets/pictures/nova-group-4.png';
    else return 'assets/pictures/nova-group-unknown.png';
  }


  const DetailsProduct({Key? key, this.product}) : super(key:key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[200]!,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.yellow,
        leading: IconButton(
          icon : Icon(
          Icons.close,
          color : Colors.black,
          ),
            onPressed : () {

              Navigator.pop(context);


            }
        ),




      ),

      body: Center(

      child :Column(
        children: <Widget>[

          SizedBox(height: 10),

          Image.network(
              product?['image'],
            height: MediaQuery.of(context).size.height * 0.25,
            //width: double.infinity,

            fit: BoxFit.fill,
          ),

          SizedBox(height: 10),


            Expanded(

              child : SingleChildScrollView(
                padding: EdgeInsets.only(left: 10,right: 10),
                child:  Container(
                  padding: EdgeInsets.all(20),
                  width : double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30)
                    ),




                  ),

                  child: Column(
                    crossAxisAlignment:CrossAxisAlignment.start,
                    children: <Widget>[

                      Text(
                        product?['nom'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color : Colors.black,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 10),

                      const SizedBox(
                        width: 200.0,
                        height: 1.0,
                        child: const DecoratedBox(
                          decoration: const BoxDecoration(
                              color: Colors.black
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      Align(
                        alignment: Alignment.centerLeft,
                        child : RichText(
                          text: TextSpan(children: <InlineSpan>[
                            TextSpan(text : "Marque : ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 16,
                                )),

                            TextSpan(text: product?['marque'],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                )),
                          ]),
                        ),
                      ),


                      SizedBox(height: 20),

                      Align(
                        alignment: Alignment.centerLeft,
                        child :  Row(
                            children : [

                              RichText(
                                text: TextSpan(children: <InlineSpan>[
                                  TextSpan(text : "Nutriscore : ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 16,
                                      )),
/*
                            TextSpan(text: product?['nutriscore'],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                )),

 */
                                ]),
                              ),

                              Image.asset(
                                getImageNutriscore(product),
                                scale: 3,
                              ),
                            ]
                        ),




                      ),




                      SizedBox(height: 20),

                      Align(
                        alignment: Alignment.centerLeft,
                        child :  Row(
                            children : [

                              RichText(
                                text: TextSpan(children: <InlineSpan>[
                                  TextSpan(text : "Score NOVA : ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 16,
                                      )),
/*
                            TextSpan(text: product?['nova'],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                )),

 */
                                ]),
                              ),

                              Image.asset(
                                getImageNova(product),
                                scale: 3,
                              ),
                            ]
                        ),




                      ),

                      SizedBox(height: 30),

                      const SizedBox(
                        width: 200.0,
                        height: 1.0,
                        child: const DecoratedBox(
                          decoration: const BoxDecoration(
                              color: Colors.black
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      Align(
                        alignment: Alignment.centerLeft,
                        child : RichText(
                          text: TextSpan(children: <InlineSpan>[
                            TextSpan(text : "Ingrédients : \n",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 16,
                                )),
                            for (var string in product?["analysis_ingredients"] ?? "")
                              TextSpan(text: string +"\n",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  )),
                          ]),
                        ),
                      ),

                      SizedBox(height: 20),

                      Align(
                        alignment: Alignment.centerLeft,
                        child : RichText(
                          text: TextSpan(children: <InlineSpan>[
                            TextSpan(text : "Additifs : \n",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 16,
                                )),
                            for (var string in product?["additifs"] ?? "")
                              TextSpan(text: string +"\n",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  )),
                          ]),
                        ),
                      ),

                      SizedBox(height: 20),

                      Align(
                        alignment: Alignment.centerLeft,
                        child : RichText(
                          text: TextSpan(children: <InlineSpan>[
                            TextSpan(text : "Catégories : \n",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 16,
                                )),
                            for (var string in product?["categories"] ?? "")
                              TextSpan(text: string +"\n",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  )),
                          ]),
                        ),
                      ),

                      SizedBox(height: 20),


                      Align(
                        alignment: Alignment.centerLeft,
                        child : RichText(
                          text: TextSpan(children: <InlineSpan>[
                            TextSpan(text : "Nutriments : \n",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 16,
                                )),
                            for (var string in product?["nutrient-levels"] ?? "")
                              TextSpan(text: string +"\n",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  )),
                          ]),
                        ),
                      ),

                      SizedBox(height: 20),

                      Align(
                        alignment: Alignment.centerLeft,
                        child : RichText(
                          text: TextSpan(children: <InlineSpan>[
                            TextSpan(text : "Nom générique : ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 16,
                                )),

                            TextSpan(text: product?['generic-name'] == null
                                ? "Pas de nom générique"
                                : product?['generic-name'],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                )),
                          ]),
                        ),


                      ),

                      SizedBox(height: 20),

                      const SizedBox(
                        width: 200.0,
                        height: 1.0,
                        child: const DecoratedBox(
                          decoration: const BoxDecoration(
                              color: Colors.black
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      Align(
                        alignment: Alignment.centerLeft,
                        child : RichText(
                          text: TextSpan(children: <InlineSpan>[
                            TextSpan(text : "Code-barre : ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 16,
                                )),

                            TextSpan(text: product?['code-barre'],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                )),
                          ]),
                        ),
                      ),










                    ],










                  ),
                ),


              ),






            ),




        ],



      ),
      ),

    );


      /*
      Scaffold(
        appBar: AppBar(
          title : Text(product?['nom']),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),

        ),
      body: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(10), // Image border
                child: SizedBox.fromSize(
                  size: Size.fromRadius(100), // Image radius
                  child: Image.network(product?["image"], fit: BoxFit.cover),
                ),
              ),
              SizedBox(height:20),
              Text(
                  "Marque : " + product?["marque"]),
              SizedBox(height:20),

              RichText(
                text: TextSpan(children: <InlineSpan>[
                  TextSpan(text : "Categories : ",
                      style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black)),
                  for (var string in product?["categories"])
                    TextSpan(text: string +", ", style: TextStyle(color: Colors.black)),
                ]),
              ),

              SizedBox(height:20),
              Text(
                  "Nutriscore : " + product?["nutriscore"]),


              SizedBox(height:20),
              Text(
                  "Score NOVA : " + product?["nova"]),
              SizedBox(height:20),

              RichText(
                text: TextSpan(children: <InlineSpan>[
                  TextSpan(text : "Ingredients : ",
                      style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black)),
                  for (var string in product?["analysis_ingredients"])
                    TextSpan(text: string +", ", style: TextStyle(color: Colors.black)),
                ]),
              ),

              SizedBox(height:20),
/*
              RichText(
                text: TextSpan(children: <InlineSpan>[
                  TextSpan(text : "Additifs : ",
                      style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black)),
                  for (var string in product?["additifs"] ?? "")
                    TextSpan(text: string +", ", style: TextStyle(color: Colors.black)),
                ]),
              ),

 */

              SizedBox(height:20),
/*
              RichText(
                text: TextSpan(children: <InlineSpan>[
                  TextSpan(text : "Nutrients : ",
                      style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black)),
                  for (var string in product?["nutrient_levels"])
                    TextSpan(text: string +", ", style: TextStyle(color: Colors.black)),
                ]),
              ),

 */

            ],



          ),


        ),



      ),




    );

       */
  }
}