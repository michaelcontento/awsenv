@echo off

setlocal

REM Due to a bug in the CLI in which some paths in environment variables
REM have quotes stripped and others do not, we need to strip quotes from
REM the paths stored in environment variables.
if defined AWS_CREDENTIAL_FILE set AWS_CREDENTIAL_FILE=%AWS_CREDENTIAL_FILE:"=%
if defined EC2_CERT set EC2_CERT=%EC2_CERT:"=%
if defined EC2_PRIVATE_KEY set EC2_PRIVATE_KEY=%EC2_PRIVATE_KEY:"=%

REM AWS_RDS_HOME must be defined.
if defined AWS_RDS_HOME (
    set SERVICE_HOME="%AWS_RDS_HOME:"=%"
) else (
    goto AWS_RDS_HOME_MISSING
)

:ARGV_LOOP
IF (%1) == () GOTO ARGV_DONE
REM Get around strange quoting bug
SET ARGV=%ARGV% %1
SHIFT
GOTO ARGV_LOOP
:ARGV_DONE

REM run
%SERVICE_HOME%\bin\service.cmd %ARGV%
goto DONE

:AWS_RDS_HOME_MISSING
echo AWS_RDS_HOME is not set
exit /b 1

:DONE
endlocal