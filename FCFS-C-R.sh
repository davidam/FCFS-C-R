#!/bin/bash

#Nombre:		FCFS-NC-R.sh
#Descripcion: 	El script simula el funcionamiento de un algoritmo de gestión de procesos first coming first served 
#			  	con memoria no continua
#Fecha:			30/05/2022
#Autor:		  	Juan Peddro Alarcón Gómez
#Organización:	Universidad de Burgos

declare -a array_memoria_aux

#Declaración de los arrays del programa
declare -a arr_tiempos_llegada
declare -a arr_tiempos_ejecucion
declare -a arr_memoria
declare -a nombres_procesos
declare -a arr_colores

declare -a ordenado_arr_tiempos_llegada
declare -a ordenado_arr_tiempos_ejecucion
declare -a ordenado_arr_memoria
declare -a ordenado_nombres_procesos
declare -a ordenado_arr_colores

#Estos arrays se usan para crear el fichero con los datos introducidos por teclado, si así lo desea el usuario
#El motivo por el cual creo este array es que los otros son ordenados (por tll) y este debe permanecer sin hacerlo.
declare -a arr_tiempos_llegada_fichero
declare -a arr_tiempos_ejecucion_fichero
declare -a arr_memoria_fichero

#Colores
declare -r DEFAULT='\e[39m' #Color por defecto
declare -r BLACK='\e[30m'
declare -r WHITE='\e[97m'

declare -r RED='\e[31m'
declare -r GREEN='\e[32m'
declare -r YELLOW='\e[33m'
declare -r BLUE='\e[34m'
declare -r MAGENTA='\e[35m'
declare -r CYAN='\e[36m'
declare -r L_GRAY='\e[36m' #Gris claro
declare -r L_RED='\e[91m' #Rojo claro
declare -r L_GREEN='\e[92m' #Verde claro
declare -r L_YELLOW='\e[93m' #Amarillo claro
declare -r L_BLUE='\e[94m' #Azul claro
declare -r L_MAGENTA='\e[95m' #Magenta claro
declare -r L_CYAN='\e[96m' #Cyan claro
declare -r D_GRAY='\e[90m' #Gris oscuro

#Esta variable guarda el limite superior de huecos en memoria hasta el cual se reubica
reubicabilidad=0
contador_colores=1


#Nombre:		array_colores
#Descripcion: 	Esta función se va a encargar de llenar el array con colores en función del número de procesos introducidos
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function array_colores {
    arr_colores[$contador]="\e[3${contador_colores}m"
    contador_colores=$(($contador_colores+1))
    if [[ $contador_colores -eq 7 ]]; then
	contador_colores=1
    fi
}


#Nombre:		pregunto_si_otro_proceso_mas
#Descripcion: 	Esta función va a preguntar si quiero introducir otro proceso
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function pregunto_si_otro_proceso_mas {
	
				tput cuf 2 | tee -a informeBN.txt

				echo "¿Quieres añadir otro proceso?(s/n)" | tee -a informeColor.txt && echo "¿Quieres añadir otro proceso?(s/n)" >> informeBN.txt

				tput cuf 2 | tee -a informeBN.txt

	       		read "op"

	       		echo "$op" >> informeColor.txt && echo "$op" >> informeBN.txt

			until [[ ${op,,} = @(s|n) ]]
				do
					echo "Respuesta introducida no válida" | tee -a informeColor.txt && echo "Respuesta introducida no válida" >> informeBN.txt
					
					echo "Introduzca una respuesta que sea s/n" | tee -a informeColor.txt && echo "Introduzca una respuesta que sea s/n" >> informeBN.txt

					read "op"

					echo "$op" >> informeColor.txt && echo "$op" >> informeBN.txt

				done
}


#Nombre:		ordenar_arrays_por_Tll
#Descripcion: 	Esta función ordena los cinco arrays según el tiempo de llegada de cada proceso (de menor a mayor)
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function ordenar_arrays_por_Tll {
	#contador guarda el número de procesos
	for (( t = 1; t <= $contador; t++ )); do

		min=1000 #1000 es un numero que hace imposible que  haya uno menor

		for (( i = 1; i <= $contador; i++ )); do

			if [[ "${arr_tiempos_llegada[$i]}" -lt "$min" ]]; then
				min="${arr_tiempos_llegada[$i]}"
				Posicion="$i"
			fi
		done

		ordenado_arr_tiempos_llegada[$t]=${arr_tiempos_llegada[$Posicion]}
		ordenado_arr_tiempos_ejecucion[$t]=${arr_tiempos_ejecucion[$Posicion]}
		ordenado_arr_memoria[$t]=${arr_memoria[$Posicion]}
		ordenado_nombres_procesos[$t]=${nombres_procesos[$Posicion]}
		ordenado_arr_colores[$t]=${arr_colores[$Posicion]}

		arr_tiempos_llegada[$Posicion]="1000"
			
		####################
	done
}



#Nombre:		copiar_arrays
#Descripcion: 	Esta función copia el contenido de los vectores ordenados a los desordenados
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function copiar_arrays {
	for (( i = 1; i <= $contador; i++ )); do
		arr_tiempos_llegada[$i]=${ordenado_arr_tiempos_llegada[$i]}
		arr_tiempos_ejecucion[$i]=${ordenado_arr_tiempos_ejecucion[$i]}
		arr_memoria[$i]=${ordenado_arr_memoria[$i]}
		nombres_procesos[$i]=${ordenado_nombres_procesos[$i]}
		arr_colores[$i]=${ordenado_arr_colores[$i]}
	done
}



#Nombre:		copia_inversa_arrays
#Descripcion: 	Esta función copia el contenido de los vectores desordenados a los ordenados
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function copia_inversa_arrays {
	for (( i = 1; i <= $contador; i++ )); do
		ordenado_arr_tiempos_llegada[$i]=${arr_tiempos_llegada[$i]}
		ordenado_arr_tiempos_ejecucion[$i]=${arr_tiempos_ejecucion[$i]}
		ordenado_arr_memoria[$i]=${arr_memoria[$i]}
		ordenado_nombres_procesos[$i]=${nombres_procesos[$i]}
		ordenado_arr_colores[$i]=${arr_colores[$i]}
	done
}


function imprimir_informe
{

	clear 

	tput bold | tee -a "informeBN.txt"

	tput cud 3 | tee -a "informeBN.txt"

	tput cuf 15 | tee -a "informeBN.txt"

	echo "Informe Final" | tee -a "informeBN.txt"

	tput sgr0 | tee -a "informeBN.txt"

	imprimir_tabla_datos

	printf " TIEMPO MEDIO ESPERA = $tiempo_medio_espera " | tee -a "informeBN.txt"

	printf "TIEMPO MEDIO RETORNO = $tiempo_medio_retorno\n \n" | tee -a "informeBN.txt"

	truncado_tiempo

	printf "\n" | tee -a "informeBN.txt"

}



#Nombre:		imprimir_tabla_datos
#Descripcion: 	Esta función imprime una primera version de la tabla de datos NO SE USA EN LA VERSION FINAL
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function imprimir_tabla_datos {

	tput cud 1 | tee -a informeBN.txt

	tput cuf 1 | tee -a informeBN.txt

	printf "┌────────────┬────────────┬────────────┬────────────┐ \n" | tee -a informeBN.txt

	tput cuf 1 | tee -a informeBN.txt

	printf "│ %3s REF %2s │ %3s TLL %2s │ %3s TEJ %2s │ %3s MEM %2s │\n" | tee -a informeBN.txt

	tput cuf 1 | tee -a informeBN.txt
	
	printf "├────────────┼────────────┼────────────┼────────────┤ \n" | tee -a informeBN.txt

	

	for (( i = 1; i <= $contador; i++ )); do
		
		tput cuf 1 | tee -a informeBN.txt

		printf "│ ${ordenado_arr_colores[$i]} %2s ${ordenado_nombres_procesos[$i]}$DEFAULT %3s"

		printf "│ %3s ${ordenado_nombres_procesos[$i]} %3s" >> informeBN.txt


		if [ "${ordenado_arr_tiempos_llegada[$i]}" = "-" ]
		then

			printf "│ ${ordenado_arr_colores[$i]} %3s ${ordenado_arr_tiempos_llegada[$i]}$DEFAULT %4s"  

			printf "│ %4s ${ordenado_arr_tiempos_llegada[$i]} %4s" >> informeBN.txt

		elif [ "${ordenado_arr_tiempos_llegada[$i]}" -lt 10 ] &>/dev/null
			then

			printf "│ ${ordenado_arr_colores[$i]} %3s ${ordenado_arr_tiempos_llegada[$i]}$DEFAULT %4s"  

			printf "│ %4s ${ordenado_arr_tiempos_llegada[$i]} %4s" >> informeBN.txt

		elif [ "${ordenado_arr_tiempos_llegada[$i]}" -gt 9 ]&>/dev/null && [ "${ordenado_arr_tiempos_llegada[$i]}" -lt 100 ]&>/dev/null
			then

			printf "│ ${ordenado_arr_colores[$i]} %2s ${ordenado_arr_tiempos_llegada[$i]}$DEFAULT %4s"

			printf "│ %3s ${ordenado_arr_tiempos_llegada[$i]} %4s" >> informeBN.txt

		elif [ "${ordenado_arr_tiempos_llegada[$i]}" -ge 100 ]&>/dev/null
			then

			printf "│ ${ordenado_arr_colores[$i]} %2s ${ordenado_arr_tiempos_llegada[$i]}$DEFAULT %3s"

			printf "│ %3s ${ordenado_arr_tiempos_llegada[$i]} %3s" >> informeBN.txt

		fi


		if [ "${ordenado_arr_tiempos_ejecucion[$i]}" = "-" ]
		then

			printf "│ ${ordenado_arr_colores[$i]} %3s ${ordenado_arr_tiempos_ejecucion[$i]}$DEFAULT %4s"

			printf "│ %4s ${ordenado_arr_tiempos_ejecucion[$i]} %4s" >> informeBN.txt

		elif [ "${ordenado_arr_tiempos_ejecucion[$i]}" -lt 10 ]&>/dev/null
			then
			
			printf "│ ${ordenado_arr_colores[$i]} %3s ${ordenado_arr_tiempos_ejecucion[$i]}$DEFAULT %4s"

			printf "│ %4s ${ordenado_arr_tiempos_ejecucion[$i]} %4s" >> informeBN.txt

		elif [ "${ordenado_arr_tiempos_ejecucion[$i]}" -gt 9 ]&>/dev/null && [ "${ordenado_arr_tiempos_ejecucion[$i]}" -lt 100 ]&>/dev/null
			then
			
			printf "│ ${ordenado_arr_colores[$i]} %2s ${ordenado_arr_tiempos_ejecucion[$i]}$DEFAULT %4s"

			printf "│ %3s ${ordenado_arr_tiempos_ejecucion[$i]} %4s" >> informeBN.txt

		elif [ "${ordenado_arr_tiempos_ejecucion[$i]}" -ge 100 ]&>/dev/null
			then
			
			printf "│ ${ordenado_arr_colores[$i]} %2s ${ordenado_arr_tiempos_ejecucion[$i]}$DEFAULT %3s"

			printf "│ %3s ${ordenado_arr_tiempos_ejecucion[$i]} %3s" >> informeBN.txt
		fi


		if [ "${ordenado_arr_memoria[$i]}" = "-" ]
			then

			printf "│ ${ordenado_arr_colores[$i]} %3s ${ordenado_arr_memoria[$i]}$DEFAULT %3s │"

			printf "│ %4s ${ordenado_arr_memoria[$i]} %3s │" >> informeBN.txt

		elif [ "${ordenado_arr_memoria[$i]}" -lt 10 ]&>/dev/null
			then
			
			printf "│ ${ordenado_arr_colores[$i]} %3s ${ordenado_arr_memoria[$i]}$DEFAULT %3s │"

			printf "│ %4s ${ordenado_arr_memoria[$i]} %3s │" >> informeBN.txt

		elif [ "${ordenado_arr_memoria[$i]}" -gt 9 ]&>/dev/null && [ "${ordenado_arr_memoria[$i]}" -lt 100 ]&>/dev/null
			then
				
				printf "│ ${ordenado_arr_colores[$i]} %2s ${ordenado_arr_memoria[$i]}$DEFAULT %3s │"

				printf "│ %3s ${ordenado_arr_memoria[$i]} %3s │" >> informeBN.txt

		elif [ "${ordenado_arr_memoria[$i]}" -ge 100 ]&>/dev/null
			then
				
				printf "│ ${ordenado_arr_colores[$i]} %2s ${ordenado_arr_memoria[$i]}$DEFAULT %2s │"

				printf "│ %3s ${ordenado_arr_memoria[$i]} %2s │" >> informeBN.txt
		fi
		
		printf "\n" | tee -a informeBN.txt
	
	done

	tput cuf 1 | tee -a informeBN.txt

	printf "└────────────┴────────────┴────────────┴────────────┘\n" | tee -a informeBN.txt
}


