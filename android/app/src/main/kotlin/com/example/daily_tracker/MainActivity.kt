package com.example.daily_tracker

import android.content.Context
import android.content.Intent
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.daily_tracker.channel.ghcl3md1bf"
    private val TAG = "MainActivity"
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler{
            call, result ->
            when(call.method){
                "updateWidgets" -> {
                    broadcastToWidget("update", call.arguments as Int)
                    result.success("broadcastSent: Update")
                }
                "deleteWidgets" -> {
                    broadcastToWidget("delete", call.arguments as Int)
                    result.success("broadcastSent: Delete")
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    private fun broadcastToWidget(todo: String, streakID : Int){
        val list = mutableListOf<Int>()
        getSharedPreferences(getString(R.string.preference_file_key), Context.MODE_PRIVATE).all.forEach {
            if(it.value == streakID) list.add(it.key.toInt())
        }
        Intent(this, DailyTrackerAppWidgetProvider::class.java).apply{
            action = when(todo){
                "update" -> DailyTrackerAppWidgetProvider.ACTION_UPDATE_MULTIPLE_WIDGETS
                "delete" -> DailyTrackerAppWidgetProvider.ACTION_DELETE_MULTIPLE_WIDGETS
                else -> ""
            }
            putExtra(DailyTrackerAppWidgetProvider.EXTRA_APPWIDGET_ID_ARRAY, list.toIntArray())
        }.let{
            sendBroadcast(it)
            Log.d(TAG, "sendBroadCast() called")
        }
    }
}
