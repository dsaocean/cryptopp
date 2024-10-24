echo off

REM Name of the project
SET ProjectDescription=Crypto++: free C++ Class Library of Cryptographic Schemes


SET LibName=cryptopp
SET TargetsFile=%LibName%.targets
SET HeaderPath=%LibName%
SET SolutionDir=..

REM Define the programs we will use
WHERE msbuild
if %ERRORLEVEL% NEQ 0 (
DOSKEY msbuild="C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe"
)


SET ReleaseVersion=%~1

REM Provide defaults for debugging purposes
IF "%ReleaseVersion%"=="" (
	REM Get the version information from the user
	SET /p "ReleaseVersion=Please specify the software release version : "
)

for /F "tokens=1,2,3 delims=." %%a in ("%ReleaseVersion%") do (
   SET VERSION_MAJOR=%%a
   SET VERSION_MINOR=%%b
   SET VERSION_REVISION=%%c
)


REM Verify that valid version information was provided
REM If there was not a 0.0.0 triplet provided, then the revision
REM will be empty
IF "%VERSION_REVISION%" == "" (
	echo Invalid version number: %ReleaseVersion%
	GOTO:eof
)

REM Remove trailing back slashes from input paths
IF %SolutionDir:~-1%==\ SET SolutionDir=%SolutionDir:~0,-1%

REM Determine where we want the built distribution to go
SET TargetDir=build\%ReleaseVersion%

REM Set the version information through a define
REM Note that the VersionInfo is used in the libDSA.props file to set the version information
SET VersionInfo=/D__DSA_%Project%_Version_Major__=%VERSION_MAJOR% /D__DSA_%Project%_Version_Minor__=%VERSION_MINOR% /D__DSA_%Project%_Version_Revision__=%VERSION_REVISION% 

REM Build the libraries
SET DSA_BUILD_ARGS="%SolutionDir%\cryptlib.vcxproj" /p:OutDir="%TargetDir%/lib/native/" /p:VisualStudioVersion=16.0
msBuild %DSA_BUILD_ARGS% /p:configuration=Release /p:platform=x64
msBuild %DSA_BUILD_ARGS% /p:configuration=Debug /p:platform=x64
msBuild %DSA_BUILD_ARGS% /p:configuration=Release /p:platform=x86
msBuild %DSA_BUILD_ARGS% /p:configuration=Debug /p:platform=x86

REM Copy the distribution files in the target directory
xcopy /Y "%SolutionDir%\*.h" "%SolutionDir%\%TargetDir%\include\%HeaderPath%\"
xcopy /Y "%SolutionDir%\Distribution\%TargetsFile%" "%SolutionDir%\%TargetDir%\build\"

nuget pack %LibName%.nuspec -Version %ReleaseVersion%  -OutputDirectory "%SolutionDir%\build" -BasePath "%SolutionDir%\%TargetDir%" -Properties LibName=%LibName%;ProjectDescription="%ProjectDescription%"


