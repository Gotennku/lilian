#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════
#   INSTALLATEUR ZITELOU POUR LINUX
#   Installation automatique sur téléphone Android
# ═══════════════════════════════════════════════════════════════════════

set -e  # Arrêter en cas d'erreur

# Configuration
APK_NAME="zitelou.apk"
PACKAGE_NAME="org.jufam.kidlauncher"
DEVICE_ADMIN="MyDeviceAdminReceiver"
MAIN_ACTIVITY="com.zitelou.ui.KidHomeActivity"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher un message coloré
print_step() {
    echo -e "${BLUE}┌───────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│ $1${NC}"
    echo -e "${BLUE}└───────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}💡 $1${NC}"
}

# Nettoyer l'écran
clear

echo ""
echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║                                                                   ║"
echo "║                   INSTALLATION ZITELOU                            ║"
echo "║           Installation automatique sur votre téléphone            ║"
echo "║                                                                   ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""
echo ""

# ═══════════════════════════════════════════════════════════════════════
# ÉTAPE 1 : Vérifications préliminaires
# ═══════════════════════════════════════════════════════════════════════

print_step "ÉTAPE 1/6 : Vérifications préliminaires"

# Récupérer le chemin du script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APK_PATH="$SCRIPT_DIR/$APK_NAME"

# Vérifier que l'APK existe
if [ ! -f "$APK_PATH" ]; then
    print_error "Le fichier $APK_NAME est introuvable !"
    echo ""
    print_info "Assurez-vous que le fichier \"$APK_NAME\" est bien dans"
    echo "   le même dossier que ce script."
    echo ""
    exit 1
fi

print_success "Fichier APK trouvé : $APK_NAME"
echo ""

# ═══════════════════════════════════════════════════════════════════════
# ÉTAPE 2 : Installation d'ADB (si nécessaire)
# ═══════════════════════════════════════════════════════════════════════

print_step "ÉTAPE 2/6 : Installation des outils Android (ADB)"

# Vérifier si ADB est installé
if command -v adb &> /dev/null; then
    print_success "ADB est déjà installé sur votre ordinateur"
    ADB_CMD="adb"
else
    print_warning "ADB n'est pas installé. Installation automatique..."
    echo ""
    
    # Détecter la distribution Linux
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    else
        DISTRO="unknown"
    fi
    
    echo "   📥 Installation d'ADB pour votre système ($DISTRO)..."
    
    case $DISTRO in
        ubuntu|debian|linuxmint|pop)
            echo "   → Utilisation d'apt-get..."
            sudo apt-get update -qq
            sudo apt-get install -y adb
            ;;
        fedora|rhel|centos)
            echo "   → Utilisation de dnf/yum..."
            if command -v dnf &> /dev/null; then
                sudo dnf install -y android-tools
            else
                sudo yum install -y android-tools
            fi
            ;;
        arch|manjaro)
            echo "   → Utilisation de pacman..."
            sudo pacman -S --noconfirm android-tools
            ;;
        opensuse*)
            echo "   → Utilisation de zypper..."
            sudo zypper install -y android-tools
            ;;
        *)
            print_error "Distribution Linux non reconnue : $DISTRO"
            echo ""
            print_info "Installez manuellement ADB avec :"
            echo "   • Ubuntu/Debian : sudo apt install adb"
            echo "   • Fedora : sudo dnf install android-tools"
            echo "   • Arch : sudo pacman -S android-tools"
            echo ""
            exit 1
            ;;
    esac
    
    # Vérifier que l'installation a réussi
    if command -v adb &> /dev/null; then
        print_success "ADB installé avec succès"
        ADB_CMD="adb"
    else
        print_error "L'installation d'ADB a échoué"
        exit 1
    fi
    
    # Configurer les règles udev pour USB (nécessaire sur Linux)
    echo ""
    echo "   🔧 Configuration des permissions USB..."
    
    UDEV_RULE='SUBSYSTEM=="usb", ATTR{idVendor}=="*", MODE="0666", GROUP="plugdev"'
    UDEV_FILE="/etc/udev/rules.d/51-android.rules"
    
    if [ ! -f "$UDEV_FILE" ]; then
        echo "$UDEV_RULE" | sudo tee "$UDEV_FILE" > /dev/null
        sudo chmod a+r "$UDEV_FILE"
        sudo udevadm control --reload-rules
        sudo udevadm trigger
        print_success "Permissions USB configurées"
    fi
