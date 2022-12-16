import 'package:flutter/material.dart';
import 'package:mentor_me/screens/events/create_screen.dart';
import 'package:mentor_me/screens/screens.dart';

import '../screens/events/event_room_screen.dart';
import '../screens/events/event_room_task_screen.dart';

class CustomRouter {
  static Route onGenerateRoute(RouteSettings settings) {
    print('Route: ${settings.name}');

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          settings: const RouteSettings(name: '/'),
          builder: (_) => const Scaffold(),
        );

      case SplashScreen.routeName:
        return SplashScreen.route();
      case Onboardingpageview.routeName:
        return Onboardingpageview.route();
      case LoginPageView.routeName:
        return LoginPageView.route();
      case EventsScreen.routeName:
        return EventsScreen.route();
      case CreateEventScreen.routeName:
        return CreateEventScreen.route();
      case EventRoomScreen.routeName:
        return EventRoomScreen.route(
            args: settings.arguments as EventRoomScreenArgs);
      case EventRoomTaskScreen.routeName:
        return EventRoomTaskScreen.route(
            args: settings.arguments as EventRoomTaskScreenArgs);
      default:
        return _errorRoute();
    }
  }

  static Route _errorRoute() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: '/error'),
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Something went wrong!'),
        ),
      ),
    );
  }
}
