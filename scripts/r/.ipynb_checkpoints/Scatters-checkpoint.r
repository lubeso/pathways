# ---
# jupyter:
#   jupytext:
#     formats: ipynb,r
#     text_representation:
#       extension: .r
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.4.2
#   kernelspec:
#     display_name: R
#     language: R
#     name: ir
# ---

library(RColorBrewer); library(ggthemes)
library(ggplot2); library(ggbeeswarm)
library(dplyr); library(beeswarm)
options(stringsAsFactors = FALSE)

df <- read.csv('../../data/info/ctracts.csv') %>% na.omit; names(df)

write.csv(df,'../../data/info/ctraces.csv',sep=',',row.names = FALSE,fileEncoding='utf8')

# +
labels <- c('white','black','indigenous','asian','pacific_islander')

label <- function (r) {
    i <- which.max(r); v <- labels[i]
    if (length(v) != 0L) {
        return(v)
    } else {
        return(NULL)
    }
}

df$majority <- df %>% subset(., select = labels) %>% apply(., 1, label) %>% 
                        as.vector %>% as.character
# -

group_by(df, majority) %>%
ggplot(data = ., aes(travel_time)) + 
facet_wrap(~ majority, dir = 'v', strip.position = 'right') + 
geom_histogram(aes(fill = majority), color = 'transparent', 
               binwidth = function(x) 2 * IQR(x) / (length(x)^(1/3))) + 
guides(fill = FALSE) +
ggtitle('Commute time by race') + xlab('Commute (minutes)') + ylab('Density') +
theme_fivethirtyeight() + theme(axis.title.x = element_text())

ggplot(data = df, aes(y = travel_time, x = median_income)) + 
geom_jitter(aes(color = majority), alpha = 0.7) + guides(fill = F) +
ggtitle('Commute times by income') + ylab('Commute (minutes)') + xlab('Median Income (USD)') +
theme_fivethirtyeight() + 
scale_color_discrete(name =  'Majority race', labels = c('Asian','Black','White')) +
theme(plot.title = element_text(size = 26),
  axis.title.x = element_text(size = 20, margin = margin(t=8,r=0,l=0,b=2)), 
  axis.title.y = element_text(size = 20, margin = margin(t=0,r=8,l=2,b=0)),
  axis.line = element_line(size = 0.3), axis.text = element_text(size = 12),
  panel.background = element_rect(fill = 'grey90'),
  plot.background = element_rect(fill = 'grey90'), legend.position = 'top',
  legend.background = element_rect(fill = 'grey90'), legend.key = element_rect(fill = 'grey90'),
  legend.text = element_text(size = 14), legend.title = element_text(size = 16),
  legend.key.size = unit(8,'pt'), legend.justification = c(0,0))

ggsave('../../figs/scatters/commute-income.png',p,width=285.75,height=285.75,units='mm',dpi=300)
