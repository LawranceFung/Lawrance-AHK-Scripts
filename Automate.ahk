#SingleInstance Force
SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory.

SleepRand(max := 300)
{
    rand := Random(0, max)
    sleepDuration := 500 + rand
    Sleep sleepDuration
}
SleepRandAtLeast(min)
{
    rand := Random(0, 300)
    sleepDuration := min + rand
    Sleep sleepDuration
}
SleepRandAtMost(max)
{
    sleepDuration := Random(0, max)
    Sleep sleepDuration
}
SleepRandBetween(min, max)
{
    sleepDuration := Random(min, max)
    Sleep sleepDuration
}