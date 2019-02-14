bakers-assistant
=====================

# Baker's Assistant

Baker's Assistant is a plugin for [LiveCode](https://www.livecode.com) that helps you with your Levure application development.

# Installation

You will find the plugin in a subfolder of the `./builds/release/` folder. Download the latest version of **bakers_assistant_plugin.livecode** file and place it in the [LiveCode plugins](http://lessons.livecode.com/m/4071/l/6348-how-to-install-a-3rd-party-plugin-in-the-livecode-ide) folder.

# Demonstration

Watch [this screencast](https://www.youtube.com/watch?v=ueWTE96gTvo) for a demonstration of how the plugin works.

# Packaging Plugin

To package the plugin for use in the LiveCode plugins folder load the application into the IDE and call `BuildPlugin "release"` from the message box. A single file, packaged version, of the app will appear in the `./builds/release` folder under a folder named after the current version defined in `app.yml`.