#Nombre:		entrada_por_teclado
#Descripcion: 	Esta función llena los arrays de datos con lo que introduzca el usuario, también genera los nombres automaticos
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function entrada_por_teclado {
	op="s"
	contador=1
	
	echo "Introduce el tamaño de la memoria:" >> informeColor.txt

	echo "Introduce el tamaño de la memoria:" >> informeBN.txt

	tput cuf 1 | tee -a informeBN.txt
 
	while read -p "Introduce el tamaño de la memoria:"  tamanio_memoria
	do

		tput cuf 1 | tee -a informeBN.txt

		if [ -z "$tamanio_memoria" ] 
				
				then

					echo -n "$tamanio_memoria" >> informeColor.txt

					echo -n "$tamanio_memoria" >> informeBN.txt

					echo " " >> informeColor.txt

					echo " " >> informeBN.txt

					echo "El tamaño de memoria no puede estar vacío" | tee -a informeColor.txt

					echo "El tamaño de memoria no puede estar vacío" >> informeBN.txt


				elif ! [ "$tamanio_memoria" -eq "$tamanio_memoria" &>/dev/null ]
				 
				 then
				
					echo -n "$tamanio_memoria" >> informeColor.txt

					echo -n "$tamanio_memoria" >> informeBN.txt

					echo " " >> informeColor.txt

					echo " " >> informeBN.txt

					echo "Inserte números enteros" | tee -a informeColor.txt

					echo "Inserte números enteros" >> informeBN.txt

				elif [ "$tamanio_memoria" -lt 0 ]
					
					then

					echo -n "$tamanio_memoria" >> informeColor.txt

					echo -n "$tamanio_memoria" >> informeBN.txt

					echo " " >> informeColor.txt

					echo " " >> informeBN.txt
					
					echo "El tamaño no puede ser negativo" | tee -a informeColor.txt

					echo "El tamaño no puede ser negativo" >> informeBN.txt

				else 

					echo -n "$tamanio_memoria" >> informeColor.txt

					echo -n "$tamanio_memoria" >> informeBN.txt

					echo " " >> informeColor.txt

					echo " " >> informeBN.txt

					break
				
				fi

	done

	echo "El tamaño de la memoria es $tamanio_memoria"| tee -a informeColor.txt

	echo "El tamaño de la memoria es $tamanio_memoria" >> informeBN.txt

	while read -p "Introduce el número hasta el cual se reubica:" reubicabilidad

	do

		echo "Introduce el número hasta el cual se reubica:" >> informeBN.txt 

		[ -z "$reubicabilidad" ] && echo "Debe introducir la reubicabilidad" | tee -a informeColor.txt && echo "Debe introducir la reubicabilidad" >> informeBN.txt && continue

		! [ "$reubicabilidad" -eq "$reubicabilidad" ]&>/dev/null && echo "Inserte enteros positivos"  && echo "Inserte enteros positivos" >> "informeBN.txt" && continue

		[ "$reubicabilidad" -lt 0 ] && echo "La reubicabilidad no puede ser menor a 0" | tee -a informeColor.txt && echo "La reubicabilidad no puede ser menor a 0" >> informeBN.txt && continue
	
		echo "La reubicabilidad es de $reubicabilidad" | tee -a informeColor.txt

		echo "La reubicabilidad es de $reubicabilidad" >> informeBN.txt

		break

	done

	
	while [[ "${op,,}" == @(s) ]]; do

			arr_tiempos_llegada[$contador]="-"
			arr_tiempos_ejecucion[$contador]="-"
			arr_memoria[$contador]="-"

			if [ $contador -gt 9 ]; then
				nombres_procesos[$contador]="P$contador"
			fi
			
			if [ $contador -lt 10 ]; then
				nombres_procesos[$contador]="P0$contador"
			fi
			array_colores
			copia_inversa_arrays
			
			clear
			imprimir_tabla_datos | tee -a informeColor.txt

			echo "Tiempo de llegada ${nombres_procesos[$contador]}:" >> informeColor.txt 

			echo "Tiempo de llegada ${nombres_procesos[$contador]}:" >> informeBN.txt 

			tput cuf 2 | tee -a informeBN.txt

			while read -p "Tiempo de llegada ${nombres_procesos[$contador]}:" tiempo_llegada
			do
				tput cuf 2 | tee -a informeBN.txt
				
				if [ -z "$tiempo_llegada" ] 
				
				then

					echo -n "$tiempo_llegada" >> informeColor.txt

					echo " " >> informeColor.txt

					echo -n "$tiempo_llegada" >> informeBN.txt

					echo " " >> informeBN.txt

					echo "El tiempo de llegada no puede estar vacío" | tee -a informeColor.txt

					echo "El tiempo de llegada no puede estar vacío" >> informeBN.txt

				elif ! [ "$tiempo_llegada" -eq "$tiempo_llegada" &>/dev/null ]
				 
				 then
					
					echo -n "$tiempo_llegada" >> informeColor.txt

					echo -n "$tiempo_llegada" >> informeBN.txt

					echo " " >> informeColor.txt

					echo " " >> informeBN.txt

					echo "Inserte números" | tee -a informeColor.txt

					echo "Inserte números" >> informeBN.txt

				elif [ "$tiempo_llegada" -lt 0 ]
					then
					
					echo -n "$tiempo_llegada" >> informeColor.txt

					echo -n "$tiempo_llegada" >> informeBN.txt

					echo " " >> informeColor.txt

					echo " " >> informeBN.txt

					echo "El tiempo de llegada no puede ser negativo" | tee -a informeColor.txt

					echo "El tiempo de llegada no puede ser negativo" >> informeBN.txt

				else 

					echo -n "$tiempo_llegada" >> informeColor.txt

					echo " " >> informeColor.txt

					echo -n "$tiempo_llegada" >> informeBN.txt

					echo " " >> informeBN.txt

					break
				
				fi

			done

			
			arr_tiempos_llegada[$contador]=$tiempo_llegada
			arr_tiempos_llegada_fichero[$contador]=$tiempo_llegada

			copia_inversa_arrays
			clear
			imprimir_tabla_datos

			echo "Tiempo de ejecución ${nombres_procesos[$contador]}:" >> informeColor.txt

			echo "Tiempo de ejecución ${nombres_procesos[$contador]}:" >> informeBN.txt

			tput cuf 2 | tee -a informeBN.txt

			while read -p "Tiempo de ejecución ${nombres_procesos[$contador]}:" tiempo_ejecucion
			do

				tput cuf 2 | tee -a informeBN.txt
				
				if [ -z "$tiempo_ejecucion" ] 
				
				then

					echo -n "$tiempo_ejecucion" >> informeColor.txt

					echo " " >> informeColor.txt

					echo -n "$tiempo_ejecucion" >> informeBN.txt

					echo " " >> informeBN.txt

					echo "El tiempo de ejecucion no puede estar vacío" | tee -a informeColor.txt

					echo "El tiempo de ejecucion no puede estar vacío" >> informeBN.txt

				elif ! [ "$tiempo_ejecucion" -eq "$tiempo_ejecucion" &>/dev/null ]
				 
				 then
					
					echo -n "$tiempo_ejecucion" >> informeColor.txt

					echo -n "$tiempo_ejecucion" >> informeBN.txt

					echo " " >> informeColor.txt

					echo " " >> informeBN.txt

					echo "Inserte números" | tee -a informeColor.txt

					echo "Inserte números" >> informeBN.txt

				elif [ "$tiempo_ejecucion" -lt 0 ]
					then
					
					echo -n "$tiempo_ejecucion" >> informeColor.txt

					echo " " >> informeColor.txt

					echo -n "$tiempo_ejecucion" >> informeBN.txt

					echo " " >> informeBN.txt

					echo "El tiempo de ejecucion no puede ser negativo" | tee -a informeColor.txt

					echo "El tiempo de ejecucion no puede ser negativo" >> informeBN.txt

				else 

					echo -n "$tiempo_ejecucion" >> informeColor.txt

					echo " " >> informeColor.txt

					echo -n "$tiempo_ejecucion" >> informeBN.txt

					echo " " >> informeBN.txt

					break
				
				fi

			done
			
			arr_tiempos_ejecucion[$contador]=$tiempo_ejecucion
			arr_tiempos_ejecucion_fichero[$contador]=$tiempo_ejecucion

			copia_inversa_arrays
			clear
			imprimir_tabla_datos
			
			echo "Memoria ${nombres_procesos[$contador]}:" >> informeColor.txt

			echo "Memoria ${nombres_procesos[$contador]}:" >> informeBN.txt

			tput cuf 2 | tee -a informeBN.txt

			while read -p "Memoria ${nombres_procesos[$contador]}:" memoria
			do
				tput cuf 2 | tee -a informeBN.txt

				if [ -z "$memoria" ] 
				
				then

					echo -n "$memoria" >> informeColor.txt

					echo " " >> informeColor.txt

					echo -n "$memoria" >> informeBN.txt

					echo " " >> informeBN.txt

					echo "El tiempo de ejecucion no puede estar vacío" | tee -a informeColor.txt

					echo "El tiempo de ejecucion no puede estar vacío" >> informeBN.txt

				elif ! [ "$memoria" -eq "$memoria" &>/dev/null ]
				 
				 then
					
					echo -n "$memoria" >> informeColor.txt

					echo " " >> informeColor.txt

					echo -n "$memoria" >> informeBN.txt

					echo " " >> informeBN.txt

					echo "Inserte números enteros" | tee -a informeColor.txt

					echo "Inserte números enteros" >> informeBN.txt

				elif [ "$memoria" -lt 0 ]
					then
					
					echo -n "$memoria" >> informeColor.txt

					echo " " >> informeColor.txt

					echo -n "$memoria" >> informeBN.txt

					echo " " >> informeBN.txt

					echo "La memoria no puede ser negativa" | tee -a informeColor.txt

					echo "La memoria no puede ser negativa" | tee -a informeBN.txt

				elif [ "$memoria" -gt "$tamanio_memoria" ]
					then
					
					echo -n "$memoria" >> informeColor.txt

					echo " " >> informeColor.txt

					echo -n "$memoria" >> informeBN.txt

					echo " " >> informeBN.txt

					echo "La memoria no puede ser mayor que la memoria total" | tee -a informeColor.txt

					echo "La memoria no puede ser mayor que la memoria total" | tee -a informeBN.txt
				
				else 

					echo -n "$memoria" >> informeColor.txt

					echo " " >> informeColor.txt

					echo -n "$memoria" >> informeBN.txt

					echo " " >> informeBN.txt

					break
				
				fi

			done
			
			arr_memoria[$contador]=$memoria
			arr_memoria_fichero[$contador]=$memoria

			ordenar_arrays_por_Tll
			copiar_arrays

			clear
			imprimir_tabla_datos | tee -a informeColor.txt
			pregunto_si_otro_proceso_mas 

			if [ "${op,,}" == "s" ]; then
				contador=$(($contador+1))
			fi
	done
}



#Nombre:		entrada_aleatoria
#Descripcion: 	Esta función llena los arrays de datos aleatoriamente, también genera los nombres automaticos
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function entrada_aleatoria {
	tamanio_memoria=$((RANDOM%99))
	reubicabilidad=$((RANDOM%6))
	echo "El tamaño de la memoria es $tamanio_memoria"
	echo "El numero hasta el cual se reubica es $reubicabilidad"
	echo "¿Cuántos procesos quieres crear?" 
	read procesos_a_crear
	contador=1
	while [ $procesos_a_crear -ge $contador ]; do

			arr_tiempos_llegada[$contador]=$((RANDOM%99))
			arr_tiempos_ejecucion[$contador]=$(((RANDOM%98)+1))
			limite_superior_mem=$(($tamanio_memoria-1))
			arr_memoria[$contador]=$(((RANDOM%$limite_superior_mem)+1))

			arr_tiempos_llegada_fichero[$contador]="${arr_tiempos_llegada[$contador]}"
			arr_tiempos_ejecucion_fichero[$contador]="${arr_tiempos_ejecucion[$contador]}"
			arr_memoria_fichero[$contador]="${arr_memoria[$contador]}"


			if [ $contador -gt 9 ]; then
				nombres_procesos[$contador]="P$contador"

			fi
			
			if [ $contador -lt 10 ]; then
				nombres_procesos[$contador]="P0$contador"
			fi

			array_colores
			ordenar_arrays_por_Tll
			copiar_arrays

			contador=$(($contador+1))

	done

	if [ $contador -gt $procesos_a_crear ]; then
		contador=$procesos_a_crear
	fi
			
}

#Nombre:		corteDatosEjecucionAnterior
#Descripcion: 	Función que recoge los datos del fichero ejecucionAnterior.txt
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function corteDatosEjecucionAnterior {
	
	contador=1

	contador_lineas=1

	while read linea 
	do
		
		

		if [ "$contador_lineas" -eq 1 ]
		then
			
			tamanio_memoria=$(echo $linea | cut -d ":" -f2)

			echo "El tamaño de la memoria es $tamanio_memoria" | tee -a informeBN.txt

			((contador_cabecera++))

		elif [ "$contador_lineas" -eq 2 ]
			then

			reubicabilidad=$(echo $linea | cut -d ":" -f2)

			((contador_cabecera++))	

		elif [ "$contador_lineas" -ge 4 ]
		
		then

		if [ ! -z "$linea" ] #Sí la línea no está vacía
			then
				
			arr_tiempos_llegada[$contador]=$(echo $linea | cut -d ":" -f1)

			arr_tiempos_ejecucion[$contador]=$(echo $linea | cut -d ":" -f2)
		
			arr_memoria[$contador]=$(echo $linea | cut -d ":" -f3)

			if [[ "${arr_memoria[$contador]}" -gt "$tamanio_memoria" ]] #Comprobamos que la memoria de los procesos no sea superior a la memoria total
				then
				
					echo "La memoria del proceso ${arr_memoria[$contador]} no puede ser mayor que la memoria total: $tamanio_memoria" | tee -a informeBN.txt

				exit 1

			fi

		if [ "$contador" -gt 9 ]; then
		
			nombres_procesos[$contador]="P$contador"
		
		fi
		
		if [ "$contador" -lt 10 ]; then
			
			nombres_procesos[$contador]="P0$contador"
		
		fi
			array_colores

			((contador++))

		fi

		fi

		((contador_lineas++))

	done < "$fichero_entrada"


		if [ $contador -gt $procesos_en_fichero ]; then
			
			contador=$procesos_en_fichero
		
		fi
		
		cd ../	
}


#Nombre:		corte_datos
#Descripcion: 	Esta función llena los arrays con los datos del fichero introducido, también genera los nombres automaticos
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function corte_datos {
	
	tamanio_memoria=`sed -n 1p $fichero_entrada | cut -d ":" -f 2`
	reubicabilidad=`sed -n 2p $fichero_entrada | cut -d ":" -f 2`
	echo "El tamaño de la memoria es $tamanio_memoria" | tee -a informeBN.txt

	for (( contador = 1; contador <= $(($procesos_en_fichero+3)); contador++ )); do
		arr_tiempos_llegada[$contador]=`sed -n $(($contador+3))p $fichero_entrada | cut -d ":" -f 1`
		arr_tiempos_ejecucion[$contador]=`sed -n $(($contador+3))p $fichero_entrada | cut -d ":" -f 2`
		arr_memoria[$contador]=`sed -n $(($contador+3))p $fichero_entrada | cut -d ":" -f 3`

		if [[ "${arr_memoria[$contador]}" -gt "$tamanio_memoria" ]] #Comprobamos que la memoria de los procesos no sea superior a la memoria total
			then
				
				echo "La memoria del proceso ${arr_memoria[$contador]} no puede ser mayor que la memoria total: $tamanio_memoria" | tee -a informeBN.txt

				exit 1

		fi

		if [ $contador -gt 9 ]; then
			nombres_procesos[$contador]="P$contador"
		fi
		
		if [ $contador -lt 10 ]; then
			nombres_procesos[$contador]="P0$contador"
		fi

		array_colores
	done

	if [ $contador -gt $procesos_en_fichero ]; then
		contador=$procesos_en_fichero
	fi

	cd ../		
}


#Nombre:		entrada_por_fichero
#Descripcion: 	Esta función realiza la entrada por fichero, pide un fichero al usuario y con corte_datos coge los datos de ese fichero
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function entrada_por_fichero {
	
	echo "Ficheros en el directorio FICHEROS_ENTRADA"
	
	cd FICHEROS_ENTRADA
	
	ls -l
	
	while read -p "Escribe el fichero del que deseas extraer los datos:" fichero_entrada
 	
 	do
 		[ -z "$fichero_entrada" ] && echo "Inserte nombre del fichero" | tee -a informeColor.txt && echo "Inserte nombre del fichero" >> informeBN.txt && continue

 		[ ! -e "$fichero_entrada" ] && echo "No existe el fichero, inserte uno" | tee -a informeColor.txt && echo "No existe el fichero, inserte uno" >> informeBN.txt && continue

 		[ ! -f "$fichero_entrada" ] && echo "No es un fichero" | tee -a informeColor.txt && echo "No es un fichero" >> informeBN.txt && continue

 		break

	done

	procesos_en_fichero=$(cat $fichero_entrada | wc -l)
	
	procesos_en_fichero=$((procesos_en_fichero-3)) 

	tput cuf 1 | tee -a "informeBN.txt"
	
	echo "El numero de líneas del fichero es $procesos_en_fichero" | tee -a "InformeColor.txt" 

	echo "El numero de líneas del fichero es $procesos_en_fichero" >> "InformeBN.txt" 
	
	contador=$procesos_en_fichero
	
	corte_datos

	cd ../.

}


#Nombre:		ejecucionAnterior
#Descripcion: 	Esta función lee la ejecución anterior
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function ejecucionAnterior
{

	cd FICHEROS_ENTRADA

	fichero_entrada="ultimosdatosejecutados.txt"

	if ! [ -e "$fichero_entrada" ] || ! [ -f "$fichero_entrada" ]
		then
			
			tput cuf 2 | tee -a informeBN.txt

			tput bold

			echo "¡No existe el fichero!¡No es posible continuar!" | tee -a informeBN.txt

			tput sgr0

			exit 1
	fi

	procesos_en_fichero=$(cat $fichero_entrada | wc -l)
	
	procesos_en_fichero=$((procesos_en_fichero-3))
	
	echo "El número de líneas del fichero es $procesos_en_fichero" | tee -a informeBN.txt
	
	corteDatosEjecucionAnterior

	cd ../.
}


