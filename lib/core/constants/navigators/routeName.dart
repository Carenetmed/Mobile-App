// ignore_for_file: file_names

/// Named route identifiers. Must match [generateRoute] in [router.dart] and [docs/ROUTES.md].
///
/// Use with: `Navigator.pushNamed(context, RouteName.xxx)` or
/// `Navigator.pushReplacementNamed(context, RouteName.xxx)`.
class RouteName {
  RouteName._();

  // --- Launch & onboarding (Flow A) ---
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';

  // --- Sign up (Flow A) ---
  static const String signUpPhone = 'signUpPhone';
  static const String signUpEmail = 'signUpEmail';
  static const String finishSignUp = 'finishSignUp';

  // --- Agreements (Flow A) ---
  static const String communityAgreement = 'communityAgreement';
  static const String notificationAgreement = 'notificationAgreement';
  static const String medicalAgreement = 'medicalAgreement';
  static const String medicalProfessional = 'medicalProfessional';
  static const String medicalEdit = 'medicalEdit';

  // --- Sign in (Flow B — Phase 3) ---
  static const String signInPhone = 'signInPhone';
  static const String signInEmail = 'signInEmail';
  static const String enterEmail = 'enterEmail';
  static const String enterPassword = 'enterPassword';
  static const String resetPasswordConfirm = 'resetPasswordConfirm';
  static const String emailVerificationConfirm = 'emailVerificationConfirm';

  /// Reserved for a combined login hub screen (not wired in Phase 0).
  static const String login = 'login';

  // --- Main app ---
  static const String dashboard = 'dashboard';
  static const String search = 'search';
  static const String findMentor = 'findMentor';
  static const String specialistDetails = 'specialistDetails';
  static const String appointments = 'appointments';
  static const String bookAppointment = 'bookAppointment';
  static const String readings = 'readings';
  static const String healthRecord = 'healthRecord';
  static const String manageReadings = 'manageReadings';
  static const String addDevice = 'addDevice';
  static const String bloodSug = 'bloodSug';
  static const String articles = 'articles';
  static const String savedArticles = 'savedArticles';
  static const String publishedArticles = 'publishedArticles';
  static const String caseStudies = 'caseStudies';
  static const String podcast = 'podcast';
  static const String emergency = 'emergency';
  static const String distressCall = 'distressCall';
  static const String discoverCommunities = 'discoverCommunities';
  static const String communityProfile = 'communityProfile';
  static const String ownerCircleProfile = 'ownerCircleProfile';
  static const String createCommunity = 'createCommunity';
  static const String qAAsk = 'qAAsk';
  static const String qAAnswerRequests = 'qAAnswerRequests';
  static const String qAAnswerForYou = 'qAAnswerForYou';
  static const String commentAnswer = 'commentAnswer';
  static const String account = 'account';
  static const String deleteAccount = 'deleteAccount';
  static const String settings = 'settings';
  static const String changeAuthentication = 'changeAuthentication';
  static const String turnOnAuthentication = 'turnOnAuthentication';
  static const String createPin = 'createPin';
  static const String confirmPinSave = 'confirmPinSave';
  static const String addPhoneNumber = 'addPhoneNumber';
  static const String confirmPhoneNumber = 'confirmPhoneNumber';
  static const String addEmail = 'addEmail';
  static const String editEmail = 'editEmail';
  static const String changeEmail = 'changeEmail';
  static const String enterPasswordToSave = 'enterPasswordToSave';
  static const String password = 'password';
  static const String publicProfile = 'publicProfile';
  static const String manageProfile = 'manageProfile';
  static const String managePortfolio = 'managePortfolio';
  static const String professionalVerificationDocuments =
      'professionalVerificationDocuments';
  static const String editYourName = 'editYourName';
  static const String editProfessionalDetails = 'editProfessionalDetails';
  static const String editYourWebsite = 'editYourWebsite';
  static const String addDescription = 'addDescription';
  static const String setAddress = 'setAddress';

  // --- Messaging (Flow D — Phase 5) ---
  static const String messages = 'messages';
  static const String chat = 'chat';
  static const String message = 'message';
  static const String notification = 'notification';
  static const String reminder = 'reminder';
  static const String schedules = 'schedules';
  static const String selectedDates = 'selectedDates';
}
