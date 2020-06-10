## Mixed Twitter analysis - #DCprotests May-June 2020

This very basic analysis was conducted on tweets using the hashtag #dcprotests in the week+ from May 29th to June 7th.

Tweets were scrapped using: https://github.com/twintproject/twint
and cleaned using the jupyter notebook `Twitter.ipynb` to produce `processed_tweets.csv`.
Major analysis inspiration was drawn from https://datavizm20.classes.andrewheiss.com/example/13-example/#complete-code

** _A MAJOR DISCLAIMER: this analysis is neither exhaustive nor statistically significant. Twitter includes tweets from trolls and bots, and the voices of more active tweeters are awarded disproportionate weight. However, this preliminary analysis can still provide important insight into the activity on the ground in Washington, DC this week, where official news and data sources have been frustratingly unhelpful._ **

<p align="center">
  <img width="90%" src="https://github.com/jordanjasuta/twitter_dcprotests/blob/master/imgs/full_week.jpeg">
</p>

Keywords were used to group tweets into those focused on damages incurred by protests (such as 'riot', 'looting, and 'not the way'), and those focused on the Black Lives Matter movement (such as 'blacklivesmatter', 'georgefloyd', and 'justice').

<p align="center">
  <img width="90%" src="https://github.com/jordanjasuta/twitter_dcprotests/blob/master/imgs/week_by_focus.jpeg">
</p>

These keyword-based groups were combined with the R sentiment analysis package 'afinn' to extract additional insight, such as a steady decrease in tone over the course of Sunday night:

<p align="center">
  <img width="40%" src="https://github.com/jordanjasuta/twitter_dcprotests/blob/master/imgs/decline.jpeg">
</p>

...and the renewed positivity of tone over the following week:

<p align="center">
  <img width="80%" src="https://github.com/jordanjasuta/twitter_dcprotests/blob/master/imgs/renewed_positivity.jpeg">
</p>



_NOTE: .R file is more complete than .Rmd as of last commit_
