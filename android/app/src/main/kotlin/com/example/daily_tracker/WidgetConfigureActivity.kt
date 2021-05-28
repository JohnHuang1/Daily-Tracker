package com.example.daily_tracker

import android.app.Activity
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.Bundle
import android.os.IBinder
import android.util.Log
import android.view.View
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import kotlinx.coroutines.*

class WidgetConfigureActivity : AppCompatActivity(), AdapterView.OnItemSelectedListener {
    private lateinit var service: FirestoreService
    private var bound: Boolean = false
    private var selectedPos = -1
    private val TAG = "WidgetConfigureActivity"

    private val connection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, ibinder: IBinder?) {
            if (ibinder == null) {
                //TODO: open main app to login
                startActivity(Intent(this@WidgetConfigureActivity, MainActivity::class.java))
                finish()
            }
            val binder = ibinder as FirestoreService.LocalBinder
            service = binder.getService()
            bound = true

            Log.d(TAG, "onServiceConnected() called")

            CoroutineScope(Dispatchers.Main).launch{
                withContext(Dispatchers.Default) {
                    delay(250L)
                }
                updateSpinner()
            }
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            bound = false
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_widget_configure)
        val appWidgetId = intent?.extras?.getInt(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID
        ) ?: AppWidgetManager.INVALID_APPWIDGET_ID

        Log.d(TAG, "onCreated() called")


        findViewById<Button>(R.id.confirmButton).setOnClickListener {
            if (bound) {
                if (selectedPos == -1) {
                    Toast.makeText(this, "Please select a tracker", Toast.LENGTH_SHORT).show()
                    updateSpinner()
                } else {
                    // update widget
                    RemoteViews(this.packageName, R.layout.daily_tracker_appwidget).also { views ->
                        val marked = service.getMarked(selectedPos)
                        views.setTextViewText(R.id.nameTextView, service.getStreakNameList()[selectedPos])
                        views.setImageViewResource(
                            R.id.checkButton,
                            if (marked) R.drawable.ic_checked else R.drawable.ic_unchecked
                        )
                        Log.d(TAG, "onClickListener: marked = $marked")
                        views.setOnClickPendingIntent(
                            R.id.checkButton,
                            PendingIntent.getBroadcast(
                                this,
                                appWidgetId,
                                Intent(this, DailyTrackerAppWidgetProvider::class.java).apply {
                                    action = DailyTrackerAppWidgetProvider.ACTION_CHECK_BOX_CLICK
                                    putExtra(
                                        DailyTrackerAppWidgetProvider.EXTRA_CHECK_BOOLEAN,
                                        marked
                                    )
                                    putExtra(
                                        AppWidgetManager.EXTRA_APPWIDGET_ID,
                                        appWidgetId
                                    )
                                },
                                PendingIntent.FLAG_CANCEL_CURRENT
                            )
                        )
                        AppWidgetManager.getInstance(this).updateAppWidget(appWidgetId, views)
                    }
                    // Pair appWidgetId to selectedPos in sharedPref
                    val sharedPref = this.getSharedPreferences(
                        getString(R.string.preference_file_key),
                        Context.MODE_PRIVATE
                    )
                    sharedPref.edit().putInt(appWidgetId.toString(), selectedPos).apply()
                    Log.d(TAG, "views updated/shared pref saved: appWidgetID = $appWidgetId | selectedPos = $selectedPos")

                    // Finish activity
                    val resultValue = Intent().apply {
                        putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                    }
                    setResult(Activity.RESULT_OK, resultValue)
                    finish()
                }
            }
        }
    }

    override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
        selectedPos = position
    }

    override fun onNothingSelected(parent: AdapterView<*>?) {
        selectedPos = -1
    }

    override fun onStart() {
        Log.d(TAG, "onStart() called")
        super.onStart()
        if (!bound) {
            bindToService()
        }
    }

    override fun onStop() {
        super.onStop()
        unbindService(connection)
        bound = false
    }

    fun bindToService() {
        Intent(this, FirestoreService::class.java).also {
            bindService(it, connection, Context.BIND_AUTO_CREATE)
        }
    }

    fun updateSpinner(){
        val list = service.getStreakNameList()

        ArrayAdapter(
            this@WidgetConfigureActivity,
            android.R.layout.simple_spinner_item,
            list
        ).let { arrayAdapter ->
            arrayAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
            findViewById<Spinner>(R.id.trackerSpinner).apply {
                adapter = arrayAdapter
                onItemSelectedListener = this@WidgetConfigureActivity
            }
            Log.d(TAG, "adapter set $list")
        }
    }
}