#Nombre:		creacionFicheroEjecucionAnterior
#Descripcion: 	Esta función crea el fichero para repetir la ejecución anterior
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function crearFicheroEjecucionAnterior
{
	
	[ ! -w "." ] && echo "No se dispone de permisos de escritura" >> informeBN.txt && echo "No se dispone de permisos de escritura" | tee -a informeColor.txt && exit 1

	[ "$opcion_menu_datos" -eq 1 ] && fichero_datos_anterior="ultimosdatosejecutados.txt" #Sí es la entrada manual

	[ "$opcion_menu_datos" -eq 4 ] && fichero_datos_anterior="ultimosdatosaleatorios.txt" #Sí es la opción de "Aleatorio Manual"

	touch "$fichero_datos_anterior"

	echo "MEM:$tamanio_memoria">"$fichero_datos_anterior"
	echo "REU:$reubicabilidad">>"$fichero_datos_anterior"
	
	echo "Tll:Tej:Mem">>"$fichero_datos_anterior"
	

	for (( i = 1; i <= $contador; i++ )); do
		if [[ $i -eq $contador ]]; then
			echo -n "${arr_tiempos_llegada_fichero[$i]}:${arr_tiempos_ejecucion_fichero[$i]}:${arr_memoria_fichero[$i]}">>$fichero_datos_anterior
		else
			echo "${arr_tiempos_llegada_fichero[$i]}:${arr_tiempos_ejecucion_fichero[$i]}:${arr_memoria_fichero[$i]}">>$fichero_datos_anterior

		fi
	done

	echo " " >> "$fichero_datos_anterior"

	[ ! -d FICHEROS_ENTRADA ] && mkdir FICHEROS_ENTRADA

	mv "$fichero_datos_anterior" FICHEROS_ENTRADA
	
}




#Nombre:		menu
#Descripcion: 	Función principal de menú
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function menu {

	entrada_maual=0


while true
do
	 tput cuf 1 | tee -a informeBN.txt
	 
	 echo "Elige una de las opciones para introducir los datos:" | tee -a informeColor.txt

	 echo "Elige una de las opciones para introducir los datos:" >> informeBN.txt

	 tput cuf 1 | tee -a informeBN.txt

	 echo "1-> Entrada por teclado"| tee -a informeColor.txt

	 echo "1-> Entrada por teclado" >> informeBN.txt
	 
	 tput cuf 1 | tee -a informeBN.txt

	 echo "2-> Repetición ejecución anterior"| tee -a informeColor.txt

	 echo "2-> Repetición ejecución anterior" >> informeBN.txt
	 
	 tput cuf 1 | tee -a informeBN.txt

	 echo "3-> Leer desde un archivo"| tee -a informeColor.txt

	 echo "3-> Leer desde un archivo" >> informeBN.txt
	 
	 tput cuf 1 | tee -a informeBN.txt

	 echo "4-> Aleatorio Manual" | tee -a informeColor.txt

	 echo "4-> Aleatorio Manual" >> informeBN.txt

	 tput cuf 1 | tee -a informeBN.txt

	 echo "5-> Aleatorio de última modificación" | tee -a informeColor.txt

	 echo "5-> Aleatorio de última modificación" >> informeBN.txt

	 tput cuf 1 | tee -a informeBN.txt

	 echo "6-> Aleatorio desde fichero" | tee -a informeColor.txt

	 echo "6-> Aleatorio desde fichero" >> informeBN.txt

	 tput cuf 1 | tee -a informeBN.txt

	 echo "0-> Salir" | tee -a informeColor.txt

	 echo "0-> Salir" >> informeBN.txt

	 tput cuf 1 | tee -a informeBN.txt

	 read opcion_menu_datos

	case $opcion_menu_datos in

		1)	echo "$opcion_menu_datos" >> informeColor.txt
			echo "$opcion_submenu_datos" >> informeBN.txt
			tput cuf 1 | tee -a informeBN.txt
			entrada_manual=1
			echo "Has elegido entrada por teclado:" | tee -a informeColor.txt
			echo "Has elegido entrada por teclado:" >> informeBN.txt
			entrada_por_teclado
			crear_fichero_entrada
			break
		;;

		2) echo "$opcion_menu_datos" >> informeColor.txt
		   echo "$opcion_menu_datos" >> informeBN.txt
		
		   tput cuf 1 | tee -a informeBN.txt

		   echo "Has elegido repetir la ejecucición anterior" | tee -a informeColor.txt
		   echo "Has elegido repetir la ejecucición anterior" >> informeBN.txt

		   ejecucionAnterior

		   ordenar_arrays_por_Tll
		   copiar_arrays

		   break
		;;

		3)	echo "$opcion_menu_datos" >> informeColor.txt
			echo "$opcion_menu_datos" >> informeBN.txt
			echo "Has elegido lectura desde archivo:" | tee -a informeColor.txt
			echo "Has elegido lectura desde archivo:" >> informeBN.txt
			entrada_por_fichero

			
			ordenar_arrays_por_Tll
			copiar_arrays
			break
		;;

		4)  echo "$opcion_menu_datos" >> informeColor.txt
			echo "$opcion_menu_datos" >> informeBN.txt
			tput cuf 1 | tee -a informeBN.txt
			echo "Has elegido generar los datos aleatoriamente:" | tee -a informeColor.txt
			echo "Has elegido generar los datos aleatoriamente:" >> informeBN.txt
			entrada_aleatoria
			crearFicheroEjecucionAnterior
			break
		;;


		5)	echo "$opcion_menu_datos" >> informeColor.txt
			echo "$opcion_menu_datos" >> informeBN.txt
			tput cuf 1 | tee -a informeBN.txt
			echo "Has elegido aleatorios de última modificación:" | tee -a informeColor.txt
			echo "Has elegido aleatorios de última modificación:" >> informeBN.txt

			break
		;;

		6)	echo "$opcion_menu_datos" >> informeColor.txt
			echo "$opcion_menu_datos" >> informeBN.txt
			tput cuf 1 | tee -a informeBN.txt
			echo "Has elegido aleatorios desde fichero:" | tee -a informeColor.txt
			echo "Has elegido aleatorios desde fichero:" >> informeBN.txt


			break
		;;

		0) 	echo "$opcion_menu_datos" >> informeColor.txt
		   	echo "$opcion_menu_datos" >> informeBN.txt

			tput cuf 1 | tee -a informeBN.txt

			echo "El programa ha finalizado" | tee -a informeColor.txt
			echo "El programa ha finalizado" >> informeBN.txt

			exit 0
		;;	

		*)	
			echo "¡ERROR! $opcion_menu_datos" | tee -a informeColor.txt
			echo "¡ERROR! $opcion_menu_datos" >> informeBN.txt
			continue
		;;
	esac
		break
done
	
}

#Nombre:		Submenú para la ejecución 
#Descripcion: 	Función de submenú que da al usuario que puede elegir el modo de ejecución
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function submenuEleccionTipoDeEjecucion
{

	ejecucion_por_eventos=0

	ejecucion_por_completo=0

	ejecucion_por_automatico=0

	while true
	do

	 tput cuf 2 | tee -a informeBN.txt
	 
	 echo "Elige una de las siguientes opciones para la ejecución:" 

	 echo "Elige una de las siguientes opciones para la ejecución:" >> informeBN.txt

	 tput cuf 2 | tee -a informeBN.txt

	 echo "1-> Ejecución por eventos(pulsando intro)" 

	 echo "1-> Ejecución por eventos(pulsando intro)" >> informeBN.txt
	  
	 tput cuf 2 | tee -a informeBN.txt

	 echo "2-> Automático(definir segundos)" 

	 echo "2-> Automático(definir segundos)" >> informeBN.txt
	 
	 tput cuf 2 | tee -a informeBN.txt

	 echo "3-> Completo(sin pausas)" 

	 echo "3-> Completo(sin pausas)" >> informeBN.txt
	 
	 tput cuf 2 | tee -a informeBN.txt

	 read opcion_submenu_datos

	 case $opcion_submenu_datos in

		1)	echo "$opcion_submenu_datos" >> informeColor.txt

			echo "$opcion_submenu_datos" >> informeBN.txt
			
			tput cuf 2 | tee -a informeBN.txt
			
			echo "Has elegido ejecución por eventos:" 

			echo "Has elegido ejecución por eventos:" >> informeBN.txt
			
			ejecucion_por_eventos=1
			
			break
		;;

		2)  echo "$opcion_submenu_datos" >> informeColor.txt

			echo "$opcion_submenu_datos" >> informeBN.txt

			tput cuf 2 | tee -a informeBN.txt

			echo "Has elegido modo automático, defina los segundos:" 

			echo "Has elegido modo automático, defina los segundos:" >> informeBN.txt

			ejecucion_por_automatico=1

			tput cuf 2
			
			while read -p "Segundos:" segundos
			do
			
				echo "$segundos" >> informeColor.txt && echo "$segundos" >> informeBN.txt

				[ -z "$segundos" ] && echo "No se puede quedar vacío"  && echo "No se puede quedar vacío" >> "informeBN.txt" && continue

				! [ "$segundos" -eq "$segundos" ]&>/dev/null && echo "Inserte enteros positivos"  && echo "Inserte enteros positivos" >> "informeBN.txt" && continue

				[ "$segundos" -le 0 ] && echo "Los segundos no pueden ser negativos o igual a 0"  && echo "Los segundos no pueden ser negativos" >> "informeBN.txt" && continue

				break
			
			done
			
			break
		;;

		3)	echo "$opcion_submenu_datos" 

			echo "$opcion_submenu_datos" >> informeBN.txt
			
			tput cuf 2 | tee -a informeBN.txt

			echo "Has elegido completo, sin pausas:" 

			echo "Has elegido completo, sin pausas:" >> informeBN.txt

			ejecucion_por_completo=1
			
			break
		;;

		*)	
			tput cuf 2 | tee -a informeBN.txt

			echo "¡ERROR! $opcion_submenu_datos incorrecta" 

			echo "¡ERROR! $opcion_submenu_datos incorrecta" >> informeBN.txt
			
			continue
		;;
	esac
		break
done


}





#Nombre:		inicializar_array_memoria
#Descripcion: 	Esta función escribe en el array de memoria tantos ceros como el tamaño de la memoria
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function inicializar_array_memoria {
	for (( i = 0 ; i <=$tamanio_memoria ; i++ )); do
		array_memoria[$i]=0
	done
	#Despues de la ultima dirección de la memoria en el array guardo este numero para poder saber donde ha acabado
	uno=$(($tamanio_memoria + 1))
	array_memoria[$uno]=1000
}


#Nombre:		inicializar_array_tiempo_restante
#Descripcion: 	Esta función escribe en el array tiempo restante tantos - como procesos 
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function inicializar_array_tiempo_restante {
	array_tiempo_restante[0]=10000
	for (( i = 1 ; i <= $contador ; i++ )); do
		array_tiempo_restante[$i]="-"

	done
}


#Nombre:		inicializar_array_tiempo_espera
#Descripcion: 	Esta función escribe en el array tiempo espera tantos - como procesos 
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function inicializar_array_tiempo_espera {
	for (( i = 1 ; i <= $contador ; i++ )); do
		array_tiempo_espera[$i]="-"
	done
}



#Nombre:		inicializar_array_tiempo_espera
#Descripcion: 	Esta función escribe en el array tiempo retorno tantos - como procesos 
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function inicializar_array_tiempo_retorno {
	for (( i = 1 ; i <= $contador ; i++ )); do
		array_tiempo_retorno[$i]="-"
	done
}



#Nombre:		inicializar_array_estado
#Descripcion: 	Esta función escribe en el array tiempo espera tantos "Fuera del sistema" como procesos 
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function inicializar_array_estado {
	for (( i = 1 ; i <= $contador ; i++ )); do
		array_estado[$i]="Fuera del sistema"
	done
}


#Nombre:		imprimir_tabla
#Descripcion: 	Esta función imprime la tabla con los tiempos
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function imprimir_tabla {
	echo -e "┌───────────────┬───────────────┬───────────────┬───────────────┐"
	printf " %4s Ref %4s Tll %4s Tej %4s Mem %4s | %4s Tes %4s Trt %4s Tre %4s Estado"
	echo " "
	echo -e"└───────────────┴───────────────┴───────────────┴───────────────┘"
	for (( i = 1; i <= $contador; i++ )); do
		printf " ${ordenado_arr_colores[$i]}%-*s %-*s %-*s %-*s $DEFAULT|${ordenado_arr_colores[$i]} %-*s %-*s %-*s %-*s $DEFAULT\n" 3 "${ordenado_nombres_procesos[$i]}" 3 "${ordenado_arr_tiempos_llegada[$i]}" 3 "${ordenado_arr_tiempos_ejecucion[$i]}" 3 "${ordenado_arr_memoria[$i]}" 3 "${array_tiempo_espera[$i]}" 3 "${array_tiempo_retorno[$i]}" 3 "${array_tiempo_restante[$i]}" 3 "${array_estado[$i]}"
		#printf "│ ${ordenado_arr_colores[$i]} ${ordenado_nombres_procesos[$i]}$DEFAULT │ ${ordenado_arr_colores[$i]}${ordenado_arr_tiempos_llegada[$i]}$DEFAULT │ ${ordenado_arr_colores[$i]}${ordenado_arr_tiempos_ejecucion[$i]}$DEFAULT │ ${ordenado_arr_colores[$i]}${ordenado_arr_memoria[$i]}$DEFAULT │ ${ordenado_arr_colores[$i]} ${array_tiempo_espera[$i]}$DEFAULT│ ${ordenado_arr_colores[$i]} ${array_tiempo_retorno[$i]}$DEFAULT │ ${ordenado_arr_colores[$i]} ${array_tiempo_restante[$i]}$DEFAULT │ ${ordenado_arr_colores[$i]} ${direcciones_memoria_inicial[$j]} $DEFAULT │ ${ordenado_arr_colores[$i]} ${direcciones_memoria_final[$j]} $DEFAULT │ ${ordenado_arr_colores[$i]}${array_estado[$i]}$DEFAULT │ \n"
		#echo "nada"
	done
}


#Nombre:		anadirCola
#Descripcion: 	Esta función mete en el array cola los procesos que entren al sistema
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function anadirCola {
	((tamCola++))
	cola[$tamCola]=$proceso
	array_estado[$proceso]="En espera"
	cambio_a_imprimir=1
	array_tiempo_espera[$proceso]=0
	array_tiempo_retorno[$proceso]=0
}



#Nombre:		eliminarCola
#Descripcion: 	Esta función mueve todos los elementos en cola a la posicion anterior y elimina uno
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function eliminarCola {
	local -i i
	for(( i = 1; i <= tamCola; i++ )); do
		cola[$i]=${cola[$i+1]}
	done
	((tamCola--))
}


function organizarMemoria
{

	posicion=0
	memoria_ocupada=0

	for i in ${array_memoria[@]}
	do
		if [ "$i" -ne 0 ] && [ "$i" -ne 1000 ]
		then
			array_memoria_aux[$posicion]=$i
			((posicion++))
			((memoria_ocupada++))
		fi
	done

	posicion=0

	for i in ${!array_memoria[*]}
	do
		array_memoria[$i]=0
	done


	#echo "Memoria principal: ${array_memoria[@]}"
	#read 

	for i in ${array_memoria_aux[@]}
	do
		array_memoria[$posicion]=${array_memoria_aux[$posicion]}
		((posicion++))
	done

	array_memoria[-1]=1000

	for i in ${!array_memoria_aux[*]}
	do
		array_memoria_aux[$i]=0
	done

	#echo "Array de memoria:${array_memoria[@]}"
	#read

}



