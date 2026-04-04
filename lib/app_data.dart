// Global state shared across the app
class AppData {
  static String selectedLanguage = "en";

  // Logged-in patient info (filled after register/login)
  static String patientFirstName = "";
  static String patientLastName = "";
  static String patientMobile = "";
  static String patientAadhaar = "";
  static String patientLocation = "";

  // Logged-in staff info (filled after staff login)
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
  static List<String> services = [];

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
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    } else if (parts.length == 1 && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return "";
  }

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