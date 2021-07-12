// Contains functionality for load removal, autostart, and autosplitting.
// Thanks to LongerWarrior for new pointers that helped smooth out cutscene issues, as well as the solution for pausing the timer on crashes

state("Necromunda-Win64-Shipping")
{
    bool loading : 0x53481E0;
    bool cutsceneState : 0x0551B1B0, 0x118, 0x0, 0x148, 0x8, 0x2e0;
    string250 map : 0x0553B900, 0x58, 0x30, 0xf8, 0x0;
//  uint mapID : 0x0553B8E8, 0xDE8, 0x5E0;
//  int cutsceneState : 0x50BC078;
//  byte loading : 0x53481E0;
}

startup
  {
        if (timer.CurrentTimingMethod == TimingMethod.RealTime)
// Asks user to change to game time if LiveSplit is currently set to Real Time.
    {        
        var timingMessage = MessageBox.Show (
            "This game uses Time without Loads (Game Time) as the main timing method.\n"+
            "LiveSplit is currently set to show Real Time (RTA).\n"+
            "Would you like to set the timing method to Game Time?",
            "LiveSplit | Necromunda: Hired Gun",
            MessageBoxButtons.YesNo,MessageBoxIcon.Question
        );
        
        if (timingMessage == DialogResult.Yes)
        {
            timer.CurrentTimingMethod = TimingMethod.GameTime;
        }
    }
}

start
{
    return (current.map == "/Game/Maps/Solo/M01_Kaerus/LVL_Kaerus" && old.cutsceneState && !current.cutsceneState);
} 

update
{ //  print(current.map);
  //  print(current.cutsceneState.ToString());  
}        

split
{
    return current.map != old.map && current.map != "/Game/Maps/Solo/M00_MartyrsEnd/LVL_MartyrsEnd";
}

isLoading
{
    return current.loading || current.cutsceneState || current.map.Contains("Specials") || String.IsNullOrEmpty(current.map);
}

exit
{
    timer.IsGameTimePaused = true;
}
