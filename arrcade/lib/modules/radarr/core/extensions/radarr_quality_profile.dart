import 'package:arrcade/core.dart';
import 'package:arrcade/modules/radarr.dart';

extension RadarrQualityProfileExtension on RadarrQualityProfile {
  String? get lunaName {
    if (this.name != null && this.name!.isNotEmpty) return this.name;
    return LunaUI.TEXT_EMDASH;
  }
}
