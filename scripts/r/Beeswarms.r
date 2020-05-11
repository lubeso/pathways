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

library(ggplot2); library(RColorBrewer); library(ggthemes)
library(ggbeeswarm); library(beeswarm)
options(stringsAsFactors = F)

ctracts <- read.csv("../../data/info/ctracts.csv"); n = nrow(ctracts)

?ggsave

# +
for (i in 1:n) {
tract <- ctracts[i,'tract']; fin <- sprintf('../julia/csvs/%d.csv',tract); df <- read.csv(fin)
p <- ggplot(data = df, mapping = aes(x = travel_time, y = rep(1,nrow(df)), color = score)) + 
        geom_beeswarm(dodge.width = 1, cex = 2, size = 4, groupOnX = F) +
        scale_color_gradient2_tableau('Red-Green Diverging', name = 'School Achievement Score',
                                     labels = c('0','1','2','3','4','5'), limits = c(0,5)) +
        ggtitle('Commute to All NYC High Schools') + xlab('Commute (minutes)') +
        theme_fivethirtyeight() +
        theme(axis.title.x = element_text(size=20), axis.text.x = element_text(size=16),
              axis.text.y = element_blank(), plot.title = element_text(size=24),
              panel.grid.major.y = element_blank(), axis.line.x = element_line(),
              legend.position = 'top',
              legend.justification = c(0,0), legend.title = element_text(size=18, vjust = 0.9), 
              legend.text = element_text(size=12), legend.key.width = unit(50,'pt'))

fout <- sprintf('../../figs/beeswarms/%d.svg', tract)
ggsave(fout, p, width = 95, height = 95, units = 'mm', dpi = 300, scale = 2)
}
# -


