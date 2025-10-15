// import 'package:app_fotografia/components/session_details_screen.dart';
// import 'package:app_fotografia/screens/auth/forgot_password/forgot_password_screen.dart';
// import 'package:app_fotografia/screens/auth/sign_in/sign_in_screen.dart';
// import 'package:app_fotografia/screens/auth/sign_up/components/privacy_policy.dart';
// import 'package:app_fotografia/screens/auth/sign_up/components/terms_conditions.dart';
// import 'package:app_fotografia/screens/auth/sign_up/sign_up_screen.dart';
// import 'package:app_fotografia/screens/chat/chat_screen.dart';
// import 'package:app_fotografia/screens/photographer/photographer_home/photographer_home_screen.dart';
// import 'package:app_fotografia/screens/photographer/photographer_description/photographer_description_screen.dart';
// import 'package:app_fotografia/screens/photographer/photographer_last_step/photographer_last_step_screen.dart';
// import 'package:app_fotografia/screens/photographer/photographer_notification/photographer_user_description_screen.dart';
// import 'package:app_fotografia/screens/photographer/photographer_profile/photographer_profile_screen.dart';
// import 'package:app_fotografia/screens/photographer/photographer_profile/screens/components/package_builder_screen.dart';
// import 'package:app_fotografia/screens/photographer/photographer_profile/screens/photographer_edit_profile.dart';
// import 'package:app_fotografia/screens/photographer/photographer_profile/screens/photographer_information/photographer_account_screen.dart';
// import 'package:app_fotografia/components/reviews/reviews_screen.dart';
// import 'package:app_fotografia/screens/photographer/protographer_activity/components/submit_photos_screen.dart';
// import 'package:app_fotografia/screens/photographer/protographer_activity/photographer_activity_screen.dart';
// import 'package:app_fotografia/screens/photographer/photographer_extra_info/photographer_extra_info_screen.dart';
// import 'package:app_fotografia/screens/user/user_activity/components/review_photographer.dart';
// import 'package:app_fotografia/screens/user/user_activity/user_activity_screen.dart';
// import 'package:app_fotografia/screens/user/user_home/user_home_screen.dart';
// import 'package:app_fotografia/screens/user/user_profile/screens/help/components/contact_support_screen.dart';
// import 'package:app_fotografia/screens/user/user_profile/screens/help/components/faq_screen.dart';
// import 'package:app_fotografia/screens/user/user_profile/screens/help/help_screen.dart';
// import 'package:app_fotografia/screens/user/user_profile/screens/payment_methods/payment_methods_screen.dart';
// import 'package:app_fotografia/screens/user/user_profile/screens/user_my_account/components/user_edit_profile.dart';
// import 'package:app_fotografia/screens/user/user_profile/screens/user_my_account/user_my_account_screen.dart';
// import 'package:app_fotografia/screens/user/user_profile/screens/settings/user_profile_settings_screen.dart';
// import 'package:app_fotografia/screens/user/user_profile/user_profile_screen.dart';
// import 'package:app_fotografia/services/arguments.dart';
// import 'package:app_fotografia/services/signed_in_out.dart';
// import 'package:app_fotografia/web/pages/home_page/home_page.dart';
// import 'package:app_fotografia/web/pages/privacy_policy/privacy_policy.dart';
// import 'package:app_fotografia/web/pages/terms_conditions/terms_and_conditions.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';

// final Map<String, WidgetBuilder> routes = {
//   SignedInOut.routeName: (context) => const SignedInOut(),
//   SignInScreen.routeName: (context) => const SignInScreen(),
//   SignUpScreen.routeName: (context) => const SignUpScreen(),
//   ForgotPasswordScreen.routeName: (context) => const ForgotPasswordScreen(),
//   PhotographerExtraInfoScreen.routeName: (context) =>
//       const PhotographerExtraInfoScreen(),
//   PhotographerLastStepScreen.routeName: (context) =>
//       const PhotographerLastStepScreen(),
//   UserHomeScreen.routeName: (context) => const UserHomeScreen(),
//   UserActivityScreen.routeName: (context) => const UserActivityScreen(),
//   UserProfileScreen.routeName: (context) => const UserProfileScreen(),
//   UserMyAccountScreen.routeName: (context) => const UserMyAccountScreen(),
//   UserSettingsScreen.routeName: (context) => const UserSettingsScreen(),
//   PhotographerActivityScreen.routeName: (context) =>
//       const PhotographerActivityScreen(),
//   PhotographerHomeScreen.routeName: (context) => const PhotographerHomeScreen(),
//   PhotographerProfileScreen.routeName: (context) =>
//       const PhotographerProfileScreen(),
//   PhotographerAccountScreen.routeName: (context) =>
//       const PhotographerAccountScreen(),
//   PhotographerDescriptionScreen.routeName: (context) =>
//       const PhotographerDescriptionScreen(),
//   ReviewsScreen.routeName: (context) => const ReviewsScreen(),
//   PhotographerEditProfile.routeName: (context) =>
//       const PhotographerEditProfile(),
//   PhotographerUserDescriptionScreen.routeName: (context) =>
//       const PhotographerUserDescriptionScreen(),
//   ChatScreen.routeName: (context) {
//     final ChatArguments args =
//         ModalRoute.of(context)!.settings.arguments as ChatArguments;
//     return ChatScreen(args: args);
//   },
//   PaymentMethodsScreen.routeName: (context) => const PaymentMethodsScreen(),
//   SubmitPhotosScreen.routeName: (context) => const SubmitPhotosScreen(),
//   ReviewPhotographerScreen.routeName: (context) =>
//       const ReviewPhotographerScreen(),
//   SessionDetailsScreen.routeName: (context) => const SessionDetailsScreen(),
//   TermsAndConditionsScreen.routeName: (context) =>
//       const TermsAndConditionsScreen(),
//   PrivacyPolicyScreen.routeName: (context) => const PrivacyPolicyScreen(),
//   HelpScreen.routeName: (context) => const HelpScreen(),
//   FaqScreen.routeName: (context) => const FaqScreen(),
//   ContactSupportScreen.routeName: (context) => const ContactSupportScreen(),
//   UserEditProfileScreen.routeName: (context) => const UserEditProfileScreen(),
//   PackagesBuilderScreen.routeName: (context) => const PackagesBuilderScreen(),
// };
