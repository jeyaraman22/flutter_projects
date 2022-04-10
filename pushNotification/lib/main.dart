import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:pushnotification/screen2.dart';
import 'package:pushnotification/screen3.dart';

final FlutterLocalNotificationsPlugin localNotification =
FlutterLocalNotificationsPlugin();
String? payload;
String? route;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey(debugLabel: "Main Navigator");

Future<void> backgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.notification!.body}");

 }

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // titletion
  importance: Importance.high,
  //groupId: "group_notify"
);

Future<void> main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
      await localNotification.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        navigatorKey: navigatorKey,
        initialRoute: (route != null)? route :'/',
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                builder: (_) =>  MyHomePage(),
              );
              break;
            case 'screen2':
              return MaterialPageRoute(
                builder: (_) =>  SecondScreen(),
              );
              break;
            case 'screen3':
              return MaterialPageRoute(
                builder: (_) => const ThirdScreen(),
              );
            default:
              return _errorRoute();
          }
        }
      ),
    );
  }
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
        builder: (_){
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Align(
                        child:  Container(
                          width: 150,
                          height: 150,
                          child: Icon(
                            Icons.delete_forever,
                            size: 48,
                          ),
                        ),
                        alignment: Alignment.center,
                      ),
                      const Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 150,
                          height: 150,
                          child: CircularProgressIndicator(
                              strokeWidth: 4,
                              value: 1.0
                            // valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.withOpacity(0.5)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20,),
                  const Text('Page Not Found'),
                  const SizedBox(height: 10,),
                  const Text('Press back button on your phone', style: TextStyle(color: Color(0xff39399d), fontSize: 28),),
                  const SizedBox(height: 20,),
                  /*ElevatedButton(
                    onPressed: () {
                      Navigator.pop();
                      return;
                    },
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all(Colors.orange),
                    ),
                    child: const Text('Back to home'),
                  ),*/
                ],
              ),
            ),
          );
        }
    );
  }
}


