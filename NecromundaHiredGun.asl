// Contains functionality for load removal, autostart, and autosplitting.
// Thanks to LongerWarrior for instance with mapID, i never knew wtf a uint was lmao

state("Necromunda-Win64-Shipping")
{
    byte loading : 0x53481E0;
    int cutsceneState : 0x50BC078;
    uint mapID : 0x0553B8E8, 0xDE8, 0x5E0;
}

init
{
	vars.loading = false;
    vars.cutsceneState = false;
    vars.mapID = false;
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
// Creates a text component at the bottom of the users LiveSplit layout displaying the current objective/quest state
		vars.SetTextComponent = (Action<string, string>)((id, text) =>
    {
        var textSettings = timer.Layout.Components.Where(x => x.GetType().Name == "TextComponent").Select(x => x.GetType().GetProperty("Settings").GetValue(x, null));
        var textSetting = textSettings.FirstOrDefault(x => (x.GetType().GetProperty("Text1").GetValue(x, null) as string) == id);
        if (textSetting == null)
        {
        var textComponentAssembly = Assembly.LoadFrom("Components\\LiveSplit.Text.dll");
        var textComponent = Activator.CreateInstance(textComponentAssembly.GetType("LiveSplit.UI.Components.TextComponent"), timer);
        timer.Layout.LayoutComponents.Add(new LiveSplit.UI.Components.LayoutComponent("LiveSplit.Text.dll", textComponent as LiveSplit.UI.Components.IComponent));

        textSetting = textComponent.GetType().GetProperty("Settings", BindingFlags.Instance | BindingFlags.Public).GetValue(textComponent, null);
        textSetting.GetType().GetProperty("Text1").SetValue(textSetting, id);
        }

        if (textSetting != null)
        textSetting.GetType().GetProperty("Text2").SetValue(textSetting, text);
    });
}

start
{
    return (current.mapID == 1 && current.cutsceneState == 65793);
}

update
{
    //tells isLoading to look for the value of 1 or if the game is currently in a cutscene (while also not being in the hub)
    vars.loading = 
    (
        (current.loading == 1)
    || 
        (
            (current.cutsceneState == 65793) && (current.mapID != 4294967295)
        )
         
    );     
 //   print(current.cutsceneState.ToString());        
}  

split
{
    return current.mapID != old.mapID && current.loading == 1;
}

isLoading
{
    return vars.loading;
}