fi

echo ""

# ═══════════════════════════════════════════════════════════════════════
# ÉTAPE 3 : Vérification du téléphone
# ═══════════════════════════════════════════════════════════════════════

print_step "ÉTAPE 3/6 : Connexion au téléphone Android"

echo "📱 Vérification de la connexion au téléphone..."
echo ""

# Tuer le serveur ADB existant et en démarrer un nouveau
$ADB_CMD kill-server &> /dev/null || true
$ADB_CMD start-server &> /dev/null || true

# Attendre 2 secondes
sleep 2

# Vérifier les appareils connectés
DEVICE_COUNT=$($ADB_CMD devices | grep -c "device$" || true)

if [ "$DEVICE_COUNT" -eq 0 ]; then
    print_error "AUCUN TÉLÉPHONE DÉTECTÉ !"
    echo ""
    print_warning "VÉRIFIEZ CES POINTS :"
    echo ""
    echo "   1. Le téléphone est connecté en USB à l'ordinateur"
    echo "   2. Le câble USB fonctionne (pas seulement pour la charge)"
    echo "   3. Le \"Débogage USB\" est activé sur le téléphone"
    echo "   4. Sur le téléphone, acceptez la popup \"Autoriser le débogage USB\""
    echo ""
    print_info "COMMENT ACTIVER LE DÉBOGAGE USB :"
    echo ""
    echo "   → Allez dans Paramètres > À propos du téléphone"
    echo "   → Tapez 7 fois sur \"Numéro de build\""
    echo "   → Retournez dans Paramètres > Options pour les développeurs"
    echo "   → Activez \"Débogage USB\""
    echo ""
    exit 1
fi

print_success "Téléphone Android détecté et connecté !"
echo ""

# ═══════════════════════════════════════════════════════════════════════
# ÉTAPE 4 : Vérification que le téléphone est vierge
# ═══════════════════════════════════════════════════════════════════════

print_step "ÉTAPE 4/6 : Vérification de l'état du téléphone"

print_warning "IMPORTANT : Pour que Zitelou fonctionne correctement,"
echo "   le téléphone doit être RÉINITIALISÉ (paramètres d'usine)"
echo "   et AUCUN compte Google ne doit être configuré."
echo ""
print_info "COMMENT RÉINITIALISER LE TÉLÉPHONE :"
echo ""
echo "   → Paramètres > Système > Options de réinitialisation"
echo "   → \"Effacer toutes les données\" (Factory Reset)"
echo "   → Au redémarrage, configurez la langue et le Wi-Fi"
echo "   → NE PAS ajouter de compte Google !"
echo ""

read -p "❓ Le téléphone a-t-il été réinitialisé et vierge (sans compte) ? (O/N) : " confirm

if [[ ! $confirm =~ ^[OoYy]$ ]]; then
    echo ""
    print_error "Veuillez réinitialiser le téléphone avant de continuer."
    echo ""
    exit 1
fi

echo ""
print_success "Parfait ! Continuation de l'installation..."
echo ""

# ═══════════════════════════════════════════════════════════════════════
# ÉTAPE 5 : Installation de l'application Zitelou
# ═══════════════════════════════════════════════════════════════════════

print_step "ÉTAPE 5/6 : Installation de l'application Zitelou"

echo "📦 Installation de Zitelou sur le téléphone..."
echo "   (Cela peut prendre quelques secondes)"
echo ""

if $ADB_CMD install -r "$APK_PATH" &> /dev/null; then
    print_success "Application Zitelou installée avec succès !"
else
    print_warning "Tentative de désinstallation de l'ancienne version..."
    $ADB_CMD uninstall $PACKAGE_NAME &> /dev/null || true
    echo "   → Nouvelle tentative d'installation..."
    
    if $ADB_CMD install -r "$APK_PATH"; then
        print_success "Application Zitelou installée avec succès !"
    else
        echo ""
        print_error "L'installation a échoué. Contactez le support."
        exit 1
    fi
