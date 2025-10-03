import 'package:hive/hive.dart';

part 'tab_model.g.dart';

@HiveType(typeId: 2)
class TabModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool enabled;

  TabModel({required this.title, this.enabled = true});
}
