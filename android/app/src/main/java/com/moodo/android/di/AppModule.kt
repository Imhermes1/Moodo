package com.moodo.android.di

import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import com.moodo.android.data.remote.firebase.FirebaseManager
import com.moodo.android.ml.AndroidMLTaskEngine
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

/**
 * Dagger Hilt dependency injection module
 * Provides Firebase and ML dependencies
 */
@Module
@InstallIn(SingletonComponent::class)
object AppModule {
    
    @Provides
    @Singleton
    fun provideFirebaseAuth(): FirebaseAuth = FirebaseAuth.getInstance()
    
    @Provides
    @Singleton
    fun provideFirebaseFirestore(): FirebaseFirestore = FirebaseFirestore.getInstance()
    
    @Provides
    @Singleton
    fun provideFirebaseManager(
        firestore: FirebaseFirestore,
        auth: FirebaseAuth
    ): FirebaseManager = FirebaseManager(firestore, auth)
    
    @Provides
    @Singleton
    fun provideAndroidMLTaskEngine(): AndroidMLTaskEngine = AndroidMLTaskEngine()
}