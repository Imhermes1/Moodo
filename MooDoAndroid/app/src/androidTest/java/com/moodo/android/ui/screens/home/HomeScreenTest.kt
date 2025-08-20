package com.moodo.android.ui.screens.home

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import com.moodo.android.ui.theme.MooDoTheme
import org.junit.Rule
import org.junit.Test

class HomeScreenTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun homeScreen_displaysCorrectInformation() {
        // This is a simplified test. In a real app, we would need to provide a fake ViewModel.
        composeTestRule.setContent {
            MooDoTheme {
                HomeScreen()
            }
        }

        composeTestRule.onNodeWithText("Hello, User!").assertIsDisplayed()
        composeTestRule.onNodeWithText("Today's Tasks").assertIsDisplayed()
    }
}
