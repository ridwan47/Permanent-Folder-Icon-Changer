@echo off
REM ============================================================================
REM Permanent Folder Icon Changer by ridwan47
REM ============================================================================
setlocal disabledelayedexpansion

REM ============================================================================
REM User Configuration
REM ============================================================================
REM Set the path to your "FolderIconUpdater.exe" file here.
set "IconUpdaterPath=%~dp0resources\FolderIconUpdater.exe"
REM set "IconUpdaterPath=%~dp0FolderIconUpdater.exe"
REM set "IconUpdaterPath=C:\MyTools\FolderIconUpdater.exe"

REM --- Context Menu Icon Configuration ---
set "ContextMenuIconPath=%~dp0icon.ico"
set "PermanentIconPath=%SystemRoot%\System32\PermanentFolderIconChanger.ico"
REM ============================================================================


REM --- DEBUG FILE SETUP in TEMP Directory ---
set "debugLogFile=%TEMP%\_folder_icon_debug.log"
del "%debugLogFile%" 2>nul
call :DebugLog "======== SCRIPT SESSION STARTED ========"

REM ----------------------------------------------------------------------------
REM Configuration: Files and Resources
REM ----------------------------------------------------------------------------
set "skipFiles=7z,CRC,SFV,dxweb,cheat,protect,launch,crash,patch,redist,language,QtWeb,mod,version,overlay,error,dump,node.exe,handler,lumaplay,createdump"
set "IconUpdater=%IconUpdaterPath%"

if not exist "%IconUpdater%" (
    cls
    echo.
    echo =================================================================
    echo  ERROR: Required component not found.
    echo =================================================================
    echo.
    echo The file 'FolderIconUpdater.exe' is missing.
    echo.
    echo Please edit this script and set the 'IconUpdaterPath'
    echo variable at the top to the correct location.
    echo.
    echo You can download it from:
    echo https://github.com/ramdany7/Folder-Icon-Updater/
    echo.
    pause
    goto :eof
)


REM ----------------------------------------------------------------------------
REM [PRIMARY METHOD] Check for a folder being dropped onto the .bat file at launch
REM ----------------------------------------------------------------------------
if not "%~1"=="" (
    if exist "%~1\" (
        call :DebugLog "Startup drag-and-drop detected for: %~1"
        call :OfferFolderActions "%~f1"
        goto :ExitScript
    ) else (
        REM Check if this is the special context menu installation parameter
        if /i "%~1"=="--install-context" ( goto :InstallContextMenu )
        if /i "%~1"=="--uninstall-context" ( goto :UninstallContextMenu )
        echo The item you dropped onto the script is not a valid folder.
        pause
        goto :eof
    )
)

:MainMenu
call :DebugLog "Main Menu displayed."
cls
echo.
echo  ========================================================================
echo                   PERMANENT FOLDER ICON CHANGER
echo                          by ridwan47
echo  ========================================================================
echo.
echo  TIP: Drag a folder onto the .bat file for quick single-folder operation
echo  DEBUG LOG: %temp%\_folder_icon_debug.log
echo.
echo  ========================================================================
echo                          OPERATION MODES
echo  ========================================================================
echo.
echo    [1]  Browse for a folder (Opens Windows Browse GUI)
echo    [2]  Scan all subfolders in current directory one by one
echo    [3]  Drag ^& Drop Folder / Paste folder path manually
echo.
echo  ------------------------------------------------------------------------
echo.
echo                    CONTEXT MENU INTEGRATION
echo.
echo    [I]  Install to folder context menu     (Press I to Install)
echo    [U]  Uninstall from folder context menu (Press U to Uninstall)
echo.
echo  ------------------------------------------------------------------------
echo.
echo    [E]  Exit
echo.
echo  ========================================================================
echo.

choice /C:123IUE /N /M "  Select your choice: "

if errorlevel 6 (
    call :DebugLog "Main Menu Choice: E (Exit)"
    goto :ImmediateExit
)
if errorlevel 5 ( call :DebugLog "Main Menu Choice: U (Uninstall)" & goto :UninstallContextMenu )
if errorlevel 4 ( call :DebugLog "Main Menu Choice: I (Install)" & goto :InstallContextMenu )
if errorlevel 3 ( call :DebugLog "Main Menu Choice: 3" & goto :ManualFolderInput )
if errorlevel 2 ( call :DebugLog "Main Menu Choice: 2" & goto :ProcessAllSubfolders )
if errorlevel 1 ( call :DebugLog "Main Menu Choice: 1" & goto :BrowseForSingleFolder )
goto :MainMenu

