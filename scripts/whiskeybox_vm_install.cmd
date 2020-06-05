@ECHO off
TITLE Install whiskeybox vm (as a host)
COLOR F0
ECHO.

rem Check admin privileges. Let's poke the hornet's nest to see if we get any errors?
ECHO Checking your administrative privileges...
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

rem If an error flag is set, we do not have admin privileges.
if '%ERRORLEVEL%' NEQ '0' (
	ECHO Attempting to execute script as a non-elevated user. Requesting administrative privileges...
	goto REQUEST_ADMIN_PRIVILEGES
) else (
	ECHO Executing script as elevated user with appropriate administrative privileges.
	goto GOT_ADMIN_PRIVILEGES
)


:REQUEST_ADMIN_PRIVILEGES
	ECHO Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
	SET params = %*:"="
	ECHO UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

	"%temp%\getadmin.vbs"
	DEL "%temp%\getadmin.vbs"
	EXIT /B


:GOT_ADMIN_PRIVILEGES
	pushd "%CD%"
	CD /D "%~dp0"


:REQUEST_WHISKEYBOX_HOST_INSTALL
SET CHOICE=
SET /P CHOICE="Do you want to install whiskeybox vm as a host on this machine? (Y/N) $> "
IF NOT '%CHOICE%'=='' SET CHOICE=%CHOICE:~0,1%

ECHO.
IF /I '%CHOICE%'=='Y' GOTO ADMIN_ACCEPTED
IF /I '%CHOICE%'=='N' GOTO ADMIN_REJECTED
ECHO You entered an invalid selection... You must type either Y (for Yes) or N (for No) to proceed!
ECHO.

GOTO REQUEST_WHISKEYBOX_HOST_INSTALL


:ADMIN_REJECTED
ECHO You have rejected the installation and whiskeybox vm was not installed as a host on this machine. Please use http://192.168.33.10 to access your box. Otherwise feel free to make your own host file modifications.
GOTO END


:ADMIN_ACCEPTED
SETLOCAL ENABLEDELAYEDEXPANSION
rem Create list of host domain(s) for whiskeybox.
SET HOSTDOMAINS=(whiskeybox.local www.whiskeybox.local)

rem Sets the local IP address(es) of the whiskeybox host domain(s).
SET whiskeybox.local=192.168.33.10
SET www.whiskeybox.local=192.168.33.10

rem Deletes parentheses from host domain(s).
SET DOMAINS=%HOSTDOMAINS:~1,-1%

FOR  %%G IN (%DOMAINS%) DO (
	SET  DOMAIN=%%G
	SET  IPADDR=!%%G!
	SET NEWLINE=^& echo.
	ECHO Carrying out installing whiskeybox vm as a host on this machine... Please wait while the changes are being made...

	rem Strip out the given line and store in a temporary file.
	type %WINDIR%\System32\drivers\etc\hosts | findstr /v !DOMAIN! > tmp.txt

	rem Add line back.
	ECHO %NEWLINE%^!IPADDR! !DOMAIN!>>tmp.txt

	rem Overwrite hosts file.
	COPY /b/v/y tmp.txt %WINDIR%\System32\drivers\etc\hosts
	DEL tmp.txt
)

ipconfig /flushdns

ECHO.
ECHO.
ECHO ************ Congrats *************************************
ECHO You have installed whiskeybox vm as a host on this machine.
ECHO Use "http://whiskeybox.local" or "http://www.whiskeybox.local" (without quotes) to access your box.
ECHO Chrome-users please note; before navigating to your box, please first navigate to the following URL in chrome "chrome://net-internals/#dns" (without quotes) and then click on the "clear host cache" button.
GOTO END


:END
ECHO.
PING -n 16 192.168.33.10 > nul
EXIT
