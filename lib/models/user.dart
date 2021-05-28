import 'streak.dart';

class User {
  final String id;
  final String fullName;
  final String email;
  final String userRole;
  List<Streak> streakList;

  User({this.id, this.fullName, this.email, this.userRole, this.streakList});

  User.fromData(Map<String, dynamic> data)
      : id = data['id'],
        fullName = data['fullName'],
        email = data['data'],
        userRole = data['userRole'],
        streakList = data['streakData'] is List<dynamic> ? data['streakData'].map<Streak>((e) => Streak.fromStreakJson(e)).toList() : Map<String, dynamic>.from(data['streakData']).entries.map<Streak>((e) => Streak.fromStreakJson(e.value)).toList();

  Map<String, dynamic> toJson(){
    return {
      'id' : id,
      'fullName' : fullName,
      'email' : email,
      'userRole' : userRole,
      'streakData' : streakList.map((streak) => streak.toJson()).toList(),
    };
  }
}
