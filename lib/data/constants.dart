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
enum Department {
  cse,
  ece,
  eee,
  it,
  mech,
  mct,
  civil,
}
enum UserMode {
  student,
  staff,
}

List<String> departmentsList = [
  "CSE",
  "MCT",
  "ECE",
  "EEE",
  "MECH",
  "IT",
  "CIVIL"
];
