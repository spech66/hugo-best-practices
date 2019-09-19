# hugo-best-practices - deployment

This folder contains a simple deployment script with basic error handling. The script will build the website in the `public` folder and copy files using `rsync`.

## Usage

Copy to the root folder of your page and modify the `deploy_config`.

Make sure the destination server is reachable by ssh using `authorized_keys`.

Just run `./deploy.sh` and wait.
