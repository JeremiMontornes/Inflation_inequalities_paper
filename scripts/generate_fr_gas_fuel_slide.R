# France: observed and counterfactual inflation, gas and motor fuels.
# Run from any directory with Rscript; input values are not recalculated.
args <- commandArgs(FALSE)
script <- sub('^--file=', '', grep('^--file=', args, value=TRUE)[1L])
root <- normalizePath(file.path(dirname(script), '..'))
library(ggplot2)
d <- read.csv(file.path(root, 'fig/fr_energy_indices_inflation_yoy.csv'),
              colClasses=c(coicop='character'))
d <- d[d$coicop %in% c('0452','0722') & is.finite(d$inflation_yoy), ]
d$date <- as.Date(d$date)
stopifnot(nrow(d)>0, !anyDuplicated(d[c('coicop','scenario','date')]))
d$energy <- factor(d$coicop, levels=c('0452','0722'), labels=c('Gas','Motor fuels'))
d$scenario <- factor(d$scenario, levels=c('Observe','Contrefactuel sans mesures'),
                     labels=c('Observed','Without support'))
stopifnot(!anyNA(d$energy), !anyNA(d$scenario))
stopifnot(all(table(d$date,d$energy,d$scenario)==1L))
p <- ggplot(d,aes(date,inflation_yoy,colour=scenario,linetype=scenario)) +
  geom_hline(yintercept=0,colour='#A5A5A5',linewidth=.35) +
  geom_line(linewidth=.9) + facet_wrap(~energy,nrow=1,scales='free_y') +
  scale_colour_manual(values=c('Observed'='#24364B','Without support'='#E07A3F')) +
  scale_linetype_manual(values=c('Observed'='solid','Without support'='dashed')) +
  scale_x_date(date_breaks='1 year',date_labels='%Y',expand=expansion(mult=c(.02,.03))) +
  labs(x=NULL,y=NULL,colour=NULL,linetype=NULL) +
  theme_minimal(base_size=17) + theme(
    text=element_text(colour='#24364B'),axis.text=element_text(colour='#24364B'),
    panel.grid.minor=element_blank(),panel.grid.major.x=element_blank(),
    panel.grid.major.y=element_line(colour='#E8ECEF',linewidth=.35),
    strip.text=element_text(face='bold',size=20),
    legend.position='bottom',legend.text=element_text(size=17),
    panel.spacing=grid::unit(1.5,'lines'),
    plot.background=element_rect(fill='white',colour=NA))
ggsave(file.path(root,'fig/slide_fr_gas_fuel_inflation.pdf'),p,width=12,height=4.7)
ggsave(file.path(root,'fig/slide_fr_gas_fuel_inflation.png'),p,width=12,height=4.7,dpi=240)