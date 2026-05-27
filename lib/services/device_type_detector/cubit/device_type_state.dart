part of 'device_type_cubit.dart';

sealed class DeviceTypeState extends Equatable {
  const DeviceTypeState();

  @override
  List<Object> get props => [];
}

class DeviceTypeLoading extends DeviceTypeState {}

class DeviceTypeReady extends DeviceTypeState {
  final DeviceType device;
  const DeviceTypeReady(this.device);

  @override
  List<Object> get props => [device];
}
