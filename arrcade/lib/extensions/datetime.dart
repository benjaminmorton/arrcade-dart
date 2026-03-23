import 'package:arrcade/database/tables/arrcade.dart';
import 'package:arrcade/extensions/string/string.dart';
import 'package:arrcade/vendor.dart';
import 'package:arrcade/widgets/ui.dart';

extension DateTimeExtension on DateTime {
  String _formatted(String format) {
    return DateFormat(format, 'en').format(this.toLocal());
  }

  DateTime floor() {
    return DateTime(this.year, this.month, this.day);
  }

  String asTimeOnly() {
    if (ArrcadeDatabase.USE_24_HOUR_TIME.read()) return _formatted('Hm');
    return _formatted('jm');
  }

  String asDateOnly({
    shortenMonth = false,
  }) {
    final format = shortenMonth ? 'MMM dd, y' : 'MMMM dd, y';
    return _formatted(format);
  }

  String asDateTime({
    bool showSeconds = true,
    bool shortenMonth = false,
    String? delimiter,
  }) {
    final format = StringBuffer(shortenMonth ? 'MMM dd, y' : 'MMMM dd, y');
    format.write(delimiter ?? LunaUI.TEXT_BULLET.pad());
    format.write(ArrcadeDatabase.USE_24_HOUR_TIME.read() ? 'HH:mm' : 'hh:mm');
    if (showSeconds) format.write(':ss');
    if (!ArrcadeDatabase.USE_24_HOUR_TIME.read()) format.write(' a');

    return _formatted(format.toString());
  }

  String asPoleDate() {
    final year = this.year.toString().padLeft(4, '0');
    final month = this.month.toString().padLeft(2, '0');
    final day = this.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String asAge() {
    final diff = DateTime.now().difference(this);
    if (diff.inSeconds < 15) return 'arrcade.JustNow'.tr();

    final days = diff.inDays.abs();
    if (days >= 1) {
      final years = (days / 365).floor();
      if (years == 1) return 'arrcade.OneYearAgo'.tr();
      if (years > 1) return 'arrcade.YearsAgo'.tr(args: [years.toString()]);

      final months = (days / 30).floor();
      if (months == 1) return 'arrcade.OneMonthAgo'.tr();
      if (months > 1) return 'arrcade.MonthsAgo'.tr(args: [months.toString()]);

      if (days == 1) return 'arrcade.OneDayAgo'.tr();
      if (days > 1) return 'arrcade.DaysAgo'.tr(args: [days.toString()]);
    }

    final hours = diff.inHours.abs();
    if (hours == 1) return 'arrcade.OneHourAgo'.tr();
    if (hours > 1) return 'arrcade.HoursAgo'.tr(args: [hours.toString()]);

    final mins = diff.inMinutes.abs();
    if (mins == 1) return 'arrcade.OneMinuteAgo'.tr();
    if (mins > 1) return 'arrcade.MinutesAgo'.tr(args: [mins.toString()]);

    final secs = diff.inSeconds.abs();
    if (secs == 1) return 'arrcade.OneSecondAgo'.tr();
    return 'arrcade.SecondsAgo'.tr(args: [secs.toString()]);
  }

  String asDaysDifference() {
    final diff = DateTime.now().difference(this);
    final days = diff.inDays.abs();
    if (days == 0) return 'arrcade.Today'.tr();

    final years = (days / 365).floor();
    if (years == 1) return 'arrcade.OneYear'.tr();
    if (years > 1) return 'arrcade.Years'.tr(args: [years.toString()]);

    final months = (days / 30).floor();
    if (months == 1) return 'arrcade.OneMonth'.tr();
    if (months > 1) return 'arrcade.Months'.tr(args: [months.toString()]);

    if (days == 1) return 'arrcade.OneDay'.tr();
    return 'arrcade.Days'.tr(args: [days.toString()]);
  }
}
