enum SignupResult {
  emailalreadyinuse,
  invalidemail,
  operationnotallowed,
  weakpassword, //less than 6 chars
  success,
}
enum LoginResult {
  invalidemail,
  userdisabled,
  usernotfound,
  wrongpassword,
  success,
}
