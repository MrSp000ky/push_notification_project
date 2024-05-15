import 'package:bloc/bloc.dart';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_notification_project/domain/entities/push_message.dart';
import 'package:push_notification_project/firebase_options.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

    Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(  options: DefaultFirebaseOptions.currentPlatform,);

  print("Handling a background message: ${message.messageId}");
}



  NotificationsBloc() : super(const NotificationsState()) {
    on<NotificationStatusChanged>(_notificationStatusChanged);
    on<NotificationReceived>(_notificationsReceived);
    //Vrificar Estado de las notificaciones
    _checkPermissionsFCM();

    //Listener para notificaciones (Cuando la app este en primer plano -> Foreground)
    _onForegroundMessage();
  }

   static Future<void> initializeFCM() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
    void _notificationsReceived(
      NotificationReceived event, Emitter<NotificationsState> emit) {
    emit(
        state.copywith(notifications: [event.message, ...state.notifications]));
    
  }



void _notificationStatusChanged(NotificationStatusChanged event,Emitter<NotificationsState> emit){
  emit(state.copywith(status: event.status));
  _getFCMToken();
}

  void _handleRemoteMessage(RemoteMessage message){
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) return; 
    final PushMessage notification = mapperRemotoMessageToEntity(message);
    print(notification.toString());
    add(NotificationReceived(notification));  
  }

    PushMessage mapperRemotoMessageToEntity(RemoteMessage message){
    return PushMessage(
      messageId: _getMessage(message),
      title: message.notification!.title?? '', 
      body: message.notification!.body?? '', 
      sentDate: message.sentTime??DateTime.now() ,
      data: message.data,
      imageUrl: _getImageUrl(message.notification!));
  }

    String _getMessage(RemoteMessage message)=>
    message.messageId?.replaceAll(':', '').replaceAll('%', '')?? '';

    String? _getImageUrl(RemoteNotification notification){
      return Platform.isAndroid
        ?notification.android?.imageUrl
        :notification.apple?.imageUrl;
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
