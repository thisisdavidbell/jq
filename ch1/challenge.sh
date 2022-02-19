#!/bin/bash


# Equivalent:
# cat jq_rkm.json | jq -r < jq_rkm.json
# jq -r < jq_rkm.json
# jq -r '.' jq_rkm.json


# Basics example
jq -r '.artObjects[] | .id' jq_rkm.json
# remove quotes (Raw strings)
jq '.artObjects[] | .id' jq_rkm.json
# keep in array
jq -r '.artObjects | map( .id )' jq_rkm.json
# in object
jq -r '.artObjects | map( { id : .id })' jq_rkm.json

echo
echo 1

# Challenge 1
# Let’s filter the Rijksmuseum JSON to only return the ids of objects that have at least one value assigned to their productionPlaces:
# keeping in array
jq -r '.artObjects | map(select(.productionPlaces | length >= 1) | .id )' jq_rkm.json
# remove from array
jq -r '.artObjects[] | select(.productionPlaces | length >= 1) | .id ' jq_rkm.json

echo
echo 2

# Challenge 2a
# let’s select only those objects whose primary maker has the particle “van” in their name, and return the artist name and artwork id.
jq -r '.artObjects[] | select(.principalOrFirstMaker | test("van")) | .principalOrFirstMaker, .title' jq_rkm.json
# put into objects
jq -r '.artObjects[] | select(.principalOrFirstMaker | test("van")) | { artist: .principalOrFirstMaker, id: .id }' jq_rkm.json

echo
echo 2b
# Challenge 2b
# let’s add the web image url for each artwork as well
jq -r '.artObjects[] | select(.principalOrFirstMaker | test("van")) | { artist: .principalOrFirstMaker, id: .id, "imageurl" : .webImage.url }' jq_rkm.json
# and output as csv (note csv needs to be an array of text entries)
# Convert to arrays of text:
jq -r '.artObjects[] | select(.principalOrFirstMaker | test("van")) | [ .principalOrFirstMaker, .id, .webImage.url ]' jq_rkm.json
# convert to csv
jq -r '.artObjects[] | select(.principalOrFirstMaker | test("van")) | [ .principalOrFirstMaker, .id, .webImage.url ] | @csv ' jq_rkm.json

echo
echo 3
# Challenge 3
# 3a: One row per tweet, with multiple hashtags in the same cell
# 3b: One row per hashtag/tweet combination
#     = object with id text field, and hashtags array
jq -r '{ id: .id, hashtags: .entities.hashtags[].text }' jq_twitter.json
# accidentally solved 3b above :point-up:
jq -r '{id: .id, hashtags: [ .entities.hashtags[].text ]}' jq_twitter.json
# remove empty hashtags
jq -r ' select(.entities.hashtags | length > 0 ) | {id: .id, hashtags: [ .entities.hashtags[].text ]}' jq_twitter.json
# remove duplicate hashtags
jq -r ' select(.entities.hashtags | length > 0 ) | {id: .id, hashtags: [ .entities.hashtags[].text ]|unique }' jq_twitter.json
# convert to csv
#  = convert array to ; separated string, and remove objects
jq -r ' select(.entities.hashtags | length > 0 ) | {id: .id, hashtags: [ .entities.hashtags[].text ]|unique | join(";")} | [ .id, .hashtags ] | @csv' jq_twitter.json
