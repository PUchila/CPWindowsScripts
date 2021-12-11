@echo off
rem Preferences and initialization
color 0b
setlocal ENABLEDELAYEDEXPANSION

echo ------------------------------------------------------------------------------------
echo *** Welcome to Sharon CyberPatriot Windows 10 and Server2019 script!             ***
echo ------------------------------------------------------------------------------------
echo:

rem Guest and Admin
choice /c ync /m "Do you wish to disable guest and admin accounts? "
if %ERRORLEVEL% equ 3 goto:eof
if %ERRORLEVEL% equ 2 echo Skipping guest and admin accounts...
if %ERRORLEVEL% equ 1 (
    echo ------------------------------------------------------------------------------------
    echo *** Disabling guest and admin accounts...                                        ***
    net user administrator /active:no
    net user guest /active:no
    echo *** Finished                                                                     ***
    echo ------------------------------------------------------------------------------------
    echo:
)

rem Firewall
choice /c ync /m "Do you wish to enable firewall? "
if %ERRORLEVEL% equ 3 goto:eof
if %ERRORLEVEL% equ 2 echo Skipping firewall...
if %ERRORLEVEL% equ 1 (
    echo ------------------------------------------------------------------------------------
    echo *** Turning on firewall...                                                       ***
    netsh advfirewall set allprofiles state on
    echo *** Finished                                                                     ***
    echo ------------------------------------------------------------------------------------
    echo:
)

Rem Services
choice /c ync /m "Do you wish to disable any services? (Manual and automatic mode are available) "
if %ERRORLEVEL% equ 3 goto:eof
if %ERRORLEVEL% equ 2 echo Skipping services...
if %ERRORLEVEL% equ 1 (
    choice /c amc /m "Manual or automatic mode? (Manual mode steps through each service while automatic mode disables them all) "
    if !ERRORLEVEL! equ 3 (
        echo Skipping services... 
    ) else (
        set services=Telephony TapiSrv Tlntsvr tlntsvr p2pimsvc simptcp fax msftpsvc iprip ftpsvc RasMan RasAuto seclogon MSFTPSVC W3SVC SMTPSVC Dfs TrkWks MSDTC DNS ERSVC NtFrs MSFtpsvc helpsvc HTTPFilter IISADMIN IsmServ WmdmPmSN Spooler RDSessMgr RPCLocator RsoPProv ShellHWDetection ScardSvr Sacsvr TermService Uploadmgr VDS VSS WINS WinHttpAutoProxySvc SZCSVC CscService hidserv IPBusEnum PolicyAgent SCPolicySvc SharedAccess SSDPSRV Themes upnphost nfssvc nfsclnt MSSQLServerADHelper
        echo ------------------------------------------------------------------------------------
        echo *** Managing services...                                                         ***
        Rem Automatic mode
        if !ERRORLEVEL! equ 1 (
            for %%a in (!services!) do (
                echo Disabling %%a
                sc stop "%%a"
                sc config "%%a" start=disabled
            )
        Rem Manual mode
        ) else (
            for %%a in (!services!) do (
                choice /c yn /m "Do you wish to disable %%a? "
                if !ERRORLEVEL! equ 1 (
                    echo Disabling %%a...
                    sc stop "%%a"
                    sc config "%%a" start=disabled
                ) else (
                    echo Skipping %%a...
                )
            )
        )
        echo *** Finished                                                                     ***
        echo ------------------------------------------------------------------------------------
    )
)

rem Remote Desktop
choice /c ync /m "Do you wish to disable remote desktop? "
if %ERRORLEVEL% equ 3 goto:eof
if %ERRORLEVEL% equ 2 echo Skipping remote desktop...
if %ERRORLEVEL% equ 1 (
    echo ------------------------------------------------------------------------------------
    echo *** Disabling remote desktop...                                                  ***
    sc stop "TermService"
    sc config "TermService" start=disabled
    sc stop "SessionEnv"
    sc config "SessionEnv" start=disabled
    sc stop "UmRdpService"
    sc config "UmRdpService" start=disabled
    sc stop "RemoteRegistry"
    sc config "RemoteRegistry" start=disabled
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 1 /f
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v "fDenyTSConnections" /t REG_DWORD /d 1 /f
    echo *** Finished                                                                     ***
    echo ------------------------------------------------------------------------------------
    echo:
)

