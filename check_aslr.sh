#!/bin/bash
# check_aslr.sh
# Demuestra el efecto de ASLR mostrando como las direcciones de memoria
# cambian (o no) entre ejecuciones segun el estado de randomize_va_space.

echo "========================================"
echo "  DEMOSTRACION DE ASLR"
echo "========================================"

echo ""
echo "[ Estado actual de ASLR ]"
ASLR=$(cat /proc/sys/kernel/randomize_va_space)
echo "  /proc/sys/kernel/randomize_va_space = $ASLR"

case $ASLR in
    0) echo "  Estado: DESACTIVADO — direcciones fijas en cada ejecucion" ;;
    1) echo "  Estado: PARCIAL — stack y librerias randomizados" ;;
    2) echo "  Estado: COMPLETO — stack, heap y librerias randomizados" ;;
esac

echo ""
echo "[ Direccion del stack en 5 ejecuciones ]"
for i in $(seq 1 5); do
    grep "\[stack\]" /proc/self/maps | awk '{print "  Ejecucion '$i': " $1}'
done

echo ""
echo "[ Direccion base de libc en 5 ejecuciones ]"
for i in $(seq 1 5); do
    # Lanza un proceso hijo y captura su mapa de memoria
    ADDR=$(cat /proc/self/maps 2>/dev/null | grep "libc" | head -1 | awk '{print $1}')
    if [ -z "$ADDR" ]; then
        ADDR=$(ldd ./vulnerable 2>/dev/null | grep libc | awk '{print $4}' | tr -d '()')
    fi
    echo "  Ejecucion $i: ${ADDR:-no disponible}"
    sleep 0.1
done

echo ""
echo "========================================"
echo "  COMANDOS UTILES"
echo "========================================"
echo "  Desactivar ASLR : sudo sysctl -w kernel.randomize_va_space=0"
echo "  Reactivar ASLR  : sudo sysctl -w kernel.randomize_va_space=2"
echo "========================================"
