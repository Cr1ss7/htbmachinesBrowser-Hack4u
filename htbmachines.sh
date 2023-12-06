#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


function ctrl_c(){
  echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
	tput cnorm
  exit 1
}

#Ctrl+c
trap ctrl_c INT

#Url principal 
main_url="https://htbmachines.github.io/bundle.js"

#Panel de ayuda
function helpPanel(){
  echo -e "\n${yellowColour}[+] Uso:${endColour}\n"
  echo -e "\t${purpleColour}m)${endColour} ${grayColour}Buscar por un nombre de maquina${endColour}\n"
  echo -e "\t${purpleColour}i)${endColour} ${grayColour}Buscar por la direccion IP${endColour}\n"
  echo -e "\t${purpleColour}y)${endColour} ${grayColour}Obtener link de la resolucion de la maquina en youtube${endColour}\n"
  echo -e "\t${purpleColour}d)${endColour} ${grayColour}Buscar maquinas por la dificultad (Facil,Media,Dificil,Insane)${endColour}\n"
  echo -e "\t${purpleColour}o)${endColour} ${grayColour}Buscar maquinas por el sistema operativo${endColour}\n"
  echo -e "\t${purpleColour}s)${endColour} ${grayColour}Buscar por Skill${endColour}\n"
  echo -e "\t${purpleColour}u)${endColour} ${grayColour}Descargar o actulizar archivos necesarios${endColour}\n"
  echo -e "\t${purpleColour}h)${endColour} ${grayColour}Mostrar panel de ayuda${endColour}\n"
}

#Actualizacion de bundle
function updateFiles(){
	if [ ! -f bundle.js ]; then
	echo -e "\n${yellowColour}[+] Descargando archivos necesarios...${endColour}\n"
	tput civis
	curl -s -X GET $main_url | js-beautify | sponge bundle.js 
	echo -e "\n[+] El archivo se descargo sin ningun problema\n"
	tput cnorm
	else
		echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Comprobando si hay actualizaciones pendientes${endColour}\n"
		sleep 2
		tput civis
		curl -s -X GET $main_url | js-beautify | sponge bundle_temp.js
		md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
		md5_original_value=$(md5sum bundle.js | awk '{print $1}')
		if [ "$md5_temp_value" == "$md5_original_value" ]; then
			echo -e "\n${yellowColour}[+]${endColour} ${grayColour}No hay actualizaciones, tienes todo al dia :D${endColour}\n"
			rm bundle_temp.js
		else
			echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Hay actualizaciones${endColour}\n"
			echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Actualizando...${endColour}\n"
			rm bundle.js
			mv bundle_temp.js bundle.js
			echo -e "\n${yellowColour}[+] Se actualizo de manera correcta :D${yellowColour}\n"
		fi
		tput cnorm
	fi
}

#Busqueda de maquina
function searchMachine(){
  	machineName="$1"
	machineResult="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's\^ *\\')"
	if [ "$machineResult" ]; then
		echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando la maquina${endColour}\n"
		echo -e "\n${grayColour}$machineResult${endColour}\n"
	else
		echo -e "\n${redColour}[!] La maquina con el nombre ${endColour}${grayColour}$machineName${endColour} ${redColour}no existe!!!${endColour}\n"
	fi
}

#Busqueda por direccion IP
function searchIP(){
	ipAddress="$1"
	machineResult=$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')
	if [ "$machineResult" ]; then
		echo -e "\n${yellowColour}[+]${endColour} ${grayColour}El nombre de la maquina con la ip${endColour} ${blueColour}$ipAddress${endColour} ${grayColour}es:${endColour}\n"
		echo -e "${yellowColour}Nombre ->\t${endColour}${grayColour}$machineResult${endColour}\n"
	else
		echo -e "\n${redColour}[!] La maquina con la direccion IP ${endColour}${grayColour}$ipAddress${endColour} ${redColour}no existe!!!${endColour}\n"
	fi
	}

function searchYoutube(){
	machineName="$1"
	linkYoutube=$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's\^ *\\' | grep "youtube" | awk 'NF{print $NF}')
	if [ "$linkYoutube" ]; then
		echo -e "\n${yellowColour}[+]${endColour} ${grayColour}El enlace la la resolucion de la maquina esta en:${endColour} ${blueColour}$linkYoutube${endColour}\n"
	else
		echo -e "\n${redColour}[!] La maquina con el nombre ${endColour}${grayColour}$machineName${endColour} ${redColour}no existe!!!${endColour}\n"
	fi
}

