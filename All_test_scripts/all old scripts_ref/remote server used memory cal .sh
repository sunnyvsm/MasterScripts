#/bin/bash
for i in `cat /tmp/mem_inf/hosts_dir/hosts_vid`
do
ssh $i 'hostname|awk '{print}' ORS='   ';echo -en "\t " ;free -m | grep "Mem:" | cut -d ":" -f2 | tr -s " " | awk -F " " "{print \$2,\$3}" OFS="\t"|awk '{print}' ORS='   ';echo -en "\t "; date +%Y-%m-%d-%H:%M' 2>> /tmp/mem_inf/all_error >> /tmp/mem_inf/all_output
done
for i in `cat /tmp/mem_inf/hosts_dir/hosts1`
do
ssh -i /tmp/mem_inf/key_pair/gio-keypair ec2-user@$i 'hostname|awk '{print}' ORS='   ';echo -en "\t " ;free -m | grep "Mem:" | cut -d ":" -f2 | tr -s " " | awk -F " " "{print \$2,\$3}" OFS="\t"|awk '{print}' ORS='   ';echo -en "\t "; date +%Y-%m-%d-%H:%M' 2>> /tmp/mem_inf/all_error >> /tmp/mem_inf/all_output
done
ssh -i  /tmp/mem_inf/key_pair/TechOps-USwest2.pem ec2-user@54.191.167.43 'hostname|awk '{print}' ORS='   ';echo -en "\t " ;free -m | grep "Mem:" | cut -d ":" -f2 | tr -s " " | awk -F " " "{print \$2,\$3}" OFS="\t"|awk '{print}' ORS='   ';echo -en "\t "; date +%Y-%m-%d-%H:%M' 2>> /tmp/mem_inf/all_error >> /tmp/mem_inf/all_output
ssh -i /tmp/mem_inf/key_pair/techops-euw1-keypair.pem ec2-user@54.194.209.207 'hostname|awk '{print}' ORS='   ';echo -en "\t " ;free -m | grep "Mem:" | cut -d ":" -f2 | tr -s " " | awk -F " " "{print \$2,\$3}" OFS="\t"|awk '{print}' ORS='   ';echo -en "\t "; date +%Y-%m-%d-%H:%M' 2>> /tmp/mem_inf/all_error >> /tmp/mem_inf/all_output
ssh -i  /tmp/mem_inf/key_pair/techops-apse1-keypair.pem ec2-user@54.254.129.168 'hostname|awk '{print}' ORS='   ';echo -en "\t " ;free -m | grep "Mem:" | cut -d ":" -f2 | tr -s " " | awk -F " " "{print \$2,\$3}" OFS="\t"|awk '{print}' ORS='   ';echo -en "\t "; date +%Y-%m-%d-%H:%M' 2>> /tmp/mem_inf/all_error >> /tmp/mem_inf/all_output


echo " " >> /tmp/mem_inf/all_output
