#### Task 2. Configure instance templates and create managed instance groups
 
<<Komen

gcloud compute instance-templates create lb-backend-template \
    --machine-type=n1-standard-1 \
    --region=$REGION \
    --network=default \
    --subnet=default \
    --tags=allow-health-check \
    --metadata=startup-script='#! /bin/bash
Komen




sudo apt-get update
sudo apt-get install apache2 -y
sudo a2ensite default-ssl
sudo a2enmod ssl
sudo su
vm_hostname="$(curl -H "Metadata-Flavor:Google" http://metadata.google.internal/computeMetadata/v1/instance/name)"
echo "Page served from: $vm_hostname" | tee /var/www/html/index.html'

sleep 40


<<komen
gcloud beta compute instance-groups managed create lb-backend-example --project=$PROJECT_ID --base-instance-name=lb-backend-example --template=projects/$PROJECT_ID/global/instanceTemplates/lb-backend-template --size=1 --zone=$ZONE --default-action-on-vm-failure=repair --no-force-update-on-repair --standby-policy-mode=manual --list-managed-instances-results=PAGELESS && gcloud beta compute instance-groups managed set-autoscaling lb-backend-example --project=$PROJECT_ID --zone=$ZONE --mode=off --min-num-replicas=1 --max-num-replicas=10 --target-cpu-utilization=0.6 --cool-down-period=60
komen


gcloud compute instance-groups set-named-ports lb-backend-example \
--named-ports http:80 \
--zone $ZONE