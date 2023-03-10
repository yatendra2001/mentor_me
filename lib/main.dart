import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:mentor_me/blocs/blocs.dart';
import 'package:mentor_me/config/custom_router.dart';
import 'package:mentor_me/repositories/repositories.dart';
import 'package:mentor_me/screens/login/login_cubit/login_cubit.dart';
import 'package:mentor_me/screens/screens.dart';
import 'package:mentor_me/utils/app_themes.dart';
import 'package:mentor_me/utils/session_helper.dart';
import 'key.dart';
import 'package:sizer/sizer.dart';

import 'screens/stream_chat/cubit/initialize_stream_chat/initialize_stream_chat_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Stripe.publishableKey =
      'pk_test_51MGH47SBsIkHMnZFx6rvm5YQAyhf2kpPY0uQMMHoOzYatk4jRlM7tdkUG2j2ehRBiBXfa3991t18uUD6B8ZqDi2I00UPhEP0aO';
  await Stripe.instance.applySettings();
  EquatableConfig.stringify = kDebugMode;
  Bloc.observer = SimpleBlocObserver();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  MyApp({Key? key}) : super(key: key);

  final client = StreamChatClient(
    streamChatApiKey,
    logLevel: Level.INFO,
  );

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),
        RepositoryProvider<UserRepository>(
          create: (_) => UserRepository(),
        ),
        RepositoryProvider<StorageRepository>(
          create: (_) => StorageRepository(),
        ),
        RepositoryProvider<EventRepository>(
          create: (_) => EventRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) =>
                AuthBloc(authRepository: context.read<AuthRepository>()),
          ),
          BlocProvider<LoginCubit>(
            create: (context) => LoginCubit(
                authRepository: context.read<AuthRepository>(),
                userRepository: context.read<UserRepository>()),
          ),
          BlocProvider(
            create: (context) => InitializeStreamChatCubit(),
          ),
        ],
        child: Sizer(
          builder: (context, orientation, deviceType) => MaterialApp(
            builder: (context, child) => StreamChat(
              client: client,
              child: child,
            ),
            navigatorKey: navigatorKey,
            title: 'MentorMe',
            debugShowCheckedModeBanner: false,
            theme: AppThemes.lightTheme,
            onGenerateRoute: CustomRouter.onGenerateRoute,
            initialRoute: SplashScreen.routeName,
          ),
        ),
      ),
    );
  }
}

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    print(event);
    super.onEvent(bloc, event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    print(transition);
    super.onTransition(bloc, transition);
  }

  @override
  Future<void> onError(
    BlocBase bloc,
    Object error,
    StackTrace stackTrace,
  ) async {
    print(error);
    super.onError(bloc, error, stackTrace);
  }
}