:BrowseForSingleFolder
call :DebugLog "Option 1: Browse for single folder selected."
echo.
echo ...Opening folder browser...
set "psCommand=Add-Type -AssemblyName System.Windows.Forms; $f=New-Object System.Windows.Forms.OpenFileDialog; $f.Title='Select a folder by navigating into it and clicking Open'; $f.ValidateNames=$false; $f.CheckFileExists=$false; $f.CheckPathExists=$true; $f.FileName='Select This Folder'; if($f.ShowDialog() -eq 'OK'){ [System.IO.Path]::GetDirectoryName($f.FileName) }"

set "selectedFolder="
for /f "usebackq delims=" %%F in (`powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "%psCommand%"`) do (
    set "selectedFolder=%%F"
)

if defined selectedFolder (
    call :OfferFolderActions "%selectedFolder%"
) else (
    call :DebugLog "Folder browse dialog cancelled."
    echo ...No folder selected.
)
echo. & pause
goto :MainMenu

:ProcessAllSubfolders
    call :DebugLog "Option 2: Scan all subfolders selected."
    echo.
    set "returnToMenu="
    for /D %%I in (*) do (
        call :DebugLog "Processing subfolder: %%~fI"
        call :OfferFolderActions "%%~fI"
        if defined returnToMenu goto :SubfolderLoopEnd
        echo.
        pause
    )
    :SubfolderLoopEnd
    cls
    echo.
    echo ======================================================
    echo  Subfolder scan complete. Returning to main menu.
    echo ======================================================
    echo.
    pause
    goto :MainMenu

:ManualFolderInput
call :DebugLog "Option 3: Manual path input selected."
cls
echo ======================================================
echo  Manual Folder Path Entry
echo ======================================================
echo.
echo IMPORTANT: Pasting a path works perfectly. Dragging
echo a path into this window may crash the script.
echo This is a bug in Windows, not the script.
echo.
set /p "manualPath=Paste folder path and press Enter: "
call :DebugLog "Manual path input received: %manualPath%"

if not defined manualPath (
    call :DebugLog "Manual path input was empty."
    echo ...No path entered.
    pause
    goto :MainMenu
)

set "cleanPath=%manualPath:"=%"
call :DebugLog "Manual path sanitized to: %cleanPath%"

if exist "%cleanPath%\" (
    echo.
    call :OfferFolderActions "%cleanPath%"
) else (
    call :DebugLog "Manual path was not a valid folder."
    echo.
    echo ...ERROR: The path "%cleanPath%" is not a valid folder.
)
echo. & pause
goto :MainMenu

:ExitScript
call :DebugLog "======== SCRIPT SESSION FINISHED (Normal Exit) ========"
echo ======================================================
echo Script finished.
echo ======================================================
pause
goto :eof

:OfferFolderActions
    setlocal
    set "folderPath=%~f1"
    cls
    echo A folder has been selected.
    echo ======================================================
    echo FOLDER: %folderPath%
    echo ======================================================
    echo.
    echo What would you like to do?
    echo.
    echo   1. Browse for an external icon (Windows Browse GUI)
    echo   2. Process this folder (find icons inside the folder)
    echo   3. Drag ^& Drop Icon File / Paste icon path manually
    echo ===============================================
    echo   0. Skip Folder
    echo   M. Main Menu
    echo   E. Exit
    echo.
    choice /C:1230ME /N /M "Select an option: "

    if errorlevel 6 ( goto :ImmediateExit )
    if errorlevel 5 (
        call :DebugLog "Action Choice: M (Main Menu)"
        endlocal
        set "returnToMenu=true"
        goto :MainMenu
    )
    if errorlevel 4 (
        call :DebugLog "Action Choice: 0 (Skip folder)"
        echo ...Skipping folder.
        endlocal
        goto :eof
    )
    if errorlevel 3 (
        call :DebugLog "Action Choice: 3 (Manual icon path)"
        endlocal & call :ManualIconInput "%folderPath%"
        goto :eof
    )
    if errorlevel 2 (
        call :DebugLog "Action Choice: 2 (Process folder)"
        endlocal & call :ProcessFolder "%folderPath%"
        goto :eof
    )
    if errorlevel 1 (
        call :DebugLog "Action Choice: 1 (Browse for external icon)"
        endlocal & call :BrowseForExternalIcon "%folderPath%"
        goto :eof
    )
