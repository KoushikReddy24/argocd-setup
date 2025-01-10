# /bin/bash
#***********************************************************************************************************#
#******* This script will do database upgrade from current version to required version automatically********#
#******* Current database backup will be taken and restore once upgrade uas been comp;eted  Databasename        ********#
#******* This script is developed by Surendra as a part of sprint#235(SOL-29586)              ********#
#***********************************************************************************************************#
set -e
echo Enter Database Name to restore:
read Databasename
echo '*******************'
echo Enter Database User Name :
read Databaseusername
echo '*******************'
kubectl get pods
sleep 5
echo '***************************************************************************************************'
echo '               Postgres current version              '
echo '***************************************************************************************************'
kubectl exec -i postgres-statefulset-0 bash -- psql -U $Databaseusername -d postgres -c "select version();"
#echo '***************************************************************************************************'
#sleep 2
kubectl exec -i postgres-statefulset-0 bash -- psql -U $Databaseusername -d postgres -c "DROP DATABASE IF EXISTS $Databasename;"
kubectl exec -i postgres-statefulset-0 bash -- psql -U $Databaseusername -d postgres -c "DROP DATABASE IF EXISTS  csreportdb;"

sleep 5
echo "                       Datbase restoration is in progress                         "
echo '*****************************************************************************************************'
cat db_dump.sql | kubectl exec -i postgres-statefulset-0 -- psql -U $Databaseusername -d postgres
sleep 5
echo '*****************************************************************************************************'
echo  "                         Database restored successfully      "
echo '*****************************************************************************************************'
kubectl exec -i postgres-statefulset-0 bash -- psql -U $Databaseusername -d $Databasename -c "alter system set shared_preload_libraries = pg_cron,repmgr;"
kubectl exec -i  postgres-statefulset-0  -- /bin/bash -c "echo 'cron.database_name = '\''certscandb'\'>> /var/lib/postgresql/data/postgresql.conf"
kubectl exec -i  postgres-statefulset-0  -- /bin/bash -c "sed -i 's/scram-sha-256/trust/g' /var/lib/postgresql/data/pg_hba.conf"
kubectl exec -i  postgres-statefulset-0  -- /bin/bash -c "echo 'host        all          repmgr            all            trust' >> /var/lib/postgresql/data/pg_hba.conf"
kubectl exec -i postgres-statefulset-0 bash -- psql -U $Databaseusername -d $Databasename -c "ALTER ROLE $Databaseusername PASSWORD 'solutions@123';"
sleep 2
cd backend-services/nfs
kubectl delete -k .
sleep 5
kubectl apply -k .
sleep 40
kubectl exec -i postgres-statefulset-0 bash -- psql -U $Databaseusername -d $Databasename -c "GRANT USAGE ON SCHEMA cron TO $Databaseusername;"
kubectl get pods
echo '******************************************************************************************************'                     
