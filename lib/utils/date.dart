String getDate(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

/*
  Returns time in HH:MM format
*/
String getFormattedTime(DateTime date) {
  return '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}

// // HACK really bad
// (String, String) convertToUTC(String date, String time){
//   final localTzOffset = DateTime.now().timeZoneOffset;
//   final localDateTime = buildDateTime(date, time);
//   final utcDateTime = localDateTime.subtract(localTzOffset);

//   return (
//     getDate(utcDateTime),
//     getFormattedTime(utcDateTime)
//   );
// }
// /*
//   Adjusts the given date and time strings to the local timezone.
//   Assumes the input date and time are in UTC.
// */
// String convertToLocal(String date, String time) {
//   final localTzOffset = DateTime.now().timeZoneOffset;
//   final utcDateTime = DateTime.parse('$date $time');
//   final localDateTime = utcDateTime.add(localTzOffset);
//   return getFormattedTime(localDateTime);
// }

DateTime buildDateTime(String date, String time) {
  return DateTime.parse('$date $time');
}
