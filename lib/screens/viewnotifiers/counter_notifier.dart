import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_tracker/const/routes.dart';
import 'package:daily_tracker/models/IOSWidgetData.dart';
import 'package:daily_tracker/models/streak.dart';
import 'package:daily_tracker/screens/viewnotifiers/base_notifier.dart';
import 'package:daily_tracker/services/authentication_service.dart';
import 'package:daily_tracker/services/dialog_service.dart';
import 'package:daily_tracker/services/firestore_service.dart';
import 'package:daily_tracker/services/navigation_service.dart';
import 'package:daily_tracker/models/dialog_models.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widgetkit/flutter_widgetkit.dart';
import 'dart:io' show Platform;

import '../../locator.dart';

class CounterNotifier extends BaseNotifier {
  static const platform = const MethodChannel('com.example.daily_tracker.channel.ghcl3md1bf');
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final DialogService _dialogService = locator<DialogService>();
  final FirestoreService _firestoreService = locator<FirestoreService>();

  List<Streak> _streakList;

  List<Streak> get streakList => _streakList;
  Streak selectedStreak;
  int _selectedIndex;

  set startIndex(int index) => _selectedIndex = index;

  int get selectedIndex => _selectedIndex;
  bool checked = false;
  bool _disposed = false;

  void createCounter() async {
    setBusy(true);
    DialogResponse response = await _dialogService.requestTextInputDialog(
      title: 'Create Counter',
      description: 'Name',
      confirmationTitle: 'Create',
      cancelTitle: 'Cancel',
    );
    if (response.confirmed)
      await _authenticationService.addStreakToUser(response.fieldOne);
    _selectedIndex = streakList.length - 1;
    selectedStreak = _streakList[_selectedIndex];
    checked = false;
    notifyListeners();
    setBusy(false);
  }

  void deleteCounter() async {
    setBusy(true);
    DialogResponse response = await _dialogService.showConfirmationDialog(
      title: 'Delete Counter',
      description: 'Are you sure you want to permanently delete this counter?',
      confirmationTitle: 'Yes',
      cancelTitle: 'No',
    );
    if (response.confirmed) {
      await _authenticationService.deleteStreakFromUser(_selectedIndex--);
      await platform.invokeMethod("deleteWidgets", _selectedIndex + 1);
    }
    setBusy(false);
  }

  void listenToStreaks() {
    setBusy(true);
    _firestoreService
        .listenToStreaksRealTime(_authenticationService.currentUser)
        .listen((streakListData) {
      List<Streak> updatedStreaks = streakListData;
      if (updatedStreaks != null) {
        if (updatedStreaks.length > 0) {
          _streakList = updatedStreaks;
          try {
            selectedStreak = _streakList[_selectedIndex];
          } catch (e) {
            selectedStreak = _streakList[0];
            _selectedIndex = 0;
          }
          if(Platform.isIOS){
            String json = jsonEncode(IOSWidgetData(_streakList, DateTime.now()));
            print("----JSON DATA: " + json);
            WidgetKit.setItem('widgetData', json, 'group.com.dailytracker');
            WidgetKit.reloadAllTimelines();
          }
          updateCheckbox();
        } else {
          _streakList = null;
          _selectedIndex = -1;
          selectedStreak = null;
        }
        notifyListeners();
      }
      setBusy(false);
    });
  }

  void navigateToCalendar() {
    _navigationService.navigateReplaceTo(CalendarViewRoute,
        arguments: selectedIndex);
  }

  void markToday() async {
    setBusy(true);
    var result = false;
    try {
      result = checked
          ? await _authenticationService.removeDateFromUser(
              selectedIndex, selectedStreak.streakDates.last)
          : await _authenticationService.addDateToUser(
              selectedIndex, Timestamp.fromDate(DateTime.now()));
    } catch (ex) {
      await _dialogService.showDialog(
          title: "Check Failed",
          description:
              "Something went wrong. Try refreshing.");
    }
    if(Platform.isAndroid){
      print("android call: --- " + await platform.invokeMethod("updateWidgets", selectedIndex));
    }
    setBusy(false);

    if (!(result is bool)) {
      await _dialogService.showDialog(
          title: "Check Failed",
          description: "Something went wrong. Try restarting.");
    }
  }

  void updateToStreak(Streak streak) {
    selectedStreak = streak;
    _selectedIndex = _streakList.indexOf(selectedStreak);
    updateCheckbox();
    notifyListeners();
  }

  void updateCheckbox() {
    checked = Streak.containsTodaysDate(selectedStreak);
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

