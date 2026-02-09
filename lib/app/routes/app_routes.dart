// ignore_for_file: constant_identifier_names

part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const SPLASH = _Paths.SPLASH;

  // Auth module
  static const AUTH = _Paths.AUTH;
  static const LOGIN = _Paths.LOGIN;
  static const ROLE_SELECTION = _Paths.ROLE_SELECTION; // signup-only entry
  static const SIGN_UP = _Paths.SIGN_UP;
  static const FORGOT_PASSWORD = _Paths.FORGOT_PASSWORD;
  static const RESET_PASSWORD = _Paths.RESET_PASSWORD;
  static const AGREEMENT = _Paths.AGREEMENT;

  // Client module
  static const CLIENT_DASHBOARD = _Paths.CLIENT_DASHBOARD;
  static const CLIENT_JOB_DETAIL = _Paths.CLIENT_JOB_DETAIL;
  static const CLIENT_SCHEDULE_JOB = _Paths.CLIENT_SCHEDULE_JOB;
  static const CLIENT_CREATE_JOB = _Paths.CLIENT_CREATE_JOB;
  static const CLIENT_EDIT_PROFILE = _Paths.CLIENT_EDIT_PROFILE;
  static const ADD_REVIEW = _Paths.ADD_REVIEW;

  // Cleaner module
  static const CLEANER_DASHBOARD = _Paths.CLEANER_DASHBOARD;
  static const CLEANER_JOB_DETAIL = _Paths.CLEANER_JOB_DETAIL;
  static const PROPERTY = _Paths.PROPERTY;
  static const ADD_PROPERTY = _Paths.ADD_PROPERTY;
  static const CLEANER_EDIT_PROFILE = _Paths.CLEANER_EDIT_PROFILE;
  static const TRAINING_AND_RESOURCES = _Paths.TRAINING_AND_RESOURCES;
  static const CLEANER_REFERENCES = _Paths.CLEANER_REFERENCES;
  static const ADD_REFERENCES = _Paths.ADD_REFERENCES;
  static const SUPPORT_DOCUMENT = _Paths.SUPPORT_DOCUMENT;
  static const ADD_DOCUMENT = _Paths.ADD_DOCUMENT;
  static const NOTIFICATION = _Paths.NOTIFICATION;
  static const CLEANER_PAYOUT_COMPUTATION = _Paths.CLEANER_PAYOUT_COMPUTATION;
  static const HELP_SUPPORT = _Paths.HELP_SUPPORT;
  static const CHANGE_PASSWORD = _Paths.CHANGE_PASSWORD;
  static const CLEANER_REVIEW = _Paths.CLEANER_REVIEW;
  static const JOB_CHAT = _Paths.JOB_CHAT;
  static const SUPPORT_CHAT = _Paths.SUPPORT_CHAT;
  static const CONTACT_US = _Paths.CONTACT_US;
}

abstract class _Paths {
  _Paths._();

  static const SPLASH = '/splash';

  static const AUTH = '/auth';
  static const LOGIN = '/auth/login';
  static const ROLE_SELECTION = '/auth/role';
  static const SIGN_UP = '/auth/signup';
  static const FORGOT_PASSWORD = '/auth/forgot-password';
  static const RESET_PASSWORD = '/auth/reset-password';
  static const AGREEMENT = '/auth/agreement';

  // Client module
  static const CLIENT_DASHBOARD = '/client';
  static const CLIENT_JOB_DETAIL = '/client/job/';
  static const CLIENT_SCHEDULE_JOB = '/client/job/schedule';
  static const CLIENT_CREATE_JOB = '/client/job/create';
  static const CLIENT_EDIT_PROFILE = '/client/edit-profile';
  static const PROPERTY = '/property';
  static const ADD_PROPERTY = '/add-property';
  static const ADD_REVIEW = '/add-review';

  // Cleaner module
  static const CLEANER_DASHBOARD = '/cleaner';
  static const CLEANER_JOB_DETAIL = '/cleaner/job/';
  static const CLEANER_EDIT_PROFILE = '/cleaner-edit-profile';
  static const TRAINING_AND_RESOURCES = '/training-and-resources';
  static const CLEANER_REFERENCES = '/cleaner/cleaner-references';
  static const ADD_REFERENCES = '/cleaner/add-references';
  static const SUPPORT_DOCUMENT = '/cleaner/support-document';
  static const ADD_DOCUMENT = '/cleaner/add-document';
  static const NOTIFICATION = '/cleaner/notification';
  static const CLEANER_PAYOUT_COMPUTATION = '/cleaner/cleaner-payout-computation';
  static const HELP_SUPPORT = '/common/help-support';
  static const CHANGE_PASSWORD = '/common/change-password';
  static const CLEANER_REVIEW = '/cleaner/cleaner-review';
  static const JOB_CHAT = '/chat/job';
  static const SUPPORT_CHAT = '/chat/support';
  static const CONTACT_US = '/common/contact-us';
}