fi

echo ""

# ═══════════════════════════════════════════════════════════════════════
# ÉTAPE 6 : Configuration du contrôle parental (Device Owner)
# ═══════════════════════════════════════════════════════════════════════

print_step "ÉTAPE 6/6 : Configuration du contrôle parental"

echo "🔒 Activation du contrôle parental Zitelou..."
echo ""

if $ADB_CMD shell dpm set-device-owner $PACKAGE_NAME/.$DEVICE_ADMIN &> /dev/null; then
    print_success "Contrôle parental activé avec succès !"
    echo ""
    
    # Attribution des permissions
    echo "🔐 Attribution des permissions nécessaires..."
    $ADB_CMD shell pm grant $PACKAGE_NAME android.permission.CALL_PHONE &> /dev/null || true
    $ADB_CMD shell pm grant $PACKAGE_NAME android.permission.READ_CONTACTS &> /dev/null || true
    $ADB_CMD shell pm grant $PACKAGE_NAME android.permission.CAMERA &> /dev/null || true
    print_success "Permissions accordées"
    echo ""
    
    # Définir comme launcher par défaut
    echo "🏠 Configuration du launcher par défaut..."
    $ADB_CMD shell pm set-home-activity $PACKAGE_NAME/$MAIN_ACTIVITY &> /dev/null || true
    print_success "Zitelou défini comme écran d'accueil"
    echo ""
else
    print_warning "Le mode de contrôle parental n'a pas pu être activé."
    echo ""
    echo "   Cela peut arriver si :"
    echo "   • Un compte Google est configuré sur le téléphone"
    echo "   • Le téléphone n'a pas été réinitialisé correctement"
    echo ""
    print_info "SOLUTION :"
    echo "   1. Réinitialisez complètement le téléphone"
    echo "   2. Ne configurez AUCUN compte (Google, Samsung, etc.)"
    echo "   3. Relancez ce script"
    echo ""
    
    read -p "❓ Voulez-vous continuer sans le mode contrôle parental ? (O/N) : " continue
    
    if [[ ! $continue =~ ^[OoYy]$ ]]; then
        echo ""
        print_error "Installation annulée."
        exit 1
    fi
    
    echo ""
    print_warning "Installation sans contrôle parental complet."
    echo "   L'enfant pourra potentiellement quitter l'application."
    echo ""
fi

# Lancer l'application
echo "🚀 Lancement de Zitelou..."
$ADB_CMD shell am start -n $PACKAGE_NAME/$MAIN_ACTIVITY &> /dev/null || true
echo ""

# ═══════════════════════════════════════════════════════════════════════
# INSTALLATION TERMINÉE !
# ═══════════════════════════════════════════════════════════════════════

echo ""
echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║                                                                   ║"
echo "║              🎉 INSTALLATION TERMINÉE AVEC SUCCÈS ! 🎉           ║"
echo "║                                                                   ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""
print_success "Zitelou est maintenant installé sur le téléphone !"
echo ""
echo "📱 PROCHAINES ÉTAPES SUR LE TÉLÉPHONE :"
echo ""
echo "   1. L'application Zitelou s'ouvre automatiquement"
echo "   2. Créez votre compte parent avec votre email"
echo "   3. Définissez un code PIN à 4 chiffres (gardez-le bien !)"
echo "   4. Ajoutez les contacts autorisés (famille, amis)"
echo "   5. Sélectionnez les applications que l'enfant peut utiliser"
echo ""
echo "🎊 Le téléphone est maintenant sécurisé pour votre enfant !"
echo ""
print_info "CONSEILS :"
echo ""
echo "   • Gardez votre code PIN parent en sécurité"
echo "   • Vous pouvez modifier les paramètres en appuyant longuement"
echo "     sur l'écran d'accueil et en entrant votre code PIN"
echo "   • Les numéros d'urgence (pompiers, police) restent toujours"
echo "     accessibles même sans contact autorisé"
echo ""
echo "📞 BESOIN D'AIDE ?"
echo ""
echo "   → Support : support@zitelou.com"
echo "   → Site web : www.zitelou.com"
echo ""
echo ""
echo "Appuyez sur Entrée pour fermer cette fenêtre..."
read
