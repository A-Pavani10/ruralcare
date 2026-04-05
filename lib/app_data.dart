// Global state shared across the app
class AppData {
  static String selectedLanguage = "en";

  // Admin info
  static String adminName = "Admin";

  // Logged-in patient info
  static String patientFirstName = "";
  static String patientLastName = "";
  static String patientMobile = "";
  static String patientAadhaar = "";
  static String patientLocation = "";

  // Logged-in staff info
  static String staffName = "";
  static String staffRole = "";
  static String staffMobile = "";
  static String staffCreatedBy = "Admin";

  // Patient's booked services: serviceName -> status (null = not booked)
  static Map<String, String?> serviceStatuses = {};

  // Patient's requests list
  static List<Map<String, String>> patientRequests = [];

  // Staff incoming requests pool (shared)
  static List<Map<String, dynamic>> incomingRequests = [];

  // Staff's claimed tasks
  static List<Map<String, dynamic>> myTasks = [];

  // Admin: list of patients
  static List<Map<String, String>> patients = [];

  // Admin: list of staff members
  static List<Map<String, String>> staffList = [];

  // Admin: list of services
  static List<Map<String, String>> services = [];

  // Admin: all requests for monitoring
  static List<Map<String, dynamic>> allRequests = [];

  // Helper: patient full name
  static String get patientFullName =>
      "$patientFirstName $patientLastName".trim();

  // Helper: patient initials
  static String get patientInitials {
    String first = patientFirstName.isNotEmpty ? patientFirstName[0] : "";
    String last = patientLastName.isNotEmpty ? patientLastName[0] : "";
    return (first + last).toUpperCase();
  }

  // Helper: staff initials
  static String get staffInitials {
    List<String> parts = staffName.trim().split(" ");
    if (parts.length >= 2) return (parts[0][0] + parts[1][0]).toUpperCase();
    if (parts.length == 1 && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return "";
  }

  // Helper: initials from any name string
  static String initialsFrom(String name) {
    List<String> parts = name.trim().split(" ");
    if (parts.length >= 2) return (parts[0][0] + parts[1][0]).toUpperCase();
    if (parts.length == 1 && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return "?";
  }

  // Helper: avatar color based on name
  static const List<int> _avatarColors = [
    0xFF4CAF50, 0xFF2196F3, 0xFFFF9800,
    0xFF9C27B0, 0xFFE91E63, 0xFF00BCD4,
  ];
  static int avatarColor(String name) {
    if (name.isEmpty) return _avatarColors[0];
    return _avatarColors[name.codeUnitAt(0) % _avatarColors.length];
  }

  static int get todayRequestCount => allRequests.length;
  static int get activeStaffCount =>
      staffList.where((s) => s['status'] != 'inactive').length;
  static int get totalPatientCount => patients.length;

  static void clearPatient() {
    patientFirstName = "";
    patientLastName = "";
    patientMobile = "";
    patientAadhaar = "";
    patientLocation = "";
    serviceStatuses = {};
    patientRequests = [];
  }

  static void clearStaff() {
    staffName = "";
    staffRole = "";
    staffMobile = "";
    staffCreatedBy = "Admin";
    myTasks = [];
  }
}