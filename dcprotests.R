# análisis de datos twitter con el hashtag #dcprotests (jalados usando `twint` y limpiados en Python)
## major inspiration drawn from https://datavizm20.classes.andrewheiss.com/example/13-example/#complete-code 


library(tidyverse)
library(tidytext)
library(textdata)

setwd("/Users/jordan.j.fischer@ibm.com/Documents/Training/RTraining/30diasdegraficos/twitter/")

tweets <- read_csv('processed_tweets_jun3.csv')
head(tweets)
table(tweets$date)
#drop rows from before May
tweets <- tweets %>% filter(date >= "2020-05-01")    # 514 rows lost (3.6%)
tweets <- tweets %>% filter(date < "2020-06-03")     # 524 rows lost

# plot over time
#tweets$mdh <- paste(format(tweets$date, "%m-%d"),format(tweets$time, "%H:00"))
library(lubridate)
tweets$mdh <- paste(format(tweets$date, "%m-%d"),hour(strptime(tweets$time, format="%H:%M:%S")),':00')

tweets_over_time <- as.data.frame(table(tweets$mdh))
colnames(tweets_over_time) <- c("hour", "num_tweets")
ggplot(tweets_over_time,
       aes(x = hour, y = num_tweets, fill = num_tweets)) +
  geom_col() +
  scale_fill_viridis_c(option = "magma", begin = 0.5, end = 0.9) +
  theme_bw() + 
  ggtitle('tweets including #dcprotests by hour') +
  theme(plot.title = element_text(hjust = 0.5), axis.text.x = element_text(angle = 90, hjust = 1))


# tag tweets with hashtags for future use
blm <- tweets
blm$tag <- ifelse(grepl("blm", blm$text), "movement", "no")
blm$tag <- ifelse(grepl("blacklivesmatter", blm$text), "movement", blm$tag)
blm$tag <- ifelse(grepl("georgefloyd", blm$text), "movement", blm$tag)
blm$tag <- ifelse(grepl("justiceforgeorgefloyd", blm$text), "movement", blm$tag)
blm$tag <- ifelse(grepl("georgefloydprotests", blm$text), "movement", blm$tag)
blm$tag <- ifelse(grepl("nojusticenopeace", blm$text), "movement", blm$tag)
blm$tag <- ifelse(grepl("lafayetteprotests", blm$text), "movement", blm$tag)
blm$tag <- ifelse(grepl("justice", blm$text), "movement", blm$tag)
blm$tag <- ifelse(grepl("march", blm$text), "movement", blm$tag)
blm$tag <- ifelse(grepl("icantbreathe", blm$text), "movement", blm$tag)
blm$tag <- ifelse(grepl("peaceful", blm$text), "movement", blm$tag)
blm$tag <- ifelse(grepl("safe", blm$text), "movement", blm$tag)

#blm$tag <- ifelse(grepl("blackouttuesday", blm$text), "movement", blm$tag)   # should maybe get it's own analysis
table(blm$tag)
blm <- filter(blm, tag == "movement")

riots <- tweets
riots$tag <- ifelse(grepl("riots", riots$text), "damage", "no")
riots$tag <- ifelse(grepl("dcriots", riots$text), "damage", riots$tag)
riots$tag <- ifelse(grepl("riotersarenotprotesters", riots$text), "damage", riots$tag)
riots$tag <- ifelse(grepl("looting", riots$text), "damage", riots$tag)
riots$tag <- ifelse(grepl("looters", riots$text), "damage", riots$tag)
riots$tag <- ifelse(grepl("excusetoloot", riots$text), "damage", riots$tag)
riots$tag <- ifelse(grepl("rioters", riots$text), "damage", riots$tag)
riots$tag <- ifelse(grepl("alllivesmatter", riots$text), "damage", riots$tag)
riots$tag <- ifelse(grepl("antifa", riots$text), "damage", riots$tag)
riots$tag <- ifelse(grepl("not the way", riots$text), "damage", riots$tag)
table(riots$tag)
riots <- filter(riots, tag == "damage")

