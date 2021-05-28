package com.example.daily_tracker

import android.app.Application
import android.app.PendingIntent
import android.app.Service
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.Bundle
import android.os.IBinder
import android.util.Log
import android.util.TypedValue
import android.widget.RemoteViews
import android.widget.Toast
import androidx.core.content.ContextCompat
import com.google.android.gms.tasks.Task
import com.google.firebase.Timestamp
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.tasks.await

class DailyTrackerAppWidgetProvider : AppWidgetProvider() {
    companion object Values {
        const val ACTION_CHECK_BOX_CLICK = "daily_tracker.action.CHECK_BOX_CLICK"
        const val ACTION_DELETE_MULTIPLE_WIDGETS = "daily_tracker.action.DELETE_MULTIPLE_WIDGETS"
        const val ACTION_UPDATE_MULTIPLE_WIDGETS = "daily_tracker.action.UPDATE_MULTIPLE_WIDGETS"
        const val EXTRA_CHECK_BOOLEAN = "daily_tracker.extra.CHECK_BOOLEAN"
        const val EXTRA_APPWIDGET_ID_ARRAY = "daily_tracker.extra.APPWIDGET_ID_ARRAY"
    }

    private val TAG = "DailyTrackerAppWidgetProvider"
    private val usersCollectionReference = FirebaseFirestore.getInstance().collection("users")
    private val firebaseAuth = FirebaseAuth.getInstance()
    private val viewModelScope = CoroutineScope(Dispatchers.IO)

