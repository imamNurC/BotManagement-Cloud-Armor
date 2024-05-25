### Task 6. Validate Bot Management with Cloud Armor



LB_IP_ADDRESS=$(gcloud compute forwarding-rules describe http-lb-forwarding-rule --global --format="value(IPAddress)")

echo $LB_IP_ADDRESS

gcloud logging read "resource.type:(http_load_balancer) AND jsonPayload.enforcedSecurityPolicy.name:(recaptcha-policy)" --project=$DEVSHELL_PROJECT_ID --format=json

gcloud logging read "resource.type:(http_load_balancer) AND jsonPayload.enforcedSecurityPolicy.name:(recaptcha-policy)" --project=$DEVSHELL_PROJECT_ID --format=json

echo "http://$LB_IP_ADDRESS/index.html"