#Nombre:		anadirMemoria
#Descripcion: 	Esta función escribe en el array memoria tantos identificadores del proceso como huecos ocupe en memoria
#				Ejemplo:
#				tamaño memoria =9
#				3: ocupa 5 en memoria, le meto, estaba el 2 con 3 espacios 
#
#				Posiciones en el array: 	0 1 2 3 4 5 6 7 8 9 10
#				Contenido en la posicion:	0 2 2 2 3 3 3 3 3 0 1000
#
#				La posicion 0 no se utiliza y la 10 guarda 1000 que indica el final del array
#
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function anadirMemoria {
	#Esta variable se encarga de que en memoria metamos solo los indices que ocupa el proceso
	contador_memoria=0
	proceso_a_meter_en_memoria=${cola[1]}

	for (( i = 1; i <=$tamanio_memoria ; i++ )); do

		#echo "Cola:${cola[1]}"
		#echo "Proceso a meter en memoria:$proceso_a_meter_en_memoria"
		#echo "Contador de memoria:$contador_memoria"
		#echo "Ordenador arr memoria:${ordenado_arr_memoria[$proceso_a_meter_en_memoria]}"
		#read

		if [[ ${array_memoria[$i]} -eq 0 ]];then 

			if [[ $contador_memoria -lt ${ordenado_arr_memoria[$proceso_a_meter_en_memoria]} ]]; then
			#echo "Antes de meter_en_memoria:${array_memoria[$i]}"
			array_memoria[$i]=$proceso_a_meter_en_memoria

			#echo "Despues de meter_en_memoria:${array_memoria[$i]}"
			((contador_memoria++))

			fi

		fi


		

	done
	cambio_a_imprimir=1
	array_estado[$proceso_a_meter_en_memoria]="En memoria"
	array_tiempo_restante[$proceso_a_meter_en_memoria]=${ordenado_arr_tiempos_ejecucion[$proceso_a_meter_en_memoria]}
}


#Nombre:		eliminarMemoria
#Descripcion: 	Esta función elimina de la memoria el proceso en ejecucion
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function eliminarMemoria {
	for (( i = 1; i <=$tamanio_memoria ; i++ )); do

		if [[ ${array_memoria[$i]} -eq $proceso_en_ejecucion ]]
		then
			#echo "Antes de igualar:${array_memoria[$i]}"
			array_memoria[$i]=0
			#echo "Despues de igualar:${array_memoria[$i]}"
		fi
	done
}

#Nombre:		buscar_en_memoria
#Descripcion: 	Esta función busca en memoria que proceso (de los que estan en memoria) ha llegado antes al sistema
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function buscar_en_memoria {
	primero_en_llegar=1000
	#echo Memoria busq:
	#echo ${array_memoria[@]}
	for (( i = 1; i <= $tamanio_memoria ; i++ )); do
		if [[ ${array_memoria[$i]} -lt $primero_en_llegar ]] && [[ ${array_memoria[$i]} -ne 0 ]]
	     then
	        primero_en_llegar=${array_memoria[$i]}
	        #echo $primero_en_llegar
	    fi
	done
	if [[ $primero_en_llegar -ne 0 ]]; then
		echo "$primero_en_llegar"
	fi	
}


#Nombre:		buscar_en_memoria
#Descripcion: 	Calcula cuantos espacios con un 0 quedan en memoria
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function calcular_memoria_restante {
	memoria_restante=0
	for (( i = 1; i <= $tamanio_memoria ; i++ )); do
		if [[ ${array_memoria[$i]} -eq 0 ]]; then
			((memoria_restante++))
		fi
	done
}






#Nombre:		tiempo_linea_temporal
#Descripcion: 	Espacios para los tiempos a imprimir por pantalla
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function tiempo_linea_temporal {
	tiempo_linea_temporal[0]="  0"
	for (( i = 1; i <= $tiempo; i++ )); do
		if [[ ${array_linea_temporal[$i]} -ne ${array_linea_temporal[$(($i - 1))]} ]] && [[ $procesos_ejecutados -ne $contador ]]; then

			if [[ $i -lt 10 ]] && [[ $i -ne 10 ]]; then
				tiempo_linea_temporal[$i]="  $i"
			else
				if [[ $i -le 99 ]]; then
					tiempo_linea_temporal[$i]=" $i"
				else
					tiempo_linea_temporal[$i]="$i"
				fi
			fi


		fi

		if [[ ${array_linea_temporal[$i]} -eq ${array_linea_temporal[$(($i - 1))]} ]]; then
			tiempo_linea_temporal[$i]="   "
		fi

		if [[ $i -eq $tiempo ]] && [[ ${array_linea_temporal[$i]} -ne ${array_linea_temporal[$(($i - 1))]} ]]; then
			if [[ $procesos_ejecutados -ne $contador ]]; then
				
			
				tiempo_linea_temporal[$i]=""


				if [[ $i -lt 10 ]] && [[ $i -ne 10 ]]; then
					tiempo_linea_temporal[$i]="  $i"
				else
					if [[ $i -le 99 ]]; then
						tiempo_linea_temporal[$i]=" $i"
					else
						tiempo_linea_temporal[$i]="$i"
					fi
				fi
			fi
		fi
	done
}




#Nombre:		procesos_linea_temporal
#Descripcion: 	Clasificación de los procesos
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function procesos_linea_temporal {


	for (( i = 0; i <= $tiempo; i++ )); do
		if [[ ${array_linea_temporal[$i]} -ne ${array_linea_temporal[$(($i - 1))]} ]] && [[ $procesos_ejecutados -ne $contador ]]; then
			procesos_linea_temporal[$i]="${ordenado_nombres_procesos[${array_linea_temporal[$i]}]}"	
		fi

		if [[ ${array_linea_temporal[$i]} -eq ${array_linea_temporal[$(($i - 1))]} ]]; then
			 procesos_linea_temporal[$i]="   "
		fi

		#if [[ $i -eq $tiempo ]]; then
		#	procesos_linea_temporal[$i]="${ordenado_nombres_procesos[${array_linea_temporal[$i]}]}"
		#fi

		if [[ $i -eq $tiempo ]] && [[ ${array_linea_temporal[$i]} -ne ${array_linea_temporal[$(($i - 1))]} ]] && [[ $procesos_ejecutados -ne $contador ]]; then
			procesos_linea_temporal[$i]=""
			procesos_linea_temporal[$i]="${ordenado_nombres_procesos[${array_linea_temporal[$i]}]}"
		fi

		if [[ $i -eq 0 ]]; then
			procesos_linea_temporal[$i]="${ordenado_nombres_procesos[${array_linea_temporal[$i]}]}"	
		fi
	done

}




#Nombre:		direcciones_linea_memoria
#Descripcion: 	Espacios de memoria para imprimir por pantalla
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function direcciones_linea_memoria {

	for (( i = 1; i <= $tamanio_memoria; i++ )); do
		if [[ $i -ne 1 ]]; then
			if [[ ${array_memoria[$i]} -ne ${array_memoria[$(($i - 1))]} ]]; then
				

				if [[ $(($i - 1)) -lt 10 ]]; then
					direcciones_linea_memoria[$i]="  $(($i - 1))"
				fi

				if [[ $(($i - 1)) -ge 10 ]]; then
					direcciones_linea_memoria[$i]=" $(($i - 1))"
				fi	
			fi

			if [[ ${array_memoria[$i]} -eq ${array_memoria[$(($i - 1))]} ]]; then
				direcciones_linea_memoria[$i]="   "
			fi

			if [[ $i -eq $tamanio_memoria ]]; then

				if [[ $(($i - 1)) -lt 10 ]]; then
					direcciones_linea_memoria[$(($i + 1))]="  $i"
				fi

				if [[ $(($i - 1)) -ge 10 ]]; then
					direcciones_linea_memoria[$(($i + 1))]=" $i"
				fi
			fi
		fi
	done
}





#Nombre:		procesos_linea_memoria
#Descripcion: 	genera el array que guarda 3 espacios o el nombre del proceso dependiendo de si se debe imprimir o no
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function procesos_linea_memoria {


	for (( i = 1; i <= $(($tamanio_memoria + 1)); i++ )); do

		if [[ ${array_memoria[$i]} -ne ${array_memoria[$(($i - 1))]} ]]; then
			procesos_linea_memoria[$i]="${ordenado_nombres_procesos[${array_memoria[$i]}]}"	
		fi

		if [[ ${array_memoria[$i]} -eq ${array_memoria[$(($i - 1))]} ]]; then
			procesos_linea_memoria[$i]="   "
		fi

		if [[ $i -eq 1 ]]; then
			procesos_linea_memoria[$i]="${ordenado_nombres_procesos[${array_memoria[$i]}]}"	
		fi

	done

	
}



#Nombre:		reubicamos
#Descripcion: 	funcion que realiza la reubicabilidad
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function reubicamos {
	
	for (( i = 0 ; i <=$tamanio_memoria ; i++ )); do
		array_memoria_ord[$i]=0
	done

	for (( i = 1; i <= $tamanio_memoria; i++ )); do
		minimo=1000
		for (( j = 1; j <= $tamanio_memoria; j++ )); do

			if [[ ${array_memoria[$j]} -lt "$minimo" ]] && [[ ${array_memoria[$j]} -ne 0 ]]; then
				minimo=${array_memoria[$j]}
				posicion=$j
				
			fi
		done
		array_memoria_ord[$i]=${array_memoria[$posicion]}
		array_memoria[$posicion]="0"
	done

	inicializar_array_memoria

	for (( i = 1; i <= $tamanio_memoria; i++ )); do
		array_memoria[$i]=${array_memoria_ord[$i]}
	done

	

	#for (( i = 1; i <= $tamanio_memoria; i++ )); do
	#	array_memoria[$i]=${array_memoria_ord[$i]}
	#done
}


#Nombre:		gg_necesito_reubicar
#Descripcion: 	Comprobamos si es necesario reubicar
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function gg_necesito_reubicar {
	contador_reubicar=0
	necesito_reubicar=0


	for (( i = 1; i <= $(($tamanio_memoria + 1)) ; i++ )); do
		
			
		
			if [[ $i -eq 1 ]]; then
				((contador_reubicar++))
			fi

			if [[ $i -ne 1 ]]; then
				if [[ ${array_memoria[$i]} -eq ${array_memoria[$(($i - 1))]} ]]; then
					((contador_reubicar++))
				fi

				if [[ ${array_memoria[$i]} -ne ${array_memoria[$(($i - 1))]} ]]; then
					if [[ $contador_reubicar -le $reubicabilidad ]]; then
					
							if [[ ${array_memoria[$(($i - 1))]} -eq 0 ]]; then
								necesito_reubicar=0
								reubicamos
								necesito_reubicar=1
							fi

							contador_reubicar=1
						#fi
						
					fi
					contador_reubicar=1
						
				fi
			fi
		
	done

}


#Nombre:		llenar_direcciones_memoria
#Descripcion: 	llena tres arrays , uno con el proceso, otro con su Dinicial y otro con su Dfinal
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function llenar_direcciones_memoria {
	contador_dir=0
	contador_partes_de_procesos_en_mem=0
	for (( i = 1; i <=  $(($tamanio_memoria +1)); i++ )); do 
		#if [[ ${array_memoria[$i]} -ne 0 ]]; then
			if [[ $i -eq 1 ]] ; then
				((contador_dir++))
				#echo "Valor de i:$i" 
				#read
			else
				if [[ ${array_memoria[$i]} -eq ${array_memoria[$(($i - 1))]} ]]  ; then
					((contador_dir++))
					#echo "Valor de la memoria:${array_memoria[$i]} y el anterior ${array_memoria[$((i-1))]}"
					#read

				fi

				if [[ ${array_memoria[$i]} -ne ${array_memoria[$(($i - 1))]} ]]; then
					
					
					direcciones_memoria_inicial[$contador_partes_de_procesos_en_mem]=${arr_tiempos_llegada[$i]}

					direcciones_memoria_proceso[$contador_partes_de_procesos_en_mem]=${array_memoria[$(($i - 1))]}
					direcciones_memoria_inicial[$contador_partes_de_procesos_en_mem]=$(($i - $(($contador_dir + 1))))
					direcciones_memoria_final[$contador_partes_de_procesos_en_mem]=$(($i - 2))
					contador_dir=1
					((contador_partes_de_procesos_en_mem++))


					#echo "${array_memoria[*]}"
					#echo "Valor de la memoria:${array_memoria[$i]} y el anterior ${array_memoria[$((i-1))]}"
					#echo "Direcciones de memoria:${direcciones_memoria_proceso[$contador_partes_de_procesos_en_mem]}"
					#echo "Direcciones de memoria inicial: ${direcciones_memoria_inicial[$contador_partes_de_procesos_en_mem]}"
					#echo "Direcciones de memoria final: ${direcciones_memoria_final[$contador_partes_de_procesos_en_mem]}"
					#echo "Contador partes de procesos en memoria:$contador_partes_de_procesos_en_mem"
					#read

				fi

			fi
			
			
		#fi
	done
}