goto :eof

:ProcessFolder
    setlocal disabledelayedexpansion
    set "targetFolder=%~f1"
    call :DebugLog "--- Begin Processing Folder: %targetFolder% ---"
    
    set "tempFile=%TEMP%\foldericon_%RANDOM%.txt"
    set "icoTempFile=%TEMP%\foldericon_ico_%RANDOM%.txt"
    set "exeTempFile=%TEMP%\foldericon_exe_%RANDOM%.txt"
    if exist "%tempFile%" del "%tempFile%"
    if exist "%icoTempFile%" del "%icoTempFile%"
    if exist "%exeTempFile%" del "%exeTempFile%"

    echo ...Scanning for suitable files, please wait...
    
    for /f "delims=" %%J in ('dir /s /b /a-d "%targetFolder%\*.ico" 2^>nul') do (
        set "skipFlag="
        for %%S in (%skipFiles%) do (echo "%%~nxJ" | findstr /i /L "%%S" >nul 2>nul && set "skipFlag=1")
        if not defined skipFlag ((echo %%J^|%%~nxJ^|%%~dpJ)>>"%icoTempFile%")
    )
    for /f "delims=" %%J in ('dir /s /b /a-d "%targetFolder%\*.exe" 2^>nul') do (
        set "skipFlag="
        for %%S in (%skipFiles%) do (echo "%%~nxJ" | findstr /i /L "%%S" >nul 2>nul && set "skipFlag=1")
        if not defined skipFlag ((echo %%J^|%%~nxJ^|%%~dpJ)>>"%exeTempFile%")
    )

    if exist "%icoTempFile%" type "%icoTempFile%" >> "%tempFile%"
    if exist "%exeTempFile%" type "%exeTempFile%" >> "%tempFile%"

    set "icoCount=0"
    set "totalCount=0"
    if exist "%icoTempFile%" ( for /f "usebackq" %%L in ("%icoTempFile%") do set /a icoCount+=1 )
    if exist "%tempFile%" ( for /f "usebackq" %%L in ("%tempFile%") do set /a totalCount+=1 )
    call :DebugLog "Found %totalCount% suitable files (%icoCount% ICOs)."
    
    if %totalCount% equ 0 (
        echo ...No suitable .ico or .exe files found.
        call :PromptUserChoice "%targetFolder%" "%tempFile%" 0 0
    ) else if %totalCount% equ 1 (
        for /f "usebackq tokens=1,2 delims=|" %%A in ("%tempFile%") do (
            echo ...One suitable file found, auto-selecting: %%B
            call :DebugLog "Auto-selecting single file: %%B"
            call :SetFolderIcon "%targetFolder%" "%%A"
        )
    ) else (
        call :PromptUserChoice "%targetFolder%" "%tempFile%" %totalCount% %icoCount%
    )
    
    if exist "%tempFile%" del "%tempFile%"
    if exist "%icoTempFile%" del "%icoTempFile%"
    if exist "%exeTempFile%" del "%exeTempFile%"
    call :DebugLog "--- End Processing Folder: %targetFolder% ---"
    endlocal
goto :eof

