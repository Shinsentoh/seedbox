#!/bin/bash
# Switch de map sur le serveur

# Configuration des chemins
TARGET_MAP=$1
SAVE_DIR="/home/seedbox/games/enshrouded/server/savegame"
MAP_DIR="/home/seedbox/games/enshrouded"
LINK_NAME="${MAP_DIR}/active_save"
BACKUP_DIR="/home/seedbox/games/enshrouded/backups"

# Validation de l'argument
if [ "$TARGET_MAP" != "A" ] && [ "$TARGET_MAP" != "B" ]; then
    echo "Usage: $0 [A|B]"
    exit 1
fi

# Déterminer quelle carte est actuellement active avant le switch
if [ -L "$LINK_NAME" ]; then
    CURRENT_TARGET=$(basename $(readlink "$LINK_NAME"))
    if [ "$CURRENT_TARGET" == "world_A" ]; then
        CURRENT_MAP="A"
    elif [ "$CURRENT_TARGET" == "world_B" ]; then
        CURRENT_MAP="B"
    else
        CURRENT_MAP="Inconnue"
    fi
else
    CURRENT_MAP="Aucune"
fi

echo "=== ÉTAPE 1 : Arrêt propre du serveur Enshrouded ==="
dcd games

echo "=== ÉTAPE 2 : Sauvegarde de sécurité automatique ==="
if [ "$CURRENT_MAP" == "A" ] || [ "$CURRENT_MAP" == "B" ]; then
    mkdir -p "$BACKUP_DIR"
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    BACKUP_FILE="${BACKUP_DIR}/backup_world_${CURRENT_MAP}_${TIMESTAMP}.tar.gz"

    echo "Création de la sauvegarde pour la Map ${CURRENT_MAP}..."
    tar -czf "$BACKUP_FILE" -C "${SAVE_DIR}" "world_${CURRENT_MAP}"
    echo "Sauvegarde créée avec succès : ${BACKUP_FILE}"
else
    echo "Aucune carte active standard détectée (Lien brisé ou manquant). Étape de sauvegarde ignorée."
fi

echo "=== ÉTAPE 3 : Mise à jour du lien symbolique ==="
rm -f "$LINK_NAME"

if [ "$TARGET_MAP" == "A" ]; then
    ln -s "${MAP_DIR}/world_A" "$LINK_NAME"
    echo "Lien symbolique orienté vers -> Map A (world_A)"
else
    ln -s "${MAP_DIR}/world_B" "$LINK_NAME"
    echo "Lien symbolique orienté vers -> Map B (world_B)"
fi

echo "=== ÉTAPE 4 : Relance du serveur Enshrouded ==="
dcu games

echo "========================================="
echo " Changement terminé ! Le serveur tourne sur la Map ${TARGET_MAP}."
echo "========================================="