#Nombre:		tabla_con_DM
#Descripcion: 	imprime la tabla final con las DM, si el proceso está en varios lugares en memoria imprime varias lineas
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function tabla_con_DM {

	tput cuf 2
	
	echo  "┌────────────┬────────────┬────────────┬────────────┬────────────┬────────────┬────────────┬────────────┬────────────┬─────────────────────────┐" | tee -a "informeBN.txt"
	
	tput cuf 2
	
	printf "│ %3s Ref %2s │ %3s Tll %2s │ %3s Tej %2s │ %3s Mem %2s │ %2s Tesp %2s │ %2s Tret %2s │ %2s Trej %2s │ %2s Mini %2s │ %2s Mfin %2s │ %7s Estado %8s │" | tee -a "informeBN.txt"
	
	echo " " | tee -a "informeBN.txt"
	
	tput cuf 2

	echo "├────────────┼────────────┼────────────┼────────────┼────────────┼────────────┼────────────┼────────────┼────────────┼─────────────────────────┤" | tee -a "informeBN.txt"
	
	 


	for (( i = 1; i <= $contador; i++ )); do
		

		if [[ ${array_estado[$i]} == "Finalizado" ]] || [[ ${array_estado[$i]} == "En espera" ]] || [[ ${array_estado[$i]} == "Fuera del sistema" ]]; then
			
			tput cuf 2

			printf "│ %2s ${ordenado_arr_colores[$i]} ${ordenado_nombres_procesos[$i]} %1s $DEFAULT │ "


			printf  "│ %2s  ${ordenado_nombres_procesos[$i]} %1s │ " >> "informeBN.txt"

			[[ "$entrada_manual" -eq 1 ]] && tput bold

			if [[ ${ordenado_arr_tiempos_llegada[$i]} -lt 10 ]]

			then
			
				printf "%2s ${ordenado_arr_colores[$i]} ${ordenado_arr_tiempos_llegada[$i]} %3s $DEFAULT │ "

				printf "2%s  ${ordenador_arr_tiempos_llegada[$i]} %3s │" >> "informeBN.txt"


			elif [[ ${ordenado_arr_tiempos_llegada[$i]} -ge 10 ]] && [[ ${ordenado_arr_tiempos_llegada[$i]} -lt 100 ]]

				then

				printf "%2s ${ordenado_arr_colores[$i]} ${ordenado_arr_tiempos_llegada[$i]} %2s $DEFAULT │ "

				printf "%2s ${ordenado_arr_tiempos_llegada[$i]} %2s │ " >> informeBN.txt

			else

				printf "%1s ${ordenado_arr_colores[$i]} ${ordenado_arr_tiempos_llegada[$i]} %2s $DEFAULT │ "

				printf "%1s ${ordenado_arr_tiempos_llegada[$i]} %2s │ " >> informeBN.txt

			fi


			if [[ "${ordenado_arr_tiempos_ejecucion[$i]}" -lt 10 ]] 

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${ordenado_arr_tiempos_ejecucion[$i]} %3s $DEFAULT │ "

					printf "%2s ${ordenado_arr_tiempos_ejecucion[$i]} %3s │" >> informeBN.txt


			elif [[ "${ordenado_arr_tiempos_ejecucion[$i]}" -ge 10 ]] && [[ "${ordenado_arr_tiempos_ejecucion[$i]}" -lt 100 ]]

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${ordenado_arr_tiempos_ejecucion[$i]} %2s $DEFAULT │ "

					printf "%2s ${ordenado_arr_tiempos_ejecucion[$i]} %2s │" >> informeBN.txt

			else

					printf "%1s ${ordenado_arr_colores[$i]} ${ordenado_arr_tiempos_ejecucion[$i]} %2s $DEFAULT │ "

					printf "%1s ${ordenado_arr_tiempos_ejecucion[$i]} %2s │ " >> informeBN.txt
			fi


			if [[ "${ordenado_arr_memoria[$i]}" -lt 10 ]] 

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${ordenado_arr_memoria[$i]} %3s $DEFAULT │ "

					printf "%2s  ${ordenado_arr_memoria[$i]} %3s │ " >> informeBN.txt


			elif [[ "${ordenado_arr_memoria[$i]}" -ge 10 ]] && [[ "${ordenado_arr_memoria[$i]}" -lt 100 ]]

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${ordenado_arr_memoria[$i]} %2s $DEFAULT │ "

					printf "%2s ${ordenado_arr_memoria[$i]} %2s │ " >> informeBN.txt

			else

					printf "%1s ${ordenado_arr_colores[$i]} ${ordenado_arr_memoria[$i]} %2s $DEFAULT │ "

					printf "%1s ${ordenado_arr_memoria[$i]} %2s │ " >> informeBN.txt
			fi

			[[ "$entrada_manual" -eq 1 ]] && tput sgr0


			if [ "${array_tiempo_espera[$i]}" = "-" ]
				
				then

					printf "%3s ${ordenado_arr_colores[$i]} ${array_tiempo_espera[$i]} %2s $DEFAULT │ "

					printf "%3s ${array_tiempo_espera[$i]} %2s │ " >> informeBN.txt
				
				fi


			if [[ "${array_tiempo_espera[$i]}" -lt 10 ]] &>/dev/null 

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${array_tiempo_espera[$i]} %3s $DEFAULT │ "

					printf "%2s ${array_tiempo_espera[$i]} %3s │ " >> informeBN.txt


			elif [[ "${array_tiempo_espera[$i]}" -ge 10 ]]&>/dev/null && [[ "${array_tiempo_espera[$i]}" -lt 100 ]] &>/dev/null

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${array_tiempo_espera[$i]} %2s $DEFAULT │ "

					printf "%2s ${array_tiempo_espera[$i]} %2s │ " >> informeBN.txt

			elif [[ "${array_tiempo_espera[$i]}" -gt 100 ]] &>/dev/null

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${array_tiempo_espera[$i]} %1s $DEFAULT │ "

					printf "%2s ${array_tiempo_espera[$i]} %1s │ " >> informeBN.txt
			fi




			if [ "${array_tiempo_retorno[$i]}" = "-" ]
				
				then

					printf "%3s ${ordenado_arr_colores[$i]} ${array_tiempo_retorno[$i]} %2s $DEFAULT │ "

					printf "%3s ${array_tiempo_retorno[$i]} %2s │ " >> informeBN.txt
				
				fi


			if [[ "${array_tiempo_retorno[$i]}" -lt 10 ]] &>/dev/null 

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${array_tiempo_retorno[$i]} %3s $DEFAULT │ "

					printf "%2s ${array_tiempo_retorno[$i]} %3s │ " >> informeBN.txt

			elif [[ "${array_tiempo_retorno[$i]}" -ge 10 ]]&>/dev/null && [[ "${array_tiempo_retorno[$i]}" -lt 100 ]] &>/dev/null

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${array_tiempo_retorno[$i]} %2s $DEFAULT │ "

					printf "%2s ${array_tiempo_retorno[$i]} %2s │ " >> informeBN.txt

			elif [[ "${array_tiempo_retorno[$i]}" -gt 100 ]] &>/dev/null

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${array_tiempo_retorno[$i]} %1s $DEFAULT │ "

					printf "%2s ${array_tiempo_retorno[$i]} %1s │ " >> informeBN.txt

			fi


			if [ "${array_tiempo_restante[$i]}" = "-" ]
				
				then

					printf "%3s ${ordenado_arr_colores[$i]} ${array_tiempo_restante[$i]} %2s $DEFAULT │ "

					printf "%3s ${array_tiempo_restante[$i]} %2s │ " >> informeBN.txt
				
				fi


			if [[ "${array_tiempo_restante[$i]}" -lt 10 ]] &>/dev/null 

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${array_tiempo_restante[$i]} %3s $DEFAULT │ "

					printf "%2s ${array_tiempo_restante[$i]} %3s │ " >> informeBN.txt


			elif [[ "${array_tiempo_restante[$i]}" -ge 10 ]]&>/dev/null && [[ "${array_tiempo_restante[$i]}" -lt 100 ]] &>/dev/null

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${array_tiempo_restante[$i]} %2s $DEFAULT │ "

					printf "%2s ${array_tiempo_restante[$i]} %2s │ " >> informeBN.txt

			elif [[ "${array_tiempo_restante[$i]}" -gt 100 ]] &>/dev/null

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${array_tiempo_restante[$i]} %1s $DEFAULT │ "

					printf "%2s ${array_tiempo_restante[$i]} %1s │ " >> informeBN.txt

			fi

			printf "%3s ${ordenado_arr_colores[$i]} - %2s $DEFAULT │ "

			printf "%3s - %2s │ " >> informeBN.txt

			printf "%3s ${ordenado_arr_colores[$i]} - %2s $DEFAULT │ "

			printf "%3s  - %2s │ " >> informeBN.txt


			if [ "${array_estado[$i]}" = "Finalizado" ]
				
				then

					printf "%4s ${ordenado_arr_colores[$i]} ${array_estado[$i]} %5s $DEFAULT │ "

					printf "%4s ${array_estado[$i]} %5s  │ " >> informeBN.txt
				
			elif [ "${array_estado[$i]}" = "Fuera del sistema" ]

				then

					printf "%1s ${ordenado_arr_colores[$i]} ${array_estado[$i]} %1s $DEFAULT │ "

					printf "%1s ${array_estado[$i]} %1s │ " >> informeBN.txt

			elif [ "${array_estado[$i]}" = "En espera" ] 

				then

					printf "%5s ${ordenado_arr_colores[$i]} ${array_estado[$i]} %5s $DEFAULT │ "

					printf "%5s ${array_estado[$i]} %5s │ " >> informeBN.txt
			
			fi

			printf "\n" | tee -a "informeBN.txt"

			
		else

		#if [[ ${array_estado[$i]} == "En memoria" ]] || [[ ${array_estado[$i]} == "En ejecucion" ]]; then
			#echo $i
			proceso_detectado=$i
			contador_parejas_direcciones_proceso=0
			while [[ $proceso_detectado -eq $i ]]; do
				for (( j = 0; j <= $contador_partes_de_procesos_en_mem; j++ )); do
					if [[ ${direcciones_memoria_proceso[$j]} -ne 0 ]]; then
						if [[ ${direcciones_memoria_proceso[$j]} -eq $i ]]; then
							#echo $j
							((contador_parejas_direcciones_proceso++))
							proceso_detectado=${direcciones_memoria_proceso[$j]}
							#echo $proceso_detectado
							#Con este if imprimo todos los datos si es la primera pareja de DM, si no lo es imprimo solo las parejas de DM
							if [[ $contador_parejas_direcciones_proceso -eq 1 ]]; then

								tput cuf 2
																 
								#printf " ${ordenado_arr_colores[$i]}%*s %*s %*s %*s $DEFAULT|${ordenado_arr_colores[$i]} %*s %*s %*s %*s %*s %*s $DEFAULT\n" 3 "${ordenado_nombres_procesos[$i]}" 3 "${ordenado_arr_tiempos_llegada[$i]}" 3 "${ordenado_arr_tiempos_ejecucion[$i]}" 3 "${ordenado_arr_memoria[$i]}" 4 "${array_tiempo_espera[$i]}" 4 "${array_tiempo_retorno[$i]}" 4 "${array_tiempo_restante[$i]}" 4 "${direcciones_memoria_inicial[$j]}" 4 "${direcciones_memoria_final[$j]}" 4 "${array_estado[$i]}"

								printf "│ %2s ${ordenado_arr_colores[$i]} ${ordenado_nombres_procesos[$i]} %1s $DEFAULT │ "

								printf "│ %2s ${ordenado_nombres_procesos[$i]} %1s │ " >> informeBN.txt

			[[ "$entrada_manual" -eq 1 ]] && tput bold

			if [[ ${ordenado_arr_tiempos_llegada[$i]} -lt 10 ]]

			then
			
				printf "%2s ${ordenado_arr_colores[$i]} ${ordenado_arr_tiempos_llegada[$i]} %3s $DEFAULT │ "

				printf "%2s ${ordenado_arr_tiempos_llegada[$i]} %3s │ " >> informeBN.txt


			elif [[ ${ordenado_arr_tiempos_llegada[$i]} -ge 10 ]] && [[ ${ordenado_arr_tiempos_llegada[$i]} -lt 100 ]]

				then

				printf "%2s ${ordenado_arr_colores[$i]} ${ordenado_arr_tiempos_llegada[$i]} %2s $DEFAULT │ "

				printf "%2s ${ordenado_arr_tiempos_llegada[$i]} %2s │ " >> informeBN.txt

			else

				printf "%2s ${ordenado_arr_colores[$i]} ${ordenado_arr_tiempos_llegada[$i]} %1s $DEFAULT │ "

				printf "%2s ${ordenado_arr_tiempos_llegada[$i]} %1s │ " >> informeBN.txt

			fi


			if [[ "${ordenado_arr_tiempos_ejecucion[$i]}" -lt 10 ]] 

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${ordenado_arr_tiempos_ejecucion[$i]} %3s $DEFAULT │ "

					printf "%2s ${ordenado_arr_tiempos_ejecucion[$i]} %3s │ " >> informeBN.txt


			elif [[ "${ordenado_arr_tiempos_ejecucion[$i]}" -ge 10 ]] && [[ "${ordenado_arr_tiempos_ejecucion[$i]}" -lt 100 ]]

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${ordenado_arr_tiempos_ejecucion[$i]} %2s $DEFAULT │ "

					printf "%2s ${ordenado_arr_tiempos_ejecucion[$i]} %2s │ " >> informeBN.txt

			else

					printf "%2s ${ordenado_arr_colores[$i]} ${ordenado_arr_tiempos_ejecucion[$i]} %1s $DEFAULT │ "

					printf "%2s ${ordenado_arr_tiempos_ejecucion[$i]} %1s │ " >> informeBN.txt
			fi


			if [[ "${ordenado_arr_memoria[$i]}" -lt 10 ]] 

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${ordenado_arr_memoria[$i]} %3s $DEFAULT │ "

					printf "%2s ${ordenado_arr_memoria[$i]} %3s │ " >> informeBN.txt


			elif [[ "${ordenado_arr_memoria[$i]}" -ge 10 ]] && [[ "${ordenado_arr_memoria[$i]}" -lt 100 ]]

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${ordenado_arr_memoria[$i]} %2s $DEFAULT │ "

					printf "%2s ${ordenado_arr_memoria[$i]} %2s │ " >> informeBN.txt

			else

					printf "%2s ${ordenado_arr_colores[$i]} ${ordenado_arr_memoria[$i]} %1s $DEFAULT │ "

					printf "%2s ${ordenado_arr_memoria[$i]} %1s │ " >> informeBN.txt
			fi

			[[ "$entrada_manual" -eq 1 ]] && tput sgr0
			
			if [ "${array_tiempo_espera[$i]}" = "-" ]
				
				then

					printf "%3s ${ordenado_arr_colores[$i]} ${array_tiempo_espera[$i]} %2s $DEFAULT │ "

					printf "%3s ${array_tiempo_espera[$i]} %2s │ " >> informeBN.txt
				
				fi


			if [[ "${array_tiempo_espera[$i]}" -lt 10 ]] &>/dev/null 

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${array_tiempo_espera[$i]} %3s $DEFAULT │ "

					printf "%2s ${array_tiempo_espera[$i]} %3s │ " >> informeBN.txt


			elif [[ "${array_tiempo_espera[$i]}" -ge 10 ]]&>/dev/null && [[ "${array_tiempo_espera[$i]}" -lt 100 ]] &>/dev/null

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${array_tiempo_espera[$i]} %2s $DEFAULT │ "

					printf "%2s ${array_tiempo_espera[$i]} %2s │ " >> informeBN.txt

			elif [[ "${array_tiempo_espera[$i]}" -gt 100 ]] &>/dev/null

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${array_tiempo_espera[$i]} %1s $DEFAULT │ "

					printf "%2s ${array_tiempo_espera[$i]} %1s │ " >> informeBN.txt
			fi




			if [ "${array_tiempo_retorno[$i]}" = "-" ]
				
				then

					printf "%3s ${ordenado_arr_colores[$i]} ${array_tiempo_retorno[$i]} %2s $DEFAULT │ "

					printf "%3s ${array_tiempo_retorno[$i]} %2s │ " >> informeBN.txt
				
				fi


			if [[ "${array_tiempo_retorno[$i]}" -lt 10 ]] &>/dev/null 

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${array_tiempo_retorno[$i]} %3s $DEFAULT │ "

					printf "%2s ${array_tiempo_retorno[$i]} %3s │ " >> informeBN.txt



			elif [[ "${array_tiempo_retorno[$i]}" -ge 10 ]]&>/dev/null && [[ "${array_tiempo_retorno[$i]}" -lt 100 ]] &>/dev/null

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${array_tiempo_retorno[$i]} %2s $DEFAULT │ "

					printf "%2s ${array_tiempo_retorno[$i]} %2s │ " >> informeBN.txt

			elif [[ "${array_tiempo_retorno[$i]}" -gt 100 ]] &>/dev/null

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${array_tiempo_retorno[$i]} %1s $DEFAULT │ "

					printf "%2s ${array_tiempo_retorno[$i]} %1s │ " >> informeBN.txt
			fi


			if [ "${array_tiempo_restante[$i]}" = "-" ]
				
				then

					printf "%3s ${ordenado_arr_colores[$i]} ${array_tiempo_restante[$i]} %2s $DEFAULT │ "

					printf "%3s ${array_tiempo_restante[$i]} %2s │ " >> informeBN.txt
				
				fi


			if [[ "${array_tiempo_restante[$i]}" -lt 10 ]] &>/dev/null 

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${array_tiempo_restante[$i]} %3s $DEFAULT │ "

					printf "%2s ${array_tiempo_restante[$i]} %3s │ " >> informeBN.txt


			elif [[ "${array_tiempo_restante[$i]}" -ge 10 ]]&>/dev/null && [[ "${array_tiempo_restante[$i]}" -lt 100 ]] &>/dev/null

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${array_tiempo_restante[$i]} %2s $DEFAULT │ "

					printf "%2s ${array_tiempo_restante[$i]} %2s │ " >> informeBN.txt

			elif [[ "${array_tiempo_restante[$i]}" -gt 100 ]] &>/dev/null

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${array_tiempo_restante[$i]} %1s $DEFAULT │ "

					printf "%2s ${array_tiempo_restante[$i]} %1s │ " >> informeBN.txt
			fi

	

			if [ "${direcciones_memoria_inicial[$j]}" = "-" ]
				
				then

					printf "%3s ${ordenado_arr_colores[$i]} ${direcciones_memoria_inicial[$j]} %2s $DEFAULT │ "

					printf "%3s ${direcciones_memoria_inicial[$j]} %2s │ " >> informeBN.txt
				
				fi


			if [[ "${direcciones_memoria_inicial[$j]}" -lt 10 ]] &>/dev/null 

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${direcciones_memoria_inicial[$j]} %3s $DEFAULT │ "

					printf "%2s ${direcciones_memoria_inicial[$j]} %3s │ " >> informeBN.txt


			elif [[ "${direcciones_memoria_inicial[$j]}" -ge 10 ]]&>/dev/null && [[ "${direcciones_memoria_inicial[$j]}" -lt 100 ]] &>/dev/null

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${direcciones_memoria_inicial[$j]} %2s $DEFAULT │ "

					printf "%2s ${direcciones_memoria_inicial[$j]} %2s │ " >> informeBN.txt


			elif [[ "${direcciones_memoria_inicial[$j]}" -gt 100 ]] &>/dev/null

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${direcciones_memoria_inicial[$j]} %1s $DEFAULT │ "

					printf "%2s ${direcciones_memoria_inicial[$j]} %1s │ " >> informeBN.txt
			fi


			if [ "${direcciones_memoria_final[$j]}" = "-" ]
				
				then

					printf "%3s ${ordenado_arr_colores[$i]} ${direcciones_memoria_final[$j]} %2s $DEFAULT │ "

					printf "%3s ${direcciones_memoria_final[$j]} %2s │ " >> informeBN.txt
				
				fi


			if [[ "${direcciones_memoria_final[$j]}" -lt 10 ]] &>/dev/null 

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${direcciones_memoria_final[$j]} %3s $DEFAULT │ "

					printf "%2s ${direcciones_memoria_final[$j]} %3s │ " >> informeBN.txt


			elif [[ "${direcciones_memoria_final[$j]}" -ge 10 ]]&>/dev/null && [[ "${direcciones_memoria_final[$j]}" -lt 100 ]] &>/dev/null

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${direcciones_memoria_final[$j]} %2s $DEFAULT │ "

					printf "%2s ${direcciones_memoria_final[$j]} %2s │ " >> informeBN.txt

			elif [[ "${direcciones_memoria_final[$j]}" -gt 100 ]] &>/dev/null

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${direcciones_memoria_final[$j]} %1s $DEFAULT │ "

					printf "%2s ${direcciones_memoria_final[$j]} %1s │ " >> informeBN.txt
			fi

			###


			if [ "${array_estado[$i]}" = "Finalizado" ]
									
				then

					printf "%3s ${ordenado_arr_colores[$i]} ${array_estado[$i]} %3s $DEFAULT │ "

					printf "%3s ${array_estado[$i]} %3s │ " >> informeBN.txt
				
			elif [ "${array_estado[$i]}" = "Fuera del sistema" ]

				then

					printf "%1s ${ordenado_arr_colores[$i]} ${array_estado[$i]} %1s $DEFAULT │ "

					printf "%1s ${array_estado[$i]} %1s │ " >> informeBN.txt

			elif [ "${array_estado[$i]}" = "En espera" ] 

				then

					printf "%5s ${ordenado_arr_colores[$i]} ${array_estado[$i]} %5s $DEFAULT │ "

					printf "%5s ${array_estado[$i]} %5s │ " >> informeBN.txt

			elif [ "${array_estado[$i]}" = "En memoria" ] 
				
				then

					printf "%5s ${ordenado_arr_colores[$i]} ${array_estado[$i]} %4s $DEFAULT │ "

					printf "%5s ${array_estado[$i]} %4s │ " >> informeBN.txt

			elif [ "${array_estado[$i]}" = "En ejecucion" ] 
				
				then

					printf "%4s ${ordenado_arr_colores[$i]} ${array_estado[$i]} %3s $DEFAULT │ "

					printf "%4s ${array_estado[$i]} %3s │ " >> informeBN.txt

			fi

			printf "\n" | tee -a "informeBN.txt"



							else
							
								tput cuf 2

								#printf " ${ordenado_arr_colores[$i]}%*s %*s %*s %*s $DEFAULT ${ordenado_arr_colores[$i]} %*s %*s %*s %*s %*s %*s $DEFAULT\n" 3 "   " 3 "   " 3 "   " 3 "   " 4 "    " 4 "    " 4 "    " 4 "${direcciones_memoria_inicial[$j]}" 4 "${direcciones_memoria_final[$j]}" 4 "    "
						
					printf "│ %2s ${ordenado_arr_colores[$i]} ${ordenado_nombres_procesos[$i]} %1s $DEFAULT │ "

					printf "│ %2s ${ordenado_nombres_procesos[$i]} %1s │" >> informeBN.txt

			
			[[ "$entrada_manual" -eq 1 ]] && tput bold

			if [[ ${ordenado_arr_tiempos_llegada[$i]} -lt 10 ]]

			then
			
				printf "%2s ${ordenado_arr_colores[$i]} ${ordenado_arr_tiempos_llegada[$i]} %3s $DEFAULT │ "

				printf "%2s ${ordenado_arr_tiempos_llegada[$i]} %3s │" >> informeBN.txt


			elif [[ ${ordenado_arr_tiempos_llegada[$i]} -ge 10 ]] && [[ ${ordenado_arr_tiempos_llegada[$i]} -lt 100 ]]

				then

				printf "%2s ${ordenado_arr_colores[$i]} ${ordenado_arr_tiempos_llegada[$i]} %2s $DEFAULT │ "

				printf "%2s ${ordenado_arr_tiempos_llegada[$i]} %2s │" >> informeBN.txt

			else

				printf "%2s ${ordenado_arr_colores[$i]} ${ordenado_arr_tiempos_llegada[$i]} %1s $DEFAULT │ "

				printf "%2s ${ordenado_arr_tiempos_llegada[$i]} %1s │ " >> informeBN.txt

			fi


			if [[ "${ordenado_arr_tiempos_ejecucion[$i]}" -lt 10 ]] 

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${ordenado_arr_tiempos_ejecucion[$i]} %3s $DEFAULT │ "

					printf "%2s ${ordenado_arr_tiempos_ejecucion[$i]} %3s │ " >> informeBN.txt


			elif [[ "${ordenado_arr_tiempos_ejecucion[$i]}" -ge 10 ]] && [[ "${ordenado_arr_tiempos_ejecucion[$i]}" -lt 100 ]]

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${ordenado_arr_tiempos_ejecucion[$i]} %2s $DEFAULT │ "

					printf "%2s ${ordenado_arr_tiempos_ejecucion[$i]} %2s │ " >> informeBN.txt

			else

					printf "%2s ${ordenado_arr_colores[$i]} ${ordenado_arr_tiempos_ejecucion[$i]} %1s $DEFAULT │ "

					printf "%2s ${ordenado_arr_tiempos_ejecucion[$i]} %1s │ " >> informeBN.txt
			fi


			if [[ "${ordenado_arr_memoria[$i]}" -lt 10 ]] 

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${ordenado_arr_memoria[$i]} %3s $DEFAULT │ "

					printf "%2s ${ordenado_arr_memoria[$i]} %3s │ " >> informeBN.txt


			elif [[ "${ordenado_arr_memoria[$i]}" -ge 10 ]] && [[ "${ordenado_arr_memoria[$i]}" -lt 100 ]]

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${ordenado_arr_memoria[$i]} %2s $DEFAULT │ "

					printf "%2s ${ordenado_arr_memoria[$i]} %2s │ " >> informeBN.txt

			else

					printf "%2s ${ordenado_arr_colores[$i]} ${ordenado_arr_memoria[$i]} %1s $DEFAULT │ "

					printf "%2s ${ordenado_arr_memoria[$i]} %1s │ " >> informeBN.txt
			fi

			[[ "$entrada_manual" -eq 1 ]] && tput sgr0
			
			if [ "${array_tiempo_espera[$i]}" = "-" ]
				
				then

					printf "%3s ${ordenado_arr_colores[$i]} ${array_tiempo_espera[$i]} %2s $DEFAULT │ "

					printf "%3s ${array_tiempo_espera[$i]} %2s │" >> informeBN.txt
				
				fi


			if [[ "${array_tiempo_espera[$i]}" -lt 10 ]] &>/dev/null 

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${array_tiempo_espera[$i]} %3s $DEFAULT │ "

					printf "%2s ${array_tiempo_espera[$i]} %3s │" >> informeBN.txt


			elif [[ "${array_tiempo_espera[$i]}" -ge 10 ]]&>/dev/null && [[ "${array_tiempo_espera[$i]}" -lt 100 ]] &>/dev/null

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${array_tiempo_espera[$i]} %2s $DEFAULT │ "

					printf "%2s ${array_tiempo_espera[$i]} %2s │ " >> informeBN.txt

			elif [[ "${array_tiempo_espera[$i]}" -gt 100 ]] &>/dev/null

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${array_tiempo_espera[$i]} %1s $DEFAULT │ "

					printf "%4s ${array_tiempo_espera[$i]} %4s │" >> informeBN.txt
			fi




			if [ "${array_tiempo_retorno[$i]}" = "-" ]
				
				then

					printf "%3s ${ordenado_arr_colores[$i]} ${array_tiempo_retorno[$i]} %2s $DEFAULT │ "

					printf "%3s ${array_tiempo_retorno[$i]} %2s │" >> "informeBN.txt"
				
				fi


			if [[ "${array_tiempo_retorno[$i]}" -lt 10 ]] &>/dev/null 

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${array_tiempo_retorno[$i]} %3s $DEFAULT │ " 
					
					printf  "%2s ${array_tiempo_retorno[$i]} %3s │ " >> "informeBN.txt"


			elif [[ "${array_tiempo_retorno[$i]}" -ge 10 ]]&>/dev/null && [[ "${array_tiempo_retorno[$i]}" -lt 100 ]] &>/dev/null

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${array_tiempo_retorno[$i]} %2s $DEFAULT │ " 
					
					printf  "%2s ${array_tiempo_retorno[$i]} %2s │ " >> "informeBN.txt"

			elif [[ "${array_tiempo_retorno[$i]}" -gt 100 ]] &>/dev/null

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${array_tiempo_retorno[$i]} %1s $DEFAULT │ " 

					printf "%2s ${array_tiempo_retorno[$i]} %1s │ " >> "informeBN.txt"
			fi


			if [ "${array_tiempo_restante[$i]}" = "-" ]
				
				then

					printf "%3s ${ordenado_arr_colores[$i]} ${array_tiempo_restante[$i]} %2s $DEFAULT │ "
					
					printf "%3s  ${array_tiempo_restante[$i]} %2s │ " >> "informeBN.txt"
				
				fi


			if [[ "${array_tiempo_restante[$i]}" -lt 10 ]] &>/dev/null 

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${array_tiempo_restante[$i]} %3s $DEFAULT │ " 
					
					printf "%2s ${array_tiempo_restante[$i]} %3s │ " >> "informeBN.txt"


			elif [[ "${array_tiempo_restante[$i]}" -ge 10 ]]&>/dev/null && [[ "${array_tiempo_restante[$i]}" -lt 100 ]] &>/dev/null

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${array_tiempo_restante[$i]} %2s $DEFAULT │ " 
					
					printf "%2s ${array_tiempo_restante[$i]} %2s │ " >> "informeBN.txt"

			elif [[ "${array_tiempo_restante[$i]}" -gt 100 ]] &>/dev/null

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${array_tiempo_restante[$i]} %1s $DEFAULT │ " 
					
					printf "%2s ${array_tiempo_restante[$i]} %1s │ " >> "informeBN.txt"
			fi

	##########MEMORIA INICIAL ########################

			if [ "${direcciones_memoria_inicial[$j]}" = "-" ]
				
				then

					printf "%3s ${ordenado_arr_colores[$i]} ${direcciones_memoria_inicial[$j]} %2s $DEFAULT │ " 
					
					printf "%3s ${direcciones_memoria_inicial[$j]} %2s │ " >> "informeBN.txt"
				
				fi


			if [[ "${direcciones_memoria_inicial[$j]}" -lt 10 ]] &>/dev/null 

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${direcciones_memoria_inicial[$j]} %3s $DEFAULT │ " 
					
					printf "%2s ${direcciones_memoria_inicial[$j]} %3s │ " >> "informeBN.txt"


			elif [[ "${direcciones_memoria_inicial[$j]}" -ge 10 ]]&>/dev/null && [[ "${direcciones_memoria_inicial[$j]}" -lt 100 ]] &>/dev/null

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${direcciones_memoria_inicial[$j]} %2s $DEFAULT │ " 

					printf "%2s ${direcciones_memoria_inicial[$j]} %2s  │ " >> "informeBN.txt"


			elif [[ "${direcciones_memoria_inicial[$j]}" -gt 100 ]] &>/dev/null

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${direcciones_memoria_inicial[$j]} %1s $DEFAULT │ " 
					
					printf "%2s ${direcciones_memoria_inicial[$j]} %1s │ "  >> "informeBN.txt"

			else 
					printf "%3s ${ordenado_arr_colores[$i]} - %2s $DEFAULT │ " 
					
					printf "%3s - %2s │" >> "informeBN.txt"

			fi

			############FINAL##############

			if [ "${direcciones_memoria_final[$j]}" = "-" ]
				
				then

					printf "%3s ${ordenado_arr_colores[$i]} ${direcciones_memoria_final[$j]} %2s $DEFAULT │ " 
					
					printf "%3s ${direcciones_memoria_final[$j]} %2s  │ " >> "informeBN.txt"
				
				fi


			if [[ "${direcciones_memoria_final[$j]}" -lt 10 ]] &>/dev/null 

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${direcciones_memoria_final[$j]} %3s $DEFAULT │ " 
					
					printf  "%2s ${direcciones_memoria_final[$j]} %3s │ " >> "informeBN.txt"


			elif [[ "${direcciones_memoria_final[$j]}" -ge 10 ]]&>/dev/null && [[ "${direcciones_memoria_final[$j]}" -lt 100 ]] &>/dev/null

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${direcciones_memoria_final[$j]} %2s $DEFAULT │ "
					
					printf "%2s ${direcciones_memoria_final[$j]} %2s │ " >> "informeBN.txt"

			elif [[ "${direcciones_memoria_final[$j]}" -gt 100 ]] &>/dev/null

				then

					printf "%2s ${ordenado_arr_colores[$i]} ${direcciones_memoria_final[$j]} %1s $DEFAULT │ " 
					
					printf "%2s ${direcciones_memoria_final[$j]} %1s │ " >> "informeBN.txt"

			else 

					printf "%3s ${ordenado_arr_colores[$i]} - %2s $DEFAULT │ " 
					
					printf "%3s - %2s │ " >> "informeBN.txt"

			fi

			#####ARRAY DE ESTADOS###########


			if [ "${array_estado[$i]}" = "Finalizado" ]
				
				then

					printf "%3s ${ordenado_arr_colores[$i]} ${array_estado[$i]} %3s $DEFAULT │ " 
					
					printf "%3s ${array_estado[$i]} %3s │ "  >> "informeBN.txt"
				
			elif [ "${array_estado[$i]}" = "Fuera del sistema" ]

				then

					printf "%1s ${ordenado_arr_colores[$i]} ${array_estado[$i]} %1s $DEFAULT │ " 
					
					printf "%1s ${array_estado[$i]} %1s │ " >> "informeBN.txt"

			elif [ "${array_estado[$i]}" = "En espera" ] 

				then

					printf "%5s ${ordenado_arr_colores[$i]} ${array_estado[$i]} %5s $DEFAULT │ " 
					
					printf "%5s ${array_estado[$i]} %5s │ "  >> "informeBN.txt"

			elif [ "${array_estado[$i]}" = "En memoria" ] 
				
				then

					printf "%5s ${ordenado_arr_colores[$i]} ${array_estado[$i]} %4s $DEFAULT │ " 
					
					printf "%5s ${array_estado[$i]} %4s │ " >> "informeBN.txt"


			elif [ "${array_estado[$i]}" = "En ejecucion" ] 
				
				then

					printf "%4s ${ordenado_arr_colores[$i]} ${array_estado[$i]} %2s $DEFAULT │ " 
					
					printf "%4s ${array_estado[$i]} %2s │ " >> "informeBN.txt"

			fi

			printf "\n" | tee -a "informeBN.txt"

							fi
							direcciones_memoria_proceso[$j]=1000
						else
							proceso_detectado=1000
						fi
					fi
				done
			done
		
		fi


	done

	tput cuf 2

	echo "└────────────┴────────────┴────────────┴────────────┴────────────┴────────────┴────────────┴────────────┴────────────┴─────────────────────────┘" | tee -a "informeBN.txt"
}


