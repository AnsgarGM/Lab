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

crear_directorios
iniciar_maquinas
sleep 7

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
        analisis_estatico "$1"

    else
        # Caso 2
        echo "Caso 2"
    fi
fi
