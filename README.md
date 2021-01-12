# Create a (Magento 2.4 + Devilbox) or config devilbox as Magento 2.4 needs it

## General

The main objective is to create a new Magento 2 instance for local development, as fast as possible and with few steps.

This is a set of 3 scripts:

- 01_magento2_create_new_local_project.sh does all the work. (A) Checks Devilbox configuration, configures it for Magento 2 needings, (B) creates project directories with /etc/hosts entry, (C)copies an installation script to execute it from inside the php container (it installs and configures magento 2 for local development)
- 02_devilbox_config_enviroment.sh just configures devilbox for magento 2 needings (A point from above only)
- 03_devilbox_create_new_project.sh just creates devilbox project directories and entry in /etc/hosts (B point from above only)

## Requirements

- Latest Devilbox installation https://devilbox.readthedocs.io/en/latest/getting-started/install-the-devilbox.html

**IMPORTANT** It will configure your devilbox project dir as ~/www-projects (this is configured in devilbox/.env file). **It will delete** devilbox/.env and devilbox/cfg/php-ini-<version>/custom.ini files every time it's executed (it does needed replaces in those files to configure Devilbox properly), so make sure you have backup of those files.

## Usage

- Clone repo or download it wherever you want in your fylesystem
- Give execution permission to the 3 main .sh files
- Open to_copy/install_magento/<version>/auth.json and paste your magento marketplace keys to avoid beign asked for credentials when the install script does the 'composer create-project' part
- Execute ./01_magento2_create_new_local_project.sh -m exampleproject and follow instructions
    - When it finishes, you will be given 2 command to execute. Just copy and paste them in a new shell
    - First command will enter devilbox php container
    - Second command will execute magento 2 installation and configuration from inside the php container (it performs a composer installation)

**TODO**

- [X] complete "TODOs" from magento2.4_local_switch.sh
- [X] create a dir structure following magento versions, so we can config or create different magento versions (a variable to switch between them will be needed)
- [X] create db creation script
- [X] create download magento and install script
- [X] create magento post installation script
- [X] clean unnecesary parameters
- [X] clean file names and main file name (main scripts should be generic as they will get called in a CLI)
- [ ] restructure includes, functions and script directories
- [ ] create each step extension system (if certain script exists, then execute it)
- [ ] integration with Dotly scripts
- [ ] in includes/variables.sh, delete hardcoded username and that user home directory
- [ ] create _stop.sh script creation to stop all container in secure way