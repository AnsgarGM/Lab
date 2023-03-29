#!/bin/bash



VM_NAME=""
ISO_PATH=""
HDD_PATH=""
HDD_SIZE_MB="" 
MEMORY_MB="" 
ID_SNAPSHOT=""
SNAP_NAME=""
# Función para mostrar la ayuda
mostrar_ayuda() {
    echo "Uso: $0 [opciones]"
    echo "Opciones disponibles:"
    echo "   create         Crea maquina Virtual"
	echo "  		-n,  --name 				Nombre Maquina virtual"
    echo "          -p,  --path 				Ruta de la imagen ISO"
    echo "          -hn, --Harddisk name		Ruta del disco duro"
	echo "          -hs, --Harddisk size		Tamano del disco duro en MB"
	echo "          -hn, --Harddisk name		Ruta del disco duro"
	echo "          -m,  --Memory size			Tamano de la Memoria RAM en MB"
	echo "   clone         Clona maquina virtual"
	echo "  		-n,  --name 				Nombre Maquina virtual"
	echo "  		-si,  --snapshot id 		ID del snapshot"
	echo "   ls            Lista las maquinas virtuales"
	echo "   delete        Elimina Maquina virtual"
	echo "  		-n,  --name 				Nombre Maquina virtual"
	echo "   start         Enciende Maquina virtual"
	echo "  		-n,  --name 				Nombre Maquina virtual"
    echo "   startsnap     Enciende snapshot"
	echo "  		-n,  --name 				Nombre Maquina virtual"
	echo "  		-sn,  --name 				Nombre snapshot"

	echo "  -h, --ayuda            Muestra esta ayuda"
}

# Definir las opciones
opciones="n:p:hn:hs:m:si:sn:h"
dato=""
accion=""

# Analizar las opciones
while getopts $opciones opcion; do
    case $opcion in
        n)
			VM_NAME=$OPTARG
			;;
		p)
			ISO_PATH=$OPTARG
			;;
		hn) 
			HDD_PATH=$OPTARG
			;;
		hs)
			HDD_SIZE_MB=$OPTARG
			;;
		m)	
			MEMORY_MB=$OPTARG
			;;
		si)
			ID_SNAPSHOT=$OPTARG	
			;;
		sn) SNAP_NAME=$OPTARG
			;;
        h)
            mostrar_ayuda
            exit 0
            ;;
        \?)
            echo "Opción inválida: -$OPTARG" >&2
            mostrar_ayuda
            exit 1
            ;;
        :)
            echo "La opción -$OPTARG requiere un argumento." >&2
            mostrar_ayuda
            exit 1
            ;;
    esac
done

if [ "$1" = "create" ]; then
    echo "[+]Creando maquina virtual $VM_PATH SO $ISO_PATH RAM $MEMORY_MB."
	VBoxManage createvm --name "$VM_NAME" --ostype "Ubuntu_64" --register
	VBoxManage modifyvm "$VM_NAME" --memory "$MEMORY_MB"
	VBoxManage createhd --filename "$HDD_PATH" --size "$HDD_SIZE_MB"
	VBoxManage storagectl "$VM_NAME" --name "SATA Controller" --add sata --controller IntelAHCI
	VBoxManage storageattach "$VM_NAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$HDD_PATH"
	VBoxManage storagectl "$VM_NAME" --name 'IDE Controller' --add ide
	VBoxManage storageattach "$VM_NAME" --storagectl 'IDE Controller' --port 1 --device 0 --type dvddrive --medium "$ISO_PATH"
	VBoxManage modifyvm "$VM_NAME" --nic1 nat
	VBoxManage modifyvm "$VM_NAME" --natpf1 "guestssh,tcp,,2222,,22"
	VBoxManage storageattach "$VM_NAME" --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium "$ISO_PATH"
	
else
    mostrar_ayuda
    exit 1
fi

if [ "$1" = "clone" ]; then
	echo "[+]Clonando maquina virtual $VM_NAME"
	VBoxManage clonevm Template --name "$VM_NAME" --options link --mode all
	VBoxManage clonevm Template --name "$VM_NAME" --options keepallmacs --options keepdisknames --snapshot Inicial
	VBoxManage clonevm Template --name "$VM_NAME" --mode all --snapshot 922790c0-7aee-4c66-873b-a88117649512 --register
else
    mostrar_ayuda
    exit 1
fi

if [ "$1" = "ls" ]; then
	echo "[+]Mostrando maquinas virtuales"
	VBoxManage list vms
else
    mostrar_ayuda
    exit 1
fi

if [ "$1" = "delete" ]; then
	echo "[+]Eliminando maquina virtual $VM_NAME"
	VBoxManage unregistervm "$VM_NAME" --delete
else
    mostrar_ayuda
    exit 1
fi

if [ "$1" = "start" ]; then
	echo "[+]Iniciando maquina virtual $VM_NAME"
	VBoxManage startvm "$VM_NAME"
else
    mostrar_ayuda
    exit 1
fi

if [ "$1" = "startsnap" ]; then
	echo "[+]Iniciando snapshot $SNAP_NAME"
	VBoxManage snapshot $VM_NAME restore $SNAP_NAME
else
    mostrar_ayuda
    exit 1
fi

if [ "$1" = "stopvm" ]; then
	echo "[+]Deteniendo $VM_NAME"
	VBoxManage controlvm $VM_NAME poweroff
else
    mostrar_ayuda
    exit 1
fi