#anti_e <- tweets   # needs expanded hashtag list
#anti_e$tag <- ifelse(grepl("#fucktrump", anti_e$text), "anti_e", "no")
#anti_e$tag <- ifelse(grepl("#fuckthepolice", anti_e$text), "anti_e", anti_e$tag)
#anti_e$tag <- ifelse(grepl("dictator", anti_e$text), "anti_e", anti_e$tag)
#table(anti_e$tag)
#anti_e <-filter(anti_e, tag == "anti_e")

by_perspective <- rbind(blm, riots)    # this dataset should remain separate because it will likely contain duplicaates


# plot by perspective over time
tweets_by_p_over_time <- as.data.frame(table(by_perspective$mdh,by_perspective$tag))
colnames(tweets_by_p_over_time) <- c("hour", "tag", "num_tweets")
ggplot(tweets_by_p_over_time,
       aes(x = hour, y = num_tweets, fill = num_tweets)) +
  geom_col() +
  scale_fill_viridis_c(option = "magma", begin = 0.5, end = 0.9) +
  theme_bw() + 
  facet_grid(tag ~ .) +
  ggtitle('tweets including #dcprotests by hour, by focus') +
  theme(plot.title = element_text(hjust = 0.5), axis.text.x = element_text(angle = 90, hjust = 1))



# plot by perspective over time AS PERCENTAGE OF PERSPECTIVE??? (divided by mean tweets per hour per category)
tweets_by_p_over_time <- as.data.frame(table(by_perspective$mdh,by_perspective$tag))
colnames(tweets_by_p_over_time) <- c("hour", "tag", "num_tweets")

# normalize as a % for ease of visual comparison
x <- tweets_by_p_over_time %>% group_by(tag) %>% summarize(sumB = mean(num_tweets))
damage <- as.integer(x[1,2])
movement <- as.integer(x[2,2])

tweets_by_p_over_time$percent <- ifelse(tweets_by_p_over_time$tag == 'damage', tweets_by_p_over_time$n/damage, 
                                     ifelse(tweets_by_p_over_time$tag == 'movement',tweets_by_p_over_time$n/movement, 0))

ggplot(tweets_by_p_over_time,
       aes(x = hour, y = percent, fill = percent)) +
  geom_col() +
  scale_fill_viridis_c(option = "magma", begin = 0.5, end = 0.9) +
  theme_bw() + 
  facet_grid(tag ~ .) +
  ggtitle('rescaled tweets including #dcprotests by hour, by focus') +
  theme(plot.title = element_text(hjust = 0.5), axis.text.x = element_text(angle = 90, hjust = 1))





# sentiment analysis 

#get_sentiments("afinn")
get_sentiments("nrc")

# get list of all words
#all_text <- paste(tweets$text, collapse = " ")
#s <- strsplit(all_text, " ")

by_word <- separate_rows(tweets, text, sep = " ", convert = FALSE)
perspective_by_word <- separate_rows(by_perspective, text, sep = " ", convert = FALSE)

# plot levels of sentiment
tweet_words <- by_word %>% 
  #drop_na() %>% 
  unnest_tokens(word, text) %>%     # Split into word tokens
  anti_join(stop_words)          # Remove stopwords 

# Join the sentiment dictionary 
tweet_sentiment <- tweet_words %>%     # may need to drop trump from dataset since this word has its own meaning
  inner_join(get_sentiments("nrc"))

tweet_sentiment_plot <- tweet_sentiment %>% 
  count(timezone, sentiment)

# do the same for the by-perspective dataset
tweet_words_by_p <- perspective_by_word %>% 
  #drop_na() %>% 
  unnest_tokens(word, text) %>%     
  anti_join(stop_words)          

sent_by_persp <- tweet_words_by_p %>%     
  inner_join(get_sentiments("nrc"))

sent_by_persp_plot <- sent_by_persp %>% 
  count(tag, sentiment)
#count(sent_by_persp$tag, sent_by_persp$sentiment)

# normalize as a % for ease of visual compsrison
x <- sent_by_persp_plot %>% group_by(tag) %>% summarize(sumB = sum(n))
damage <- as.integer(x[1,2])
movement <- as.integer(x[2,2])

