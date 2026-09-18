# Run from the paper repository: Rscript scripts/generate_fr_energy_annex.R
# Input copied unchanged from build-figures-tables/outputs/fr_energy_observed_counterfactual.
# The existing price_index is used without recalculation or filtering of dates.
library(ggplot2)
d <- read.csv('fig/fr_energy_indices_inflation_yoy.csv', colClasses=c(coicop='character'))
d$date <- as.Date(d$date)
stopifnot(!anyDuplicated(d[c('coicop','scenario','date')]), all(is.finite(d$price_index)))
d$energy <- factor(d$coicop, levels=c('0452','0451','0722'), labels=c('Gas','Electricity','Motor fuels'))
d$scenario <- factor(d$scenario, levels=c('Observe','Contrefactuel sans mesures'), labels=c('Observed','Without support'))
stopifnot(!anyNA(d$energy),!anyNA(d$scenario))
p <- ggplot(d,aes(date,price_index,colour=scenario,linetype=scenario)) +
 geom_line(linewidth=0.85) + facet_wrap(~energy,nrow=1,scales='free_y') +
 scale_colour_manual(values=c('Observed'='#24364B','Without support'='#E07A3F')) +
 scale_linetype_manual(values=c('Observed'='solid','Without support'='dashed')) +
 scale_x_date(date_breaks='2 years',date_labels='%Y',expand=expansion(mult=c(.02,.04))) +
 labs(x=NULL,y=NULL,colour=NULL,linetype=NULL) +
 theme_minimal(base_size=15) + theme(
 text=element_text(colour='#24364B'),axis.text=element_text(colour='#24364B'),
 panel.grid.minor=element_blank(),panel.grid.major.x=element_blank(),
 panel.grid.major.y=element_line(colour='#E8ECEF',linewidth=.35),
 strip.text=element_text(face='bold',size=17),
 legend.position='bottom',legend.text=element_text(size=15),
 panel.spacing=grid::unit(1.3,'lines'),
 plot.background=element_rect(fill='#FAFAF8',colour=NA))
ggsave('fig/slide_fr_energy_price_indices.pdf',p,width=12,height=4.6)
