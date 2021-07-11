// Contains functionality for load removal, autostart, and autosplitting.
// Thanks to LongerWarrior for instance with mapID, i never knew wtf a uint was lmao

state("Necromunda-Win64-Shipping")
{
    byte loading : 0x53481E0;
    int cutsceneState : 0x50BC078;
//    uint mapID : 0x0553B8E8, 0xDE8, 0x5E0;
    string250 objective : 0x055424C8, 0x1E8, 0xBD0
}

init
{
	vars.loading = false;
    vars.cutsceneState = false;
    vars.mapID = false;
}

startup
  {
	  	refreshRate=30;
		if (timer.CurrentTimingMethod == TimingMethod.RealTime)
// Asks user to change to game time if LiveSplit is currently set to Real Time.
    {        
        var timingMessage = MessageBox.Show (
            "This game uses Time without Loads (Game Time) as the main timing method.\n"+
            "LiveSplit is currently set to show Real Time (RTA).\n"+
            "Would you like to set the timing method to Game Time?",
            "LiveSplit | Cyberpunk 2077",
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
// Declares the name of the text component
    settings.Add("quest_state", true, "Current Objective");

// Dictionary containing all of the available objectives/quest states that can be split on	
	vars.objectivename = new Dictionary<string,string>
	{
		{"08_drive_downtown","Meet Padre // Entered Padre's Car"}, //moves from Meet Padre - Meet Jackie
		// Manual split for The Worst Ending
	};
	
// split on specified objectives
	settings.Add("Quest States", true);
// Add objectives to setting list
	foreach (var script in vars.objectivename) {
		settings.Add(script.Key, true, script.Value, "Quest States");
	}
}

start
{
    return (current.cutsceneState != old.cutsceneState);
}

update
{
	if (settings["quest_state"]) 
    {
      vars.SetTextComponent("Current Map", (current.objective)); 
    }

    //tells isLoading to look for the value of 1 or if the game is closed (crashed)
    vars.loading = 
    (
        (current.loading == 1) 
    || 
        (
                (current.cutsceneState == 65793) && (current.objective !="/Game/Maps/Solo/M00_MartyrsEnd/LVL_MartyrsEnd")
        ) 
    ||
        (String.IsNullOrEmpty(current.objective))
    );     
  //  print(current.objective);
  //  print(current.cutsceneState.ToString());  
}        

split
{
    return current.objective != old.objective && current.objective != "/Game/Maps/Solo/M00_MartyrsEnd/LVL_MartyrsEnd";
}

isLoading
{
    return vars.loading;
}

exit
{
    vars.loading = false;
}
