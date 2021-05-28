package com.example.daily_tracker

class StreakData(var streakList: List<Streak>) {
    val namelist : List<String> get() = streakList.map{it.name}.toList()

    fun getMarked(streakID : Int) : Boolean{
        return try{
            Streak.containsTodayDate(streakList[streakID])
        } catch(ex: Exception){
            false
        }
    }

    fun getStreakName(streakID: Int): String{
        return try{
            streakList[streakID].name
        } catch (ex: Exception){
            "empty"
        }
    }
}