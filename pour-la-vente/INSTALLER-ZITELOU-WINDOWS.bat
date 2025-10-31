@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM ═══════════════════════════════════════════════════════════════════════
REM   INSTALLATEUR ZITELOU POUR WINDOWS
REM   Installation automatique sur téléphone Android
REM ═══════════════════════════════════════════════════════════════════════

title Installation Zitelou
color 0B

echo.
echo ╔═══════════════════════════════════════════════════════════════════╗
echo ║                                                                   ║
echo ║                   INSTALLATION ZITELOU                            ║
echo ║           Installation automatique sur votre téléphone            ║
echo ║                                                                   ║
echo ╚═══════════════════════════════════════════════════════════════════╝
echo.
echo.

REM Configuration
set "APK_NAME=zitelou.apk"
set "PACKAGE_NAME=org.jufam.kidlauncher"
set "DEVICE_ADMIN=MyDeviceAdminReceiver"
set "MAIN_ACTIVITY=com.zitelou.ui.KidHomeActivity"
set "ADB_URL=https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
set "TEMP_DIR=%TEMP%\zitelou-install"

REM ═══════════════════════════════════════════════════════════════════════
REM ÉTAPE 1 : Vérifications préliminaires
REM ═══════════════════════════════════════════════════════════════════════

echo ┌───────────────────────────────────────────────────────────────────┐
echo │ ÉTAPE 1/6 : Vérifications préliminaires                          │
echo └───────────────────────────────────────────────────────────────────┘
echo.

REM Vérifier que l'APK existe
if not exist "%~dp0%APK_NAME%" (
    echo ❌ ERREUR : Le fichier %APK_NAME% est introuvable !
    echo.
    echo 💡 Assurez-vous que le fichier "%APK_NAME%" est bien dans
    echo    le même dossier que ce script.
    echo.
    pause
    exit /b 1
)

echo ✅ Fichier APK trouvé : %APK_NAME%
echo.

REM ═══════════════════════════════════════════════════════════════════════
REM ÉTAPE 2 : Installation d'ADB (si nécessaire)
REM ═══════════════════════════════════════════════════════════════════════

echo ┌───────────────────────────────────────────────────────────────────┐
echo │ ÉTAPE 2/6 : Installation des outils Android (ADB)                │
echo └───────────────────────────────────────────────────────────────────┘
echo.

REM Vérifier si ADB est déjà installé
where adb >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ✅ ADB est déjà installé sur votre ordinateur
    set "ADB_CMD=adb"
) else (
    echo ⚠️  ADB n'est pas installé. Téléchargement en cours...
    echo.
    
    REM Créer un dossier temporaire
    if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"
    
    REM Télécharger ADB avec PowerShell
    echo    📥 Téléchargement d'ADB depuis Google...
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%ADB_URL%' -OutFile '%TEMP_DIR%\platform-tools.zip'}" >nul 2>&1
    
    if !ERRORLEVEL! NEQ 0 (
        echo    ❌ Échec du téléchargement d'ADB
        echo.
        echo    💡 Vérifiez votre connexion internet et réessayez.
        echo.
        pause
        exit /b 1
    )
    
    echo    ✅ Téléchargement terminé
    echo    📦 Extraction des fichiers...
    
    REM Extraire ADB
    powershell -Command "& {Expand-Archive -Path '%TEMP_DIR%\platform-tools.zip' -DestinationPath '%TEMP_DIR%' -Force}" >nul 2>&1
    
    if !ERRORLEVEL! NEQ 0 (
        echo    ❌ Échec de l'extraction
        pause
        exit /b 1
    )
    
    echo    ✅ ADB installé avec succès
    set "ADB_CMD=%TEMP_DIR%\platform-tools\adb.exe"
)

echo.

REM ═══════════════════════════════════════════════════════════════════════
REM ÉTAPE 3 : Vérification du téléphone
REM ═══════════════════════════════════════════════════════════════════════

echo ┌───────────────────────────────────────────────────────────────────┐
echo │ ÉTAPE 3/6 : Connexion au téléphone Android                       │
echo └───────────────────────────────────────────────────────────────────┘
echo.

echo 📱 Vérification de la connexion au téléphone...
echo.

REM Tuer le serveur ADB existant et en démarrer un nouveau
"%ADB_CMD%" kill-server >nul 2>&1
"%ADB_CMD%" start-server >nul 2>&1

