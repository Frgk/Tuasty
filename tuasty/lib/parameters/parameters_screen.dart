import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tuasty/authpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuasty/parameters/constant.dart';

import 'package:pie_chart/pie_chart.dart';

class ParametersScreen extends StatefulWidget {
  @override
  _ParametersScreenState createState() => _ParametersScreenState();
}

class _ParametersScreenState extends State<ParametersScreen> {
  var docRef = Map<String, dynamic>();
  var docName = '';

  List<bool> daysList = [true, false, false, false, false, false, false];
  List<bool> hoursList = [true, false, false];

  late final prefs;

  late double total_food;

  late Map<String, double> dataMap;

  final ScrollController _firstController = ScrollController();

  Icon getStatisticsEmoji(var data) {
    if (data['consumed_food'].toDouble() == 0 &&
        data['discarded_food'].toDouble() == 0) {
      return Icon(
        Icons.fastfood,
        color: Colors.grey,
      );
    } else if (data['consumed_food'].toDouble() >=
            data['discarded_food'].toDouble()
        ) {
      return Icon(
        Icons.mood,
        color: Colors.green,
      );
    } else {
      return Icon(
        Icons.mood_bad,
        color: Colors.red,
      );
    }
  }

  Text getStatisticsText(var data) {
    if (data['consumed_food'].toDouble() == 0 &&
        data['discarded_food'].toDouble() == 0) {
      return Text(
        "Il n'y a pas assez d'informations pour réaliser des statistiques !",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey,
        ),
      );
    } else if (data['consumed_food'].toDouble() >=
            data['discarded_food'].toDouble())
         {
      return Text(
        "Vous avez un comportement exemplaire !",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.green,
        ),
      );
    } else {
      return Text(
        "Vous pouvez mieux faire !",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.red,
        ),
      );
    }
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

    prefs = await SharedPreferences.getInstance();

    List<String>? paramDays = prefs.getStringList('listOfDays');
    List<String>? paramHours = prefs.getStringList('listOfHours');

    for (int i = 0; i < paramDays!.length; i++) {
      if (paramDays[i] == 'false')
        daysList[i] = false;
      else
        daysList[i] = true;
    }

    for (int i = 0; i < paramHours!.length; i++) {
      if (paramHours[i] == 'false')
        hoursList[i] = false;
      else
        hoursList[i] = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection('users')
      .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        //stream: _usersStream,
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          } else {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color : Colors.black),
                  onPressed: () => Navigator.of(context).pop(),

                ),
                title: Text("Profil",
                style: TextStyle(
                  color: Colors.black,
                ),
                ),
                centerTitle: true,
                automaticallyImplyLeading: true,
                shape: Border(
                    bottom: BorderSide(
                      color: Colors.black,
                      width: 2,
                    )
                ),

          flexibleSpace: Container(
          decoration: BoxDecoration(
          gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.yellow.shade500,
            Colors.yellow.shade400,
            Colors.yellow.shade300,
          ]),
          ),


              ),
              ),


              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.yellow.shade300,
                      Colors.yellow.shade200,
                      Colors.yellow.shade100,
                      //Colors.white,
                    ],
                  ),
                ),
                child: Column(
                  children: snapshot.data!.docs
                      .map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;

                    dataMap = {
                      "Aliment consommé": data['consumed_food'].toDouble(),
                      "Aliment jeté": data['discarded_food'].toDouble(),
                    };

                    total_food = data['consumed_food'].toDouble() +
                        data['discarded_food'].toDouble();

                    return Expanded(


                      child :SingleChildScrollView(
                        //color: Colors.yellow,
                        scrollDirection: Axis.vertical,



                        child: Column(
                          children: [

                            SizedBox(height: 20,),

                            Icon(
                              Icons.person,
                              color: Colors.black,
                              size: 50.0,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Name : " + docName,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Email : " +
                                  FirebaseAuth.instance.currentUser!.email
                                      .toString(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 40),
                            const SizedBox(
                              width: 300.0,
                              height: 5.0,
                              child: const DecoratedBox(
                                decoration:
                                const BoxDecoration(color: Colors.black),
                              ),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            PieChart(
                              dataMap: dataMap,
                              animationDuration: Duration(milliseconds: 800),
                              chartLegendSpacing: 32,
                              chartRadius:
                              MediaQuery.of(context).size.width / 3.2,

                              initialAngleInDegree: 0,
                              chartType: ChartType.ring,
                              ringStrokeWidth: 32,

                              legendOptions: LegendOptions(
                                showLegendsInRow: false,
                                legendPosition: LegendPosition.right,
                                showLegends: true,
                                legendTextStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              chartValuesOptions: ChartValuesOptions(
                                showChartValueBackground: true,
                                showChartValues: true,
                                showChartValuesInPercentage: true,
                                showChartValuesOutside: false,
                                decimalPlaces: 1,
                              ),
                              totalValue: total_food,
                              colorList: [
                                Colors.green,
                                Colors.red,
                              ],
                              // gradientList: ---To add gradient colors---
                              // emptyColorGradient: ---Empty Color gradient---
                            ),
                            SizedBox(height: 50),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                ),
                                getStatisticsEmoji(data),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: getStatisticsText(data),
                                ),
                              ],
                            ),
                            SizedBox(height: 40),
                            const SizedBox(
                              width: 300.0,
                              height: 5.0,
                              child: const DecoratedBox(
                                decoration:
                                const BoxDecoration(color: Colors.black),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Notification : ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            ToggleButtons(
                              isSelected: daysList,
                              fillColor: Colors.black,
                              color: Colors.black,
                              renderBorder: false,
                              borderColor: Colors.green,
                              selectedColor: Colors.white,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 1),
                                  child: Text('Lu'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 1),
                                  child: Text('Ma'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 1),
                                  child: Text('Me'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 1),
                                  child: Text('Je'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 1),
                                  child: Text('Ve'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 1),
                                  child: Text('Sa'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 1),
                                  child: Text('Di'),
                                ),
                              ],
                              onPressed: (int newIndex) async {
                                setState(() {
                                  daysList[newIndex] = !daysList[newIndex];
                                });

                                var temp_days = [
                                  'true',
                                  'true',
                                  'true',
                                  'true',
                                  'true',
                                  'true',
                                  'true'
                                ];
                                for (int i = 0; i < daysList.length; i++) {
                                  if (daysList[i] == true)
                                    temp_days[i] = 'true';
                                  else
                                    temp_days[i] = 'false';
                                }

                                await prefs.setStringList(
                                    'listOfDays', temp_days);
                              },
                            ),
                            SizedBox(height: 10),
                            ToggleButtons(
                              isSelected: hoursList,
                              fillColor: Colors.black,
                              color: Colors.black,
                              renderBorder: false,
                              borderColor: Colors.green,
                              selectedColor: Colors.white,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 1),
                                  child: Text('8:00'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 1),
                                  child: Text('13:00'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 1),
                                  child: Text('18:00'),
                                ),
                              ],
                              onPressed: (int newIndex) async {
                                setState(() {
                                  for (int index = 0;
                                  index < hoursList.length;
                                  index++) {
                                    if (index == newIndex)
                                      hoursList[index] = true;
                                    else
                                      hoursList[index] = false;
                                  }
                                });

                                var temp_hours = ['true', 'true', 'true'];
                                for (int i = 0; i < hoursList.length; i++) {
                                  if (hoursList[i] == true)
                                    temp_hours[i] = 'true';
                                  else
                                    temp_hours[i] = 'false';
                                }

                                await prefs.setStringList(
                                    'listOfHours', temp_hours);
                              },
                            ),
                            SizedBox(height: 30),
                            Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Text(
                                "Veuillez fermer l'application pour que le changement des notifications soit appliqué !",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            const SizedBox(
                              width: 300.0,
                              height: 5.0,
                              child: const DecoratedBox(
                                decoration:
                                const BoxDecoration(color: Colors.black),
                              ),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final batch =
                                await FirebaseFirestore.instance.batch();
                                final dbRef = await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(docName);

                                batch.update(dbRef, {'consumed_food': 0});
                                batch.update(dbRef, {'discarded_food': 0});

                                batch.commit().then((_) {
                                  // ...
                                });

                                displayToast(
                                    context,
                                    Colors.green,
                                    Colors.white,
                                    Icons.check_box_rounded,
                                    "Réinitialisation effectuée !");
                              },
                              icon: Icon(
                                Icons.lock_clock_outlined,
                                color: Colors.white,
                              ), //icon data for elevated button
                              label:
                              Text("Reset les statistiques"), //label text
                            ),
                            SizedBox(height: 20),
                            const SizedBox(
                              width: 300.0,
                              height: 5.0,
                              child: const DecoratedBox(
                                decoration:
                                const BoxDecoration(color: Colors.black),
                              ),
                            ),
                            SizedBox(height: 60),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  FirebaseAuth.instance.signOut(),
                              icon: Icon(
                                // <-- Icon
                                Icons.arrow_back_ios,
                                size: 24.0,
                              ),
                              label: Text('SIGN OUT'),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red,
                              ),
                            ),
                            SizedBox(height: 50),
                          ],
                        ),
                      ),

                    );

                  })
                      .toList()
                      .cast(),
                ),
              ),

            );





          }
        });
  }
}
