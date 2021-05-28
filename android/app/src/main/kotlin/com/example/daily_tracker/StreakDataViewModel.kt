package com.example.daily_tracker

import androidx.lifecycle.ViewModel
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.coroutines.*


class StreakDataViewModel : ViewModel() {

    private val viewModelScope = CoroutineScope(Dispatchers.IO)
    private val usersCollectionReference = FirebaseFirestore.getInstance().collection("users")
    private val firebaseAuth = FirebaseAuth.getInstance()

    fun getData() : StreakData {
        var streakList: List<Streak> = emptyList()
        firebaseAuth.currentUser?.uid?.let { id ->
            usersCollectionReference.document(id).get().result?.data?.get("streakData").let { data ->
                streakList = (data as List<*>).map { streak ->
                    Streak.fromJson(streak as Map<String, *>)
                }.toList()
            }
        }

        return StreakData(streakList)
    }
}