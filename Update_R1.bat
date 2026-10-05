@echo off
setlocal EnableExtensions enabledelayedexpansion
cd /d "%~dp0"
mode con lines=30 cols=90
title Update Phicomm R1 v5.1.3

set "APK_OTA=new_EchoService.apk"
set "APK_DLNA=autodlna.apk"
set "APK_UNI=unisound.apk"
set "APK_AI=ai-box-plus-5-1-3.apk"
set "DEFAULT_IP=192.168.43.1"

for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "ESC=%%b"

set "IP="
set "SERIAL="
set "ver="
set "ipaddress="
set "hostname="
set "r1="
set "IP_RETRY="
set "MAX_RETRY="

:menu
cls
echo.
echo Update cho loa Phicomm R1 All in One - AI-BOX-PLUS.COM
echo.
echo Mua loa hoac can ho tro vui long lien he Hoang Quang Minh
echo SDT/Zalo: %ESC%[33m039.737.5555%ESC%[0m
echo Facebook: %ESC%[33mhttps://www.facebook.com/quang.minh97/%ESC%[0m
echo Tron bo Video huong dan chi tiet ve loa Phicomm R1:
echo %ESC%[33mhttps://www.youtube.com/playlist?list=PLK-7C8xPvBXDHc2isS4tO023dCYNNry8g%ESC%[0m
echo.
echo ------------------------------------------------------------------
echo Vui long chon reset loa ve cai dat goc truoc khi tien hanh cai dat
echo HD reset loa xem tai: %ESC%[33mhttps://youtu.be/d09fAdcn2qs%ESC%[0m
echo.
echo Vui long chon
echo 1. Kiem tra va cap nhat Firmware loa
echo 2. Kiem tra IP cua loa
echo 3. Cai dat Auto DLNA + Unisound + AI Tieng Viet
echo 4. Exit
echo ------------------------------------------------------------------
echo.
set "choice="
set /p "choice=Chon thao tac ban muon thuc hien %ESC%[33m(1-4)%ESC%[0m: "
if not defined choice goto menu
set "choice=%choice:~0,1%"

if /I "%choice%"=="1" goto check_update_fw
if /I "%choice%"=="2" goto check_ip
if /I "%choice%"=="3" goto install_ai
if /I "%choice%"=="4" goto exit

echo.
echo %ESC%[31mLua chon khong hop le, vui long chon lai!%ESC%[0m
timeout /t 1 >nul
goto menu

:check_update_fw
call :connect_retry "%DEFAULT_IP%" 3 || (
	cls
	echo.
	echo Vui long an va giu nut tron tren loa 6 giay de bat phat wifi cua loa!
	echo.
	echo Sau do ket noi wifi cua may tinh nay voi Wifi Phicomm_R1_... va thu lai!
	echo.
	echo Vui long xem video huong dan that ky tai %ESC%[33mhttps://youtu.be/AYQd2xn_-m0%ESC%[0m
	pause >nul
	goto menu
)
call :device_info
cls
echo.
echo --------------------------------------------
echo        Kiem tra Firmware loa hien tai
echo --------------------------------------------
echo.
if "%hostname%" neq "" echo Device name: %hostname%
if "%ver%" neq "" echo Firmware version: %ver%
if "%ipaddress%" neq "" echo Device IP: %ipaddress%
echo.
set "need_update="
set "ver_num=%ver%"
set "ver_not_num="
for /f "delims=0123456789" %%x in ("%ver_num%") do set "ver_not_num=1"
if not defined ver_not_num if defined ver_num (
  if %ver_num% gtr 2999 if not "%ver_num%"=="3448" (
    if /i "%r1%"=="true" set "need_update=1"
  )
)
if defined need_update goto r1_low_ver
if "%ver%"=="3448" goto update_not

:r1_low_ver
if exist "ota\ota-%ver%.txt" if exist "firmware\incremental-ota-%ver%.zip" (
	echo Phien ban firmware R1 %ver% cua ban khong phai phien ban moi nhat. Ban co the nang cap Firmware bang cong cu nay!
	echo.
	echo Nhan phim bat ky de cap nhat Firmware!
	pause >nul
	goto update
)
echo Khong tim thay goi update cho version %ver% (ota\ota-%ver%.txt va firmware\incremental-ota-%ver%.zip).
echo.
pause >nul
goto menu

:update
cls
echo.
echo --------------------------------------------
echo          Cap nhat Firmware cho loa
echo --------------------------------------------
echo.
echo Dang xoa bo nho dem truoc khi cai dat...
adb -s "%SERIAL%" shell rm /sdcard/otaprop.txt >nul 2>&1
adb -s "%SERIAL%" shell rm /sdcard/incremental*.zip >nul 2>&1
adb -s "%SERIAL%" shell rm -rf /data/local/tmp/* >nul 2>&1
adb -s "%SERIAL%" shell /system/bin/pm clear com.phicomm.speaker.otaservice >nul 2>&1
adb -s "%SERIAL%" shell settings put secure install_non_market_apps 1 >nul 2>&1
call :require_file "%APK_OTA%" || goto menu
call :require_file "firmware\incremental-ota-%ver%.zip" || goto menu
call :require_file "ota\ota-%ver%.txt" || goto menu
echo.
echo Bat dau tai len %APK_OTA%...
call :push_or_fail "%APK_OTA%" "/data/local/tmp/%APK_OTA%" || goto menu
echo.
echo Cai dat %APK_OTA%...
call :install_or_fail "/data/local/tmp/%APK_OTA%" || goto menu
adb -s "%SERIAL%" shell rm "/data/local/tmp/%APK_OTA%" >nul 2>&1
adb -s "%SERIAL%" shell am startservice com.phicomm.speaker.player/.EchoService >nul 2>&1
echo.
echo Bat dau tai len firmware...
call :push_or_fail "firmware\incremental-ota-%ver%.zip" "/sdcard/incremental-ota-%ver%.zip" || goto menu
echo.
echo Bat dau tai len cau hinh OTA...
call :push_or_fail "ota\ota-%ver%.txt" "/sdcard/otaprop.txt" || goto menu
echo.
echo Tai len thanh cong! Dang reboot loa...
adb -s "%SERIAL%" reboot >nul 2>&1
timeout /t 1 /nobreak >nul
cls
echo.
echo %ESC%[33mLoa dang khoi dong lai. Vui long cau hinh Wifi lai cho loa de bat dau update%ESC%[0m
echo.
echo HD cau hinh Wifi cho loa bang may tinh: %ESC%[33mhttps://youtu.be/71aPeIQm55o%ESC%[0m
echo.Hoac
echo HD cau hinh Wifi cho loa bang iPhone: %ESC%[33mhttps://youtu.be/i8w8kkx9cPk%ESC%[0m
echo.Hoac
echo HD cau hinh Wifi cho loa bang Android: %ESC%[33mhttps://youtu.be/2-vT8Q1cSa8%ESC%[0m
echo.
echo %ESC%[31mLUU Y: Neu cau hinh wifi cho loa bang may tinh bi loi hay su dung dien thoai de cau hinh Wifi%ESC%[0m
echo.
echo %ESC%[31mQUAN TRONG: Neu khong cau hinh wifi lai cho loa thi se khong UPDATE FIRMWARE duoc nhe%ESC%[0m
echo.
echo Nhan phim bat ky de quay lai menu!
pause >nul
goto menu

:update_not
echo Phien ban firmware %ver% cua ban dang la moi nhat, khong can nang cap firmware!
echo.
echo Nhan phim bat ky de quay lai menu!
pause >nul
goto menu

:check_ip
call :connect_retry "%DEFAULT_IP%" 3 || (
	cls
	echo.
	echo Vui long an va giu nut tron tren loa 6 giay de bat phat wifi cua loa!
	echo.
	echo Sau do ket noi wifi cua may tinh nay voi Wifi Phicomm_R1_... va thu lai!
	pause >nul
	goto menu
)
call :device_info
cls
echo.
echo --------------------------------------------
echo        Kiem tra IP cua loa trong mang
echo --------------------------------------------
echo.
if "%ipaddress%" neq "" (
    echo IP cua loa la: %ipaddress%
	adb -s "%SERIAL%" reboot >nul 2>&1
	timeout /t 1 /nobreak >nul
	echo.
	echo Nhan phim bat ky de quay lai menu va sau do bam phim 3 de bat dau cai dat AI tieng Viet
) ELSE (
	echo %ESC%[31mChua tim thay IP loa%ESC%[0m
	echo.
    echo Loa chua duoc cau hinh Wifi hoac cau hinh Wifi cho loa bi loi!
	echo.
	echo Vui long thuc hien cau hinh mang wifi lai cho loa!
	echo.
	echo HD cau hinh Wifi cho loa bang may tinh: %ESC%[33mhttps://youtu.be/71aPeIQm55o%ESC%[0m
	echo.Hoac
	echo HD cau hinh Wifi cho loa bang iPhone: %ESC%[33mhttps://youtu.be/i8w8kkx9cPk%ESC%[0m
	echo.Hoac
	echo HD cau hinh Wifi cho loa bang Android: %ESC%[33mhttps://youtu.be/2-vT8Q1cSa8%ESC%[0m
	echo.
	echo %ESC%[31mLUU Y: Neu cau hinh wifi cho loa bang may tinh bi loi hay su dung dien thoai de cau hinh Wifi%ESC%[0m
	echo.
	echo Nhan phim bat ky de quay lai menu va thu lai
)
pause >nul
goto menu

:install_ai
if "%ipaddress%" neq "" (
	echo.
    echo Da tim thay IP loa: %ipaddress% , nhan phim bat ky de bat dau cai dat...
	pause >nul
) ELSE (
	cls
	echo.
	echo %ESC%[31mChua tim thay IP loa%ESC%[0m
	echo.
	echo HAY XEM KY VIDEO HUONG DAN CAI DAT TRUOC KHI LAM
	echo.
	echo %ESC%[33mVideo HD: https://youtu.be/hACTHZDilEw%ESC%[0m
	echo.
    echo Nhan phim bat ky de quay lai menu va thuc hien kiem tra IP cua loa theo huong dan trong video...
	pause >nul
	goto menu
)
call :connect_retry "%ipaddress%" 5 || (
	cls
	echo.
	echo %ESC%[33mLoi, hay xem that ky video huong dan va thu lai%ESC%[0m
	echo.
	echo %ESC%[33mVideo HD: https://youtu.be/hACTHZDilEw%ESC%[0m
	pause >nul
	goto menu
)
set "LAST_IP=%IP%"
cls
echo.
echo -------------------------------------------------------
echo      Cai dat Auto DLNA + Unisound + AI Tieng Viet
echo -------------------------------------------------------
call :require_file "%APK_DLNA%" || goto menu
call :require_file "%APK_UNI%"  || goto menu
call :require_file "%APK_AI%"   || goto menu
echo.
echo Dang xoa bo nho dem truoc khi cai dat...
adb -s "%SERIAL%" shell rm /sdcard/otaprop.txt >nul 2>&1
adb -s "%SERIAL%" shell rm /sdcard/incremental*.zip >nul 2>&1
adb -s "%SERIAL%" shell /system/bin/pm clear com.phicomm.speaker.otaservice >nul 2>&1
adb -s "%SERIAL%" shell rm -rf /data/local/tmp/* >nul 2>&1
adb -s "%SERIAL%" shell settings put secure install_non_market_apps 1 >nul 2>&1
echo.
echo Tat cac ung dung khong can thiet tren loa...
adb -s "%SERIAL%" shell /system/bin/pm hide com.phicomm.speaker.airskill
adb -s "%SERIAL%" shell /system/bin/pm hide com.phicomm.speaker.exceptionreporter
adb -s "%SERIAL%" shell /system/bin/pm hide com.phicomm.speaker.systemtool
adb -s "%SERIAL%" shell /system/bin/pm hide com.phicomm.speaker.device
adb -s "%SERIAL%" shell /system/bin/pm hide com.phicomm.speaker.otaservice
adb -s "%SERIAL%" shell /system/bin/pm hide com.phicomm.speaker.productiontest
adb -s "%SERIAL%" shell /system/bin/pm hide com.phicomm.speaker.bugreport
echo.
echo Dang tai AutoDLNA + Unisound...
call :push_or_fail "%APK_DLNA%" "/data/local/tmp/%APK_DLNA%" || goto menu
call :push_or_fail "%APK_UNI%"  "/data/local/tmp/%APK_UNI%"  || goto menu
echo.
echo Dang cai dat AutoDLNA + Unisound...
call :install_or_fail "/data/local/tmp/%APK_DLNA%" || goto menu
call :install_or_fail "/data/local/tmp/%APK_UNI%"  || goto menu
adb -s "%SERIAL%" shell rm "/data/local/tmp/%APK_DLNA%" >nul 2>&1
adb -s "%SERIAL%" shell rm "/data/local/tmp/%APK_UNI%"  >nul 2>&1
echo.
echo Dang khoi dong AutoDLNA + Unisound...
adb -s "%SERIAL%" shell am startservice com.phicomm.speaker.player/.EchoService >nul 2>&1
adb -s "%SERIAL%" shell am start com.phicomm.speaker.device/.ui.MainActivity >nul 2>&1
echo.
echo Cai dat AI tro ly ao Tieng Viet sau 3s nua...
timeout /t 3 /nobreak >nul
cls
echo.
echo ---------------------------------------------
echo        Cai dat AI tro ly ao Tieng Viet
echo ---------------------------------------------
echo.
echo Khoi phuc ung dung can thiet...
adb -s "%SERIAL%" shell /system/bin/pm unhide com.phicomm.speaker.ijetty
adb -s "%SERIAL%" shell /system/bin/pm unhide com.phicomm.speaker.netctl
echo.
echo Dang go cai dat phien ban AI cu...
adb -s "%SERIAL%" shell /system/bin/pm uninstall info.dourok.voicebot >nul 2>&1
echo.
echo Dang tai AI vao loa...
call :push_or_fail "%APK_AI%" "/data/local/tmp/%APK_AI%" || goto menu
echo.
echo Dang cai dat AI...
call :install_or_fail "/data/local/tmp/%APK_AI%" || goto menu
adb -s "%SERIAL%" shell rm "/data/local/tmp/%APK_AI%" >nul 2>&1
echo.
echo Dang khoi dong AI Tro ly ao tieng Viet...
adb -s "%SERIAL%" shell am start -n info.dourok.voicebot/.java.activities.MainActivity >nul 2>&1
timeout /t 5 /nobreak >nul
echo.
echo ------------------------------------------------------------------------
echo       Truy cap vao trang Xiaozhi.me de nhap ma 6 so va cau hinh AI
echo  Neu ban da tung cau hinh AI vui long an phim bat ky de bo qua buoc nay
echo ------------------------------------------------------------------------
timeout /t 2 /nobreak >nul
echo.
echo Nhan phim bat ky de khoi dong lai loa!
pause >nul
adb -s "%SERIAL%" reboot >nul 2>&1
cls
echo.
echo --------------------------
echo     CAI DAT HOAN TAT!
echo --------------------------
echo.
echo Vui long doi loa khoi dong hoan tat!
echo.
if "%ipaddress%" neq "" (
  echo Truy cap dia chi %ipaddress%:8081 de vao bang dieu khien loa va trai nghiem!
) else (
  echo Truy cap IP cua loa:8081 de vao bang dieu khien loa va trai nghiem!
)
echo.
echo HDSD bang dieu khien loa xem tai: %ESC%[33mhttps://youtu.be/a1LVovG5Kys%ESC%[0m
echo.
echo Tron bo Video huong dan chi tiet ve loa Phicomm R1:
echo %ESC%[33mhttps://www.youtube.com/playlist?list=PLK-7C8xPvBXDHc2isS4tO023dCYNNry8g%ESC%[0m
echo.
echo Cam on ban da su dung!
echo.
echo Mua loa Phicomm R1 vui long lien he Hoang Quang Minh
echo Facebook: %ESC%[33mhttps://www.facebook.com/quang.minh97/%ESC%[0m
echo SDT/Zalo: %ESC%[33m039.737.5555%ESC%[0m
echo Nhom Zalo ho tro: %ESC%[33mhttps://zalo.me/g/jwmnrx884%ESC%[0m
echo.
echo Cai dat xong, nhan phim bat ky de thoat!
pause >nul
endlocal
exit

:exit
endlocal
exit

:connect_retry
call :require_adb || exit /b 1
set "IP_RETRY=%~1"
set "MAX_RETRY=%~2"
if not defined MAX_RETRY set "MAX_RETRY=3"
if not defined IP_RETRY exit /b 1
set /a "CRT_N=0"

:connect_retry_loop
set /a "CRT_N+=1"
echo.
echo %ESC%[33m[Ket noi] Thu lan thu !CRT_N!/%MAX_RETRY% %ESC%[0m
call :connect %IP_RETRY%
if not errorlevel 1 exit /b 0
if !CRT_N! LSS %MAX_RETRY% (
  echo %ESC%[33mKet noi that bai, se thu lai sau 1 giay...%ESC%[0m
  timeout /t 1 >nul
  goto connect_retry_loop
)
exit /b 1

:connect
call :require_adb || exit /b 1
set "IP=%~1"
if not defined IP exit /b 1
set "SERIAL=%IP%:5555"
echo Bat dau ket noi thiet bi [%SERIAL%]...
call :adb_reset
adb connect "%SERIAL%" >nul 2>&1
set "STATE="
for /f "usebackq delims=" %%i in (`adb -s "%SERIAL%" get-state 2^>nul`) do set "STATE=%%i"
if /I not "!STATE!"=="device" (
  call :Warn "Ket noi that bai (ADB chua thay thiet bi). Hay kiem tra lai ket noi va thu lai!"
  exit /b 1
)
adb -s "%SERIAL%" shell ls >nul 2>&1
if errorlevel 1 (
  call :Warn "adb shell bi loi (co the 'unauthorized' / mat ket noi). Hay thu ket noi lai!"
  exit /b 1
)
echo Ket noi thanh cong!
exit /b 0

:device_info
set "ver="
set "ipaddress="
set "hostname="
set "r1="
for /f "usebackq delims=" %%i in (`adb -s "%SERIAL%" shell getprop ro.build.version.incremental 2^>nul`) do set "ver=%%i"
for /f "usebackq delims=" %%i in (`adb -s "%SERIAL%" shell getprop dhcp.wlan0.ipaddress 2^>nul`) do set "ipaddress=%%i"
for /f "usebackq delims=" %%i in (`adb -s "%SERIAL%" shell getprop net.hostname 2^>nul`) do set "hostname=%%i"
for /f "usebackq delims=" %%i in (`adb -s "%SERIAL%" shell getprop ro.build.host 2^>nul`) do set "build_host=%%i"
for /f "usebackq delims=" %%i in (`adb -s "%SERIAL%" shell getprop ro.product.model 2^>nul`) do set "build_model=%%i"
if /I "%build_host%"=="phicomm" if /I "%build_model%"=="rk322x-box" set "r1=true"
exit /b 0

:push_or_fail
adb -s "%SERIAL%" push "%~1" "%~2"
if errorlevel 1 (
  call :fail "Tai file len that bai: %~1"
  exit /b 1
)
exit /b 0

:install_or_fail
adb -s "%SERIAL%" shell /system/bin/pm install -r "%~1"
if errorlevel 1 (
  call :fail "Cai dat that bai: %~1"
  exit /b 1
)
exit /b 0

:Warn
echo %ESC%[31m%~1%ESC%[0m
timeout /t 1 >nul
exit /b 0

:adb_reset
taskkill /f /t /im adb.exe >nul 2>&1
adb kill-server >nul 2>&1
adb start-server >nul 2>&1
timeout /t 1 /nobreak >nul
exit /b 0

:require_adb
if exist "adb.exe" exit /b 0
call :adb_not_found

:require_file
if exist "%~1" exit /b 0
call :fail "Khong tim thay file: %~1"
exit /b 1

:fail
cls
color 04
echo.
echo %~1
pause >nul
exit /b 0

:adb_not_found
cls
color 04
echo.
echo Khong tim thay file adb, hay giai nen toan bo thu muc cai dat va chay lai file Update_R1 trong thu muc da giai nen!
pause >nul
exit