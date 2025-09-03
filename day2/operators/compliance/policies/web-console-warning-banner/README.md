# Web console warning banner

- Modifify the warning_banner.yaml file with the correct display text and color for your configuration

- Apply the console notification object to create the warning banner in the web console

Note: This console notification only appears after a user logs into the cluster. It does not appear on the web console splash screen
Customizing the web console splash screen is done in another config directory in this repository: custom-web-console-splash-screen

```console
oc create -f warning_banner.yaml
```
