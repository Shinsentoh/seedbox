#!/bin/bash
# Switch de map sur le serveur

# Configuration des chemins
TARGET_MAP=$1
SAVE_DIR="/home/seedbox/games/enshrouded"
LINK_NAME="active_save"
LINK_PATH="${SAVE_DIR}/$LINK_NAME"
BACKUP_DIR="${SAVE_DIR}/backups"
SCRIPT_DIR=$(pwd)

# Validation de l'argument
if [ "$TARGET_MAP" != "A" ] && [ "$TARGET_MAP" != "B" ]; then
    echo "Usage: $0 [A|B]"
    exit 1
fi

# Déterminer quelle carte est actuellement active avant le switch
if [ -L "$LINK_PATH" ]; then
    CURRENT_TARGET=$(basename $(readlink "$LINK_PATH"))
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
docker stop enshrouded

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
rm -f "$LINK_PATH"

cd "$SAVE_DIR"

if [ "$TARGET_MAP" == "A" ]; then
    ln -sfn "world_A" "$LINK_NAME"
    echo "Lien symbolique orienté vers -> Map A (world_A)"
else
    ln -sfn "world_B" "$LINK_NAME"
    echo "Lien symbolique orienté vers -> Map B (world_B)"
fi

cd "$SCRIPT_DIR"

echo "=== ÉTAPE 4 : Relance du serveur Enshrouded ==="
docker start enshrouded

echo "========================================="
echo " Changement terminé ! Le serveur tourne sur la Map ${TARGET_MAP}."
echo "========================================="
