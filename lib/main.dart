import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app/app.dart';
part 'app/routes.dart';
part 'app/theme.dart';
part 'core/utils/session.dart';
part 'core/utils/ui_helpers.dart';
part 'core/common_widgets/common_widgets.dart';
part 'services/auth_service.dart';
part 'services/firestore_service.dart';
part 'services/notification_service.dart';
part 'services/request_service.dart';
part 'screens/splash/splash_screen.dart';
part 'screens/auth/language_screen.dart';
part 'screens/auth/role_screen.dart';
part 'screens/auth/admin_login_screen.dart';
part 'screens/auth/staff_login_screen.dart';
part 'screens/auth/patient_entry_screen.dart';
part 'screens/auth/patient_login_screen.dart';
part 'screens/auth/patient_registration_screen.dart';
part 'screens/admin/admin_dashboard_screen.dart';
part 'screens/admin/admin_summary_screen.dart';
part 'screens/admin/admin_patients_screen.dart';
part 'screens/admin/admin_staff_screen.dart';
part 'screens/staff/staff_dashboard_screen.dart';
part 'screens/staff/staff_incoming_screen.dart';
part 'screens/staff/staff_tasks_screen.dart';
part 'screens/staff/staff_profile_screen.dart';
part 'screens/patient/patient_dashboard_screen.dart';
part 'screens/patient/patient_profile_screen.dart';
part 'screens/services/book_service_screen.dart';
part 'screens/services/admin_services_screen.dart';
part 'screens/requests/request_widgets.dart';
part 'screens/requests/patient_requests_screen.dart';
part 'screens/requests/request_monitor_screen.dart';
part 'screens/notifications/notifications_screen.dart';

const green = Color(0xFF16794F);
final db = FirebaseFirestore.instance;
final auth = FirebaseAuth.instance;
final fmt = DateFormat('dd/MM/yyyy HH:mm');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await seedDefaultAdminIfMissing();
  await seedDefaultServicesIfMissing();
  runApp(const RuralCareApp());
}