:PromptUserChoice
    setlocal disabledelayedexpansion
    set "targetFolder=%~f1"
    set "tempFileArg=%~2"
    set "totalCountArg=%~3"
    set "icoCountArg=%~4"
    
    REM Store basePath before enabling delayed expansion
    set "basePath=%targetFolder%\"
    
    echo.
    if %totalCountArg% gtr 0 (
        echo Multiple suitable files found. Please choose one:
    ) else (
        echo No local files found. You can browse for an icon.
    )
    echo.
    echo   0. [Skip this folder]
    if %totalCountArg% gtr 0 (
        set "displayNum=0"
        set "headerPrinted="
        setlocal enabledelayedexpansion
        
        if %icoCountArg% gtr 0 echo. & echo   --- ICO Files ---
        
        for /f "usebackq tokens=2,3 delims=|" %%F in ("!tempFileArg!") do (
            set /a displayNum+=1
            if !displayNum! gtr %icoCountArg% if not defined headerPrinted (
                echo. & echo   --- EXE Files ---
                set "headerPrinted=1"
            )

            set "fileName=%%F"
            set "parentDir=%%G"
            
            REM Compare paths to determine location display
            if /i "!parentDir!"=="!basePath!" (
                set "location=root"
            ) else (
                REM Use temporary variable for substring replacement
                set "location=!parentDir!"
                for %%B in ("!basePath!") do set "location=!location:%%~B=!"
                
                REM Clean up leading backslash if present
                if "!location:~0,1!"=="\" set "location=!location:~1!"
                
                REM Add leading backslash for display
                if not "!location!"=="" set "location=\!location!"
            )

            set "paddedName=!fileName!                                        "
            set "paddedName=!paddedName:~0,35!"

            echo   !displayNum!. !paddedName! --- (!location!)
        )
        endlocal
    )
    echo. & echo   B. [Browse for another .ico file]
    echo   M. [Return to Main Menu]
    echo   E. [Exit]
    echo.
    
    if %totalCountArg% gtr 9 goto :PromptUserChoice_Legacy

    setlocal enabledelayedexpansion
    set "choiceChars=0BME"
    for /L %%N in (1,1,%totalCountArg%) do set "choiceChars=!choiceChars!%%N"
    
    echo Press a key to make your choice (no Enter needed)...
    choice /C:!choiceChars! /N

    set "choiceErrorLevel=%errorlevel%"
    endlocal & set choiceErrorLevel=%choiceErrorLevel%

    if %choiceErrorLevel% equ 1 (
        echo ...Skipping.
        call :DebugLog "User chose to skip."
        endlocal
        goto :eof
    )
    if %choiceErrorLevel% equ 2 (
        call :DebugLog "User chose to browse for external icon."
        endlocal & call :BrowseForExternalIcon "%targetFolder%"
        goto :eof
    )
    if %choiceErrorLevel% equ 3 (
        call :DebugLog "User chose M for Main Menu."
        endlocal
        set "returnToMenu=true"
        goto :MainMenu
    )
    if %choiceErrorLevel% equ 4 ( goto :ImmediateExit )
    
    set /a "selectedChoice = choiceErrorLevel - 4"
    call :FindSelectionByNumber "%targetFolder%" "%tempFileArg%" %selectedChoice%
    endlocal
goto :eof

:PromptUserChoice_Legacy
    set /p "userChoice=Type your choice (0-%totalCountArg%, B, M, or E) and press Enter: "
    call :DebugLog "Legacy prompt input received: %userChoice%"

    if /i "%userChoice%"=="e" ( goto :ImmediateExit )
    if /i "%userChoice%"=="m" (
        call :DebugLog "User chose M for Main Menu."
        endlocal
        set "returnToMenu=true"
        goto :MainMenu
    )
    if /i "%userChoice%"=="b" (
        call :DebugLog "User chose to browse for external icon."
        call :BrowseForExternalIcon "%targetFolder%"
        endlocal
        goto :eof
    )
    set /a "selectedChoice=-1" & set /a "selectedChoice=%userChoice%" 2>nul
    
    if %selectedChoice% lss 1 (
        if %selectedChoice% equ 0 ( echo ...Skipping. & call :DebugLog "User chose to skip." ) else ( echo ...Invalid choice. )
        endlocal
        goto :eof
    )
    if %selectedChoice% gtr %totalCountArg% (
        echo ...Invalid choice.
        endlocal
        goto :eof
    )
    call :FindSelectionByNumber "%targetFolder%" "%tempFileArg%" %selectedChoice%
    endlocal
goto :eof

:FindSelectionByNumber
    setlocal
    set "targetFolder=%~1"
    set "tempFileArg=%~2"
    set "selectedChoice=%~3"
    call :DebugLog "User selected item #%selectedChoice% from the list."
    set "currentLine=0"
    set "foundPath="
    for /f "usebackq tokens=1 delims=|" %%A in ("%tempFileArg%") do (
        set /a currentLine+=1
        setlocal enabledelayedexpansion
        if !currentLine! equ %selectedChoice% (
            endlocal
            set "foundPath=%%A"
            goto :SelectionFound
        )
        endlocal
    )