class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String title ="Push Notification";
  String messageTitle = "TITLE";
  String notificationAlert = "BODY";
  String token='';

  registerNotification()async{
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
            channel.id,
            channel.name,
            importance: Importance.max,
            priority: Priority.defaultPriority,
            groupKey: channel.groupId);
        NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
        List<ActiveNotification>? activeNotifications =
        await localNotification.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
            ?.getActiveNotifications();
        InboxStyleInformation inboxStyleInformation = InboxStyleInformation(
            [],
            contentTitle: "${(activeNotifications?.length)} messages",
            summaryText: "${(activeNotifications?.length)} messages");
        AndroidNotificationDetails groupNotifications =
        AndroidNotificationDetails(channel.id,
            channel.name,
            styleInformation: inboxStyleInformation,
            setAsGroupSummary: true,
            groupKey: channel.groupId);
        NotificationDetails groupNotificationDetailsPlatformSpefics =
        NotificationDetails(android: groupNotifications);
        if (message.data['page'] == "alert") {
          showDialog(context: context,
              builder: (_) =>
                  WillPopScope(
                    onWillPop: () async => false,
                    child: AlertDialog(
                      title: const Text(
                          "To use this app, download the latest version."),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context),
                            child: const Text("Update"))
                      ],
                    ),));
        } else {
          localNotification.show(
              notification.hashCode,
              message.data['title'],
              message.data['body'],
             (activeNotifications?.isEmpty)! ?
             notificationDetails :
              groupNotificationDetailsPlatformSpefics, payload: message.data['page']);

          print(
              "---ACTIVE NOTIFICATION LENGTH---${activeNotifications!.length}");
          if (activeNotifications.length > 0) {
          List<String>? lines = activeNotifications.map((e) =>
              e.title.toString()).toList();

        }
        }

          // List<ActiveNotification>? activeNotifications =
          //     await localNotification.resolvePlatformSpecificImplementation<
          //     AndroidFlutterLocalNotificationsPlugin>()?.getActiveNotifications();
          // print("---ACTIVE NOTIFICATION LENGTH---${activeNotifications!.length}");
          // if(activeNotifications.length > 1){
          //   List<String>? lines = activeNotifications.map((e) => e.title.toString()).toList();
          //   InboxStyleInformation inboxStyleInformation = InboxStyleInformation(lines,
          //       contentTitle: "${(activeNotifications.length)} messages",
          //       summaryText: "${(activeNotifications.length)} messages");
          //   AndroidNotificationDetails groupNotifications =
          //   AndroidNotificationDetails(channel.id,
          //       channel.name,
          //       importance: Importance.max,
          //       priority: Priority.high,
          //       styleInformation: inboxStyleInformation,
          //       setAsGroupSummary: true,
          //       groupKey: channel.groupId);
          //   NotificationDetails groupNotificationDetailsPlatformSpefics =
          //   NotificationDetails(android: groupNotifications);
          //   await localNotification.show(
          //       0,
          //       "",
          //       "", groupNotificationDetailsPlatformSpefics);
          // }

      }
    });
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
    await localNotification.getNotificationAppLaunchDetails();
    var initialzationSettingsAndroid =
    const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
    InitializationSettings(android: initialzationSettingsAndroid);
    await localNotification.initialize(initializationSettings,
        onSelectNotification: (String? payload){
          if(payload == "screen2"){
            Navigator.of(context).push(MaterialPageRoute(builder: (_)=>  SecondScreen()));
          }else
          if(payload == "screen3"){
            Navigator.of(context).push(MaterialPageRoute(builder: (_)=> const ThirdScreen()));
          }else{
            print("PAYLOAD--$payload");
          }
        });
  }

  checkForInitalMessage()async{
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if(initialMessage?.data['page'] != "alert") {
      print("Get Initial Message called");
        if(initialMessage?.data['page'] == "screen2"){
          Navigator.of(context).push(MaterialPageRoute(builder: (_)=> SecondScreen()));
        }
        if(initialMessage?.data['page'] == "screen3"){
          Navigator.of(context).push(MaterialPageRoute(builder: (_)=> const ThirdScreen()));
        }
        if(initialMessage?.data['page'] == "alert"){
          showDialog(context: context,
              builder: (_) =>
                  WillPopScope(
                    onWillPop: () async => false,
                    child: AlertDialog(
                      title: const Text(
                          "To use this app, download the latest version."),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context),
                            child: const Text("Update"))
                      ],
                    ),));
        }
    }

  }
  backgroundNotify()async{
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("On Message Opened App Called");
      print(message.data['page']);
      if (message.data['page'] == "alert") {
        showDialog(context: context,
            builder: (_) =>
                WillPopScope(
                  onWillPop: () async => false,
                  child: AlertDialog(
                    title: const Text(
                        "To use this app, download the latest version."),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context),
                          child: const Text("Update"))
                    ],
                  ),));
      } else {
      if (message.data['page'] == "screen2") {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (_) =>  SecondScreen()));
      }
      if (message.data['page'] == "screen3") {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ThirdScreen()));
      }
    }
    });
  }
  @override
  void initState(){
    print("--INIT CALLED--");
    super.initState();
    //FirebaseMessaging.instance.getToken().then((value) => print("Token--$value"));
    // FirebaseMessaging.instance.onTokenRefresh.listen((event) async{
    //   await FirebaseMessaging.instance.getToken().then((value) => token = value!);
    //   FirebaseMessaging.instance.sendMessage(to: token); });
    //print("TOKEN--$token");
    checkForInitalMessage();
    registerNotification();
    backgroundNotify();
     }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(onPressed: ()=> Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => SecondScreen())),
              icon: const Icon(Icons.chevron_right))
        ],
        backgroundColor: const Color(0xff008078),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
                messageTitle,
              style: Theme.of(context).textTheme.headline3,
            ),
            Text(
              notificationAlert,
              style: Theme.of(context).textTheme.headline5,
            ),
          ],
        ),
      ),
    );
  }
}
