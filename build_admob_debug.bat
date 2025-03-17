@echo off
setlocal enabledelayedexpansion

REM Set paths to SDK and Java
SET ANDROID_SDK_ROOT=D:\Android\SDK
SET JAVA_HOME=D:\Java\jdk-17.0.11

echo Setting up Gradle and building AdMob plugin (DEBUG)...

REM Create Gradle Wrapper directory if it doesn't exist
if not exist gradle\wrapper mkdir gradle\wrapper

REM Create gradle-wrapper.properties file
(
echo distributionBase=GRADLE_USER_HOME
echo distributionPath=wrapper/dists
echo distributionUrl=https://services.gradle.org/distributions/gradle-8.6-bin.zip
echo zipStoreBase=GRADLE_USER_HOME
echo zipStorePath=wrapper/dists
) > gradle\wrapper\gradle-wrapper.properties

REM Download gradle-wrapper.jar
echo Downloading gradle-wrapper.jar...
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://github.com/gradle/gradle/raw/master/gradle/wrapper/gradle-wrapper.jar', 'gradle\wrapper\gradle-wrapper.jar')"

REM Create directories for addons if they don't exist
if not exist demo\addons\AdmobPlugin\bin\debug mkdir demo\addons\AdmobPlugin\bin\debug
if not exist demo\addons\AdmobPlugin\bin\release mkdir demo\addons\AdmobPlugin\bin\release

REM Build project
echo Building AdMob plugin (DEBUG)...
call gradlew.bat --no-daemon assembleDebug

if %ERRORLEVEL% neq 0 (
    echo Error building project.
    exit /b %ERRORLEVEL%
)

echo Build completed successfully!
echo DEBUG AAR file is in directory: demo\addons\AdmobPlugin\bin\debug\
dir demo\addons\AdmobPlugin\bin\debug\

endlocal
