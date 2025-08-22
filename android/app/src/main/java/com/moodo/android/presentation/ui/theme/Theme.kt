package com.moodo.android.presentation.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

/**
 * MooDo Android theme with calming colors
 * Equivalent to iOS calming color palette
 */

// Primary color palette inspired by iOS version
private val md_theme_light_primary = Color(0xFF3498DB)
private val md_theme_light_onPrimary = Color(0xFFFFFFFF)
private val md_theme_light_primaryContainer = Color(0xFFEBF4FF)
private val md_theme_light_onPrimaryContainer = Color(0xFF1B262E)

private val md_theme_light_secondary = Color(0xFF9B59B6)
private val md_theme_light_onSecondary = Color(0xFFFFFFFF)
private val md_theme_light_secondaryContainer = Color(0xFFF3E8FF)
private val md_theme_light_onSecondaryContainer = Color(0xFF2A1A33)

private val md_theme_light_tertiary = Color(0xFF27AE60)
private val md_theme_light_onTertiary = Color(0xFFFFFFFF)
private val md_theme_light_tertiaryContainer = Color(0xFFE8F5E8)
private val md_theme_light_onTertiaryContainer = Color(0xFF0D2818)

private val md_theme_light_error = Color(0xFFE74C3C)
private val md_theme_light_errorContainer = Color(0xFFFFDAD6)
private val md_theme_light_onError = Color(0xFFFFFFFF)
private val md_theme_light_onErrorContainer = Color(0xFF410002)

private val md_theme_light_background = Color(0xFFFDFCFF)
private val md_theme_light_onBackground = Color(0xFF1A1C1E)
private val md_theme_light_surface = Color(0xFFFDFCFF)
private val md_theme_light_onSurface = Color(0xFF1A1C1E)

private val md_theme_light_surfaceVariant = Color(0xFFE2E3E8)
private val md_theme_light_onSurfaceVariant = Color(0xFF44474E)
private val md_theme_light_outline = Color(0xFF74777F)
private val md_theme_light_inverseOnSurface = Color(0xFFF1F0F4)
private val md_theme_light_inverseSurface = Color(0xFF2F3033)
private val md_theme_light_inversePrimary = Color(0xFF85C5FF)

// Dark theme colors
private val md_theme_dark_primary = Color(0xFF85C5FF)
private val md_theme_dark_onPrimary = Color(0xFF003258)
private val md_theme_dark_primaryContainer = Color(0xFF004A78)
private val md_theme_dark_onPrimaryContainer = Color(0xFFCCE5FF)

private val md_theme_dark_secondary = Color(0xFFD1BBFF)
private val md_theme_dark_onSecondary = Color(0xFF3F2844)
private val md_theme_dark_secondaryContainer = Color(0xFF583E5C)
private val md_theme_dark_onSecondaryContainer = Color(0xFFEFD7FF)

private val md_theme_dark_tertiary = Color(0xFF7DDCA0)
private val md_theme_dark_onTertiary = Color(0xFF003919)
private val md_theme_dark_tertiaryContainer = Color(0xFF005227)
private val md_theme_dark_onTertiaryContainer = Color(0xFF99F8BC)

private val md_theme_dark_error = Color(0xFFFFB4AB)
private val md_theme_dark_errorContainer = Color(0xFF93000A)
private val md_theme_dark_onError = Color(0xFF690005)
private val md_theme_dark_onErrorContainer = Color(0xFFFFDAD6)

private val md_theme_dark_background = Color(0xFF1A1C1E)
private val md_theme_dark_onBackground = Color(0xFFE2E2E6)
private val md_theme_dark_surface = Color(0xFF1A1C1E)
private val md_theme_dark_onSurface = Color(0xFFE2E2E6)

private val md_theme_dark_surfaceVariant = Color(0xFF44474E)
private val md_theme_dark_onSurfaceVariant = Color(0xFFC4C7CE)
private val md_theme_dark_outline = Color(0xFF8E9199)
private val md_theme_dark_inverseOnSurface = Color(0xFF1A1C1E)
private val md_theme_dark_inverseSurface = Color(0xFFE2E2E6)
private val md_theme_dark_inversePrimary = Color(0xFF3498DB)

private val LightColors = lightColorScheme(
    primary = md_theme_light_primary,
    onPrimary = md_theme_light_onPrimary,
    primaryContainer = md_theme_light_primaryContainer,
    onPrimaryContainer = md_theme_light_onPrimaryContainer,
    secondary = md_theme_light_secondary,
    onSecondary = md_theme_light_onSecondary,
    secondaryContainer = md_theme_light_secondaryContainer,
    onSecondaryContainer = md_theme_light_onSecondaryContainer,
    tertiary = md_theme_light_tertiary,
    onTertiary = md_theme_light_onTertiary,
    tertiaryContainer = md_theme_light_tertiaryContainer,
    onTertiaryContainer = md_theme_light_onTertiaryContainer,
    error = md_theme_light_error,
    errorContainer = md_theme_light_errorContainer,
    onError = md_theme_light_onError,
    onErrorContainer = md_theme_light_onErrorContainer,
    background = md_theme_light_background,
    onBackground = md_theme_light_onBackground,
    surface = md_theme_light_surface,
    onSurface = md_theme_light_onSurface,
    surfaceVariant = md_theme_light_surfaceVariant,
    onSurfaceVariant = md_theme_light_onSurfaceVariant,
    outline = md_theme_light_outline,
    inverseOnSurface = md_theme_light_inverseOnSurface,
    inverseSurface = md_theme_light_inverseSurface,
    inversePrimary = md_theme_light_inversePrimary,
)

private val DarkColors = darkColorScheme(
    primary = md_theme_dark_primary,
    onPrimary = md_theme_dark_onPrimary,
    primaryContainer = md_theme_dark_primaryContainer,
    onPrimaryContainer = md_theme_dark_onPrimaryContainer,
    secondary = md_theme_dark_secondary,
    onSecondary = md_theme_dark_onSecondary,
    secondaryContainer = md_theme_dark_secondaryContainer,
    onSecondaryContainer = md_theme_dark_onSecondaryContainer,
    tertiary = md_theme_dark_tertiary,
    onTertiary = md_theme_dark_onTertiary,
    tertiaryContainer = md_theme_dark_tertiaryContainer,
    onTertiaryContainer = md_theme_dark_onTertiaryContainer,
    error = md_theme_dark_error,
    errorContainer = md_theme_dark_errorContainer,
    onError = md_theme_dark_onError,
    onErrorContainer = md_theme_dark_onErrorContainer,
    background = md_theme_dark_background,
    onBackground = md_theme_dark_onBackground,
    surface = md_theme_dark_surface,
    onSurface = md_theme_dark_onSurface,
    surfaceVariant = md_theme_dark_surfaceVariant,
    onSurfaceVariant = md_theme_dark_onSurfaceVariant,
    outline = md_theme_dark_outline,
    inverseOnSurface = md_theme_dark_inverseOnSurface,
    inverseSurface = md_theme_dark_inverseSurface,
    inversePrimary = md_theme_dark_inversePrimary,
)

@Composable
fun MoodoTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colorScheme = when {
        darkTheme -> DarkColors
        else -> LightColors
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography,
        content = content
    )
}