#Nombre:		tiempos_medios
#Descripcion: 	calcula los tiempos medios
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function tiempos_medios {
	procesos_media=0
	tiempo_medio_espera_acumulado=0
	tiempo_medio_retorno_acumulado=0

	for (( i = 1; i <= $contador ; i++ )); do
		if [[ ${array_estado[$i]} != "Fuera del sistema" ]]; then
			((procesos_media++))
			tiempo_medio_espera_acumulado=$((tiempo_medio_espera_acumulado + array_tiempo_espera[$i]))
			#echo $tiempo_medio_espera
			tiempo_medio_retorno_acumulado=$((tiempo_medio_retorno_acumulado + array_tiempo_retorno[$i]))
		fi
	done
	if [[ $procesos_media -ne 0 ]] && [[ $tiempo_medio_espera_acumulado -ne 0 ]]; then
		tiempo_medio_espera=$(echo "scale=2;$tiempo_medio_espera_acumulado/$procesos_media" | bc -l)
	fi
	if [[ $procesos_media -ne 0 ]] && [[ $tiempo_medio_retorno_acumulado -ne 0 ]]; then
		tiempo_medio_retorno=$(echo "scale=2;$tiempo_medio_retorno_acumulado/$procesos_media" | bc -l)
	fi
}


#Nombre:		truncado_memoria
#Descripcion: 	Esta función imprime la barra de memoria cortandola para que en caso de que se necesite otra linea coincida la impresión de
#				los 3 arrays, el de procesos, la barra y el de direcciones
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function truncado_memoria {

	#Esta variable guarda las columnas que tiene el terminal 
	ancho_terminal="$(tput cols)"
	#En esta variable guardo los elementos (cada uno de 3 columnas) que caben en cada linea
	elementos_por_linea=$(($(($ancho_terminal/3))-2))
	#echo "elementos por linea:$elementos_por_linea"
	#En esta variable guardo el numero de lineas a imprimir
	lineas=$(($(($tamanio_memoria/$elementos_por_linea))+1))
	#echo "lineas:$lineas"
	ultima_posicion_impresa=0
	for (( j = 1; j <= $lineas; j++ )); do
		
		if [[ "$j" -ne 1 ]]; then
			
			printf "\n" | tee -a "informeBN.txt"
		
		fi

		if [[ "$j" -eq 1 ]]; then
			
			printf "   |"  | tee -a "informeBN.txt"
		
		else
			
			printf "    " | tee -a "informeBN.txt"
		
		fi
		
		for (( i = $(($ultima_posicion_impresa+1)); i <=$(($elementos_por_linea*$j)); i++ )); do
			if [[ "$i" -le $tamanio_memoria ]]; then
				
				printf "${ordenado_arr_colores[${array_memoria[$i]}]}${procesos_linea_memoria[$i]}$DEFAULT" 
				
				echo -ne "${procesos_linea_memoria[$i]}" >> "informeBN.txt"
			fi
		done
		
		echo "" | tee -a "informeBN.txt"
		
		if [[ "$j" -eq 1 ]]; then
			
			printf " BM|" | tee -a "informeBN.txt"
		
		else
		
			printf "    " | tee -a "informeBN.txt"
		
		fi
		
		for (( i = $(($ultima_posicion_impresa+1)); i <=$(($elementos_por_linea*$j)); i++ )); do
			
			if [[ "$i" -le $tamanio_memoria ]]; then

					printf "${ordenado_arr_colores[${array_memoria[$i]}]}\u2593\u2593\u2593$DEFAULT"

				if [[ ${ordenado_arr_colores[${array_memoria[$i]}]} = "\e[39m" ]] #Si es de color gris, quiere decir que está vacío, por tanto lo envíamos de diferente forma al fichero
					then

					echo -ne "▒▒▒" >> "informeBN.txt"

				else
				
					echo -ne "\u2593\u2593\u2593" >> "informeBN.txt"
					
				fi
			fi
			
		done

		if [[ "$j" -eq $lineas ]]; then

					printf "$tamanio_memoria" | tee -a "informeBN.txt"

		fi
		
		echo " " | tee -a "informeBN.txt"

		
		if [[ "$j" -eq 1 ]]; then

			printf "   |" | tee -a "informeBN.txt"

			printf "  0" | tee -a "informeBN.txt"

		else

			printf "  " | tee -a "informeBN.txt"

		fi
		for (( i = $(($ultima_posicion_impresa)); i <=$(($elementos_por_linea*$j)); i++ )); do
			
			if [[ "$i" -le $tamanio_memoria ]]; then

				printf "${direcciones_linea_memoria[$i]}" | tee -a "informeBN.txt"
				
			fi
			
		done
		ultima_posicion_impresa=$(($(($elementos_por_linea*$j))))
	done
}



