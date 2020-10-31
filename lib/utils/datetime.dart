bool isLeapYear(int year) {
  if (year % 400 == 0) {
    return true;
  }
  if (year % 100 == 0) {
    return false;
  }
  if (year % 4 == 0) {
    return true;
  }
  return false;
}

int daysInCurrentMonth(DateTime dt) {
  switch (dt.month) {
    case 2:
      return isLeapYear(dt.year) ? 29 : 28;
    case 4:
    case 6:
    case 9:
    case 11:
      return 30;
    default:
      return 31;
  }
}

DateTime updateYear(DateTime dt, int year) {
  if (dt == null) {
    return DateTime(year);
  }
  return DateTime(year, dt.month, dt.day, dt.hour, dt.minute);
}

DateTime updateMonth(DateTime dt, int month) {
  if (dt == null) {
    final now = DateTime.now();
    return DateTime(now.year, month);
  }
  return DateTime(dt.year, month, dt.day, dt.hour, dt.minute);
}

DateTime updateDay(DateTime dt, int day) {
  if (dt == null) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
  return DateTime(dt.year, dt.month, day, dt.hour, dt.minute);
}

DateTime updateHour(DateTime dt, int hour) {
  if (dt == null) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour);
  }
  return DateTime(dt.year, dt.month, dt.day, hour, dt.minute);
}

DateTime updateMinute(DateTime dt, int minute) {
  if (dt == null) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour, minute);
  }
  return DateTime(dt.year, dt.month, dt.day, dt.hour, minute);
}
