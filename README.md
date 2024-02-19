# bash_cups_control
cups_control

Tenta validar diversos comportamentos e status das filas de impressão no CUPS e se necessário ou possível, autocorrigir

Deve ser utilizado sempre com o mesmo suário local que estiver executando o JVM da aplicação, e pode depender de chaves públicas para acesso SSH de usuário com permissão de execução sudoer sem senha para alguns comandos com permissão no systemd (como status e reload de alguns serviços)

Recomendado execução em crontab:

*/2     *       *       *       *       nice -n 13 ionice -c2 -n7 /home/sc-tos-app/cups/coleta_status_cups.sh
