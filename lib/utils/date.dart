String getDate(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

String formatTime(DateTime date) {
  return '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}

String castTimeZoneToLocal(String date, String timestampWithTimezone) {
  final dateTime = DateTime.parse('$date $timestampWithTimezone');
  final localTzOffset = DateTime.now().timeZoneOffset;
  final dataTzOffset = dateTime.timeZoneOffset;
  final difference = localTzOffset - dataTzOffset;
  final adjustedTime = dateTime.add(difference);
  return formatTime(adjustedTime);
}
