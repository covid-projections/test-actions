# JHU Case Data.

Sourced from https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_daily_reports.

## Content Change Notes

* First, JHU originally published only county-level data until 2020-03-10. The closest to a "state" number for prior dates is a sum of the handful of reporting counties.
* Then, JHU switched to almost only state-level data.
* Finally, around March 20-24, JHU switched to county-only data with some extra not-quite-county records to account for cases attributed to a state but not to a county.

## Format Change Notes

* There was a change in columns around March 20-24. This both added columns and renamed existing ones.

## Other Data Quality Notes

* Some of the files begin with Unicode byte order marks (BOM)
* There are some other extraneous characters, too.
* Pandas mostly handles these automatically.
