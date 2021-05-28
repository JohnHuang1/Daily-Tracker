import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_tracker/models/streak.dart';
import 'package:daily_tracker/models/user.dart';

class FirestoreService {
  final CollectionReference _usersCollectionReference =
      FirebaseFirestore.instance.collection('users');

  final StreamController<List<Streak>> _streakController =
      StreamController<List<Streak>>.broadcast();

  Future createUser(User user) async {
    try {
      await _usersCollectionReference
          .doc(user.id)
          .set(user.toJson())
          .then((value) => print("user added"))
          .catchError((error) => print("failed to add user: $error"));
    } catch (e) {
      return e.message;
    }
  }

  Future getUser(String uid) async {
    try {
      var userData = await _usersCollectionReference.doc(uid).get();
      return User.fromData(userData.data());
    } catch (e) {
      print("getUser error ---------- " + e.toString());
      print("getUser error ---------- ");
      return null;
    }
  }

  Future<bool> updateStreakData(User user) async {
    try {
      await _usersCollectionReference
          .doc(user.id)
          .update({
        'streakData': user.streakList
            .map((streak) => streak.toJson())
            .toList()
      });
      return true;
    } catch (e) {
      print("updateStreakData error " + e.message);
      return false;
    }
  }

  Stream listenToStreaksRealTime(User user){
    // register handler for when data changes
    print("listenToStreaksRealTime called");
    if(user != null){
      _usersCollectionReference.doc(user.id).snapshots().listen((snapshots) {
        var streaks = snapshots.data()['streakData'];
        if(streaks is List<dynamic>){
          streaks = snapshots.data()['streakData'].map<Streak>((e) => Streak.fromStreakJson(e)).toList();
        } else {
          streaks = Map<String, dynamic>.from(snapshots.data()['streakData']).entries.map<Streak>((e) => Streak.fromStreakJson(e.value)).toList();
        }

        // Add streaks to controller
        print("listenToStreaksRealTime streaks added");
        _streakController.add(streaks);
      });
    }
    return _streakController.stream;
  }
}