REM Attendre 2 secondes
timeout /t 2 /nobreak >nul

REM Vérifier les appareils connectés
"%ADB_CMD%" devices | findstr /R "device$" >nul 2>&1

if %ERRORLEVEL% NEQ 0 (
    echo ❌ AUCUN TÉLÉPHONE DÉTECTÉ !
    echo.
    echo ⚠️  VÉRIFIEZ CES POINTS :
    echo.
    echo    1. Le téléphone est connecté en USB à l'ordinateur
    echo    2. Le câble USB fonctionne (pas seulement pour la charge)
    echo    3. Le "Débogage USB" est activé sur le téléphone
    echo    4. Sur le téléphone, acceptez la popup "Autoriser le débogage USB"
    echo.
    echo 💡 COMMENT ACTIVER LE DÉBOGAGE USB :
    echo.
    echo    → Allez dans Paramètres ^> À propos du téléphone
    echo    → Tapez 7 fois sur "Numéro de build"
    echo    → Retournez dans Paramètres ^> Options pour les développeurs
    echo    → Activez "Débogage USB"
    echo.
    pause
    exit /b 1
)

echo ✅ Téléphone Android détecté et connecté !
echo.

REM ═══════════════════════════════════════════════════════════════════════
REM ÉTAPE 4 : Vérification que le téléphone est vierge
REM ═══════════════════════════════════════════════════════════════════════

echo ┌───────────────────────────────────────────────────────────────────┐
echo │ ÉTAPE 4/6 : Vérification de l'état du téléphone                  │
echo └───────────────────────────────────────────────────────────────────┘
echo.

echo ⚠️  IMPORTANT : Pour que Zitelou fonctionne correctement,
echo    le téléphone doit être RÉINITIALISÉ (paramètres d'usine)
echo    et AUCUN compte Google ne doit être configuré.
echo.
echo 💡 COMMENT RÉINITIALISER LE TÉLÉPHONE :
echo.
echo    → Paramètres ^> Système ^> Options de réinitialisation
echo    → "Effacer toutes les données" (Factory Reset)
echo    → Au redémarrage, configurez la langue et le Wi-Fi
echo    → NE PAS ajouter de compte Google !
echo.

set /p "confirm=❓ Le téléphone a-t-il été réinitialisé et vierge (sans compte) ? (O/N) : "

if /i not "%confirm%"=="O" if /i not "%confirm%"=="Oui" (
    echo.
    echo ❌ Veuillez réinitialiser le téléphone avant de continuer.
    echo.
    pause
    exit /b 1
)

echo.
echo ✅ Parfait ! Continuation de l'installation...
echo.

REM ═══════════════════════════════════════════════════════════════════════
REM ÉTAPE 5 : Installation de l'application Zitelou
REM ═══════════════════════════════════════════════════════════════════════

echo ┌───────────────────────────────────────────────────────────────────┐
echo │ ÉTAPE 5/6 : Installation de l'application Zitelou                │
echo └───────────────────────────────────────────────────────────────────┘
echo.

echo 📦 Installation de Zitelou sur le téléphone...
echo    (Cela peut prendre quelques secondes)
echo.

"%ADB_CMD%" install -r "%~dp0%APK_NAME%" >nul 2>&1

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Échec de l'installation de l'application
    echo.
    echo 💡 Essayez de désinstaller l'ancienne version si elle existe :
    echo.
    "%ADB_CMD%" uninstall %PACKAGE_NAME% >nul 2>&1
    echo    → Ancienne version désinstallée (si elle existait)
    echo    → Nouvelle tentative d'installation...
    echo.
    "%ADB_CMD%" install -r "%~dp0%APK_NAME%"
    
    if !ERRORLEVEL! NEQ 0 (
        echo.
        echo ❌ L'installation a échoué. Contactez le support.
        pause
        exit /b 1
    )
)

echo ✅ Application Zitelou installée avec succès !
echo.

REM ═══════════════════════════════════════════════════════════════════════
REM ÉTAPE 6 : Configuration du contrôle parental (Device Owner)
REM ═══════════════════════════════════════════════════════════════════════

echo ┌───────────────────────────────────────────────────────────────────┐
echo │ ÉTAPE 6/6 : Configuration du contrôle parental                   │
echo └───────────────────────────────────────────────────────────────────┘
echo.

