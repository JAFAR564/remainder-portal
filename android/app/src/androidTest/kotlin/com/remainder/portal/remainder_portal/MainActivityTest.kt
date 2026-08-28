package com.remainder.portal.remainder_portal

import org.junit.Rule
import org.junit.runner.RunWith
import pl.leancode.patrol.PatrolTestRule
import pl.leancode.patrol.PatrolTestRunner

@RunWith(PatrolTestRunner::class)
class MainActivityTest {
    @get:Rule
    val rule: PatrolTestRule<MainActivity> = PatrolTestRule(MainActivity::class.java)
}
