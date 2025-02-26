package com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.survey_wall_screen

import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

object Util {
    fun endsIn(dateString: String?): String {
        if (dateString == null) return ""
        try {
            val format = SimpleDateFormat(
                "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US,
            )
            val endDate = format.parse(dateString)
            val today = Date()

            return if (endDate != null && endDate.after(today)) {
                val diff = endDate.time - today.time
                val hour = 1000*60*60L
                val day = hour * 24L

                val days = diff / day
                val hours = (diff % day) / hour
                "Ends in $days days, $hours hours"
            } else {
                ""
            }
        }catch (exception: Exception) {
            return ""
        }
    }
}
