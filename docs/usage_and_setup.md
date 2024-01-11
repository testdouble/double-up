# Usage & Setup

## Slack commands

The following Slack commands are available to use with `/doubleup`

- `login`: Anywhere is Slack, you can run the `login` and it will send you a timed, authentication URL you can use to log into the UI portion of Double Up. Instead of maintaining a list of users with credentials, we leverage Slack to do the heavy lifting. Whatever authenticated user uses `login`, that same user will receive a message from the Double Up app with a URL that is invalid after 30 minutes.

## App Setup Instructions

1. Follow instructions and [create a new slack app](https://api.slack.com/authentication/basics)
2. Add the following scopes to your slack app: `users:read`, `mpim:write`, `im:write`, `chat:write`, `channels:join`, `channels:manage`, `groups:write`, `groups:read`, `mpim:read`, `im:read`, and `channels:read`.
3. Create a new app in Heroku or your hosting service of choice. Go to wherever you can add environment variables.
4. Set `MIN_GROUP_SIZE` to 3.
5. Get your secret key base and the oauth token for your newly created slack app. Store those as `SLACK_SIGNING_SECRET` and `SLACK_OAUTH_TOKEN`.
6. Create Slash Command called `doubleup` with a URL path of `/command/handle`.
7. Deploy app to Heroku (or your hosting service of choice).
8. If using Heroku, install Heroku Scheduler.
9. Schedule `rake create_groups` to run every day at a time of your choice. If you have a hosting service that will allow you to run cron jobs, you can remove the code mentioned above that checks that day and week and just use cron format. If using Heroku, just run daily and it will quit if it's not the right day 🙂
10. PROFIT!
