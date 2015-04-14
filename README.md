# Heat-Tool
Rebuild and redesign of the OSHA Heat Safety Tool in Swift.

## Analytics
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
