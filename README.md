# Create a (Magento 2.4 + Devilbox) or config devilbox as Magento 2.4 needs it

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