# Dead Link Checker

Check for dead links and notify about them via Slack

### How to run

```bash
bundle install --path=vendor/bundle
```

```bash
SLACK_WEBHOOK=<your-slack-webhook> \
LINK_LIST_URL=<your-link-list-url> \
PRIMARY_WAIT_TIME=3 \
ON_FAIL_WAIT_TIME=30 \
RETRY_COUNT=3 \
bundle exec ruby lib/dead_link_checker.rb
```

### Config
`JOBS_LIST_URL` (string): API endpoint URL that returns links to check as a JSON array.

JSON format:
```
[
  "https://example.com/link-1",
  "https://example.com/link-2",
  "https://example.com/link-3",
]
```

`PRIMARY_WAIT_TIME` (integer): Number of seconds to wait between checking links

`ON_FAIL_WAIT_TIME` (integer): Number of seconds to wait before retrying a failed link

`RETRY_COUNT` (integer): Number of times to retry when a link fails before notifying

`SLACKHOOK_WEBHOOK` (string): Link for [incoming webhook](https://slack.com/help/articles/115005265063-Incoming-webhooks-for-Slack) for Slack

### Screenshots

If the script finds a dead link, you'll receive a Slack message like this in the channel/slack worspace specified by your supplied webhook:

![image](https://user-images.githubusercontent.com/6726985/91029287-86f5c700-e639-11ea-805f-2062f3f90d21.png)


### Kubernetes Cron Job Config

Example cron config to run this as a kubernetes cron job:

```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: dead-link-checker
spec:
  schedule: "0 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: dead-link-checker
            image: registry.gitlab.com/etdev/dead-link-checker:0.1
            imagePullPolicy: Always
            command:
              - "/bin/sh"
              - "-c"
              - "bundle exec ruby lib/dead_link_checker.rb"
            env:
            - name: SLACK_WEBHOOK
              valueFrom:
                secretKeyRef:
                  name: {{ your-secret-name }}
                  key: {{ your-secret-key }}
            - name: LINK_LIST_URL
              value: {{ link-list-api-endpoint-url }}
            - name: PRIMARY_WAIT_TIME
              value: 5
            - name: ON_FAIL_WAIT_TIME
              value: 30
            - name: RETRY_COUNT
              value: 3
          restartPolicy: OnFailure
```
