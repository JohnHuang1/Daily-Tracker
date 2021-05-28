package com.example.daily_tracker

import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.IBinder
import com.google.firebase.Timestamp
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore

class FirestoreService : Service() {
    private val usersCollectionReference = FirebaseFirestore.getInstance().collection("users")
    private val firebaseAuth = FirebaseAuth.getInstance()
    private var streakList: List<Streak> = emptyList()
    private val binder = LocalBinder()

    fun markToday(mark: Boolean, streakID: Int): Boolean {
        // Checks for completion
        if(streakList.isEmpty() || streakID > streakList.size - 1) return false
        val marked = getMarked(streakID)
        if(marked == mark) return true
        // update local list
        if(mark){
            streakList[streakID].streakDates.add(Timestamp.now())
        } else {
            streakList[streakID].streakDates.removeAt(streakList[streakID].streakDates.size - 1)
        }
        //update firestore
        var completed = false
        firebaseAuth.currentUser?.uid?.let{
            id -> usersCollectionReference.document(id).update(mapOf(
                "streakData" to streakList.map{
                    streak -> streak.toJson()
                }.toList()
            )).addOnSuccessListener { completed = true }.addOnFailureListener { completed = false }
        }
        return completed
    }

    fun getStreakName(streakID: Int): String{
        return streakList[streakID].name
    }

    fun getMarked(streakID: Int): Boolean{
        return Streak.containsTodayDate(streakList[streakID])
    }

    fun getStreakNameList(): List<String> {
        return streakList.map{ it.name }.toList()
    }

    override fun onBind(intent: Intent?): IBinder? {
        // load local streakList
        // Get data from firebase
        firebaseAuth.currentUser?.uid?.let { id ->
            usersCollectionReference.document(id).get().addOnCompleteListener { task ->
                task.result?.data?.get("streakData").let { data ->
                    streakList = (data as List<*>).map { streak ->
                        Streak.fromJson(streak as Map<String, *>)
                    }.toList()
                }
            }
        } ?: return null
        return binder
    }

    inner class LocalBinder : Binder() {
        fun getService(): FirestoreService = this@FirestoreService
    }
}