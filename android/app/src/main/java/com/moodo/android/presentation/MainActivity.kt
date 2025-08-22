package com.moodo.android.presentation

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import com.moodo.android.presentation.ui.theme.MoodoTheme
import com.moodo.android.presentation.ui.main.MoodoApp
import dagger.hilt.android.AndroidEntryPoint

/**
 * Main Activity for MooDo Android
 * Equivalent to ContentView.swift in iOS version
 */
@AndroidEntryPoint
class MainActivity : FragmentActivity() {
    
    private lateinit var biometricPrompt: BiometricPrompt
    private lateinit var promptInfo: BiometricPrompt.PromptInfo
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        
        setupBiometricAuthentication()
        
        setContent {
            MoodoTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    var isAuthenticated by remember { mutableStateOf(false) }
                    
                    LaunchedEffect(Unit) {
                        checkBiometricAuthentication { authenticated ->
                            isAuthenticated = authenticated
                        }
                    }
                    
                    if (isAuthenticated) {
                        MoodoApp()
                    } else {
                        // Show loading or authentication screen
                        AuthenticationScreen(
                            onAuthenticationRequested = {
                                requestBiometricAuthentication { authenticated ->
                                    isAuthenticated = authenticated
                                }
                            }
                        )
                    }
                }
            }
        }
    }
    
    private fun setupBiometricAuthentication() {
        biometricPrompt = BiometricPrompt(this, ContextCompat.getMainExecutor(this),
            object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                    super.onAuthenticationSucceeded(result)
                    // Authentication successful
                }
                
                override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                    super.onAuthenticationError(errorCode, errString)
                    // Handle authentication error
                }
                
                override fun onAuthenticationFailed() {
                    super.onAuthenticationFailed()
                    // Handle authentication failure
                }
            })
        
        promptInfo = BiometricPrompt.PromptInfo.Builder()
            .setTitle("MooDo Authentication")
            .setSubtitle("Use your biometric credential to access your data")
            .setNegativeButtonText("Cancel")
            .build()
    }
    
    private fun checkBiometricAuthentication(callback: (Boolean) -> Unit) {
        val biometricManager = BiometricManager.from(this)
        when (biometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK)) {
            BiometricManager.BIOMETRIC_SUCCESS -> {
                // Biometric features available and enrolled
                callback(false) // Require authentication
            }
            BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE,
            BiometricManager.BIOMETRIC_ERROR_HW_UNAVAILABLE,
            BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED -> {
                // No biometric features available or enrolled
                callback(true) // Allow access without biometric
            }
        }
    }
    
    private fun requestBiometricAuthentication(callback: (Boolean) -> Unit) {
        val biometricManager = BiometricManager.from(this)
        when (biometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK)) {
            BiometricManager.BIOMETRIC_SUCCESS -> {
                biometricPrompt.authenticate(promptInfo)
                callback(true) // Simplified for demo
            }
            else -> {
                callback(true) // Allow access if biometric not available
            }
        }
    }
}

@Composable
private fun AuthenticationScreen(
    onAuthenticationRequested: () -> Unit
) {
    // Simple authentication screen
    // In production, this would be a proper authentication UI
    LaunchedEffect(Unit) {
        onAuthenticationRequested()
    }
}