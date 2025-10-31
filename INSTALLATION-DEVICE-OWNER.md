# 📱 Guide d'Installation Device Owner - Zitelou

**Version:** 1.0  
**Date:** 31 octobre 2025  
**Pour:** Galaxy XCover 5 & appareils compatibles

---

## ⚠️ IMPORTANT : POURQUOI ÇA PLANTE ?

Si le téléphone **plante en boucle**, c'est généralement parce que :

1. ❌ Un compte Google est configuré
2. ❌ Le téléphone n'a pas été réinitialisé correctement
3. ❌ Le Device Owner n'est pas activé correctement
4. ❌ Mauvaise version de l'APK utilisée

**→ Ce guide règle tous ces problèmes !**

---

## 🎯 ÉTAPE 1 : PRÉPARER LE TÉLÉPHONE (CRUCIAL !)

### 1.1 Réinitialiser complètement le téléphone

```
Paramètres > Système > Options de réinitialisation > Effacer toutes les données (Factory Reset)
```

**⚠️ ATTENTION :** Sauvegarde tes données importantes avant !

### 1.2 Premier démarrage (SANS COMPTE GOOGLE !)

Après la réinitialisation :

- ✅ **Configure la langue** (Français)
- ✅ **Configure le Wi-Fi** (ton réseau)
- ⛔ **NE PAS AJOUTER DE COMPTE GOOGLE** (skip cette étape)
- ⛔ **NE PAS CONFIGURER SAMSUNG ACCOUNT** (skip aussi)
- ⛔ **Skip toutes les étapes optionnelles**

**💡 Astuce :** Si on te force à ajouter un compte, réinitialise à nouveau.

### 1.3 Activer le mode développeur

```
Paramètres > À propos du téléphone > "Numéro de build"
```

**→ Tape 7 fois rapidement** sur "Numéro de build"

Tu verras : *"Vous êtes maintenant développeur !"*

### 1.4 Activer le débogage USB

```
Paramètres > Options pour les développeurs > Débogage USB
```

**→ Active le switch** et confirme "OK"

---

## 💻 ÉTAPE 2 : SUR L'ORDINATEUR

### 2.1 Vérifier qu'ADB est installé

Ouvre un terminal et tape :

```bash
adb version
```

**Si ADB n'est pas installé :**

```bash
# Sur Ubuntu/Debian
sudo apt install adb

# Sur macOS
brew install android-platform-tools

# Sur Windows
# Télécharge depuis : https://developer.android.com/tools/releases/platform-tools
```

### 2.2 Connecter le téléphone en USB

1. Branche le téléphone à l'ordinateur avec un câble USB
2. Sur le téléphone, une popup apparaît : **"Autoriser le débogage USB ?"**
3. Coche **"Toujours autoriser depuis cet ordinateur"**
4. Appuie sur **"OK"**

### 2.3 Vérifier la connexion

```bash
adb devices
```

Tu dois voir quelque chose comme :

```
List of devices attached
R58N50ABCDE    device
```

**Si tu vois "unauthorized" :** Vérifie la popup sur le téléphone et accepte.

---

## 🚀 ÉTAPE 3 : INSTALLATION AUTOMATIQUE (RECOMMANDÉ)

### Méthode 1 : Script automatique

```bash
cd /home/patrick/Projets/USTS/USTS-ZITELOU/scripts/deployment
./deploy-device-owner.sh
```

**Le script fait tout automatiquement :**
- ✅ Vérifie les prérequis
- ✅ Installe l'APK
- ✅ Configure le Device Owner
- ✅ Définit les permissions
- ✅ Configure le launcher

**→ Suis simplement les instructions à l'écran !**

---

## 🛠️ ÉTAPE 3 BIS : INSTALLATION MANUELLE (SI LE SCRIPT ÉCHOUE)

### 3.1 Installer l'APK

```bash
cd /home/patrick/Projets/USTS/USTS-ZITELOU/frontend-Zitelou
adb install -r zitelou-complete-ux-ota.apk
```

Tu dois voir : `Success`

