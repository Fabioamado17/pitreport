@echo off

:: Ler versao do pubspec.yaml via PowerShell
for /f "delims=" %%v in ('powershell -NoProfile -Command "(Select-String -Path pubspec.yaml -Pattern '^version:').Line -replace '^version:\s*','' "') do set APP_VERSION=%%v

if "%APP_VERSION%"=="" (
    echo ERRO: Nao foi possivel ler a versao do pubspec.yaml.
    exit /b 1
)

echo Versao: %APP_VERSION%
echo A compilar APK release...

flutter build apk --release

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    set APK_NAME=pitreport-%APP_VERSION%.apk
    copy /Y "build\app\outputs\flutter-apk\app-release.apk" "build\app\outputs\flutter-apk\%APK_NAME%"
    echo.
    echo APK disponivel em: build\app\outputs\flutter-apk\%APK_NAME%
    powershell -NoProfile -Command "Invoke-Item '%~dp0build\app\outputs\flutter-apk'"
) else (
    echo Build falhou ou APK nao encontrado.
    exit /b 1
)
