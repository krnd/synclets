@ECHO OFF

REM =============================< PREPARE >====================================

CD /D "%~dp0"

REM =============================< PULL >=======================================
ECHO.
ECHO.
ECHO ################# PULL #################
ECHO.

git pull

IF %ERRORLEVEL% NEQ 0 GOTO __FAIL

REM =============================< COMMIT >=====================================
ECHO.
ECHO.
ECHO ################# COMMIT ###############
ECHO.

git add --all

git commit --message="%DATE% %TIME%"

REM =============================< PUSH >=======================================
ECHO.
ECHO.
ECHO ################# PUSH #################
ECHO.

git push

IF %ERRORLEVEL% NEQ 0 GOTO __FAIL

REM =============================< RESULT >=====================================
ECHO.
ECHO.
ECHO ################# SUCCESS ##############
ECHO.

TIMEOUT 3

GOTO :EOF


REM ===================< FAIL >=============================
:__FAIL
ECHO.
ECHO.

PAUSE
