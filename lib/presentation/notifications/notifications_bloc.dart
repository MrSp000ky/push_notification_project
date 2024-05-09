import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_notification_project/firebase_options.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationsBloc() : super(const NotificationsState()) {
    on<NotificationStatusChanged>(_notificationStatusChanged);
    _checkPermissionsFCM();
  }

   static Future<void> initializeFCM() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }


void _notificationStatusChanged(NotificationStatusChanged event,Emitter<NotificationsState> emit){
  emit(state.copywith(status: event.status));
  _getFCMToken();
}

  void _handleRemoteMessage(RemoteMessage message){
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) return; 
    print('Message also contained a notification: ${message.notification}');
  
  }

  void _onForegroundMessage(){
    FirebaseMessaging.onMessage.listen(_handleRemoteMessage);
  }


  void _checkPermissionsFCM() async {
    final settings = await messaging.getNotificationSettings();
    add(NotificationStatusChanged(settings.authorizationStatus));
  }

  void _getFCMToken() async {
    final settings = await messaging.getNotificationSettings();
    if (settings.authorizationStatus != AuthorizationStatus.authorized) return;
    final token = await messaging.getToken();
    print("Sesion: $token");
  }


  void requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );
    add(NotificationStatusChanged(settings.authorizationStatus)); 
  }


}