#Busqueda por la dificultad de la maquina
function searchDifficulty(){
	difficulty="$1"
	machineNames=$(cat bundle.js | sed 's/Fácil/Facil/' | sed 's/Difícil/Dificil/' | grep "dificultad: \"$difficulty\"" -B 5 | grep "name" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)
	if [ "$machineNames" ];then
		if [ "$difficulty" == "Facil" ]; then
			echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Las maquinas con dificultad${endColour} ${blueColour}$difficulty${endColour} ${grayColour}son:${endColour}\n${greenColour}$machineNames${endColour}"
		elif [ "$difficulty" == "Media" ]; then
			echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Las maquinas con dificultad${endColour} ${blueColour}$difficulty${endColour} ${grayColour}son:${endColour}\n${yellowColour}$machineNames${endColour}"
		elif [ "$difficulty" == "Dificil" ]; then
			echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Las maquinas con dificultad${endColour} ${blueColour}$difficulty${endColour} ${grayColour}son:${endColour}\n${redColour}$machineNames${endColour}"
		elif [ "$difficulty" == "Insane" ]; then
			echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Las maquinas con dificultad${endColour} ${blueColour}$difficulty${endColour} ${grayColour}son:${endColour}\n${purpleColour}$machineNames${endColour}"
		fi
	else
		echo -e "\n${redColour}[!] No existe la dificultad ${endColour}${grayColour}$difficulty${endColour}${redColour}!!!${endColour}\n"
	fi
}

#Busqueda por el sistema operativo de la maquina
function searchOsMachines(){
	os="$1"
	machinesNames="$(cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
	if [ "$machinesNames" ];then
		if [ "$os" == "Windows" ];then
			echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Las maquinas con sistema operativo $os son:${endColour}\n${blueColour}$machinesNames${endColour}\n"
		else
			echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Las maquinas con sistema operativo $os son:${endColour}\n${greenColour}$machinesNames${endColour}\n"
		fi
	else
		echo -e "\n${redColour}[!] No existen maquinas con el SO ${endColour}${grayColour}$os${endColour}${redColour}!!!${endColour}\n"
	fi
}

function searchMachineOsDifficulty(){
	difficulty="$1"
	os="$2"
	filter=$(cat bundle.js | sed 's/Fácil/Facil/' | sed 's/Difícil/Dificil/' | grep "dificultad: \"$difficulty\"" -B 5 | grep "so: \"$os\"" -C 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)	
	if [ "$filter" ];then
		if [ "$difficulty" == "Facil" ]; then
			echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Las maquinas con dificultad${endColour} ${blueColour}$difficulty${endColour} ${grayColour}y S.O${endColour} ${blueColour}$os${endColour} ${grayColour}son:${endColour}\n${greenColour}$filter${endColour}"
		elif [ "$difficulty" == "Media" ]; then
			echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Las maquinas con dificultad${endColour} ${blueColour}$difficulty${endColour} ${grayColour}y S.O${endColour} ${blueColour}$os${endColour} ${grayColour}son:${endColour}\n${yellowColour}$filter${endColour}"
		elif [ "$difficulty" == "Dificil" ]; then
			echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Las maquinas con dificultad${endColour} ${blueColour}$difficulty${endColour} ${grayColour}y S.O${endColour} ${blueColour}$os${endColour} ${grayColour}son:${endColour}\n${redColour}$filter${endColour}"
		elif [ "$difficulty" == "Insane" ]; then
			echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Las maquinas con dificultad${endColour} ${blueColour}$difficulty${endColour} ${grayColour}y S.O${endColour} ${blueColour}$os${endColour} ${grayColour}son:${endColour}\n${purpleColour}$filter${endColour}"
		fi
	else
		echo -e "\n${redColour}[!] No existen maquinas con dificultad${endColour} ${grayColour}$difficulty${endColour} ${redColour}y S.O${endColour} ${blueColour}$os ${endColour}${redColour}!!!${endColour}\n"
	fi
}

#Busqueda por habiliadades
function getSkill(){
	skill="$1"
	check_skill=$(cat bundle.js | grep "skills:" -B 6 | grep "$skill" -i -B 6 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)
	if [ "$check_skill" ];then
		echo -e "${yellowColour}[+]${endColour}${grayColour}Las maquinas con la habilidad de ${endColour}${blueColour}$skill${endColour}${grayColour} son:${endColour}\n${purpleColour}$check_skill${endColour}"
	else
		echo -e "\n${redColour}[!] No existen maquinas con habilidad${endColour} ${grayColour}$skill${endColour} ${redColour}!!!${endColour}\n"
	fi
}

#Indicadores
declare -i parameter_counter=0

#Chivatos
declare -i chivato_difficulty=0
declare -i chivato_os=0

while getopts "m:hui:y:d:o:s:" arg; do
  case $arg in
    m) machineName=$OPTARG; let parameter_counter+=1;;
	u) let parameter_counter+=2;;
    i) ipAddress=$OPTARG; let parameter_counter+=3;;
    y) machineName=$OPTARG; let parameter_counter+=4;;
    d) difficulty=$OPTARG; chivato_difficulty=1; let parameter_counter+=5;;
    o) os=$OPTARG; chivato_os=1; let parameter_counter+=6;;
    s) skill=$OPTARG; let parameter_counter+=7;;
    h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
	updateFiles
elif [ $parameter_counter -eq 3 ]; then
	searchIP $ipAddress	
elif [ $parameter_counter -eq 4 ]; then
	searchYoutube $machineName
elif [ $parameter_counter -eq 5 ]; then
	searchDifficulty $difficulty
elif [ $parameter_counter -eq 6 ]; then
	searchOsMachines $os
elif [ $parameter_counter -eq 7 ]; then
	getSkill "$skill"
elif [ $chivato_difficulty -eq 1 ] && [ $chivato_os -eq 1 ]; then
	searchMachineOsDifficulty $difficulty $os
else
  helpPanel
fi
