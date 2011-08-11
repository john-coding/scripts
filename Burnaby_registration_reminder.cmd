@if not "%echoInScript%"=="true" echo off
setlocal

call :setup
call :start_new_session

FOR /L %%a IN (0, 1, 10000) DO (
	for %%c in ( %classes% ) do (
		echo check class %%c
		call :check_registration %%c %regExpToSearch%
		call :wait 30
	)
)
exit /b 0


:setup
	set classes=247245, 248628
	set musicFileToPlay=%home%\Music\HappyHatters_TheHatSong.mp3
	set regExpToSearch="Spots Available"
	set url=http://webreg.city.burnaby.bc.ca/webreg/Activities/Activities.asp

	set _user-agent="Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 7.1; Trident/5.0)"
	set _cookieFile=burnabyWebregCookie.temp

	REM follow redirection by "--location"
	REM fake user-agent as website will reject the default user-agent of curl.
	set curlCommand=curl "%url%" ^
		--location ^
		--user-agent %_user-agent% ^
		--cookie %_cookieFile% ^
		--cookie-jar %_cookieFile%
exit /b 0


REM start a new http session
:start_new_session
	if exist %_cookieFile%	del %_cookieFile%

	%curlCommand% --output initialResponse.temp
exit /b 0


REM first parameter is the class code. Seoncd paramter is the regular expression to search.
:check_registration
	REM follow redirection by "--location"
	REM fake user-agent as website will reject the default user-agent of curl.

	REM this is the crucial command. 
	%curlCommand% --data "SearchType=IVRSearch&cbarcode=%1" | findstr /inr /c:%2

	if %errorlevel% equ 0 (
		REM the class is open for registration! Play some music to alert me!
		start %musicFileToPlay%
		REM wait until the music has played for a while 
		call :wait 240	
	)
exit /b 0


REM default to wait for 10 seconds.
:wait
	set waitTime=10
	if [%1] neq [] set waitTime=%1 
	
	choice /T %waitTime%  /D y
exit /b 0
