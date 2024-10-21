package com.pratik.alarmapp

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.*
import android.util.Log
import android.widget.Toast

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.alarm/setAlarm"

    override fun configureFlutterEngine(@NonNull flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setAlarm") {
                val time = call.argument<String>("time")
                if (time != null) {
                    setAlarm(time)
                    result.success("Alarm is set for $time")
                } else {
                    result.error("UNAVAILABLE", "Time is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun setAlarm(time: String) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, AlarmReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(this, 0, intent, PendingIntent.FLAG_IMMUTABLE)
    
        val sdf = SimpleDateFormat("HH:mm", Locale.getDefault())
        val now = Calendar.getInstance()
        val alarmTimeCalendar = Calendar.getInstance()
    
        // Parse the input time and set it to the alarm time calendar
        try {
            val parsedTime = sdf.parse(time)
            if (parsedTime != null) {
                alarmTimeCalendar.time = parsedTime
                alarmTimeCalendar.set(Calendar.YEAR, now.get(Calendar.YEAR))
                alarmTimeCalendar.set(Calendar.MONTH, now.get(Calendar.MONTH))
                alarmTimeCalendar.set(Calendar.DAY_OF_MONTH, now.get(Calendar.DAY_OF_MONTH))
    
                // If the alarm time is before the current time, set it for tomorrow
                if (alarmTimeCalendar.before(now)) {
                    alarmTimeCalendar.add(Calendar.DAY_OF_MONTH, 1)
                }
    
                val triggerAtMillis = alarmTimeCalendar.timeInMillis
                Log.d("AlarmApp", "Alarm set for: ${alarmTimeCalendar.time}")
    
                alarmManager.setExact(AlarmManager.RTC_WAKEUP, triggerAtMillis, pendingIntent)
                Toast.makeText(this, "Alarm set for: ${sdf.format(alarmTimeCalendar.time)}", Toast.LENGTH_SHORT).show()
            } else {
                Log.d("AlarmApp", "Failed to parse time")
            }
        } catch (e: Exception) {
            e.printStackTrace()
            Log.d("AlarmApp", "Error setting alarm: ${e.message}")
        }
    }    
}
