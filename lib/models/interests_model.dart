import 'package:hive/hive.dart';

part 'interests_model.g.dart';

@HiveType(typeId: 2)
class InterestsModel extends HiveObject {

@HiveField(0)
List interests = [];

}