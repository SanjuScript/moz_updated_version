import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moz_updated_version/services/device_type_detector/device_type_detector.dart';

part 'device_type_state.dart';

class DeviceTypeCubit extends Cubit<DeviceTypeState> {
  DeviceTypeCubit() : super(DeviceTypeLoading());
  Future<void> detect(context) async {
    final device = await DeviceDetector.getDeviceType(context);
    log("====DEVICE TYPE=======\n${device.toString()}");
    emit(DeviceTypeReady(device));
  }
}
