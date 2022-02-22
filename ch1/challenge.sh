# #!/bin/bash

function title () {
  echo ""
  echo "Challenge $1"
  echo "============"
  echo ""
}

# # Equivalent:
# # cat jq_rkm.json | jq -r < jq_rkm.json
# # jq -r < jq_rkm.json
# # jq -r '.' jq_rkm.json


# # Basics example
# jq -r '.artObjects[] | .id' jq_rkm.json
# # remove quotes (Raw strings)
# jq '.artObjects[] | .id' jq_rkm.json
# # keep in array
# jq -r '.artObjects | map( .id )' jq_rkm.json
# # in object
# jq -r '.artObjects | map( { id : .id })' jq_rkm.json

# title 1

# # Challenge 1
# # Let’s filter the Rijksmuseum JSON to only return the ids of objects that have at least one value assigned to their productionPlaces:
# # keeping in array
# jq -r '.artObjects | map(select(.productionPlaces | length >= 1) | .id )' jq_rkm.json
# # remove from array
# jq -r '.artObjects[] | select(.productionPlaces | length >= 1) | .id ' jq_rkm.json

# title 2

# # Challenge 2a
# # let’s select only those objects whose primary maker has the particle “van” in their name, and return the artist name and artwork id.
# jq -r '.artObjects[] | select(.principalOrFirstMaker | test("van")) | .principalOrFirstMaker, .title' jq_rkm.json
# # put into objects
# jq -r '.artObjects[] | select(.principalOrFirstMaker | test("van")) | { artist: .principalOrFirstMaker, id: .id }' jq_rkm.json

# title 2b
# # let’s add the web image url for each artwork as well
# jq -r '.artObjects[] | select(.principalOrFirstMaker | test("van")) | { artist: .principalOrFirstMaker, id: .id, "imageurl" : .webImage.url }' jq_rkm.json
# # and output as csv (note csv needs to be an array of text entries)
# # Convert to arrays of text:
# jq -r '.artObjects[] | select(.principalOrFirstMaker | test("van")) | [ .principalOrFirstMaker, .id, .webImage.url ]' jq_rkm.json
# # convert to csv
# jq -r '.artObjects[] | select(.principalOrFirstMaker | test("van")) | [ .principalOrFirstMaker, .id, .webImage.url ] | @csv ' jq_rkm.json

# title 3
# # blank out text fields as could be anything (Note this processing pretty printed file, but no other meaningful changes):
# # jq '.text = "" | .retweeted_status.text = ""' jq_twitter.json > out && mv out jq_twitter.json

# # 3a: One row per tweet, with multiple hashtags in the same cell, into csv
# # 3b: One row per hashtag/tweet combination, into csv
# #     = object with id text field, and hashtags array
# jq -r '{ id: .id, hashtags: .entities.hashtags[].text }' jq_twitter.json
# # accidentally solved 3b above :point-up:, so finish it off into csv
# jq -r '[ .id, .entities.hashtags[].text ]' jq_twitter.json
# # note -  this leaves in all entries which have no hashtag - there is no explode, in the array entry it just has flat id plus all hashtag texts, even if zero hastag texts

# jq -r '{ id: .id, hashtags: .entities.hashtags[].text } | [ .id, .hashtags ] | @csv' jq_twitter.json
# # note - this only has entries with hashtags - it explodes the hashtags entries, but the explode doesnt happen where hashtags empty, and actually these entries are not passed on (its removed)

# # Challenge 3a
# jq -r '{id: .id, hashtags: [ .entities.hashtags[].text ]}' jq_twitter.json
# # remove empty hashtags
# jq -r ' select(.entities.hashtags | length > 0 ) | {id: .id, hashtags: [ .entities.hashtags[].text ]}' jq_twitter.json
# # remove duplicate hashtags
# jq -r ' select(.entities.hashtags | length > 0 ) | {id: .id, hashtags: [ .entities.hashtags[].text ]|unique }' jq_twitter.json
# # convert to csv
# #  = convert array to ; separated string, and remove objects
# jq -r ' select(.entities.hashtags | length > 0 ) | {id: .id, hashtags: [ .entities.hashtags[].text ]|unique | join(";")} | [ .id, .hashtags ] | @csv' jq_twitter.json

# title 4

