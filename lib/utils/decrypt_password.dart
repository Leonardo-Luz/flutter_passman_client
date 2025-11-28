Future<String> decryptPassword({
  required String encrypted,
  required String masterPassword,
}) async {
  // Simulate work
  await Future.delayed(const Duration(milliseconds: 300));

  // TODO: real decryption
  if (masterPassword != "123") {
    throw Exception("Invalid master password");
  }

  return "decrypted:$encrypted";
}