    override fun onUpdate(
        context: Context?,
        appWidgetManager: AppWidgetManager?,
        appWidgetIds: IntArray?
    ) {
        context ?: return
        val loggedIn = firebaseAuth.currentUser != null
        appWidgetIds?.forEach { id ->
            if (!loggedIn) {
                appWidgetManager?.updateAppWidget(
                    id,
                    getErrorWidgetRemoteViews(context, "Click To Login"))
            } else {
                // update widget
                viewModelScope.launch {
                    val streakData = getData()
                    appWidgetManager?.updateAppWidget(
                        id,
                        getWidgetRemoteViews(context, id, getStreakID(context, id), streakData)
                    )
                }
            }
        }
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent != null) Log.d(TAG, "onReceive: Intent.Action= " + intent.action)
        super.onReceive(context, intent)
        val loggedIn = firebaseAuth.currentUser != null
        if (loggedIn && intent != null && intent.extras != null && intent.action != null && context != null) {
            val widgetManager = AppWidgetManager.getInstance(context)
            when (intent.action) {
                ACTION_CHECK_BOX_CLICK -> {
                    Log.d(TAG, "ACTION CHECK BOX REACHED")
                    viewModelScope.launch {
                        val streakData = getData()
                        val check = intent.extras!!.getBoolean(EXTRA_CHECK_BOOLEAN)
                        val appWidgetID =
                            intent.extras!!.getInt(AppWidgetManager.EXTRA_APPWIDGET_ID)
                        val streakID = getStreakID(context, appWidgetID)
                        Log.d(
                            TAG,
                            "Before markToday marked = ${streakData.getMarked(streakID)} | check = $check | widgetID = $appWidgetID"
                        )
                        val newData = markToday(!check, streakID, streakData)
                        if (newData != null) {
                            widgetManager.updateAppWidget(
                                appWidgetID,
                                getWidgetRemoteViews(
                                    context,
                                    appWidgetID,
                                    getStreakID(context, appWidgetID),
                                    newData
                                )
                            )
                            Log.d(
                                TAG,
                                "AppWidgetManager.updateAppWidget called: marked = ${
                                    newData.getMarked(streakID)
                                }"
                            )
                        }
                    }
                }
                ACTION_UPDATE_MULTIPLE_WIDGETS -> {
                    viewModelScope.launch {
                        val streakData = getData()
                        intent.getIntArrayExtra(EXTRA_APPWIDGET_ID_ARRAY)?.forEach { id ->
                            val streakID = getStreakID(context, id)
                            if(!widgetManager.getAppWidgetIds(ComponentName(context, DailyTrackerAppWidgetProvider::class.java)).contains(id)){
                                context.getSharedPreferences(context.getString(R.string.preference_file_key), Context.MODE_PRIVATE).edit().remove(id.toString()).apply()
                            }
                            else {
                                widgetManager.updateAppWidget(id, getWidgetRemoteViews(context, id, streakID, streakData))
                            }
                        }
                    }
                }
                ACTION_DELETE_MULTIPLE_WIDGETS -> {
                    intent.getIntArrayExtra(EXTRA_APPWIDGET_ID_ARRAY)?.forEach { id ->
                        Log.d(TAG, "DELETE WIDGET = $id")
                        if(!widgetManager.getAppWidgetIds(ComponentName(context, DailyTrackerAppWidgetProvider::class.java)).contains(id)){
                            context.getSharedPreferences(context.getString(R.string.preference_file_key), Context.MODE_PRIVATE).edit().remove(id.toString()).apply()
                        }
                        else {
                            widgetManager.updateAppWidget(id, getErrorWidgetRemoteViews(context, "Tracker has been deleted"))
                        }
                    }
                }
            }
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context?,
        appWidgetManager: AppWidgetManager?,
        appWidgetId: Int,
        newOptions: Bundle?
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        val maxWidth = newOptions?.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_WIDTH)
        val maxHeight = newOptions?.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT)
        viewModelScope.launch {
            appWidgetManager?.updateAppWidget(appWidgetId,
                context?.let {
                    getWidgetRemoteViews(
                        it,
                        appWidgetId,
                        getStreakID(context, appWidgetId),
                        getData()
                    ).apply {
                        if (maxWidth != null && maxHeight != null) {
                            val height = if (maxWidth > maxHeight) maxHeight else maxWidth
                            val textSize = (height / 6).toFloat()
                            setTextViewTextSize(
                                R.id.nameTextView, TypedValue.COMPLEX_UNIT_SP,
                                textSize
                            )
                            Log.d(
                                TAG,
                                "-------------------------\nmaxWidth = $maxWidth\nmaxHeight = $maxHeight\nTextSize = $textSize\n----------------------------------"
                            )
                        }
                    }
                })
        }
    }

    private fun getCheckBoxIntent(
        context: Context,
        appWidgetID: Int,
        check: Boolean
    ): PendingIntent {
        return Intent(context, DailyTrackerAppWidgetProvider::class.java).apply {
            action = ACTION_CHECK_BOX_CLICK
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetID)
            putExtra(EXTRA_CHECK_BOOLEAN, check)
        }.let {
            PendingIntent.getBroadcast(context, appWidgetID, it, PendingIntent.FLAG_CANCEL_CURRENT)
        }
    }

    private fun getWidgetRemoteViews(
        context: Context,
        appWidgetID: Int,
        streakIndex: Int,
        streakData: StreakData
    ): RemoteViews {
        return RemoteViews(context.packageName, R.layout.daily_tracker_appwidget).apply {
            setTextViewText(R.id.nameTextView, streakData.getStreakName(streakIndex))
            setImageViewResource(
                R.id.checkButton,
                if (streakData.getMarked(streakIndex)) R.drawable.ic_checked else R.drawable.ic_unchecked
            )
            setOnClickPendingIntent(
                R.id.checkButton,
                getCheckBoxIntent(context, appWidgetID, streakData.getMarked(streakIndex))
            )
        }
    }

    private fun getErrorWidgetRemoteViews(context: Context, errorMsg: String) : RemoteViews{
        return RemoteViews(context.packageName, R.layout.daily_tracker_appwidget_error).apply {
            setTextViewText(R.id.errMsgTextView, errorMsg)
            setOnClickPendingIntent(
                R.id.errMsgTextView,
                PendingIntent.getBroadcast(
                    context,
                    0,
                    Intent(context, MainActivity::class.java),
                    PendingIntent.FLAG_CANCEL_CURRENT
                )
            )
        }
    }

    private fun getStreakID(context: Context, appWidgetID: Int): Int {
        return context.getSharedPreferences(
            context.getString(R.string.preference_file_key),
            Context.MODE_PRIVATE
        ).getInt(appWidgetID.toString(), -1).also {
            Log.d(TAG, "getStreakID = $appWidgetID | selectedPos = $it")
            if (it == -1) {
                print("onUpdate error: streakIndex == -1")
            }
        }
    }

    suspend fun getData(): StreakData {
        return firebaseAuth.currentUser?.uid?.let { id ->
            usersCollectionReference.document(id).get().await().let {
                it.data?.get("streakData").let { data ->
                    StreakData((data as List<*>).map { streak ->
                        Streak.fromJson(streak as Map<String, *>)
                    }.toList())
                }
            }
        } ?: StreakData(emptyList())
    }

    suspend fun markToday(mark: Boolean, streakID: Int, streakData: StreakData): StreakData? {
        val streakList = streakData.streakList
        // Checks for completion
        if (streakID > streakList.size - 1) {
            Log.d(TAG, "markToday outOfBounds")
            return null
        }
        val marked = streakData.getMarked(streakID)
        if (marked == mark) {
            Log.d(TAG, "markToday marked==mark $mark")
            return null
        }
        // update local list
        if (mark) {
            streakList[streakID].streakDates.add(Timestamp.now())
        } else {
            streakList[streakID].streakDates.removeAt(streakList[streakID].streakDates.size - 1)
        }
        //update firestore
        firebaseAuth.currentUser?.uid?.let { id ->
            usersCollectionReference.document(id).update(
                mapOf(
                    "streakData" to streakList.map { streak ->
                        streak.toJson()
                    }.toList()
                )
            ).await()
        }
        return StreakData(streakList)
    }

    override fun onDeleted(context: Context?, appWidgetIds: IntArray?) {
        super.onDeleted(context, appWidgetIds)
        val pref = context?.getSharedPreferences(
            context.getString(R.string.preference_file_key),
            Context.MODE_PRIVATE
        )?.edit()
        appWidgetIds?.forEach {
            pref?.remove(it.toString())
        }
        pref?.apply()
    }


}