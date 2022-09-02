
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

//1import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:http/http.dart' as http;
//import 'package:image/image.dart' as image;
//import 'package:path_provider/path_provider.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';



Future<List<int>> initialzeDaysNotification() async {

  var prefs = await SharedPreferences.getInstance();

  var initialList = [DateTime.monday,DateTime.tuesday,DateTime.wednesday,DateTime.thursday,DateTime.friday,DateTime.saturday,DateTime.sunday];

  List<int> newList = [];

  var listOfDays = prefs.getStringList('listOfDays');

  for(int i =0; i < initialList.length;i++){
    if(listOfDays?[i] == 'true'){
      newList.add(initialList[i]);
    }

  }

  print("LIST OF DAYS");
  print(newList);

  return newList;

}

Future<int> initialzeHoursNotification() async {

  var prefs = await SharedPreferences.getInstance();

  var hours = 0;



  var listOfHours = prefs.getStringList('listOfHours');

 if(listOfHours?[0] == 'true') hours = 8;
 else if(listOfHours?[1] == 'true') hours = 13;
 else hours = 18;

  print("HOURS");
  print(hours);

  return hours;

}




class NotificationWidget{
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();

  final NotifDays = initialzeDaysNotification();
  final NotifHours = initialzeHoursNotification();


  static Future init({bool scheduled = false}) async {
    var initAndroidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    var ios = IOSInitializationSettings();
    final settings = InitializationSettings(android: initAndroidSettings, iOS: ios);

    // When app is closed
    final details = await _notifications.getNotificationAppLaunchDetails();

    if(details != null && details.didNotificationLaunchApp){
      onNotifications.add(details.payload);
    }

    await _notifications.initialize(
        settings,
        onSelectNotification: (payload) async {
          onNotifications.add(payload);
        }
    );

    if(scheduled){
      tz.initializeTimeZones();
      final locationTime = await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(locationTime));
      //print("AYAYAYAYA"+tz.local.toString());

    }


  }

  static tz.TZDateTime _scheduleDaily(Time time){
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime(tz.local,now.year, now.month, now.day,
    time.hour, time.minute, time.second);



    return scheduledDate.isBefore(now)
        ? scheduledDate.add(Duration(days:1))
        : scheduledDate;

  }


  static tz.TZDateTime _scheduleWeekly(Time time, {required List<int> days}){
    tz.TZDateTime scheduledDate = _scheduleDaily(time);

    while(!days.contains(scheduledDate.weekday)){
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }

    return scheduledDate;

  }



  static Future showNotification({
   var id = 0,
   var title,
   var body,
   var payload,


}) async =>
      _notifications.show(
        id,
        title,
        body,

        await notificationDetails(),
        payload: payload,

        );

  static Future showScheduledNotification({
    var id = 0,
    var title,
    var body,
    var payload,
    required scheduleTime,


  }) async =>
      _notifications.zonedSchedule(
        id,
        title,
        body,
        //_scheduleDaily(Time(8,15,0)),
        tz.TZDateTime.from(scheduleTime, tz.local),

        await notificationDetails(),
        payload: payload,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,

      );


  static Future showRepeatNotification({
    var id = 0,
    var title,
    var body,
    var payload,
    //required scheduleTime,


  }) async =>
      _notifications.zonedSchedule(
        id,
        title,
        body,
        _scheduleDaily(Time(11,20,0)),
        //tz.TZDateTime.from(scheduleTime, tz.local),

        await notificationDetails(),
        payload: payload,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,

      );

  static Future showRepeatWeeklyNotification({
    var id = 0,
    var title,
    var body,
    var payload,
    //required scheduleTime,


  }) async =>
      _notifications.zonedSchedule(
        id,
        title,
        body,
        //_scheduleWeekly(Time(await initialzeHoursNotification() -2,0,0), days : await initialzeDaysNotification()),
        _scheduleWeekly(Time((await initialzeHoursNotification()) -2,0,0), days : await initialzeDaysNotification()),
        //tz.TZDateTime.from(scheduleTime, tz.local),

        await notificationDetails(),
        payload: payload,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,

      );





static notificationDetails() async{
  return NotificationDetails(
  android: AndroidNotificationDetails(
    'channel id 3',
    'channel name',
    //importance: Importance.max,
    icon: '@mipmap/ic_launcher',

    largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),

    ongoing: false,
    styleInformation: BigTextStyleInformation(''),

  ),
    iOS : IOSNotificationDetails()





  );



}




}