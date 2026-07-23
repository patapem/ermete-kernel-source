#!/bin/bash
set -eo pipefail

echo "========================================================="
echo " ERMETE OS CHIMERA KERNEL - RPM BUILDER"
echo "========================================================="

WORKSPACE_DIR="/workspace"
RPMBUILD_DIR="$WORKSPACE_DIR/rpmbuild_out"

echo ">>> Preparazione ambiente rpmbuild isolato..."
mkdir -p "$RPMBUILD_DIR"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

cd "$WORKSPACE_DIR"

echo ">>> Download del Kernel CachyOS (Sorgente Pura)..."
git clone --depth 1 https://github.com/CachyOS/linux-cachyos.git cachyos-tree

echo ">>> Generazione dell'archivio sorgente (linux-cachyos.tar.gz)..."
# Ignoriamo la cartella .git per ridurre il peso dell'archivio
tar --exclude='.git' -czf "$RPMBUILD_DIR/SOURCES/linux-cachyos.tar.gz" -C cachyos-tree .

echo ">>> Copia dei file di configurazione e Spec..."
cp ermete-bedrock.cfg "$RPMBUILD_DIR/SOURCES/"
cp ermete-kernel.spec "$RPMBUILD_DIR/SPECS/"

echo ">>> Applicazione Best Practice RPM (setup extraction)..."
sed -i 's/%prep/%prep\n%setup -c -n linux-cachyos/g' "$RPMBUILD_DIR/SPECS/ermete-kernel.spec"
sed -i '/Source0:/a Source1:        linux-cachyos.tar.gz' "$RPMBUILD_DIR/SPECS/ermete-kernel.spec"

echo ">>> Avvio compilazione RPM tramite rpmbuild..."
rpmbuild --define "_topdir $RPMBUILD_DIR" -ba "$RPMBUILD_DIR/SPECS/ermete-kernel.spec"

echo "========================================================="
echo " COMPILAZIONE COMPLETATA "
echo "========================================================="
echo "I pacchetti RPM si trovano in: $RPMBUILD_DIR/RPMS/x86_64/"
