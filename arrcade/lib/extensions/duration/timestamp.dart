import 'package:arrcade/vendor.dart';
import 'package:arrcade/widgets/ui.dart';

extension DurationAsTimestampExtension on Duration? {
  String asNumberTimestamp() {
    if (this == null) return LunaUI.TEXT_EMDASH;

    final hours = this!.inHours.toString().padLeft(2, '0');
    final minutes = (this!.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (this!.inSeconds % 60).toString().padLeft(2, '0');

    if (hours == '00') return '$minutes:$seconds';
    return '$hours:$minutes:$seconds';
  }

  String asWordsTimestamp({
    int multiplier = 1,
    int divisor = 1,
  }) {
    if (this == null) return 'arrcade.Unknown'.tr();
    if (this!.inSeconds <= 5) return 'arrcade.Minutes'.tr(args: ['0']);

    final List<String> words = [];

    final days = this!.inDays;
    if (days > 0) {
      if (days == 1) {
        words.add('arrcade.OneDay'.tr());
      } else {
        words.add('arrcade.Days'.tr(args: [days.toString()]));
      }
    }

    final hours = this!.inHours % 24;
    if (hours > 0) {
      if (hours == 1) {
        words.add('arrcade.OneHour'.tr());
      } else {
        words.add('arrcade.Hours'.tr(args: [hours.toString()]));
      }
    }

    final minutes = this!.inMinutes % 60;
    if (minutes > 0) {
      if (minutes == 1) {
        words.add('arrcade.OneMinute'.tr());
      } else {
        words.add('arrcade.Minutes'.tr(args: [minutes.toString()]));
      }
    }

    return words.isEmpty ? 'arrcade.UnderAMinute'.tr() : words.join(' ');
  }
}