# # 4
# # Next: Grouping
# # - grouping of data across aray abjects
# # Example: slurp -s - puts each 'json line' into a single array (basically put { } at start/end.) - making it a single object read in at the same time, so we can see across all data at the same time
# jq -s '.[0].user'  jq_twitter.json
# # group all tweets by user:
# jq -s 'group_by(.user)'  jq_twitter.json

# # 4a:  Let’s create a table with columns for the user id, user name, followers count.
# jq -s 'group_by(.user) | .[] | { user_id: .[0].user.id, user_name: .[0].user.screen_name, user_followers: .[0].user.followers_count }'  jq_twitter.json
# # now also collate the tweet ids of each tweet (user 14331818 has 3 tweets)
# jq -s 'group_by(.user) | .[] | { user_id: .[0].user.id, user_name: .[0].user.screen_name, user_followers: .[0].user.followers_count, tweet_ids:  [ .[].id ]  }'  jq_twitter.json
# # convert tweet ids to single field separated by a semicolon
# jq -s 'group_by(.user) | .[] | { user_id: .[0].user.id, user_name: .[0].user.screen_name, user_followers: .[0].user.followers_count, tweet_ids:  [ .[].id ] | join(";")  }'  jq_twitter.json
# # going to convert to csv - so needs to be flat array elements
# jq -s 'group_by(.user) | .[] | { user_id: .[0].user.id, user_name: .[0].user.screen_name, user_followers: .[0].user.followers_count, tweet_ids:  [ .[].id ] | join(";") } | [ .user_id, .user_name, .user_followers, .tweet_ids ] '  jq_twitter.json
# # can we shorten this straight to array?
# #  - note: the ids are integers - need to be strings for join to work
# #   - note: precedence. In the longer example above where we used objects then converted to array, the join was contained in the object so scope/precedence was clear. In the array, this isn't clear, so we need to add the brackets to ensure we attempt to join just the array we exploded from the tweet ids.
# jq -s 'group_by(.user) | .[] | [ .[0].user.id, .[0].user.screen_name, .[0].user.followers_count, ([ .[].id ] | join(";")) ] '  jq_twitter.json
# # note we cannot shorten it further using map as its not a single top level array we want, its a set of json lines arrays, so we have to add in the array anyway
# # note we would still also need to remove the outer array with .[] anyway, for valid csv
# jq -s 'group_by(.user) | map( [.[0].user.id, .[0].user.screen_name, .[0].user.followers_count, ([ .[].id ] | join(";")) ])'  jq_twitter.json
# # convert to csv
# #  - note we need to add in the -r as well as -s, in order to remove the quotes
# jq -sr 'group_by(.user) | .[] | [ .[0].user.id, .[0].user.screen_name, .[0].user.followers_count, ([ .[].id ] | join(";")) ] | @csv'  jq_twitter.json

title 5

# 5 Counting
# we will use jq to count the number of times unique hashtags appear in this dataset
# count all hashtags to start with
# jq -s 'map(.entities.hashtags[].text) | unique | length' jq_twitter.json
# count occurance of each hashtag 
jq  -sr 'map( { hashtag: .entities.hashtags[].text }) | group_by(.hashtag) | .[] | { hashtag: .[0].hashtag, count: length } ' jq_twitter.json
# question asks for csv again...
jq  -sr 'map( { hashtag: .entities.hashtags[].text }) | group_by(.hashtag) | .[] | [ .[0].hashtag, length ] | @csv ' jq_twitter.json

title 6

# First of the "Challenges" 
# add to the hashtag-counting filter to only count hashtags when their tweet has been retweeted at least 200 times.
#   Hint: the retweet count is saved under the key retweet_count
jq  -sr 'map(select(.retweet_count >= 200)) | map( { hashtag: .entities.hashtags[].text, aretweet_count: .retweet_count }) | group_by(.hashtag) | .[] | { hashtag: .[0].hashtag, count: length, bretweet_count: .[0].aretweet_count } ' jq_twitter.json

title 7
# try to compute the total number of times each user has had their tweets (at least within this dataset) retweeted
# plan:
#   - group_by users
#   - sum(?) retweet_count
jq -s 'group_by(.user) | map({ user_id: .[0].user.id, total_retweets: [ .[].retweet_count ] | add })'  jq_twitter.json