#Nombre:		truncado_tiempo
#Descripcion: 	Esta función imprime la barra de tiempo cortandola para que en caso de que se necesite otra linea coincida
#				la impresión de los 3 arrays, el de procesos, la barra y el de tiempo
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function truncado_tiempo {

	#Esta variable guarda las columnas que tiene el terminal 
	ancho_terminal="$(tput cols)"
	#En esta variable guardo los elementos (cada uno de 3 columnas) que caben en cada linea
	elementos_por_linea=$(($(($ancho_terminal/3))-2))
	#echo "elementos por linea:$elementos_por_linea"
	#En esta variable guardo el numero de lineas a imprimir
	lineas=$(($(($tiempo/$elementos_por_linea))+1))
	#echo "lineas:$lineas"
	ultima_posicion_impresa=0
	for (( j = 1; j <= $lineas; j++ )); do

		if [[ $j -ne 1 ]]; then

			printf "\n" | tee -a "informeBN.txt"

		fi

		if [[ $j -eq 1 ]]; then

			printf "   |"  | tee -a "informeBN.txt"

		else

			printf "    "  | tee -a "informeBN.txt"

		fi

		for (( i = $(($ultima_posicion_impresa)); i <=$(($(($elementos_por_linea*$j))-1)); i++ )); do
			
			if [[ $i -le $tiempo ]]; then
					
				printf "${ordenado_arr_colores[${array_linea_temporal[$i]}]}${procesos_linea_temporal[$i]}$DEFAULT"
				
				echo -ne "${procesos_linea_temporal[$i]}" >> "informeBN.txt"
					
			fi
		done

		echo " " | tee -a "informeBN.txt"

		if [[ $j -eq 1 ]]; then

			printf " BT|" | tee -a "informeBN.txt"

		else

			printf "    "  | tee -a "informeBN.txt"

		fi

		for (( i = $(($ultima_posicion_impresa)); i <=$(($(($elementos_por_linea*$j))-1)); i++ )); do
			
			if [[ $i -lt $tiempo ]]; then
				
					printf "${ordenado_arr_colores[${array_linea_temporal[$i]}]}\u2593\u2593\u2593$DEFAULT"

				if [[ ${ordenado_arr_colores[${array_linea_temporal[$i]}]} = "\e[39m" ]] #Si es de color gris, quiere decir que está vacío, por tanto lo envíamos de diferente forma al fichero
					
					then

					echo -ne "▒▒▒" >> "informeBN.txt"

				else
				
					echo -ne "\u2593\u2593\u2593" >> "informeBN.txt"
					
				fi

			fi
			
		done
		
		if [[ $j -eq $lineas ]]; then
			
			if [[ ${array_linea_temporal[$tiempo]} -eq ${array_linea_temporal[$(($tiempo-1))]} ]] || [[ $procesos_ejecutados -eq $contador ]]; then
				
				if [[ $tiempo -ne 0 ]]; then
					
					printf "$tiempo" | tee -a "informeBN.txt"
				
				fi
				
			fi
		fi
		
		echo "" | tee -a "informeBN.txt"
		
		if [[ $j -eq 1 ]]; then
			
			printf "   |" | tee -a "informeBN.txt"
			
			#printf "0 " | tee -a "informeBN.txt"
		
		else
		
			printf "   " | tee -a "informeBN.txt"
		
		fi
		
		for (( i = $(($ultima_posicion_impresa)); i <=$(($(($elementos_por_linea*$j))-1)); i++ )); do
			
			if [[ $i -le $tiempo ]]; then

				printf "${tiempo_linea_temporal[$i]}" | tee -a "informeBN.txt"

			fi
			
		done
		ultima_posicion_impresa=$(($(($elementos_por_linea*$j))))
	done
}


#Nombre:		crear_fichero_entrada
#Descripcion: 	Esta función crea un fichero con los datos de entrada
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function crear_fichero_entrada {

	tput cuf 2 | tee -a "informeBN.txt"

	while read -p "¿Quiere guardar en otro fichero? Además, del estándar [s/n]:" opcion
	do
		

		if [ -z "$opcion" ] 
		then
			tput cuf 2 | tee -a "informeBN.txt"
			
			echo "Elija, sí o no" | tee -a "informeBN.txt"
		
		else 
				
			case ${opcion,,} in

			s|sí)
				 while read -p "Elige nombre del fichero:" fichero_datos_salida
				  do
				  	[ -z "$fichero_datos_salida" ] && echo "El nombre del fichero no puede quedar vacío" | tee -a "informeBN.txt" && continue

				  	echo "Elige nombre del fichero $fichero_datos_salida" >> "informeBN.txt"

				  	break
				done
				
				fichero_estandar="ultimosdatosejecutados.txt"

				echo "MEM:$tamanio_memoria">>$fichero_datos_salida && echo "MEM:$tamanio_memoria">>$fichero_estandar
				echo "REU:$reubicabilidad">>$fichero_datos_salida && echo "REU:$reubicabilidad">>$fichero_estandar
	
				echo "Tll:Tej:Mem">>$fichero_datos_salida && echo "Tll:Tej:Mem">>$fichero_estandar
	

				for (( i = 1; i <= $contador; i++ )); do
		
				if [[ $i -eq $contador ]]; then

					echo -n "${arr_tiempos_llegada_fichero[$i]}:${arr_tiempos_ejecucion_fichero[$i]}:${arr_memoria_fichero[$i]}">>$fichero_datos_salida

					echo -n "${arr_tiempos_llegada_fichero[$i]}:${arr_tiempos_ejecucion_fichero[$i]}:${arr_memoria_fichero[$i]}">>$fichero_estandar
		
				else
			
					echo "${arr_tiempos_llegada_fichero[$i]}:${arr_tiempos_ejecucion_fichero[$i]}:${arr_memoria_fichero[$i]}">>$fichero_datos_salida

					echo "${arr_tiempos_llegada_fichero[$i]}:${arr_tiempos_ejecucion_fichero[$i]}:${arr_memoria_fichero[$i]}">>$fichero_estandar

				fi
	
			done
	
				[ ! -d FICHEROS_ENTRADA ] && mkdir FICHEROS_ENTRADA

				mv $fichero_datos_salida FICHEROS_ENTRADA

				mv $fichero_estandar FICHEROS_ENTRADA

			break
			;;

			n|no)  echo "$opcion" >> "informeBN.txt"
				   crearFicheroEjecucionAnterior

				break
				;;

			esac

			
			fi

	done

	
	
}

