import 'package:arrcade/core.dart';
import 'package:arrcade/modules/sonarr.dart';

extension SonarrHistoryRecordLunaExtension on SonarrHistoryRecord {
  String lunaSeriesTitle() {
    return this.series?.title ?? LunaUI.TEXT_EMDASH;
  }

  String? lunaSeasonEpisode() {
    if (this.episode == null) return null;
    String season = this.episode?.seasonNumber != null
        ? 'sonarr.SeasonNumber'.tr(
            args: [this.episode!.seasonNumber.toString()],
          )
        : 'arrcade.Unknown'.tr();
    String episode = this.episode?.episodeNumber != null
        ? 'sonarr.EpisodeNumber'.tr(
            args: [this.episode!.episodeNumber.toString()],
          )
        : 'arrcade.Unknown'.tr();
    return '$season ${LunaUI.TEXT_BULLET} $episode';
  }

  bool lunaHasPreferredWordScore() {
    return (this.data!['preferredWordScore'] ?? '0') != '0';
  }

  String lunaPreferredWordScore() {
    if (lunaHasPreferredWordScore()) {
      int? _preferredScore = int.tryParse(this.data!['preferredWordScore']);
      if (_preferredScore != null) {
        String _prefix = _preferredScore > 0 ? '+' : '';
        return '$_prefix${this.data!['preferredWordScore']}';
      }
    }
    return LunaUI.TEXT_EMDASH;
  }
}
