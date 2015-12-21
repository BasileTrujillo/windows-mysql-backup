::SETTINGS TIME
For /f "tokens=1-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%b-%%a)
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a%%b)
set backuptime=%mydate%_%mytime%
echo %backuptime%

:: SETTINGS AND PATHS 
:: Note: Do not put spaces before the equal signs or variables will fail

:: Name of the database user with rights to all tables
set dbuser=foo

:: Password for the database user
set dbpass=bar

:: Error log path - Important in debugging your issues
set errorLogPath="C:\MySQLBackups\backupfiles\dumperrors.txt"

:: MySQL EXE Path
set mysqldumpexe="C:\Program Files\MySQL\MySQL Server 5.6\bin\mysqldump.exe"
set mysqlexe="C:\Program Files\MySQL\MySQL Server 5.6\bin\mysql.exe"

:: Error log path
set backupfldr=C:\MySQLBackups\backupfiles\

:: Path to data folder which may differ from install dir
set datafldr="C:\ProgramData\MySQL\MySQL Server 5.6\data"

:: Path to zip executable
set zipper="C:\MySQLBackups\zip\7za.exe"

:: Number of days to retain .zip backup files 
set retaindays=30

:: DONE WITH SETTINGS

:: GO FORTH AND BACKUP EVERYTHING!
%mysqlexe% -u%dbuser% -p%dbpass% -s -N -e "SHOW DATABASES" | For /F "usebackq" %%D in (`findstr /V "information_schema performance_schema"`) Do ( 
	%mysqldumpexe% --user=%dbuser% --password=%dbpass% --databases --routines --log-error=%errorLogPath% %%D > "%backupfldr%%%D_%backuptime%.sql"
)

echo "Zipping all files ending in .sql in the folder"

:: .zip option clean but not as compressed
%zipper% a -tzip "%backupfldr%FullBackup.%backuptime%.zip" "%backupfldr%*.sql"

echo "Deleting all the files ending in .sql only"
 
del "%backupfldr%*.sql"

echo "Deleting zip files older than 30 days now"
Forfiles -p %backupfldr% -s -m *.* -d -%retaindays% -c "cmd /c del /q @path"

::SEND FILES TO NAS SERITECH FTP
set backupfldr=C:\MySQLBackups\backupfiles\
cd %backupfldr%
@echo off
echo user FTP_USER>ftpup.dat
echo FTP_PASSWORD>>ftpup.dat
echo cd /backup/BDD>>ftpup.dat
echo binary>>ftpup.dat
echo put FullBackup.%backuptime%.zip>>ftpup.dat
echo quit>>ftpup.dat
ftp -n -s:ftpup.dat ftp.exemple.com
del ftpup.dat

echo "done"

::return to the main script dir on end
popd