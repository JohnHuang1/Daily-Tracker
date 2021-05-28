import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_tracker/const/routes.dart';
import 'package:daily_tracker/locator.dart';
import 'package:daily_tracker/models/streak.dart';
import 'package:daily_tracker/services/authentication_service.dart';
import 'package:daily_tracker/services/dialog_service.dart';
import 'package:daily_tracker/services/firestore_service.dart';
import 'package:daily_tracker/services/navigation_service.dart';
import 'package:flutter/material.dart';

import 'base_notifier.dart';

class CalendarNotifier extends BaseNotifier {
  final AuthenticationService _authenticationService = locator<AuthenticationService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final DialogService _dialogService = locator<DialogService>();
  final FirestoreService _firestoreService = locator<FirestoreService>();

  bool _disposed = false;
  List<bool> expandedList = List.generate(12, (_) => false);
  bool _allExpand = false;
  bool get allExpand => _allExpand;
  Streak _selectedStreak;
  Streak get selectedStreak => _selectedStreak;
  List<Streak> _streakList;
  int _selectedIndex;
  int currentYear = DateTime.now().year;
  List<List<Timestamp>> dates = List.generate(12, (_) => List.empty(growable: true));

  set setIndex(int index) => _selectedIndex = index;

  void listenToStreaks(){
    setBusy(true);
    _firestoreService.listenToStreaksRealTime(_authenticationService.currentUser).listen((streakListData) {
      List<Streak> updatedStreaks = streakListData;
      if(updatedStreaks != null){
        if(updatedStreaks.length > 0){
          _streakList = updatedStreaks;
          try{
            _selectedStreak = _streakList[_selectedIndex];
          } catch (e){
            _selectedStreak = _streakList[0];
            _selectedIndex = 0;
          }
        } else {
          _streakList = null;
          _selectedIndex = -1;
          _selectedStreak = null;
        }
        updateDates();
        notifyListeners();
      }
      setBusy(false);
    });
  }

  void updateDates(){
    dates = List.generate(12, (_) => List.empty(growable: true));
    for(Timestamp t in _selectedStreak.streakDates){
      DateTime dt = t.toDate();
      if(dt.year == currentYear){
        dates[dt.month - 1].add(t);
      }
    }
  }

  void updateYear(int increment){
    int newYear = currentYear + increment;
    if(newYear >= _selectedStreak.startYear && newYear <= DateTime.now().year) currentYear = newYear;
    updateDates();
    notifyListeners();
  }

  bool atEndYear(){
    return currentYear == DateTime.now().year;
  }

  bool atStartYear(){
    return currentYear == _selectedStreak.startYear;
  }

  void expand(int index){
    expandedList[index] = !expandedList[index];
    notifyListeners();
  }

  void expandAll(){
    expandedList = List.generate(12, (_) => !_allExpand);
    _allExpand = !_allExpand;
    notifyListeners();
  }

  void navigateToCounter(){
    _navigationService.navigateReplaceTo(CounterViewRoute, arguments: _selectedIndex);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }
}