:SelectionFound
    if defined foundPath (
        call :DebugLog "Matched item #%selectedChoice% to path: %foundPath%"
        echo.
        for %%F in ("%foundPath%") do echo ...You selected: %%~nxF
        endlocal & call :SetFolderIcon "%targetFolder%" "%foundPath%"
    ) else (
        endlocal
    )
goto :eof

:BrowseForExternalIcon
    set "browseTarget=%~f1"
    echo.
    echo ...Opening file browser...
    set "psCommand=Add-Type -AssemblyName System.windows.forms; $f=New-Object System.Windows.Forms.OpenFileDialog; $f.InitialDirectory='%CD%'; $f.Filter='Icon Files (*.ico)|*.ico|All Files (*.*)|*.*'; $f.Title='Select an Icon File'; [void]$f.ShowDialog(); if ($f.FileName -ne '') { $f.FileName }"
    
    set "selectedFile="
    for /f "usebackq delims=" %%F in (`powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "%psCommand%"`) do (
        set "selectedFile=%%F"
    )

    if defined selectedFile (
        call :DebugLog "User browsed and selected external file: %selectedFile%"
        echo ...You selected: %selectedFile%
        call :SetFolderIcon "%browseTarget%" "%selectedFile%"
    ) else (
        call :DebugLog "User cancelled the browse dialog."
        echo ...No file selected.
    )
goto :eof

:ManualIconInput
    setlocal
    set "targetFolder=%~1"
    for %%F in ("%targetFolder%") do set "folderName=%%~nxF"
    cls
    echo ======================================================
    echo  Manual Icon Path Entry ^>^> %folderName%
    echo ======================================================
    echo.
    echo IMPORTANT: Pasting a path works perfectly. Dragging
    echo a path into this window may crash the script.
    echo This is a bug in Windows, not the script.
    echo.
    set /p "iconPath=Paste icon path (.ico or .exe) and press Enter: "
    set "cleanPath=%iconPath:"=%"
    call :DebugLog "Manual icon path sanitized to: %cleanPath%"

    if not defined iconPath (
        call :DebugLog "Manual icon path input was empty."
        echo ...No path entered.
        endlocal
        goto :eof
    )

    if not exist "%cleanPath%" (
        call :DebugLog "Manual icon path does not exist."
        echo ...ERROR: The file path you entered does not exist.
        pause
        endlocal
        goto :eof
    )

    for %%F in ("%cleanPath%") do set "ext=%%~xF"
    if /i not "%ext%"==".ico" if /i not "%ext%"==".exe" (
        call :DebugLog "Manual icon path is not a valid file type."
        echo ...ERROR: The file must be an .ico or .exe.
        pause
        endlocal
        goto :eof
    )
    
    endlocal & call :SetFolderIcon "%targetFolder%" "%cleanPath%"
goto :eof

:SetFolderIcon
    setlocal disabledelayedexpansion
    set "targetFolder=%~f1"
    set "fullPath=%~f2"
    
    setlocal enabledelayedexpansion
    
    for %%F in ("!fullPath!") do (
        set "fileName=%%~nxF"
        set "fileExt=%%~xF"
    )
    
    call :DebugLog "SetFolderIcon: Target Folder is '!targetFolder!'"
    call :DebugLog "SetFolderIcon: Full Icon Path is '!fullPath!'"
    
    echo ...Processing icon for "!fileName!"
    set "iconPath="
    
    pushd "!targetFolder!" || (call :DebugLog "FATAL ERROR: Could not pushd to target folder."& echo ...ERROR: Access denied.& endlocal & endlocal & goto :eof)

    REM --- Use GOTO for robust conditional logic ---
    if /i "!fileExt!"==".exe" goto :SetIcon_ProcessExe
    if /i "!fileExt!"==".ico" goto :SetIcon_ProcessIco
    goto :SetIcon_ProcessOther

:SetIcon_ProcessExe
    call :DebugLog "File is an EXE. Using full absolute path."
    set "iconPath=!fullPath!"
    goto :SetIcon_EndProcessing

