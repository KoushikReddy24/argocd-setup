# /bin/bash
#***********************************************************************************************************#
#******* This script will do database upgrade from current version to required version automatically********#
#******* Current database backup will be taken and restore once upgrade uas been comp;eted          ********#
#******* This script is developed by Surendra as a part of sprint#235(SOL-29586)              ********#
#***********************************************************************************************************#
set -e
echo Enter Database Name to take backup:
read Databasename
echo '********************'
echo Enter Database User Name to take backup:
read Databaseusername
echo '********************'
sleep 2
kubectl get pods
sleep 2
echo '***************************************************************************************************'
echo "                        $Databasename Database current version                           "
echo '***************************************************************************************************'
kubectl exec -i postgres-statefulset-0 bash -- psql  -U $Databaseusername -d $Databasename -c "select version();"
sleep 2
echo '***************************************************************************************************'
echo "                   Database backup started               "                       
echo '***************************************************************************************************'
kubectl exec -i postgres-statefulset-0 -- bash -c "pg_dumpall -U $Databaseusername">db_dump.sql
sleep 2
echo '*****************************************************************************************************'
echo "                   Database backup completed successfully     "
echo '***************************************************************************************************'
