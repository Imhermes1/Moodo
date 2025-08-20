package com.moodo.android.ui.screens.home

import com.moodo.android.data.repository.MooDoRepository
import com.moodo.android.domain.recommendation.RecommendationEngine
import com.moodo.android.domain.scheduler.TaskScheduler
import io.mockk.coEvery
import io.mockk.mockk
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.Test

@ExperimentalCoroutinesApi
class HomeViewModelTest {

    private val testDispatcher = StandardTestDispatcher()

    private lateinit var viewModel: HomeViewModel
    private val repository: MooDoRepository = mockk()
    private val taskScheduler: TaskScheduler = mockk()
    private val recommendationEngine: RecommendationEngine = mockk()

    @Before
    fun setUp() {
        Dispatchers.setMain(testDispatcher)
        coEvery { repository.getAllTasks() } returns flowOf(emptyList())
        coEvery { repository.getAllMoodEntries() } returns flowOf(emptyList())
        coEvery { taskScheduler.optimizeTaskSchedule(any()) } returns emptyList()
        coEvery { recommendationEngine.generateRecommendations(any()) } returns emptyList()

        viewModel = HomeViewModel(repository, taskScheduler, recommendationEngine)
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun `initial state is correct`() = runTest {
        val initialState = HomeUiState()
        assertEquals(initialState, viewModel.uiState.value)
    }
}
