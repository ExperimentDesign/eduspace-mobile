import 'package:eduspace_mobile/views/classrooms/ClassroomsPage.dart';
import 'package:eduspace_mobile/views/iam/LoginPage.dart';
import 'package:eduspace_mobile/views/iam/RegisterPage.dart';
import 'package:eduspace_mobile/views/reservations/ReservationsPage.dart';
import 'package:eduspace_mobile/views/resources/ResourcesPage.dart';
import 'package:eduspace_mobile/views/sharedspaces/SharedSpacesPage.dart';
import 'package:eduspace_mobile/views/summary/SummaryPage.dart';
import 'package:eduspace_mobile/views/teachers/TeachersManagementPage.dart';
import 'package:flutter/material.dart';

import '../views/home/HomePage.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => HomePage(),
  '/login': (context) => LoginPage(),
  '/register': (context) => RegisterPage(),
  '/classrooms': (context) => ClassroomsPage(),
  '/shared-spaces': (context) => SharedSpacesPage(),
  '/teachers': (context) => TeachersManagementPage(),
  '/resources': (context) => ResourcesPage(),
  '/summary': (context) => SummaryPage(),
  '/reservations': (context) => ReservationsPage(),
};