#!/bin/sh
COMANDO=$0
ARGUMENTO=$1
LOG_GERAL=~/cups/status.log
LOG_NOTIDLE=~/cups/not_idle.log
LOG_PRESOS=~/cups/jobs_presos.log
LOG_ANTIGOS=~/cups/jobs_antigos.log

function ajuda_(){
        echo "Usage: $COMANDO [-v] [-h|--help]" >&2 ;
}

function guarda_jobs_suspeitos_antigos_(){
if [[ ${DEBUG} == "ON" ]] ; then 
	echo BACKUP DO ARQUIVO DE JOBS SUSPEITOS
fi
cat ${LOG_PRESOS} > ${LOG_ANTIGOS}
}

function coleta_status_(){
if [[ ${DEBUG} == "ON" ]] ; then 
	echo COLETA STATUS DOS DISPOSITIVOS E FILAS
fi
lpstat -W not-completed -u sc-tos-app -tv > ${LOG_GERAL}
}

function separa_not_idle_(){
if [[ ${DEBUG} == "ON" ]] ; then 
	echo SEPARA POSSIVEIS IMPRESSORAS COM PROBLEMA
fi
cat ${LOG_GERAL} | grep printer | grep -v idle > ${LOG_NOTIDLE}
}

function separa_jobs_suspeitos_(){
if [[ ${DEBUG} == "ON" ]] ; then 
	echo SEPARA POSSIVEIS JOBS PROBLEMAS
fi
cat ${LOG_NOTIDLE} | grep -e "^printer" | awk -F" " {'print $5'} | cut -d '.' -f 1 > ${LOG_PRESOS}
}

function decide_ai_(){
if [[ ${DEBUG} == "ON" ]] ; then 
	echo DECIDE O QUE FAZER SE ACHAR JOB REPETIDO NAS LISTAS
fi
for JOB_ANTIGO in `cat ${LOG_ANTIGOS}` ; do 
  grep ${JOB_ANTIGO} ${LOG_PRESOS}
  ULTIMA=$? 
  if [ ${ULTIMA} -eq 0 ] ; then
     /bin/cancel.cups ${JOB_ANTIGO}	
  fi
done
}

function arruma_param_(){
    case "${ARGUMENTO}" in
              -v)
			 echo "Server Server: AZR-TOS-PRD-003"
			 DEBUG=ON
                         ;;
              *)
			 DEBUG=OFF
                         ;;
    esac
guarda_jobs_suspeitos_antigos_;
coleta_status_;
separa_not_idle_;
separa_jobs_suspeitos_;
decide_ai_;
}

case "${ARGUMENTO}" in
        -h|--help)
                ajuda_;
                ;;
        *)
                arruma_param_;
                ;;
esac
