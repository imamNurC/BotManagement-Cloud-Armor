### Task 5. Create Cloud Armor security policy rules for Bot Management

gcloud compute security-policies create recaptcha-policy \
    --description "policy for bot management"

gcloud compute security-policies update recaptcha-policy \
  --recaptcha-redirect-site-key "$RECAPTCHA_KEY"

gcloud compute security-policies rules create 2000 \
    --security-policy recaptcha-policy\
    --expression "request.path.matches('good-score.html') &&    token.recaptcha_session.score > 0.4"\
    --action allow

gcloud compute security-policies rules create 3000 \
    --security-policy recaptcha-policy\
    --expression "request.path.matches('bad-score.html') && token.recaptcha_session.score < 0.6"\
    --action "deny-403"

gcloud compute security-policies rules create 1000 \
    --security-policy recaptcha-policy\
    --expression "request.path.matches('median-score.html') && token.recaptcha_session.score == 0.5"\
    --action redirect \
    --redirect-type google-recaptcha

gcloud compute backend-services update http-backend \
    --security-policy recaptcha-policy --global