#Nombre:		bucle_principal_script
#Descripcion: 	Esta función coordina todas las tareas del funcionamiento del algoritmo
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function bucle_principal_script {
	declare -a cola
	declare -a array_estado
	declare -a array_tiempo_restante
	declare -a array_tiempo_espera
	declare -a array_tiempo_retorno
	#Estos arrays se encargan de calcular los elementos de la linea de memoria
	declare -a array_memoria
	declare -a direcciones_linea_memoria
	declare -a procesos_linea_memoria
	#Estos arrays se encargan de calcular los elementos de la linea de tiempo
	declare -a array_linea_temporal
	declare -a tiempo_linea_temporal
	declare -a procesos_linea_temporal
	#Este es un array bidimensional encargado de guardar en la columna 1 el proceso y en las dos siguientes la DIn y la DFi
	declare -a direcciones_memoria
	declare -a direcciones_memoria_final
	declare -a direcciones_memoria_inicial
	declare -a direcciones_memoria_proceso

	ordenado_nombres_procesos[0]="---"
	ordenado_arr_colores[0]="$DEFAULT"
	unset direcciones_memoria_proceso
	unset direcciones_memoria_inicial
	unset direcciones_memoria_final

	contador_partes_de_procesos_en_mem=0



	proceso=1
	tamCola=0
	proceso_en_ejecucion=0
	tiempo=-1
	procesos_ejecutados=0
	tiempo_medio_espera=0
	tiempo_medio_retorno=0

	inicializar_array_tiempo_espera
	inicializar_array_tiempo_restante
	inicializar_array_estado
	inicializar_array_tiempo_retorno
	inicializar_array_memoria

	submenuEleccionTipoDeEjecucion

	while [[ $procesos_ejecutados -lt $contador ]]; do
		((tiempo++))
		cambio_a_imprimir=0
		#echo Tiempo=$tiempo

		if [[ $proceso_en_ejecucion -ne 0 ]] && [[ $tiempo -ne 0 ]]; then
			array_tiempo_restante[$proceso_en_ejecucion]=$((${array_tiempo_restante[$proceso_en_ejecucion]}-1))
		fi

		if [[ ${array_tiempo_restante[$proceso_en_ejecucion]} -eq 0 ]]; then
			if [[ $proceso_en_ejecucion != 0 ]]; then
				#echo $proceso_en_ejecucion
				((procesos_ejecutados++))
			fi

			array_estado[$proceso_en_ejecucion]="Finalizado"
			cambio_a_imprimir=1
			array_tiempo_retorno[$proceso_en_ejecucion]=$((${array_tiempo_retorno[$proceso_en_ejecucion]}+1))
			#array_tiempo_espera[$proceso_en_ejecucion]=$((${array_tiempo_espera[$proceso_en_ejecucion]}+1))
			#array_tiempo_retorno[$proceso_en_ejecucion]=$tiempo
			eliminarMemoria
			organizarMemoria

			#echo Memoria despues de EM:
			#echo "eliminar"
			#imprimir_mem
			proceso_en_ejecucion=0
		fi


		for (( j = 1; j<=$contador ; j++ )); do
			
			if [[ $tiempo -eq ${ordenado_arr_tiempos_llegada[$j]} ]]; then
			#echo "tiempo: $tiempo"
			#echo "ordenador arrays:${ordenado_arr_tiempos_llegada[$j]}"
			#read
			proceso=$j
			anadirCola
			fi
		done

		
		primero_en_cola=${cola[1]}
		calcular_memoria_restante

		while [[ $memoria_restante -ge ${ordenado_arr_memoria[$primero_en_cola]} ]] && [[ $tamCola -gt 0 ]]; do
			primero_en_cola=${cola[1]}
			calcular_memoria_restante
			if [[ $memoria_restante -ge ${ordenado_arr_memoria[$primero_en_cola]} ]] && [[ $tamCola -gt 0 ]]; then
				#echo "memoria restante: $memoria_restante"
				#echo "Array ordenado en memoria: ${ordenado_arr_memoria[$primero_en_cola]}"
				#echo "tamaño cola: $tamCola"
				#read
				gg_necesito_reubicar
				anadirMemoria
				#echo "añadir"
				#imprimir_mem
				eliminarCola

				
			fi
		done	
		
		#Condicional encargado de meter procesos a CPU
		if [[ $proceso_en_ejecucion -eq 0 ]]; then
			proceso_en_ejecucion=$(buscar_en_memoria)
			if [[ $proceso_en_ejecucion  -gt 100 ]]; then
				proceso_en_ejecucion=0
			fi
			#echo "buscar"
			#imprimir_mem
			#echo EN EJ: $proceso_en_ejecucion
			if [[ $tiempo -ne 0 ]] && [[ $tiempo -ne ${ordenado_arr_tiempos_llegada[$proceso_en_ejecucion]} ]]; then
				array_tiempo_espera[$proceso_en_ejecucion]=$((${array_tiempo_espera[$proceso_en_ejecucion]}+1))
			fi

			array_estado[$proceso_en_ejecucion]="En ejecucion"
			if [[ $proceso_en_ejecucion -ne 0 ]]; then
				cambio_a_imprimir=1
			fi
			

		fi

		#Con esto actualizo unidad de tiempo a unidad de tiempo la LINEA TEMPORAL

			direcciones_linea_memoria
			procesos_linea_memoria
			
			array_linea_temporal[$tiempo]=$proceso_en_ejecucion
			tiempo_linea_temporal
			procesos_linea_temporal
		
		#Bucle encargado de calcular el TIEMPO DE RETORNO
		for (( i = 1; i <= $contador ; i++ )); do
			if [[ ${array_estado[$i]} == "En memoria" ]] || [[ ${array_estado[$i]} == "En espera" ]] || [[ ${array_estado[$i]} == "En ejecucion" ]]; then
				if [[ $tiempo -ne ${ordenado_arr_tiempos_llegada[$i]} ]]; then
					array_tiempo_retorno[$i]=$((${array_tiempo_retorno[$i]}+1))
					
				fi
			fi

		done

		#Bucle encargado de calcular el TIEMPO EN ESPERA
		for (( i = 1; i <= $contador ; i++ )); do
			if [[ ${array_estado[$i]} == "En memoria" ]] || [[ ${array_estado[$i]} == "En espera" ]]; then
				if [[ $tiempo -ne ${ordenado_arr_tiempos_llegada[$i]} ]]; then
					array_tiempo_espera[$i]=$((${array_tiempo_espera[$i]}+1))
					
				fi
			fi

		done

		
		for (( i = 1; i <= $contador; i++ )); do
			if [[ ${array_tiempo_restante[$i]} != "-" ]]; then
				if [[ ${array_tiempo_restante[$i]} -eq 0 ]]&>/dev/null; then
					array_tiempo_restante[$i]="-"
				fi
			fi
		done

		llenar_direcciones_memoria

		tiempos_medios
		
		

		if [[ $cambio_a_imprimir -eq 1 ]] && [[ $tiempo -ge ${ordenado_arr_tiempos_llegada[1]} ]] ||  [[ $tiempo -eq 0 ]] || [[ $procesos_ejecutados -eq $contador ]] ; then
			clear
			printf "%1s FCFS-C-R \n" | tee -a informeBN.txt
			printf "%1s T=$tiempo    %5s    MEMtotal=$tamanio_memoria \n" | tee -a informeBN.txt
				
			
			tabla_con_DM

			
			if [[ $necesito_reubicar -eq 1 ]]; then
				echo -e " \e[31m\e[1m\e[106mSE HA REUBICADO LA MEMORIA\u2757\u2757\e[49m\e[39m\e[0m"
				necesito_reubicar=0
			fi
			
			printf " TIEMPO MEDIO ESPERA = $tiempo_medio_espera " | tee -a "informeBN.txt"
			printf "TIEMPO MEDIO RETORNO = $tiempo_medio_retorno\n" | tee -a "informeBN.txt"
			#echo "$procesos_ejecutados"
			truncado_memoria
			#imprimir_procesos_linea_memoria
			#imprimir_linea_memoria
			#echo "${direcciones_linea_memoria[@]}"
			#imprimir_direcciones_linea_memoria
			echo "" | tee -a "informeBN.txt"
			#echo $procesos_media
		
			
			#echo "LINEA TEMPORAL:"
			#echo ${array_linea_temporal[@]}
			
			#echo ${tiempo_linea_temporal[@]}
			#if [[ $tiempo -eq 0 ]]; then
			#	printf "   |\n"
			#	printf " BT|\n"
			#	printf "   |"
			#fi

			if [[ $tiempo -ge 0 ]]; then
				#echo "${tiempo_linea_temporal[@]}"
				truncado_tiempo
				
				#echo ""
				#imprimir_procesos_linea_temporal
				#imprimir_linea_temporal
				#imprimir_tiempo_linea_temporal
			fi
			
			printf "\n" | tee -a "informeBN.txt"

			if [ "$ejecucion_por_eventos" -eq 1 ]
			then
				
				read -ers -p " Pulse [intro] para continuar la ejecucion" #CONTROL DE EJECUCIÓN DEL PROGRAMA

				echo " Pulse [intro] para continuar la ejecucion" >> informeBN.txt
			
			elif [ "$ejecucion_por_automatico" -eq 1 ]
				then
				
				sleep "$segundos"
			
			elif [ "$ejecucion_por_completo" -eq 1 ]
				then

				sleep 0.1

			fi

		fi
		
		 for (( i = 1; i <= $contador_partes_de_procesos_en_mem; i++ )); do
		 	direcciones_memoria_proceso[$i]=0
		 	direcciones_memoria_inicial[$i]=0
		 	direcciones_memoria_final[$i]=0

		 done

	done

	imprimir_informe
}


#Nombre:		quitar_clear
#Descripcion: 	Esta función quita los clear del fichero a color
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function quitar_clear {
	sed -i 's/\x1b\[3J//g' informeColor.txt
	sed -i 's/\x1b\[2J//g' informeColor.txt
	sed -i 's/\x1b\[H//g' informeColor.txt
	#sed -i 's/\x1b\[3J\x1b\[2J\x1b\[H//g' informePrueba.txt no va
}





#Nombre:		inicio
#Descripcion: 	Inicio del script
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function inicio {
	clear 
	
	echo "      ############################################################" | tee -a informeColor.txt
	echo "      #                     Creative Commons                     #" | tee -a informeColor.txt
	echo "      #                                                          #" | tee -a informeColor.txt
	echo "      #                   BY - Atribución (BY)                   #" | tee -a informeColor.txt
	echo "      #                 NC - No uso Comercial (NC)               #" | tee -a informeColor.txt
	echo "      #                SA - Compartir Igual (SA)                 #" | tee -a informeColor.txt
	echo "      ############################################################" | tee -a informeColor.txt


	echo "      ############################################################">> informeBN.txt
	echo "      #                     Creative Commons                     #">> informeBN.txt
	echo "      #                                                          #">> informeBN.txt
	echo "      #                   BY - Atribución (BY)                   #">> informeBN.txt
	echo "      #                 NC - No uso Comercial (NC)               #">> informeBN.txt
	echo "      #                SA - Compartir Igual (SA)                 #">> informeBN.txt
	echo "      ############################################################">> informeBN.txt


	echo "">>informeColor.txt && echo "" >> informeBN.txt
	echo "">>informeColor.txt && echo "" >> informeBN.txt

	echo "      #######################################################################">> informeColor.txt
	echo "      #                                                                     #">> informeColor.txt
	echo "      #                         INFORME DE PRÁCTICA                         #">> informeColor.txt
	echo "      #                         GESTIÓN DE PROCESOS                         #">> informeColor.txt
	echo "      #---------------------------------------------------------------------#">> informeColor.txt
	echo "      #     Algoritmo:FCFS-NC-R                                             #">> informeColor.txt
	echo "      #     Último Alumno: Juan Pedro Alarcón Gómez                         #">> informeColor.txt
	echo "      #                                                                     #">> informeColor.txt
	echo "      #     Alumnos Anteriores:                                             #">> informeColor.txt
	echo "      #        Víctor Paniagua Santana                                      #">> informeColor.txt
	echo "      #        Enzo Argeñal                                                 #">> informeColor.txt
	echo "      #        Hector Cogollos y Luis Miguel Cabrejas                       #">> informeColor.txt
	echo "      #        Omar Santos Bernabé                                          #">> informeColor.txt
	echo "      #---------------------------------------------------------------------#">> informeColor.txt
	echo "      #              Sistemas Operativos 2º Semestre                        #">> informeColor.txt
	echo "      #              Grado en ingeniería informática (2021-2022)            #">> informeColor.txt
	echo "      #                                                                     #">> informeColor.txt
	echo "      #######################################################################">> informeColor.txt



	echo "      #######################################################################">> informeBN.txt
	echo "      #                                                                     #">> informeBN.txt
	echo "      #                         INFORME DE PRÁCTICA                         #">> informeBN.txt
	echo "      #                         GESTIÓN DE PROCESOS                         #">> informeBN.txt
	echo "      #---------------------------------------------------------------------#">> informeBN.txt
	echo "      #     Algoritmo:FCFS-SN-N-S                                           #">> informeBN.txt
	echo "      #     Último Alumno: Juan Pedro Alarcón Gómez                         #">> informeBN.txt
	echo "      #                                                                     #">> informeBN.txt
	echo "      #     Alumnos Anteriores:                                             #">> informeBN.txt
	echo "      #        Víctor Paniagua Santana                                      #">> informeBN.txt
	echo "      #        Enzo Argeñal                                                 #">> informeBN.txt
	echo "      #        Hector Cogollos y Luis Miguel Cabrejas                       #">> informeBN.txt
	echo "      #        Omar Santos Bernabé                                          #">> informeBN.txt
	echo "      #---------------------------------------------------------------------#">> informeBN.txt
	echo "      #              Sistemas Operativos 2º Semestre                        #">> informeBN.txt
	echo "      #              Grado en ingeniería informática (2021-2022)            #">> informeBN.txt
	echo "      #                                                                     #">> informeBN.txt
	echo "      #######################################################################">> informeBN.txt



	
	echo "" | tee -a informeBN.txt
	echo "" | tee -a informeBN.txt

	echo " " >> informeColor.txt
	echo " " >> informeColor.txt

	echo -e "\e[31m        /= = = = = = = = = = = = = = = = = = = = = = = = = = = =\\"  | tee -a informeColor.txt
	echo -e "\e[31m       /= = = = = = = = = = = = = = = = = = = = = = = = = = = = =\\" | tee -a informeColor.txt
	echo -e "\e[31m      ||                                                         ||\e[39m" | tee -a informeColor.txt
	echo -e "\e[31m      ||   FCFS-SN-N-S:                                          ||\e[39m" | tee -a informeColor.txt
	echo -e "\e[31m      ||        -FCFS:First Coming First Served                  ||\e[39m" | tee -a informeColor.txt
	echo -e "\e[31m      ||        -C:Continua                           			||\e[39m" | tee -a informeColor.txt
	echo -e "\e[31m      ||        -R:Reubicable 		                            ||\e[39m" | tee -a informeColor.txt
	echo -e "\e[31m      ||                                                         ||\e[39m" | tee -a informeColor.txt
	echo -e "\e[31m      ||                                                         ||\e[39m" | tee -a informeColor.txt
	echo -e "\e[31m      ||   AUTOR:                                                ||\e[39m" | tee -a informeColor.txt
	echo -e "\e[31m      ||        -Juan Pedro Alarcón Gómez                        ||\e[39m" | tee -a informeColor.txt
	echo -e "\e[31m      ||                                                         ||\e[39m" | tee -a informeColor.txt
	echo -e "\e[31m      ||   VERSIÓN:                                              ||\e[39m" | tee -a informeColor.txt
	echo -e "\e[31m      ||        -Mayo 2022  	                                    ||\e[39m" | tee -a informeColor.txt
	echo -e "\e[31m      ||                                                         ||\e[39m" | tee -a informeColor.txt
	echo -e "\e[31m       \\= = = = = = = = = = = = = = = = = = = = = = = = = = = = =/\e[39m" | tee -a informeColor.txt
	echo -e "\e[31m        \\= = = = = = = = = = = = = = = = = = = = = = = = = = = =/\e[39m"  | tee -a informeColor.txt



	echo -e "        /= = = = = = = = = = = = = = = = = = = = = = = = = = = =\\"   >> informeBN.txt
	echo -e "       /= = = = = = = = = = = = = = = = = = = = = = = = = = = = =\\"  >> informeBN.txt
	echo -e "      ||                                                         ||" >> informeBN.txt
	echo -e "      ||   FCFS-NC-R:                                            ||" >> informeBN.txt
	echo -e "      ||        -FCFS:First Coming First Served                  ||" >> informeBN.txt
	echo -e "      ||        -C:Memoria Continua                             ||" >> informeBN.txt
	echo -e "      ||        -R:Reubicable                           	  	  ||" >> informeBN.txt
	echo -e "      ||                                                         ||" >> informeBN.txt
	echo -e "      ||                                                         ||" >> informeBN.txt
	echo -e "      ||   AUTOR:                                                ||" >> informeBN.txt
	echo -e "      ||        -Juan Pedro Alarcón Gómez                        ||" >> informeBN.txt
	echo -e "      ||                                                         ||" >> informeBN.txt
	echo -e "      ||   VERSIÓN:                                              ||" >> informeBN.txt
	echo -e "      ||        -Mayo 2022                                       ||" >> informeBN.txt
	echo -e "      ||                                                         ||" >> informeBN.txt
	echo -e "       \\= = = = = = = = = = = = = = = = = = = = = = = = = = = = =/" >> informeBN.txt
	echo -e "        \\= = = = = = = = = = = = = = = = = = = = = = = = = = = =/"  >> informeBN.txt

	
	echo " " | tee -a informeColor.txt
	echo " " >> informeBN.txt
	
	read -ers -p "Pulse [intro] para continuar la ejecucion"

	tput cuf 1 >> informeBN.txt

	echo "Pulse [intro] para continuar la ejecucion" >> informeBN.txt

}


#Nombre:		comienzo
#Descripcion: 	Con esta función comenzamos el programa
#Autor:		  	Juan Pedro Alarcón Gómez
#Organización:	Universidad de Burgos
function comienzo {
	#Esta variable guarda el numero maximo de partes de procesos con las que se reubica
	reubicabilidad=0

	opcion_menu_datos=0
	rm FICHEROS_ENTRADA/informeColor.txt
	rm FICHEROS_ENTRADA/informeBN.txt
	inicio
	clear
	echo ""
	menu

	
	bucle_principal_script | tee -a informeColor.txt
	quitar_clear
	
}

#Llamada a la función anterior
comienzo
