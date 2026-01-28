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

  // Client module
  static const CLIENT_DASHBOARD = _Paths.CLIENT_DASHBOARD;
  static const CLIENT_JOB_DETAIL = _Paths.CLIENT_JOB_DETAIL;
  static const CLIENT_CREATE_JOB = _Paths.CLIENT_CREATE_JOB;
  static const CLIENT_EDIT_PROFILE = _Paths.CLIENT_EDIT_PROFILE;

  // Cleaner module
  static const CLEANER_DASHBOARD = _Paths.CLEANER_DASHBOARD;
  static const CLEANER_JOB_DETAIL = _Paths.CLEANER_JOB_DETAIL;
  static const PROPERTY = _Paths.PROPERTY;
  static const ADD_PROPERTY = _Paths.ADD_PROPERTY;
  static const DETAIL_PROPERTY = _Paths.DETAIL_PROPERTY;
  static const CLEANER_EDIT_PROFILE = _Paths.CLEANER_EDIT_PROFILE;
  static const TRAINING_AND_RESOURCES = _Paths.TRAINING_AND_RESOURCES;
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

  // Client module
  static const CLIENT_DASHBOARD = '/client';
  static const CLIENT_JOB_DETAIL = '/client/job/';
  static const CLIENT_CREATE_JOB = '/client/job/create';
  static const CLIENT_EDIT_PROFILE = '/client/edit-profile';
  static const PROPERTY = '/property';
  static const ADD_PROPERTY = '/add-property';
  static const DETAIL_PROPERTY = '/detail-property';

  // Cleaner module
  static const CLEANER_DASHBOARD = '/cleaner';
  static const CLEANER_JOB_DETAIL = '/cleaner/job/';
  static const CLEANER_EDIT_PROFILE = '/cleaner-edit-profile';
  static const TRAINING_AND_RESOURCES = '/training-and-resources';
}
