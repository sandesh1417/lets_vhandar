splitName({required String fullName}) {
  List<String> parts = fullName.split(" ");
  String firstName = parts[0];
  String lastName = parts[1];
  return [firstName, lastName];
}
