package com.moodo.android.data.db

import androidx.room.TypeConverter
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.moodo.android.data.model.TaskNote
import java.util.Date
import java.util.UUID

class TypeConverters {
    private val gson = Gson()

    @TypeConverter
    fun fromTimestamp(value: Long?): Date? {
        return value?.let { Date(it) }
    }

    @TypeConverter
    fun dateToTimestamp(date: Date?): Long? {
        return date?.time
    }

    @TypeConverter
    fun fromUUID(uuid: UUID?): String? {
        return uuid?.toString()
    }

    @TypeConverter
    fun toUUID(uuid: String?): UUID? {
        return uuid?.let { UUID.fromString(it) }
    }

    @TypeConverter
    fun fromStringList(value: String?): List<String> {
        if (value == null) {
            return emptyList()
        }
        val listType = object : TypeToken<List<String>>() {}.type
        return gson.fromJson(value, listType)
    }

    @TypeConverter
    fun toStringList(list: List<String>): String {
        return gson.toJson(list)
    }

    @TypeConverter
    fun fromTaskNoteList(value: String?): List<TaskNote> {
        if (value == null) {
            return emptyList()
        }
        val listType = object : TypeToken<List<TaskNote>>() {}.type
        return gson.fromJson(value, listType)
    }

    @TypeConverter
    fun toTaskNoteList(list: List<TaskNote>): String {
        return gson.toJson(list)
    }
}
