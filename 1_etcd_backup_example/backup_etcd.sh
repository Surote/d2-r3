#!/bin/bash

etcd_backup_path=/home/lab-user/backup
ssh_private_key=/home/lab-user/.ssh/ocp

etcd_master_backup_script=/usr/local/bin/cluster-backup.sh
echo -e "\n@@@@@@@@@@ START BACKUP ETCD on $(date) @@@@@@@@@@\n"
for master_node in 192.168.162.25 192.168.162.17 192.168.162.13
do
  echo -e "\n########## BACKUP ETCD on $master_node ##########\n"
  ssh -i $ssh_private_key core@$master_node "sudo $etcd_master_backup_script ./assets/backup"
  ssh -i $ssh_private_key core@$master_node "sudo chmod 604 /var/home/core/assets/backup/snapshot_*.db"
  ssh -i $ssh_private_key core@$master_node "sudo chmod 604 /var/home/core/assets/backup/static_kuberesources_*.gz"
  scp -p -i $ssh_private_key core@$master_node:/var/home/core/assets/backup/snapshot_*.db $etcd_backup_path/$master_node/
  scp -p -i $ssh_private_key core@$master_node:/var/home/core/assets/backup/static_kuberesources_*.gz $etcd_backup_path/$master_node/
  ssh -i $ssh_private_key core@$master_node "sudo rm -rf ./assets"
  find $etcd_backup_path/$master_node/ -name "snapshot_*" -type f -daystart -mtime +4 -exec rm -f {} \;
  find $etcd_backup_path/$master_node/ -name "static_kuberesources*" -type f -daystart -mtime +4 -exec rm -f {} \;

done


