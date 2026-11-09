>[!WARNING]
>This repository has been archived and is no longer maintained. The code is provided for historical reference and may contain unpatched or unknown vulnerabilities. It should ***not*** be used in production systems.

# Heat-Tool
Rebuild and redesign of the OSHA Heat Safety Tool in Swift.

## Analytics
### Screen View Data Model
* Heat Index Screen
* Precautions Screen
* More Info Screen
* Info Content Screen

### Event Data Model
Category | Action | Label
------------ | ------------- | -------------
location-field | tap | get-current-conditions
location-field | tap | location-services-disabled-alert
app | open-app | get-current-conditions
app | bring-app-to-foreground | get-current-conditions
keyboard | set | calculate-entered-conditions
now-risk | tap | open-precautions
todays-max-risk | tap | open-precautions
more-info | tap | open-info
osha-logo | tap | open-osha-website
dol-logo | tap | open-dol-website
