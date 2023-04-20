#!/bin/bash

crear_directorios(){
    mkdir -p MLWD/Configuraciones/maq_virt/mv1 MLWD/Configuraciones/maq_virt/mv2
    mkdir -p MLWD/Experimentos
}

iniciar_maquinas(){
    VBoxManage snapshot Estatico restore Inicial
    VBoxManage startvm Estatico
    #VBoxManage startvm Dinamico
}

#restablecer_maquinas(){
    # Codigo para restablecer maquina virtal
#}

analisis_estatico(){
    echo "Parametrito $1"

    #archivo = "$1"
    COMANDOS=(
        "file Documentos/$1"
        "exiftool Documentos/$1"
        "md5sum Documentos/$1"
        "sha1sum Documentos/$1"
        "sha256sum Documentos/$1"
    )

    dir_salida="./salida" # Cambiar a la estructura del documento de la practica
    if [ ! -d "$dir_salida" ]; then
        mkdir "$dir_salida"
    fi

    sshpass -p 123456 scp -P 2222 "./$1" analista@localhost:/home/analista/Documentos/$1
    #echo "sshpass -p 123456 scp -P 2222 ./$1 analista@localhost:/home/analista/Documentos/$1"

    for cmd in "${COMANDOS[@]}"; do
        #echo "Comando $cmd"
        sshpass -p 123456 ssh -p 2222 analista@localhost "$cmd" >> "${dir_salida}/$(echo "$cmd" | tr ' ' '-' | tr '/' '-').txt"
        #echo "sshpass -p 123456 ssh -p 2222 analista@localhost $cmd > ${dir_salida}/$(echo $cmd | tr ' ' '-').txt"
    done

    #sshpass -p 123456 ssh -p 2222 analista@localhost "file Documentos/$1" > textito.txt
    #sshpass -p 123456 ssh -p 2222 analista@localhost "exiftool Documentos/$1" > textito.txt

    #sshpass -p 123456 ssh -p 2222 analista@localhost "md5sum Documentos/$1" > md5.txt
    #sshpass -p 123456 ssh -p 2222 analista@localhost "sha1sum Documentos/$1" > sha1.txt
    #sshpass -p 123456 ssh -p 2222 analista@localhost "sha256sum Documentos/$1" > sha256.txt


}

crea_experimento(){

    dir="./MLWD/Experimentos/"

    # Verificar si hay carpetas numeradas en el directorio
    if [ -z "$(ls $dir | grep -E "^[0-9]+$")" ]; then
        next_num=1
    else
        # Obtener el último número y sumar 1
        last_num=$(ls $dir | grep -E "^[0-9]+$" | sort -n | tail -1)
        next_num=$((last_num+1))
    fi

    # Crear la nueva carpeta
    mkdir "$dir/$next_num"
    echo "Se ha creado la carpeta $next_num en $dir."


    # experimento = $(ls $dir | grep -E "^[0-9]+$" | sort -n | tail -1)
    # echo "num $experimento"
}


crear_directorios


# if [ "$vm_state" == "running" ]; then
#     echo "La máquina virtual $vm_name está encendida."
vm_state=$(VBoxManage showvminfo "Estatico" | grep "State:" | awk '{print $2}')

if [ "$vm_state" == "powered" ]; then
    echo "La máquina virtual $vm_name está apagada."
    #iniciar_maquinas
    #sleep 7
fi

if [[ $( file -b "$1" ) =~ .*JSON.* ]]; then
    # Caso 3 y 4
    if [ ! -z "$2" ]; then
        # caso 4
        echo "Caso 4"
    else
        # caso 3
        echo "Caso 3"
    fi
else
    # Caso 1 y 2
    if [ -f "$1" ]; then
        # Caso 1
        echo "Caso 1"
        crea_experimento
        # ciclar binarios para crear carpetas
        #analisis_estatico "$1"

    else
        # Caso 2
        echo "Caso 2"
    fi
fi
