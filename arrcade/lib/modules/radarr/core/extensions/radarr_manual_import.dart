import 'package:arrcade/core.dart';
import 'package:arrcade/extensions/int/bytes.dart';
import 'package:arrcade/modules/radarr.dart';

extension LunaRadarrManualImportExtension on RadarrManualImport {
  String? get lunaLanguage {
    if ((this.languages?.length ?? 0) > 1) return 'Multi-Language';
    if ((this.languages?.length ?? 0) == 1) return this.languages![0].name;
    return LunaUI.TEXT_EMDASH;
  }

  String get lunaQualityProfile {
    return this.quality?.quality?.name ?? LunaUI.TEXT_EMDASH;
  }

  String get lunaSize {
    return this.size.asBytes();
  }

  String get lunaMovie {
    if (this.movie == null) return LunaUI.TEXT_EMDASH;
    String title = this.movie!.title ?? LunaUI.TEXT_EMDASH;
    int? year = (this.movie!.year ?? 0) == 0 ? null : this.movie!.year;
    return [
      title,
      if (year != null) '($year)',
    ].join(' ');
  }
}
