abstract final class Validators {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? v) =>
      (v == null || !_email.hasMatch(v.trim())) ? 'Enter a valid email' : null;

  static String? password(String? v) =>
      (v == null || v.length < 6) ? 'At least 6 characters' : null;

  static String? required(String? v, [String field = 'This field']) =>
      (v == null || v.trim().isEmpty) ? '$field is required' : null;
}
