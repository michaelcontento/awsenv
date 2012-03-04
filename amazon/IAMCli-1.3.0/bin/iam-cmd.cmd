@echo off


setlocal

REM Copyright 2006-2011 Amazon.com, Inc. or its affiliates.  All Rights Reserved.  Licensed under the 
REM Amazon Software License (the "License").  You may not use this file except in compliance with the License. A copy of the 
REM License is located at http://aws.amazon.com/asl or in the "license" file accompanying this file.  This file is distributed on an "AS 
REM IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific
REM language governing permissions and limitations under the License.

REM Set intermediate env vars because the %VAR:x=y% notation below
REM (which replaces the string x with the string y in VAR)
REM doesn't handle undefined environment variables. This way
REM we're always dealing with defined variables in those tests.
set CHK_JAVA_HOME=_%JAVA_HOME%
set CHK_AWS_IAM_HOME=_%AWS_IAM_HOME%

if "%CHK_AWS_IAM_HOME:"=%" == "_" goto AWS_IAM_HOME_MISSING
if "%CHK_JAVA_HOME:"=%" == "_" goto JAVA_HOME_MISSING 

REM If a classpath exists preserve it
SET CP=%CLASSPATH%

REM Brute force
SET CP=%CP%;%AWS_IAM_HOME%\lib\commons-logging-1.1.1\commons-logging-1.1.1.jar
SET CP=%CP%;%AWS_IAM_HOME%\lib\commons-logging-1.1.1\commons-logging-adapters-1.1.1.jar
SET CP=%CP%;%AWS_IAM_HOME%\lib\commons-logging-1.1.1\commons-logging-api-1.1.1.jar
SET CP=%CP%;%AWS_IAM_HOME%\lib\apache-log4j-1.2.15\log4j-1.2.15.jar
SET CP=%CP%;%AWS_IAM_HOME%\lib\args4j-2.0.10\args4j-2.0.10.jar
SET CP=%CP%;%AWS_IAM_HOME%\lib\commons-codec-1.3\commons-codec-1.3.jar
SET CP=%CP%;%AWS_IAM_HOME%\lib\commons-httpclient-4.1.1\httpclient-4.1.1.jar
SET CP=%CP%;%AWS_IAM_HOME%\lib\commons-httpclient-4.1.1\httpcore-4.1.jar
SET CP=%CP%;%AWS_IAM_HOME%\lib\saxonhe-9.0.2j\saxon9he.jar
SET CP=%CP%;%AWS_IAM_HOME%\lib\aws-iam-cli\AWSIdentityManagementServiceCLI.jar

REM Grab the class name
SET CMD=%1

REM SHIFT doesn't affect %* so we need this clunky hack
SET ARGV=%2
SHIFT
SHIFT
:ARGV_LOOP
IF (%1) == () GOTO ARGV_DONE
REM Get around strange quoting bug
SET ARGV=%ARGV% "%1"
SHIFT
GOTO ARGV_LOOP
:ARGV_DONE

"%JAVA_HOME:"=%\bin\java" %AWS_IAM_JVM_OPTS% -classpath "%CP%" com.amazonaws.services.auth.identity.cli.view.%CMD% %ARGV%
goto DONE

:JAVA_HOME_MISSING
echo JAVA_HOME is not set
exit /b 1

:AWS_IAM_HOME_MISSING
echo AWS_IAM_HOME is not set
exit /b 1

:DONE
endlocal