rem Registry keys
choice /c ync /m "Do you wish to manage registry keys? "
if %ERRORLEVEL% equ 3 goto:eof
if %ERRORLEVEL% equ 2 echo Skipping registry keys...
if %ERRORLEVEL% equ 1 (
    echo ------------------------------------------------------------------------------------
    echo *** Managing registry keys...                                                    ***
    reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU /v AutoInstallMinorUpdates /t REG_DWORD /d 1 /f
    reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU /v NoAutoUpdate /t REG_DWORD /d 0 /f
    reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU /v AUOptions /t REG_DWORD /d 4 /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v AUOptions /t REG_DWORD /d 4 /f
    reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /v DisableWindowsUpdateAccess /t REG_DWORD /d 0 /f
    reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /v ElevateNonAdmins /t REG_DWORD /d 0 /f
    reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer /v NoWindowsUpdate /t REG_DWORD /d 0 /f
    reg add "HKLM\SYSTEM\Internet Communication Management\Internet Communication" /v DisableWindowsUpdateAccess /t REG_DWORD /d 0 /f
    reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\WindowsUpdate /v DisableWindowsUpdateAccess /t REG_DWORD /d 0 /f
    echo Restrict CD ROM drive
    reg ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AllocateCDRoms /t REG_DWORD /d 1 /f
    echo Disallow remote access to floppy disks
    reg ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AllocateFloppies /t REG_DWORD /d 1 /f
    echo Disable auto Admin logon
    reg ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_DWORD /d 0 /f
    echo Clear page file, will take longer to shutdown
    reg ADD "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v ClearPageFileAtShutdown /t REG_DWORD /d 1 /f
    echo Prevent users from installing printer drivers 
    reg ADD "HKLM\SYSTEM\CurrentControlSet\Control\Print\Providers\LanMan Print Services\Servers" /v AddPrinterDrivers /t REG_DWORD /d 1 /f
    echo Add auditing to Lsass.exe
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\LSASS.exe" /v AuditLevel /t REG_DWORD /d 00000008 /f
    echo Enable LSA protection
    reg add HKLM\SYSTEM\CurrentControlSet\Control\Lsa /v RunAsPPL /t REG_DWORD /d 00000001 /f
    echo Limit use of blank passwords
    reg ADD HKLM\SYSTEM\CurrentControlSet\Control\Lsa /v LimitBlankPasswordUse /t REG_DWORD /d 1 /f
    echo Auditing access of Global System Objects
    reg ADD HKLM\SYSTEM\CurrentControlSet\Control\Lsa /v auditbaseobjects /t REG_DWORD /d 1 /f
    echo Auditing Backup and Restore
    reg ADD HKLM\SYSTEM\CurrentControlSet\Control\Lsa /v fullprivilegeauditing /t REG_DWORD /d 1 /f
    echo Restrict Anonymous Enumeration #1
    reg ADD HKLM\SYSTEM\CurrentControlSet\Control\Lsa /v restrictanonymous /t REG_DWORD /d 1 /f
    echo Restrict Anonymous Enumeration #2
    reg ADD HKLM\SYSTEM\CurrentControlSet\Control\Lsa /v restrictanonymoussam /t REG_DWORD /d 1 /f
    echo Disable storage of domain passwords
    reg ADD HKLM\SYSTEM\CurrentControlSet\Control\Lsa /v disabledomaincreds /t REG_DWORD /d 1 /f
    echo Take away Anonymous user Everyone permissions
    reg ADD HKLM\SYSTEM\CurrentControlSet\Control\Lsa /v everyoneincludesanonymous /t REG_DWORD /d 0 /f
    echo Allow Machine ID for NTLM
    reg ADD HKLM\SYSTEM\CurrentControlSet\Control\Lsa /v UseMachineId /t REG_DWORD /d 0 /f
    echo Do not display last user on logon
    reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v dontdisplaylastusername /t REG_DWORD /d 1 /f
    echo Enable UAC
    echo UAC setting, prompt on Secure Desktop
    reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v PromptOnSecureDesktop /t REG_DWORD /d 1 /f
    echo Enable Installer Detection
    reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableInstallerDetection /t REG_DWORD /d 1 /f
    echo Disable undocking without logon
    reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v undockwithoutlogon /t REG_DWORD /d 0 /f
    echo Enable CTRL+ALT+DEL
    reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v DisableCAD /t REG_DWORD /d 0 /f
    echo Max password age
    reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 1 /f
    reg ADD HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters /v MaximumPasswordAge /t REG_DWORD /d 15 /f
    echo Disable machine account password changes
    reg ADD HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters /v DisablePasswordChange /t REG_DWORD /d 1 /f
    echo Require strong session key
    reg ADD HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters /v RequireStrongKey /t REG_DWORD /d 1 /f
    echo Require Sign/Seal
    reg ADD HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters /v RequireSignOrSeal /t REG_DWORD /d 1 /f
    echo Sign Channel
    reg ADD HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters /v SignSecureChannel /t REG_DWORD /d 1 /f
    echo Seal Channel
    reg ADD HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters /v SealSecureChannel /t REG_DWORD /d 1 /f
    echo Set idle time to 45 minutes
    reg ADD HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters /v autodisconnect /t REG_DWORD /d 45 /f
    echo Require Security Signature - Disabled pursuant to checklist
    reg ADD HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters /v enablesecuritysignature /t REG_DWORD /d 0 /f
    echo Enable Security Signature - Disabled pursuant to checklist
    reg ADD HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters /v requiresecuritysignature /t REG_DWORD /d 0 /f
    echo Clear null session pipes
    reg ADD HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters /v NullSessionPipes /t REG_MULTI_SZ /d "" /f
    echo Restict Anonymous user access to named pipes and shares
    reg ADD HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters /v NullSessionShares /t REG_MULTI_SZ /d "" /f
    echo Encrypt SMB Passwords
    reg ADD HKLM\SYSTEM\CurrentControlSet\services\LanmanWorkstation\Parameters /v EnablePlainTextPassword /t REG_DWORD /d 0 /f
    echo Clear remote registry paths
    reg ADD HKLM\SYSTEM\CurrentControlSet\Control\SecurePipeServers\winreg\AllowedExactPaths /v Machine /t REG_MULTI_SZ /d "" /f
    echo Clear remote registry paths and sub-paths
    reg ADD HKLM\SYSTEM\CurrentControlSet\Control\SecurePipeServers\winreg\AllowedPaths /v Machine /t REG_MULTI_SZ /d "" /f
    echo Enable smart screen for IE8
    reg ADD "HKCU\Software\Microsoft\Internet Explorer\PhishingFilter" /v EnabledV8 /t REG_DWORD /d 1 /f
    echo Enable smart screen for IE9 and up
    reg ADD "HKCU\Software\Microsoft\Internet Explorer\PhishingFilter" /v EnabledV9 /t REG_DWORD /d 1 /f
    echo Disable IE password caching
    reg ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v DisablePasswordCaching /t REG_DWORD /d 1 /f
    echo Warn users if website has a bad certificate
    reg ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v WarnonBadCertRecving /t REG_DWORD /d 1 /f
    echo Warn users if website redirects
    reg ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v WarnOnPostRedirect /t REG_DWORD /d 1 /f
    echo Enable Do Not Track
    reg ADD "HKCU\Software\Microsoft\Internet Explorer\Main" /v DoNotTrack /t REG_DWORD /d 1 /f
    reg ADD "HKCU\Software\Microsoft\Internet Explorer\Download" /v RunInvalidSignatures /t REG_DWORD /d 1 /f
    reg ADD "HKCU\Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_LOCALMACHINE_LOCKDOWN\Settings" /v LOCALMACHINE_CD_UNLOCK /t REG_DWORD /d 1 /f
    reg ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v WarnonZoneCrossing /t REG_DWORD /d 1 /f
    echo Show hidden files
    reg ADD HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v Hidden /t REG_DWORD /d 1 /f
    echo Disable sticky keys
    reg ADD "HKU\.DEFAULT\Control Panel\Accessibility\StickyKeys" /v Flags /t REG_SZ /d 506 /f
    echo Show super hidden files
    reg ADD HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v ShowSuperHidden /t REG_DWORD /d 1 /f
    echo Disable dump file creation
    reg ADD HKLM\SYSTEM\CurrentControlSet\Control\CrashControl /v CrashDumpEnabled /t REG_DWORD /d 0 /f
    echo Disable autoruns
    reg ADD HKCU\SYSTEM\CurrentControlSet\Services\CDROM /v AutoRun /t REG_DWORD /d 1 /f
    echo *** Finished                                                                     ***
    echo ------------------------------------------------------------------------------------
    echo:
)