### 3.2 Configurer le Device Owner (COMMANDE MAGIQUE)

```bash
adb shell dpm set-device-owner org.jufam.kidlauncher/.MyDeviceAdminReceiver
```

**Résultat attendu :**
```
Success: Device owner set to package org.jufam.kidlauncher
Active admin set to component {...}
```

**Si ça échoue :** Le téléphone n'est pas vierge → Réinitialise-le à nouveau.

### 3.3 Vérifier que le Device Owner est actif

```bash
adb shell dpm list-owners
```

Tu dois voir :
```
org.jufam.kidlauncher/.MyDeviceAdminReceiver
```

### 3.4 Donner les permissions

```bash
adb shell pm grant org.jufam.kidlauncher android.permission.CALL_PHONE
adb shell pm grant org.jufam.kidlauncher android.permission.READ_CONTACTS
adb shell pm grant org.jufam.kidlauncher android.permission.CAMERA
```

### 3.5 Définir comme launcher par défaut

```bash
adb shell pm set-home-activity org.jufam.kidlauncher/com.zitelou.ui.KidHomeActivity
```

### 3.6 Lancer l'application

```bash
adb shell am start -n org.jufam.kidlauncher/com.zitelou.ui.KidHomeActivity
```

**→ L'application Zitelou se lance sur le téléphone !**

---

## ✅ ÉTAPE 4 : VÉRIFICATION

### 4.1 Vérifie que tout fonctionne

- [ ] L'application Zitelou se lance automatiquement
- [ ] Tu ne peux pas quitter l'application (bouton Home ne fait rien)
- [ ] L'application demande de configurer un code PIN parent
- [ ] Les boutons "Appels", "Photos", "Musique" sont visibles

### 4.2 Configuration initiale de Zitelou

**Sur le téléphone :**

1. **Crée ton compte parent** avec ton email
2. **Définis un code PIN à 4 chiffres** (garde-le bien !)
3. **Ajoute les contacts autorisés** (famille, amis)
4. **Sélectionne les applications autorisées** :
   - Appareil photo
   - Spotify Kids / Deezer Kids
   - WhatsApp
   - etc.

**→ Le téléphone est prêt ! 🎉**

---

## 🔍 RÉSOLUTION DES PROBLÈMES

### Problème 1 : "Device Owner échoue"

**Erreur :**
```
Error: Not allowed to set the device owner because there are already some accounts on the device
```

**Solution :**
1. Réinitialise complètement le téléphone
2. Ne configure AUCUN compte (Google, Samsung, etc.)
3. Réessaye

---

### Problème 2 : "L'application plante au démarrage"

**Symptômes :** L'app se ferme ou redémarre en boucle

**Solutions possibles :**

**A. Vérifie que le Device Owner est actif :**
```bash
adb shell dpm list-owners
```

Si vide → Réexécute :
```bash
adb shell dpm set-device-owner org.jufam.kidlauncher/.MyDeviceAdminReceiver
```

**B. Vérifie les logs pour voir l'erreur :**
```bash
adb logcat -s ZitelouApp
```

**C. Vérifie que le backend API est accessible :**
```bash
curl https://api.zitelou.usts.ai/api/children
```

Si le backend ne répond pas, l'app peut planter. Lance le backend :
```bash
cd /home/patrick/Projets/USTS/USTS-ZITELOU/zitelou-api
docker compose up -d
```

---

### Problème 3 : "Aucun appareil détecté"

**Erreur :**
```
List of devices attached
```

**Solutions :**

1. **Vérifie le câble USB** (certains câbles ne font que de la charge)
2. **Essaye un autre port USB** de l'ordinateur
3. **Sur le téléphone**, vérifie que le débogage USB est activé
4. **Débranche et rebranche** le câble
5. **Révoque les autorisations ADB** et réessaye :
   ```
   Paramètres > Options pour les développeurs > Révoquer les autorisations de débogage USB
   ```
   Puis rebranche le téléphone et accepte à nouveau.

---

### Problème 4 : "Permission denied"

**Erreur lors de l'installation :**
```
adb: failed to install [...]: Failure [INSTALL_FAILED_PERMISSION_DENIED]
```

