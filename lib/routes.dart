import 'package:attendzone_new/screens/Announcements.dart';
import 'package:attendzone_new/screens/Projects.dart';
import 'package:attendzone_new/screens/chat.dart';
import 'package:attendzone_new/screens/messages.dart';
import 'package:attendzone_new/screens/home.dart';
import 'package:attendzone_new/screens/login.dart';
import 'package:attendzone_new/screens/profile.dart';
import 'package:go_router/go_router.dart';

import 'main.dart';
class AppRoutes {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: prefs.getBool('login') ?? false ? '/home' : '/',
      //initialLocation: prefs.getBool('login') ?? false ? '/home' : '/',
      // errorPageBuilder: (context, state) {
      //   return MaterialPage(child: Scaffold(
      //     appBar: AppBar(title: Text('Error')),
      //     body: Center(child: Text('Page not found')),
      //   ));
      // },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Login(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/Projects',
          builder: (context, state) => const Projects(),
        ),
        GoRoute(
          path: '/Profile',
          builder: (context, state) => const Profile(),
        ),
        GoRoute(
          path: '/announcements',
          builder: (context, state) => const Chat(),
        ),
        GoRoute(
          path: '/Chat',
          builder: (context, state) {
            final args = state.extra as ChatPage;
            return ChatPage(
              sender: args.sender,
              projectName: args.projectName,
            );
          },
        ),
      ],
    );
  }
}