echo 🔒 Activation du contrôle parental Zitelou...
echo.

"%ADB_CMD%" shell dpm set-device-owner %PACKAGE_NAME%/.%DEVICE_ADMIN% >nul 2>&1

if %ERRORLEVEL% NEQ 0 (
    echo ⚠️  Le mode de contrôle parental n'a pas pu être activé.
    echo.
    echo    Cela peut arriver si :
    echo    • Un compte Google est configuré sur le téléphone
    echo    • Le téléphone n'a pas été réinitialisé correctement
    echo.
    echo 💡 SOLUTION :
    echo    1. Réinitialisez complètement le téléphone
    echo    2. Ne configurez AUCUN compte (Google, Samsung, etc.)
    echo    3. Relancez ce script
    echo.
    
    set /p "continue=❓ Voulez-vous continuer sans le mode contrôle parental ? (O/N) : "
    
    if /i not "!continue!"=="O" if /i not "!continue!"=="Oui" (
        echo.
        echo ❌ Installation annulée.
        pause
        exit /b 1
    )
    
    echo.
    echo ⚠️  Installation sans contrôle parental complet.
    echo    L'enfant pourra potentiellement quitter l'application.
    echo.
) else (
    echo ✅ Contrôle parental activé avec succès !
    echo.
    
    REM Attribution des permissions
    echo 🔐 Attribution des permissions nécessaires...
    "%ADB_CMD%" shell pm grant %PACKAGE_NAME% android.permission.CALL_PHONE >nul 2>&1
    "%ADB_CMD%" shell pm grant %PACKAGE_NAME% android.permission.READ_CONTACTS >nul 2>&1
    "%ADB_CMD%" shell pm grant %PACKAGE_NAME% android.permission.CAMERA >nul 2>&1
    echo ✅ Permissions accordées
    echo.
    
    REM Définir comme launcher par défaut
    echo 🏠 Configuration du launcher par défaut...
    "%ADB_CMD%" shell pm set-home-activity %PACKAGE_NAME%/%MAIN_ACTIVITY% >nul 2>&1
    echo ✅ Zitelou défini comme écran d'accueil
    echo.
)

REM Lancer l'application
echo 🚀 Lancement de Zitelou...
"%ADB_CMD%" shell am start -n %PACKAGE_NAME%/%MAIN_ACTIVITY% >nul 2>&1
echo.

REM ═══════════════════════════════════════════════════════════════════════
REM INSTALLATION TERMINÉE !
REM ═══════════════════════════════════════════════════════════════════════

echo.
echo ╔═══════════════════════════════════════════════════════════════════╗
echo ║                                                                   ║
echo ║              🎉 INSTALLATION TERMINÉE AVEC SUCCÈS ! 🎉           ║
echo ║                                                                   ║
echo ╚═══════════════════════════════════════════════════════════════════╝
echo.
echo ✅ Zitelou est maintenant installé sur le téléphone !
echo.
echo 📱 PROCHAINES ÉTAPES SUR LE TÉLÉPHONE :
echo.
echo    1. L'application Zitelou s'ouvre automatiquement
echo    2. Créez votre compte parent avec votre email
echo    3. Définissez un code PIN à 4 chiffres (gardez-le bien !)
echo    4. Ajoutez les contacts autorisés (famille, amis)
echo    5. Sélectionnez les applications que l'enfant peut utiliser
echo.
echo 🎊 Le téléphone est maintenant sécurisé pour votre enfant !
echo.
echo 💡 CONSEILS :
echo.
echo    • Gardez votre code PIN parent en sécurité
echo    • Vous pouvez modifier les paramètres en appuyant longuement
echo      sur l'écran d'accueil et en entrant votre code PIN
echo    • Les numéros d'urgence (pompiers, police) restent toujours
echo      accessibles même sans contact autorisé
echo.
echo 📞 BESOIN D'AIDE ?
echo.
echo    → Support : support@zitelou.com
echo    → Site web : www.zitelou.com
echo.
echo.

REM Nettoyage
if exist "%TEMP_DIR%" (
    rd /s /q "%TEMP_DIR%" >nul 2>&1
)

echo Appuyez sur une touche pour fermer cette fenêtre...
pause >nul

exit /b 0
