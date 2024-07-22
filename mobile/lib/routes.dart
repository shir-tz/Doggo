
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/screens/auth/forgot_password_screen.dart';
import 'package:mobile/screens/auth/login_screen.dart';
import 'package:mobile/screens/auth/signup_step1_screen.dart';
import 'package:mobile/screens/auth/signup_step2_screen.dart';
import 'package:mobile/screens/bottom_menu.dart';
import 'package:mobile/screens/goals_screen.dart';
import 'package:mobile/screens/home/home_screen.dart';
import 'package:mobile/screens/profile/user_profile_screen.dart';

final Map<String, WidgetBuilder> routes = {
  //auth
  LoginScreen.routeName: (context) => const LoginScreen(),
  SignUpStep1Screen.routeName: (context) => const SignUpStep1Screen(),
  SignUpStep2Screen.routeName: (context) => const SignUpStep2Screen(),
  ForgotPasswordScreen.routeName: (context) => const ForgotPasswordScreen(),
  //menu
  BottomMenu.routeName: (context) => const BottomMenu(),
  //profile
  UserProfileScreen.routeName: (context) => const UserProfileScreen(),
  //home
  //goals
  // add screens here
};