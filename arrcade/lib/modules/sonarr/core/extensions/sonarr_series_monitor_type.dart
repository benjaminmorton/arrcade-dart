import 'package:arrcade/core.dart';
import 'package:arrcade/modules/sonarr.dart';

extension LunaSonarrSeriesMonitorTypeExtension on SonarrSeriesMonitorType {
  String get lunaName {
    switch (this) {
      case SonarrSeriesMonitorType.ALL:
        return 'All Episodes';
      case SonarrSeriesMonitorType.FUTURE:
        return 'Future Episodes';
      case SonarrSeriesMonitorType.MISSING:
        return 'Missing Episodes';
      case SonarrSeriesMonitorType.EXISTING:
        return 'Existing Episodes';
      case SonarrSeriesMonitorType.PILOT:
        return 'Pilot Episode';
      case SonarrSeriesMonitorType.FIRST_SEASON:
        return 'Only First Season';
      case SonarrSeriesMonitorType.LATEST_SEASON:
        return 'Only Latest Season';
      case SonarrSeriesMonitorType.NONE:
        return 'None';
      default:
        return 'arrcade.Unknown'.tr();
    }
  }
}
