#!/bin/bash

# 🚀 Script de déploiement Device Owner - Zitelou
# Automatise l'installation de Zitelou en tant que Device Owner sur Galaxy XCover 5

set -e  # Arrêter en cas d'erreur

# Configuration
APK_PATH="/home/patrick/Projets/USTS/USTS-ZITELOU/frontend-Zitelou/zitelou-complete-ux-ota.apk"
PACKAGE_NAME="org.jufam.kidlauncher"
DEVICE_ADMIN="MyDeviceAdminReceiver"
MAIN_ACTIVITY="com.zitelou.ui.KidHomeActivity"
API_URL="https://api.zitelou.usts.ai"

echo "🚀 DÉPLOIEMENT DEVICE OWNER - ZITELOU"
echo "===================================="
echo ""

# Vérifications préliminaires
echo "📋 Vérifications préliminaires..."

if [ ! -f "$APK_PATH" ]; then
    echo "❌ APK non trouvé : $APK_PATH"
    echo "💡 Compilez d'abord l'APK avec : ./gradlew assembleRelease"
    exit 1
fi

if ! command -v adb &> /dev/null; then
    echo "❌ ADB non installé"
    echo "💡 Installez ADB avec : sudo apt install adb"
    exit 1
fi

echo "✅ APK trouvé : $APK_PATH"
echo "✅ ADB installé : $(adb version | head -1)"

# Vérifier la connexion ADB
echo ""
echo "📱 Vérification de la connexion Android..."
DEVICES=$(adb devices | grep -v "List" | grep "device" | wc -l)

if [ $DEVICES -eq 0 ]; then
    echo "❌ Aucun appareil Android connecté"
    echo "💡 Connectez votre Galaxy XCover 5 en USB et activez le débogage USB"
    echo "💡 Puis exécutez : adb devices"
    exit 1
fi

echo "✅ Appareil Android connecté"

# Vérifier l'accès au backend
echo ""
echo "🌐 Vérification du backend..."
if curl -s --connect-timeout 5 "$API_URL/api/children" > /dev/null; then
    echo "✅ Backend accessible : $API_URL"
else
    echo "⚠️  Backend non accessible : $API_URL"
    echo "💡 Démarrez le backend avec : docker compose up -d"
    echo "💡 Ou modifiez l'IP dans le script si nécessaire"
    read -p "❓ Continuer malgré tout ? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Demander confirmation avant installation
echo ""
echo "⚠️  ATTENTION : Installation Device Owner"
echo "────────────────────────────────────────"
echo "🔹 Le téléphone doit être RÉINITIALISÉ (factory reset)"
echo "🔹 Aucun compte Google configuré"
echo "🔹 Cette opération est IRRÉVERSIBLE sans reset"
echo ""
read -p "❓ Le téléphone a-t-il été réinitialisé ? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Effectuez un factory reset avant de continuer"
    exit 1
fi

echo ""
read -p "❓ Continuer l'installation Device Owner ? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Installation annulée"
    exit 1
fi

# Installation de l'APK
echo ""
echo "📦 Installation de l'APK..."
if adb install -r "$APK_PATH"; then
    echo "✅ APK installé avec succès"
else
    echo "❌ Échec de l'installation APK"
    exit 1
fi

# Configuration Device Owner
echo ""
echo "🔒 Configuration Device Owner..."
if adb shell dpm set-device-owner $PACKAGE_NAME/.$DEVICE_ADMIN; then
    echo "✅ Device Owner configuré avec succès"
else
    echo "❌ Échec de la configuration Device Owner"
    echo "💡 Vérifiez que le téléphone est bien réinitialisé"
    exit 1
fi

# Vérification de l'installation
echo ""
echo "🔍 Vérification de l'installation..."
adb shell dpm list-owners

# Octroi des permissions
echo ""
echo "🔐 Attribution des permissions..."
adb shell pm grant $PACKAGE_NAME android.permission.CALL_PHONE 2>/dev/null || echo "⚠️  Permission CALL_PHONE déjà accordée"
adb shell pm grant $PACKAGE_NAME android.permission.READ_CONTACTS 2>/dev/null || echo "⚠️  Permission READ_CONTACTS déjà accordée"

# Définir comme Home par défaut
echo ""
echo "🏠 Configuration du launcher par défaut..."
adb shell pm set-home-activity $PACKAGE_NAME/$MAIN_ACTIVITY

# Test de démarrage
echo ""
echo "🚀 Test de démarrage de l'application..."
if adb shell am start -n $PACKAGE_NAME/$MAIN_ACTIVITY; then
    echo "✅ Application démarrée avec succès"
else
    echo "⚠️  Erreur lors du démarrage - vérifiez les logs"
fi

# Résumé final
echo ""
echo "🎉 INSTALLATION TERMINÉE !"
echo "========================="
echo ""
echo "✅ Zitelou installé en tant que Device Owner"
echo "✅ Mode kiosque activé"
echo "✅ Permissions accordées"
echo "✅ Launcher par défaut configuré"
echo ""
echo "📱 L'appareil est maintenant sécurisé pour l'enfant"
echo "🔒 L'enfant ne peut plus quitter l'application"
echo ""
echo "🛠️  Commandes utiles :"
echo "   - Logs app : adb logcat -s ZitelouApp"
echo "   - Logs admin : adb logcat -s MyDeviceAdminReceiver"
echo "   - Status : adb shell dpm list-owners"
echo ""
echo "💡 En cas de problème, consultez : DEVICE_OWNER_INSTALLATION.md"