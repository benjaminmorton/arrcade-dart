import 'package:arrcade/core.dart';

abstract class LunaWebhooks {
  Future<void> handle(Map<dynamic, dynamic> data);

  static String buildUserTokenURL(String token, LunaModule module) {
    return 'https://notify.arrcade.app/v1/${module.key}/user/$token';
  }

  static String buildDeviceTokenURL(String token, LunaModule module) {
    return 'https://notify.arrcade.app/v1/${module.key}/device/$token';
  }
}
