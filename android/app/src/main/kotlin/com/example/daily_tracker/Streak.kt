package com.example.daily_tracker

import com.google.firebase.Timestamp
import com.google.type.Date
import com.google.type.DateTime
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.ZoneOffset

class Streak(val name: String, val streakDates: MutableList<Timestamp>) {
    companion object Factory{
        fun fromJson(data : Map<String, *>) : Streak{
            return Streak(data["name"] as String, data["dates"] as MutableList<Timestamp>)
        }
        fun roundToDay(time: Timestamp): Timestamp{
            val now = LocalDateTime.ofEpochSecond(time.seconds, time.nanoseconds, ZoneOffset.UTC)
            return Timestamp(LocalDateTime.of(now.year, now.month, now.dayOfMonth,0,0).toEpochSecond(ZoneOffset.UTC), 0)
        }
        fun containsTodayDate(streak: Streak): Boolean{
            if(streak.streakDates.isNotEmpty()) return streak.streakDates.last().compareTo(roundToDay(Timestamp.now())) > -1
            return false
        }
    }
    fun toJson(): Map<String, *>{
        return mapOf("name" to name, "dates" to streakDates)
    }
}