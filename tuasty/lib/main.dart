

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';



import 'package:tuasty/home.dart';
import 'package:tuasty/authpage.dart';
import 'package:shared_preferences/shared_preferences.dart';



Future<void> initializeParameter() async {
  final prefs = await SharedPreferences.getInstance();

  final List<String>? listOfDays = prefs.getStringList('listOfDays');
  final List<String>? listOfHours = prefs.getStringList('listOfHours');





  if(listOfDays == null){
    await prefs.setStringList('listOfDays', ['true','false','false','false','false','false','false']);
  }
  if(listOfHours == null){
    await prefs.setStringList('listOfHours', ['true','false','false']);
  }



}




Future<void> main() async {


  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await initializeParameter();









  runApp(MaterialApp(
    home: Main(),
  )
  );
}




class Main extends StatelessWidget{
  
final Future<FirebaseApp> _fbApp = Firebase.initializeApp();

  Main({Key? key}) : super(key: key);

@override
Widget build(BuildContext context){

  return MaterialApp(
    home: FutureBuilder(
      future: _fbApp,
      builder: (context, snapshot){
        if (snapshot.hasError){
          return Text("Error");
        } else if (snapshot.hasData){

          return MainPage();

        } else{
          return Center(
            child: CircularProgressIndicator(),
          );
        }



      },



    ),

  );


}



  /*
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
    SystemUiOverlay.bottom,
    SystemUiOverlay.top,

  ]);
  */

  //await Firebase.initializeApp(
  /*
  options: FirebaseOptions(
      apiKey: 'AIzaSyA6jYVMmI6J7Hqzp9PINFYW75GrNWD76P0',
      appId: 'appId',
      messagingSenderId: 'messagingSenderId',
      projectId: 'tuasty-90b4f')
  */


  //await initializeParameter();

// Apple and Android

 /*
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
*/
// Web
  //await FirebaseFirestore.instance.enablePersistence(const PersistenceSettings(synchronizeTabs: true));









}


class MainPage extends StatefulWidget {

  @override
  _MainPage createState() => _MainPage();

}


class _MainPage extends State<MainPage> {







  @override
  Widget build(BuildContext context) => Scaffold(
    body: StreamBuilder<User?>(
      stream:FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          //return Center(child:CircularProgressIndicator());
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Loading...',
                style: Theme.of(context).textTheme.headline6,
              ),
              CircularProgressIndicator(

                semanticsLabel: 'Linear progress indicator',
              ),
            ],

          );


        } else if (snapshot.hasError){
          return Center(child: Text('Something went wrong'));
        }
        else if (snapshot.hasData){
          return HomePage();
        }else{
          return AuthPage();
        }
      },

    ),
  );
}