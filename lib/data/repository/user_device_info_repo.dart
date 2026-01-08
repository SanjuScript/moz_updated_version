import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moz_updated_version/services/get_user_device_details.dart';

class UserDeviceRepository {
  static Future<void> saveDeviceInfo(userId) async {
    final data = await DeviceInfoService.getDeviceData();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('device_info')
        .doc('main')
        .set(data, SetOptions(merge: true));
  }
}
