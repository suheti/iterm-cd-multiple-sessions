#!/usr/bin/osascript

-- Launches multiple SSH session
-- cd into the specified repo dirs below
-- creates and uses a new tab if iTerm is already running and there is an opened window.
-- creates and uses a new window if iTerm is not running, or when there is no opened window.

on run argv
	set dirs to {"~/projects/repo1/", "~/projects/repo1/", "/playground/"}
	
	set numColumns to (round ((count dirs) ^ 0.5) rounding up)
	
	set allSessions to {}
	set columnTops to {}
	
	set isNewWindow to false
	
	-- set the boolean isNewWindow properly when the application is not running
	tell application "System Events" to set isNewWindow to not (exists (processes where name contains "iTerm"))
	
	tell application "iTerm"
		try
			-- check there is an opened window with opened session
			tell current window
				get current session
			end tell
		on error
			create window with default profile
			set isNewWindow to true
		end try
		
		-- create column tops
		tell current window
			if not isNewWindow then
				-- only create new tab when the window was already there before we run script
				create tab with default profile
			end if
			copy current session to end of |allSessions|
			copy current session to end of |columnTops|
			tell current session
				repeat numColumns - 1 times
					set newSession to (split vertically with default profile)
					copy newSession to end of |allSessions|
					copy newSession to end of |columnTops|
					tell newSession to select
				end repeat
			end tell
		end tell

		-- split each column
		set columnsDone to 0
		repeat with columnTop in columnTops
			tell columnTop
				-- calculate how many vertical panes we need here
				set numVertical to (round(((count dirs)-(count allSessions))/(numColumns-columnsDone)) rounding up) + 1
				repeat numVertical - 1 times
					copy (split horizontally with default profile) to end of |allSessions|
				end repeat
				set columnsDone to columnsDone + 1
			end tell
		end repeat

		-- run ssh commands on all sessions
		repeat with loopIndex from 1 to number of items in allSessions
			tell item loopIndex of allSessions
				write text "cd " & (item loopIndex of dirs)
			end tell
		end repeat
	end tell
	
end run
