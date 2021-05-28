import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_tracker/models/streak.dart';
import 'package:daily_tracker/services/firestore_service.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user.dart' as u;

import '../locator.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = locator<FirestoreService>();

  u.User _currentUser;
  int _counter;
  u.User get currentUser => _currentUser;

  Future loginWithEmail(
      {@required String email, @required String password}) async {
    try {
      var authResult = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      await _populateCurrentUser(authResult.user);
      return authResult.user != null;
    } catch (e) {
      print(e.message);
      return e.message;
    }
  }

  Future signUpWithEmail(
      {@required String email,
      @required String password,
      @required String fullName,
      @required String userRole}) async {
    try {
      var authResult = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);

      // create a new user profile on firestore
      _currentUser = u.User(
        id: authResult.user.uid,
        email: email,
        fullName: fullName,
        userRole: userRole,
        streakList: [],
      );

      await _firestoreService.createUser(_currentUser);

      return authResult.user != null;
    } catch (e) {
      return e.message;
    }
  }

  Future<bool> isUserLoggedIn() async {
    var user = _firebaseAuth.currentUser;
    await _populateCurrentUser(user);
    return user != null;
  }

  Future _populateCurrentUser(User user) async {
    if(user != null) {
      _currentUser = await _firestoreService.getUser(user.uid);
    }
  }

  Future addDateToUser(int index, Timestamp timestamp) async {
    // if(_counter == null) {
    //   _counter = 0;
    //   print("_counter set to 0");
    // }
    // print("addDateToUser  -------- ");
    // print("index: $index | streakList.length: ${_currentUser.streakList.toString()} | timestamp: $timestamp");
    // print("-------------------counter: ${++_counter}");
    _currentUser.streakList[index].streakDates.add(timestamp);
    var result = await _firestoreService.updateStreakData(_currentUser);
    return result;
  }
  Future<bool> removeDateFromUser(int index, Timestamp timestamp) async {
    // if(_counter == null) {
    //   _counter = 0;
    //   print("_counter set to 0");
    // }
    // print("removeDateFromUser -------- ");
    // print("index: $index | streakList.length: ${_currentUser.streakList.toString()} | timestamp: $timestamp");
    // print("----------------counter: ${++_counter}");
    _currentUser.streakList[index].streakDates.remove(timestamp);
    bool result = await _firestoreService.updateStreakData(_currentUser);
    return result;
  }

  Future<bool> addStreakToUser(String name) async {
    _currentUser.streakList.add(Streak.empty(name: name));
    bool result = await _firestoreService.updateStreakData(_currentUser);
    return result;
  }

  Future<bool> deleteStreakFromUser(int index) async {
    _currentUser.streakList.removeAt(index);
    return await _firestoreService.updateStreakData(_currentUser);
  }

  void listenToStreaks(){
    _firestoreService.listenToStreaksRealTime(_currentUser).listen((streakListData) {
      print("authenticationService listenToStreaks()");
      List<Streak> updatedStreaks = streakListData;
      if(updatedStreaks != null){
        _currentUser.streakList = updatedStreaks;
    }});
  }

}
