#SingleInstance Force
SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory.

SleepRand(max := 300)
{
    Random(0, max, &rand)
    sleepDuration := 500 + rand
    Sleep sleepDuration
}
SleepRandAtLeast(min)
{
    Random(0, 300, &rand)
    sleepDuration := min + rand
    Sleep sleepDuration
}