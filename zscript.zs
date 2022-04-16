version 4.7

class GGWPDeathMessageHandler : StaticEventHandler
{
	private Array<string> _DeathMessages;
	private Array<string> _DeathSubtitles;
	private bool _PlayingMusic;
	private string _Message;
	private string _Subtitle;
	private string _DMCache;
	private string _DSCache;
	private int _MsgIndex;
	private int _SubIndex;
	private int _MsgTimer;
	private int _SubTimer;

	private ui HUDFont _MainFont;
	private ui HUDFont _SubFont;

	override void OnRegister()
	{
		int lump = -1;
		while (-1 != (lump = Wads.FindLump("deathmessages", lump + 1)))
		{
			string s = Wads.ReadLump(lump);
			s.Replace("\r\n", "\n");
			s.Split(_DeathMessages, "\n");
		}

		lump = -1;
		while (-1 != (lump = Wads.FindLump("deathsubtitles", lump + 1)))
		{
			string s = Wads.ReadLump(lump);
			s.Replace("\r\n", "\n");
			s.Split(_DeathSubtitles, "\n");
		}
	}

	override void WorldTick()
	{
		if (Players[ConsolePlayer].mo.Health > 0)
		{
			_Message = "";
			_Subtitle= "";
			_MsgIndex = 0;
			_SubIndex = 0;
			_MsgTimer = 0;
			_SubTimer = 0;
			if (_PlayingMusic)
			{
				_PlayingMusic = false;
				S_ChangeMusic("*", 0, true, true);
				SetMusicVolume(1);
			}
			return;
		}

		if (!_PlayingMusic)
		{
			_PlayingMusic = true;
			if (_DeathMessages.Size() > 0) _DMCache = _DeathMessages[Random(0, _DeathMessages.Size() - 1)];
			if (_DeathSubtitles.Size() > 0) _DSCache = _DeathSubtitles[Random(0, _DeathSubtitles.Size() - 1)];
			S_ChangeMusic("hddead", 0, true, true);
			SetMusicVolume(ggwp_volume);
		}


		string c;
		int i;
		if (_MsgIndex < _DMCache.Length())
		{
			if (_MsgTimer <= ggwp_deathmessagedelay)
			{
				_MsgTimer++;
				return;
			}

			[c, i] = GetChar(_DMCache, _MsgIndex);

			_Message = AppendString(_Message, c);
			_MsgIndex += i;
			_MsgTimer = 0;
		}
		else if (_SubIndex < _DSCache.Length())
		{
			if (_SubTimer <= ggwp_deathsubtitledelay)
			{
				_SubTimer++;
				return;
			}

			[c, i] = GetChar(_DSCache, _SubIndex);

			_Subtitle = AppendString(_Subtitle, c);
			_SubIndex += i;
			_SubTimer = 0;
		}
	}

	override void RenderOverlay(RenderEvent e)
	{
		StatusBar.FullScreenOffsets = true;
		if (!_MainFont) _MainFont = HUDFont.Create(BigFont);
		if (!_SubFont) _SubFont = HUDFont.Create(SmallFont);
		if (Players[ConsolePlayer].mo.Health > 0) return;

		StatusBar.DrawString(
			_MainFont,
			_Message,
			(0, 0),
			StatusBar.DI_SCREEN_CENTER | StatusBar.DI_TEXT_ALIGN_CENTER
		);

		StatusBar.DrawString(
			_SubFont,
			_Subtitle,
			(0, -40),
			StatusBar.DI_SCREEN_CENTER_BOTTOM | StatusBar.DI_TEXT_ALIGN_CENTER,
			scale: (0.5, 0.5)
		);
	}

	// Returns a char and an int incrementing the index
	string, int GetChar(string text, int index)
	{
		int oldIndex = index;
		string c = text.Mid(index, 1);

		if (c == '\')
		{
			index++;
			if (index >= text.Length()) return c;
			string l = text.Mid(index, 1);

			if (l == "c" && index + 1 < text.Length())
			{
				// Get colour and text
				c = AppendString("\c", text.Mid(index + 1, 1));
				index++;
			}
			else c = AppendString('\', l);
		}

		index++;
		return c, index - oldIndex;
	}

	string AppendString(string a, string b)
	{
		return string.Format("%s%s", a, b);
	}
}
