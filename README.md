# COVID-19 Data Sources
Repository for all public source data used by
[covid-data-model](https://github.com/covid-projections/covid-data-model)
and/or
[covid-projections](https://github.com/covid-projections/covid-data-model)

## Notes
* Use README.md files to document where data has been sourced from.
* When committing updated data, include timestamp / version info to help
  describe the exact version of the data that's being imported. Consider 
  including it in a version.txt file as well as in your commit message.  To 
  the extent possible, we want clear audit trails for incoming data.
* Don't check in multiple versions of the same data. We can rely on git history
  instead.
* If data is being downloaded / scraped by a script, check the script in under
  scripts/
* Git LFS is required to correctly checkout at least the US Census Shapefiles
  for now because they are very big. You have to run something like `git lfs
  install` and `git lfs fetch`.

## Resources

### SIR Data Sources

* Johns Hopkins Data
  * [Mapping](https://systems.jhu.edu/research/public-health/ncov/)
  * [Data](https://github.com/CSSEGISandData/COVID-19)
* [Scraped Data](https://github.com/lazd/coronadatascraper)
  * [Historical Snapshots](https://github.com/lazd/coronadatascraper-cache)
  * [Splunk aggregation & dashboard (JHU data)](https://github.com/splunk/corona_virus)

### Containment Data Sources

* [US State-Level Containment Policies](https://www.multistate.us/pages/covid-19-policy-tracker)
* [AEI Action Tracker](https://www.aei.org/covid-2019-action-tracker/)
  * Their source: [National Governors Association](https://www.nga.org/coronavirus/#actions)
* [NYTimes Stay-At-Home Orders](https://www.nytimes.com/interactive/2020/us/coronavirus-stay-at-home-order.html)
* [LA Times Tracker](https://www.latimes.com/projects/california-coronavirus-cases-tracking-outbreak/) (California only)
* [Local Action Tracker](https://www.nlc.org/program-initiative/covid-19-local-action-tracker)
* [National Association of Counties Tracker](https://ce.naco.org/?dset=COVID-19&ind=Emergency%20Declaration%20Types) -- looks promising
* [Oxford COVID-19 Response Tracker](https://www.bsg.ox.ac.uk/research/research-projects/oxford-covid-19-government-response-tracker) - Historical country-level intervention data
* [Stateside State & Local Government Report](https://www.stateside.com/sites/default/files/2020-03/Covid-19%20Overview_33020_3p_pub.pdf)

### Hospital Capacity Data

* [American Hospital Directory](https://www.ahd.com/states/hospital_CA.html) (Link is to CA data, but seems to support any state)
* [Medicare Claims for Inpatients](https://www.cms.gov/Research-Statistics-Data-and-Systems/Statistics-Trends-and-Reports/Hospital-Service-Area-File)
* [CA Healthcare Facilities](https://data.chhs.ca.gov/dataset/licensed-healthcare-facility-listing/resource/641c5557-7d65-4379-8fea-6b7dedbda40b?inner_span=True)
* [American Hosptial Association](https://www.ahadata.com/aha-hospital-statistics/) (paywalled)