:SetIcon_ProcessIco
    for %%N in ("!fileName!") do (
        set "baseName=%%~nN"
        set "ext=%%~xN"
    )
    set "finalName=icon_!baseName!!ext!"
    call :DebugLog "ICO selected. Base proposed name is '!finalName!'."
    
    if exist "!finalName!" (
        set "counter=2"
        :NameCheckLoop
        set "finalName=icon_!baseName!_!counter!!ext!"
        if exist "!finalName!" (
            set /a counter+=1
            goto :NameCheckLoop
        )
    )
    call :DebugLog "Conflict check passed. Final name will be '!finalName!'."
    
    REM --- [FINAL LOGIC] Always create a copy. Never rename the original. ---
    call :DebugLog "Copying '!fullPath!' to '!finalName!'."
    copy /Y "!fullPath!" "!finalName!" >nul 2>nul

    if not errorlevel 1 (
        echo ...Icon file copied to '!finalName!'.
        set "iconPath=!finalName!"
    ) else (
        call :DebugLog "COPY FAILED. Using full absolute path as fallback."
        echo ...Warning: Could not copy icon into folder. Using original path.
        set "iconPath=!fullPath!"
    )
    goto :SetIcon_EndProcessing

:SetIcon_ProcessOther
    call :DebugLog "WARNING: Unexpected file extension '!fileExt!'. Using full path."
    set "iconPath=!fullPath!"
    goto :SetIcon_EndProcessing

:SetIcon_EndProcessing
    REM --- Use FolderIconUpdater.exe to set icon with instant refresh ---
    call :DebugLog "Using FolderIconUpdater.exe with icon path: '!iconPath!'"
    "%IconUpdater%" /f "!targetFolder!" /i "!iconPath!" /a +H+S >nul 2>nul
    
    if errorlevel 1 (
        call :DebugLog "FolderIconUpdater.exe reported an error. Falling back to manual method."
        echo ...Warning: Icon updater reported an issue. Using fallback method...
        
        if exist "desktop.ini" (attrib -s -h -r "desktop.ini" 2>nul & del "desktop.ini" 2>nul)
        
        call :DebugLog "Writing to desktop.ini manually..."
        (
            echo [.ShellClassInfo]
            echo IconResource=!iconPath!,0
        ) > "desktop.ini"

        call :DebugLog "Setting desktop.ini attributes (+s +h -a)."
        attrib +s +h -a "desktop.ini" >nul 2>nul
    )

    REM --- Hide the copied/renamed icon file so the folder stays clean ---
    if defined iconPath if /i not "!iconPath!"=="!fullPath!" (
        call :DebugLog "Setting attributes (+s +h -a) on local icon file (!iconPath!)."
        attrib +s +h -a "!iconPath!" >nul 2>nul
    )

    popd
    echo ...Folder icon set successfully.
    endlocal
    endlocal
goto :eof

:DebugLog
    echo %date% @ %time% - %~1 >> "%debugLogFile%"
goto :eof