rem Import Policies
choice /c ync /m "Do you wish to import GPOs? "
if %ERRORLEVEL% equ 3 goto:eof
if %ERRORLEVEL% equ 2 echo Skipping GPOs...
if %ERRORLEVEL% equ 1 (
    echo ------------------------------------------------------------------------------------
    echo *** Importing policies from policies folder...                                   ***
    .\LGPO.exe /g .\Policies /v
    echo *** Finished                                                                     ***
    echo ------------------------------------------------------------------------------------
    echo:
)

rem User Audit
choice /c ync /m "Do you wish to perform a user audit? This includes changing passwords of every user and removing all users not in authorizedusers.txt. "
if %ERRORLEVEL% equ 3 goto:eof
if %ERRORLEVEL% equ 2 echo Skipping user audit...
if %ERRORLEVEL% equ 1 (
    echo ------------------------------------------------------------------------------------
    echo *** Performing user audit...                                                     ***
    Rem Change passwords of all users
    echo Changing password of every user to "q1W@e3R$t5Y^u7I*o9"
    for /f "delims=" %%a in ('cscript //NoLogo .\GetLocalUsers.vbs') do (
        if !USERNAME! equ %%a (
            echo Skipping current user %%a...
            echo:
        ) else (
            echo Changing password of %%a...
            net user %%a q1W@e3R$t5Y^u7I*o9
        )
    )

    Rem Populate array of users in file
    ::echo Reading authorizedusers.txt for authorized users...
    ::set /a i = 0
    ::for /f "tokens=*" %%a in (authorizedusers.txt) do (
    ::    set /a i += 1
    ::    echo !i!
    ::    set authusers[!i!]=%%a
    ::)
    ::set /a total=!i!
    ::for /l %%i in (1,1,!total!) do echo !authusers[%%i]!
    echo *** Finished                                                                     ***
    echo ------------------------------------------------------------------------------------
    echo:
)
pause