####  Task 4. Create and deploy reCAPTCHA session token and challenge-page site key




# Run the gcloud command and store the output in a variable using command substitution
TOKEN_KEY=$(gcloud recaptcha keys create --display-name=test-key-name \
  --web --allow-all-domains --integration-type=score --testing-score=0.5 \
  --waf-feature=session-token --waf-service=ca --format="value(name)")

# Extract the token key without the project and key path
TOKEN_KEY=$(echo "$TOKEN_KEY" | awk -F '/' '{print $NF}')

# Echo the token key
echo "Token key: $TOKEN_KEY"

RECAPTCHA_KEY=$(gcloud recaptcha keys create --display-name=challenge-page-key \
--web --allow-all-domains --integration-type=INVISIBLE \
--waf-feature=challenge-page --waf-service=ca --format="value(name)")

RECAPTCHA_KEY=$(echo "$RECAPTCHA_KEY" | awk -F '/' '{print $NF}' )

# Run the gcloud command to list VM instances and filter by name
INSTANCE_NAME=$(gcloud compute instances list --format="value(name)" \
  --filter="name~^lb-backend-example" | head -n 1)

# Echo the instance name
echo "Instance name: $INSTANCE_NAME"

cat > prepare_disk.sh <<'EOF_END'
export TOKEN_KEY="$TOKEN_KEY"

cd /var/www/html/

sudo tee index.html > /dev/null <<HTML_CONTENT
<!doctype html>
<html>
<head>
  <title>ReCAPTCHA Session Token</title>
  <script src="https://www.google.com/recaptcha/enterprise.js?render=$TOKEN_KEY&waf=session" async defer></script>
</head>
<body>
  <h1>Main Page</h1>
  <p><a href="/good-score.html">Visit allowed link</a></p>
  <p><a href="/bad-score.html">Visit blocked link</a></p>
  <p><a href="/median-score.html">Visit redirect link</a></p>
</body>
</html>
HTML_CONTENT

sudo tee good-score.html > /dev/null <<GOOD_SCORE_CONTENT
<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
</head>
<body>
  <h1>Congrats! You have a good score!!</h1>
</body>
</html>
GOOD_SCORE_CONTENT

sudo tee bad-score.html > /dev/null <<BAD_SCORE_CONTENT
<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
</head>
<body>
  <h1>Sorry, You have a bad score!</h1>
</body>
</html>
BAD_SCORE_CONTENT

sudo tee median-score.html > /dev/null <<MEDIAN_SCORE_CONTENT
<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
</head>
<body>
  <h1>You have a median score that we need a second verification.</h1>
</body>
</html>
MEDIAN_SCORE_CONTENT
EOF_END

gcloud compute scp prepare_disk.sh $INSTANCE_NAME:/tmp --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet

gcloud compute ssh $INSTANCE_NAME --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet --command="export TOKEN_KEY=$TOKEN_KEY && bash /tmp/prepare_disk.sh"