sent_by_persp_plot$percent <- ifelse(sent_by_persp_plot$tag == 'damage', sent_by_persp_plot$n/damage, 
                                     ifelse(sent_by_persp_plot$tag == 'movement',sent_by_persp_plot$n/movement, 0))

# overall sentiment of all tweets
library(RColorBrewer)
ggplot(tweet_sentiment_plot, aes(x = sentiment, y = n, fill = sentiment)) +
  geom_col(position = position_dodge()) +
  #scale_alpha_manual() +
  scale_fill_brewer(palette = 'RdYlBu') + 
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5), axis.text.x = element_text(angle = 90, hjust = 1))

# sentiment of tweets by perspective groups
ggplot(sent_by_persp_plot, aes(x = sentiment, y = percent, fill = sentiment)) +
  geom_col(position = position_dodge()) +
  facet_grid(tag ~ .) +
  scale_fill_brewer(palette = 'RdYlBu') + 
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5), axis.text.x = element_text(angle = 90, hjust = 1))


#sentiments over time (line graph)
#sent_by_persp_plot <- sent_by_persp %>% 
 # count(tag, sentiment)

sent_by_persp_lines <- sent_by_persp %>% 
  group_by(mdh) %>% 
  count(sentiment)

ggplot(sent_by_persp_lines, aes(x = mdh, y = n, fill = sentiment)) +
  geom_col() +
  scale_fill_brewer(palette = 'RdYlBu') + 
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5), axis.text.x = element_text(angle = 90, hjust = 1))




# para mostrar lo mismo a lo largo del tiempo, vamos a usar solo sentimiento positivo y negativo 
# (como no podemos mapear en 10 dimensiones)

polar_sentiment <- tweet_words %>%     # may need to drop trump from dataset since this word has its own meaning
  inner_join(get_sentiments("afinn"))

# group by hour
sentiment_by_hour <- polar_sentiment %>% 
  group_by(mdh) %>% 
  summarise(value = mean(value))

#plot mean sentiment for all tweets
ggplot(sentiment_by_hour,
       aes(x = mdh, y = value, fill = value)) +
  geom_col() +
  scale_fill_viridis_c(option = "magma", end = 0.9) +
  theme_bw() + 
  ggtitle('mean sentiment of tweets containing #dcprotests by hour') +
  theme(plot.title = element_text(hjust = 0.5), axis.text.x = element_text(angle = 90, hjust = 1))




# plot mean sentiment for different perspectives (based on hashtag)

polar_sent_by_p <- tweet_words_by_p %>%
  inner_join(get_sentiments("afinn"))

# group by hour
sent_by_hour_by_p <- polar_sent_by_p %>% 
  group_by(mdh, tag) %>% 
  summarise(value = mean(value))


ggplot(sent_by_hour_by_p,
       aes(x = mdh, y = value, fill = value)) +
  geom_col() +
  scale_fill_viridis_c(option = "magma", end = 0.9) +
  facet_grid(tag ~ .) +
  theme_bw() + 
  ggtitle('mean sentiment of tweets containing #dcprotests by hour') +
  theme(plot.title = element_text(hjust = 0.5), axis.text.x = element_text(angle = 90, hjust = 1))





num_tweets_hr_by_p <- polar_sent_by_p %>% 
  count(timezone, mdh)

ggplot() +
  geom_col(data = sent_by_hour_by_p,
           aes(x = mdh, y = value, fill = value)) +
  scale_fill_viridis_c(option = "magma", end = 0.9) +
  facet_grid(tag ~ .) +
  theme_bw() +
  geom_line(data = num_tweets_hr_by_p, aes(x = mdh, y = n/150, group = 1), lwd=0.2) + 
  ggtitle('mean sentiment of tweets containing #dcprotests by hour') +
  theme(plot.title = element_text(hjust = 0.5), axis.text.x = element_text(angle = 90, hjust = 1))


ggplot() +
  geom_line(data = num_tweets_hr_by_p, aes(x = mdh, y = n, group = 1)) 


library(jpeg)
library(grid)
img <- readJPEG("./decline.jpeg")
grid.raster(img)


