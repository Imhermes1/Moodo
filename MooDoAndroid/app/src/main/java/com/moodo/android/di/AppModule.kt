package com.moodo.android.di

import android.content.Context
import androidx.room.Room
import com.moodo.android.data.db.AppDatabase
import com.moodo.android.data.db.dao.MoodDao
import com.moodo.android.data.db.dao.TaskDao
import com.moodo.android.data.db.dao.ThoughtDao
import com.moodo.android.data.repository.MooDoRepository
import com.moodo.android.data.repository.MooDoRepositoryImpl
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object AppModule {

    @Provides
    @Singleton
    fun provideAppDatabase(@ApplicationContext context: Context): AppDatabase {
        return Room.databaseBuilder(
            context,
            AppDatabase::class.java,
            "moodo_database"
        ).build()
    }

    @Provides
    @Singleton
    fun provideTaskDao(appDatabase: AppDatabase): TaskDao {
        return appDatabase.taskDao()
    }

    @Provides
    @Singleton
    fun provideThoughtDao(appDatabase: AppDatabase): ThoughtDao {
        return appDatabase.thoughtDao()
    }

    @Provides
    @Singleton
    fun provideMoodDao(appDatabase: AppDatabase): MoodDao {
        return appDatabase.moodDao()
    }

    @Provides
    @Singleton
    fun provideMooDoRepository(
        taskDao: TaskDao,
        thoughtDao: ThoughtDao,
        moodDao: MoodDao
    ): MooDoRepository {
        return MooDoRepositoryImpl(taskDao, thoughtDao, moodDao)
    }
}