**Solution :**
```bash
# Désinstalle l'ancienne version
adb uninstall org.jufam.kidlauncher

# Réinstalle
adb install -r zitelou-complete-ux-ota.apk
```

---

### Problème 5 : "L'app ne se lance pas automatiquement"

**Solution :**

```bash
# Définis Zitelou comme launcher par défaut
adb shell pm set-home-activity org.jufam.kidlauncher/com.zitelou.ui.KidHomeActivity

# Puis redémarre le téléphone
adb reboot
```

---

## 🛠️ COMMANDES UTILES POUR LE DEBUG

### Voir les logs de l'application

```bash
# Logs généraux de Zitelou
adb logcat -s ZitelouApp

# Logs du Device Admin
adb logcat -s MyDeviceAdminReceiver

# Logs complets (filtré)
adb logcat | grep -i zitelou
```

### Vérifier l'état du Device Owner

```bash
adb shell dpm list-owners
```

### Désinstaller complètement (pour recommencer)

```bash
adb uninstall org.jufam.kidlauncher
```

### Tuer l'app et la relancer

```bash
# Arrêter l'app
adb shell am force-stop org.jufam.kidlauncher

# Relancer l'app
adb shell am start -n org.jufam.kidlauncher/com.zitelou.ui.KidHomeActivity
```

### Vérifier les permissions accordées

```bash
adb shell dumpsys package org.jufam.kidlauncher | grep permission
```

### Redémarrer le téléphone

```bash
adb reboot
```

---

## 📦 QUELLE APK UTILISER ?

**APK recommandée :**
```
/home/patrick/Projets/USTS/USTS-ZITELOU/frontend-Zitelou/zitelou-complete-ux-ota.apk
```

**Autres APK disponibles** (pour tests seulement) :
- `zitelou-device-owner.apk` - Version de base
- `zitelou-debug-*.apk` - Versions de debug (ne pas utiliser en production)

**💡 Astuce :** Toujours utiliser la version `complete-ux-ota` pour un téléphone final.

---

## ✅ CHECKLIST COMPLÈTE AVANT INSTALLATION

Avant de lancer l'installation, vérifie :

- [ ] Téléphone **réinitialisé aux paramètres d'usine**
- [ ] **Aucun compte Google** configuré sur le téléphone
- [ ] **Aucun compte Samsung** configuré
- [ ] Mode développeur **activé** (7 clics sur "Numéro de build")
- [ ] Débogage USB **activé**
- [ ] Téléphone **connecté en USB** à l'ordinateur
- [ ] `adb devices` **affiche le téléphone**
- [ ] APK `zitelou-complete-ux-ota.apk` **présent**
- [ ] Câble USB **fonctionnel** (pas seulement charge)

**→ Si tout est coché, c'est bon ! Lance l'installation !**

---

## 🎯 RÉSUMÉ EN 5 ÉTAPES

1. **Réinitialise le téléphone** (sans compte Google)
2. **Active le débogage USB** (mode développeur)
3. **Connecte le téléphone** à l'ordinateur
4. **Lance le script** `./deploy-device-owner.sh`
5. **Configure Zitelou** sur le téléphone (code PIN + contacts)

**→ C'est fini ! Le téléphone est sécurisé pour l'enfant ! 🎉**

---

## 📞 SUPPORT

**En cas de problème :**

1. Vérifie d'abord la section "Résolution des problèmes" ci-dessus
2. Regarde les logs : `adb logcat -s ZitelouApp`
3. Vérifie que le Device Owner est actif : `adb shell dpm list-owners`
4. Contacte le développeur avec les logs

---

## 📚 RESSOURCES

- **Script d'installation :** `/scripts/deployment/deploy-device-owner.sh`
- **Documentation complète :** `/scripts/installation-diy/README.md`
- **API Backend :** `https://api.zitelou.usts.ai`

---

**🚀 Bon courage avec l'installation ! Si tu suis ce guide, ça devrait marcher du premier coup !**

*Créé le 31 octobre 2025 - Zitelou v1.0*
