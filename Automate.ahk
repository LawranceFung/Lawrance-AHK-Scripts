#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance Force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

SleepRand(max=300)
{
    Random, rand, 0, %max%
    sleepDuration = 500 + rand
    sleep % sleepDuration
}
SleepRandAtLeast(min)
{
    Random, rand, 0, %300%
    sleepDuration = min + rand
    sleep % sleepDuration
}