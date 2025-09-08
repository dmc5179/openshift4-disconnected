# Web console warning banner

- Modifify the classification-banner.yaml file with the correct display text and color for your configuration.  For the compliance operator to regonize compliance the ConsoleNotification must be named classification-banner

- These are the hexadecimal mappings for the banner background color based on classification level
| Level | Color Code |
| CONTROLLED UNCLASSIFIED INFORMATION | (CUI, color code: #502B85) |
| UNCLASSIFIED | (U, color code: #007A33) |
| CONFIDENTIAL | (C, color code: #0033A0) |
| SECRET | (S, color code: #C8102E) |
| TOP SECRET | (TS, color code: #FF8C00) |
| TOP SECRET//SENSITIVE COMPARTMENT INFORMATION | (TS//SCI, color code: #FCE83A) |

- Apply the console notification object to create the warning banner in the web console

Note: This console notification only appears after a user logs into the cluster. It does not appear on the web console splash screen
Customizing the web console splash screen is done in another config directory in this repository: custom-web-console-splash-screen

```console
oc create -f classification_banner.yaml
```
