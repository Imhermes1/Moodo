package com.moodo.android.data.db.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import com.moodo.android.data.model.Thought
import kotlinx.coroutines.flow.Flow
import java.util.UUID

@Dao
interface ThoughtDao {
    @Query("SELECT * FROM thoughts")
    fun getAllThoughts(): Flow<List<Thought>>

    @Query("SELECT * FROM thoughts WHERE id = :thoughtId")
    suspend fun getThoughtById(thoughtId: UUID): Thought?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertThought(thought: Thought)

    @Update
    suspend fun updateThought(thought: Thought)

    @Delete
    suspend fun deleteThought(thought: Thought)
}