:InstallContextMenu
    cls
    echo ======================================================
    echo  Install Context Menu Integration
    echo ======================================================
    echo.
    echo This will add "Change Folder Icon" to the right-click
    echo context menu when you right-click on any folder.
    echo.
    echo The icon will be permanently copied to System32.
    echo.
    echo NOTE: This requires Administrator privileges.
    echo.
    
    REM Check if running as administrator
    net session >nul 2>&1
    if %errorlevel% neq 0 (
        echo ERROR: Administrator privileges required!
        echo.
        echo Please right-click this script and select
        echo "Run as administrator" to install the context menu.
        echo.
        pause
        goto :MainMenu
    )
    
    call :DebugLog "Installing context menu integration..."
    echo Installing...
    echo.
    
    set "scriptPath=%~f0"
    set "sourceIconPath=%ContextMenuIconPath%"
    set "targetIconPath=%PermanentIconPath%"
    
    REM Check if source icon file exists
    if defined sourceIconPath (
        if not exist "%sourceIconPath%" (
            echo WARNING: Icon file not found at: %sourceIconPath%
            echo The context menu will be installed without an icon.
            echo.
            call :DebugLog "Icon file not found, installing without icon."
            set "targetIconPath="
        ) else (
            call :DebugLog "Copying icon to System32..."
            echo Copying icon to System32 for permanent persistence...
            
            REM Copy icon to System32
            copy /Y "%sourceIconPath%" "%targetIconPath%" >nul 2>nul
            
            if errorlevel 1 (
                echo WARNING: Could not copy icon to System32.
                echo The context menu will be installed without an icon.
                echo.
                call :DebugLog "Failed to copy icon to System32."
                set "targetIconPath="
            ) else (
                echo Icon successfully copied to System32.
                call :DebugLog "Icon copied successfully to: %targetIconPath%"
            )
        )
    ) else (
        echo NOTE: No icon path configured.
        echo The context menu will be installed without an icon.
        echo.
        call :DebugLog "No icon path configured, installing without icon."
        set "targetIconPath="
    )
    
    echo.
    echo Creating registry entries...
    
    REM Create registry entries for folder context menu
    reg add "HKEY_CLASSES_ROOT\Directory\shell\SetFolderIcon" /ve /d "Change Folder Icon" /f >nul 2>nul
    
    if defined targetIconPath (
        reg add "HKEY_CLASSES_ROOT\Directory\shell\SetFolderIcon" /v "Icon" /d "%targetIconPath%" /f >nul 2>nul
    )
    
    reg add "HKEY_CLASSES_ROOT\Directory\shell\SetFolderIcon\command" /ve /d "\"%scriptPath%\" \"%%1\"" /f >nul 2>nul
    
    REM Also add to directory background (when right-clicking inside a folder)
    reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\SetFolderIcon" /ve /d "Change Folder Icon" /f >nul 2>nul
    
    if defined targetIconPath (
        reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\SetFolderIcon" /v "Icon" /d "%targetIconPath%" /f >nul 2>nul
    )
    
    reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\SetFolderIcon\command" /ve /d "\"%scriptPath%\" \"%%V\"" /f >nul 2>nul
    
    if errorlevel 1 (
        echo.
        echo ERROR: Failed to install context menu.
        echo Please ensure you have administrator privileges.
        call :DebugLog "Context menu installation FAILED."
    ) else (
        echo.
        echo ======================================================
        echo  SUCCESS! Context menu installed.
        echo ======================================================
        echo.
        echo You can now right-click any folder and select
        echo "Change Folder Icon" from the context menu.
        echo.
        call :DebugLog "Context menu installation completed successfully."
    )
    
    echo.
    pause
    goto :MainMenu

:UninstallContextMenu
    cls
    echo ======================================================
    echo  Uninstall Context Menu Integration
    echo ======================================================
    echo.
    echo This will remove "Change Folder Icon" from the
    echo right-click context menu.
    echo.
    echo NOTE: This requires Administrator privileges.
    echo.
    
    REM Check if running as administrator
    net session >nul 2>&1
    if %errorlevel% neq 0 (
        echo ERROR: Administrator privileges required!
        echo.
        echo Please right-click this script and select
        echo "Run as administrator" to uninstall the context menu.
        echo.
        pause
        goto :MainMenu
    )
    
    call :DebugLog "Uninstalling context menu integration..."
    echo Uninstalling...
    echo.
    
    REM Remove the permanent icon from System32
    set "targetIconPath=%PermanentIconPath%"
    if exist "%targetIconPath%" (
        echo Removing permanent icon from System32...
        del "%targetIconPath%" >nul 2>nul
        if errorlevel 1 (
            echo WARNING: Could not delete icon from System32.
            echo You may need to delete it manually: %targetIconPath%
            call :DebugLog "Failed to delete icon from System32."
        ) else (
            echo Icon removed from System32.
            call :DebugLog "Icon deleted successfully from System32."
        )
        echo.
    )
    
    echo Removing registry entries...
    
    REM Remove registry entries
    reg delete "HKEY_CLASSES_ROOT\Directory\shell\SetFolderIcon" /f >nul 2>nul
    reg delete "HKEY_CLASSES_ROOT\Directory\Background\shell\SetFolderIcon" /f >nul 2>nul
    
    if errorlevel 1 (
        echo.
        echo NOTE: Context menu may not have been installed,
        echo or it has already been removed.
        call :DebugLog "Context menu uninstallation completed (may not have been installed)."
    ) else (
        echo.
        echo ======================================================
        echo  SUCCESS! Context menu removed.
        echo ======================================================
        echo.
        echo The "Change Folder Icon" entry has been removed
        echo from the folder context menu.
        echo.
        call :DebugLog "Context menu uninstallation completed successfully."
    )
    
    echo.
    pause
    goto :MainMenu

:ImmediateExit
    call :DebugLog "======== SCRIPT SESSION FINISHED (User Exit) ========"
    exit