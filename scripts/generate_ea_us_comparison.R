args <- commandArgs(trailingOnly=FALSE)
script <- sub("^--file=", "", args[grepl("^--file=",args)][1])
root <- normalizePath(file.path(dirname(script), ".."))
d <- read.csv(file.path(root,"fig/ea_us_income_comparison_rebased.csv"))
d$date <- as.Date(d$date)
navy <- "#24364B"
cols <- c("Euro area"="#178C8C", "United States"="#D95D39")
pdf(file.path(root,"fig/ea_us_income_comparison.pdf"),width=11.8,height=4.8,family="sans",useDingbats=FALSE)
par(mfrow=c(1,1),mar=c(3.2,3.8,2.8,.7),oma=c(0,0,2.6,0),fg=navy,col.axis=navy,col.lab=navy,las=1,bty="n",cex=1.05)
for(base in c("2002-01")) {
 z <- d[d$base==base,]
 plot(z$date,z$index,type="n",xlab="",ylab="Price index",xaxt="n",yaxt="n",ylim=c(98,max(z$index)*1.015))
 ticks <- pretty(c(100,max(z$index)),n=5)
 abline(h=ticks,col="#E8ECEF",lwd=.6)
 axis(2,at=ticks,tick=FALSE)
 years <- if(base=="2002-01") c(2002,2006,2010,2014,2018,2022,2026) else 2021:2026
 axis.Date(1,at=as.Date(paste0(years,"-01-01")),format="%Y",tick=FALSE)
 for(region in names(cols)) for(q in c(1,5)) {
  v <- z[z$region==region & z$quintile==q,];lines(v$date,v$index,col=cols[[region]],lty=if(q==1)1 else 2,lwd=2.3)
 }
 title(main=if(base=="2002-01") "Long run | January 2002 = 100" else "Recent period | January 2021 = 100",adj=0,cex.main=1.1,col.main=navy)
}
par(oma=c(0,0,0,0),fig=c(0,1,0,1),new=TRUE,mar=c(0,0,0,0))
plot.new()
legend("top",inset=.01,legend=c("Euro area: Q1","Euro area: Q5","United States: Q1","United States: Q5"),col=rep(cols,each=2),lty=rep(c(1,2),2),lwd=2.3,horiz=TRUE,bty="n",text.col=navy,cex=1.05)
dev.off()

