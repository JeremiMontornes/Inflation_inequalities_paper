#!/usr/bin/env Rscript
# Reproduce the layout/category colours of IMF Fiscal Monitor April 2023,
# Figure 2.5, for EA20 annual-average inflation in calendar 2022.
# Run: Rscript scripts/generate_ea20_imf_quintiles_2022.R
# Plot saved data only: append --plot-only (base R, no external data needed).
# Rebuild requires the sibling build-figures-tables and inflationinequality
# repositories and their cached Eurostat/HBS inputs. Override locations with
# INFLATION_BUILD_ROOT and INFLATIONINEQUALITY_PACKAGE_REPO.
args <- commandArgs(TRUE)
script <- sub('^--file=', '', grep('^--file=', commandArgs(FALSE), value=TRUE)[1L])
root <- normalizePath(file.path(dirname(script), '..'), mustWork=TRUE)
out <- file.path(root, 'fig', 'fig_EA20_2022_inflation_by_quintile_imf')
data_path <- paste0(out, '_data.csv')
labels <- c('Food and non-alcoholic beverages',
            'Housing, water, electricity, gas and other fuels',
            'Transport', 'Other consumption categories')
# Reconstructed from the reference raster: blue, orange, grey, green; red line.
palette <- c('#4472C4', '#ED7D31', '#A5A5A5', '#00B050')
quintiles <- c('First quintile','Second quintile','Third quintile',
               'Fourth quintile','Fifth quintile')

if (!'--plot-only' %in% args) {
  Sys.setenv(BUILD_EXCLUDE_COICOP='041,042', EUROSTAT_CACHE_MODE='offline')
  build_root <- normalizePath(Sys.getenv('INFLATION_BUILD_ROOT',
    file.path(dirname(root), 'build-figures-tables')), mustWork=TRUE)
  package_root <- normalizePath(Sys.getenv('INFLATIONINEQUALITY_PACKAGE_REPO',
    file.path(dirname(root), 'inflationinequality')), mustWork=TRUE)
  suppressPackageStartupMessages(library(data.table))
  pkgload::load_all(package_root, quiet=TRUE)
  source(file.path(build_root,'scripts/89_delta_cache_helpers.R'))
  enable_delta_cache(build_root)
  source(file.path(build_root,'scripts/87_hbs_micro_objects.R'))
  enable_HBS_micro(build_root)
  source(file.path(build_root,'scripts/90_ras_default_helpers.R'))
  use_ras_weighting_by_default()
  source(file.path(build_root,'scripts/91_custom_ea20_income_helpers.R'))
  source(file.path(build_root,'scripts/93_annual_product_contribution_helpers.R'))
  countries <- c('AT','BE','CY','DE','EE','EL','ES','FI','FR','HR',
                 'IE','IT','LT','LU','LV','MT','NL','PT','SI','SK')
  cw <- load_country_weights('EA20', countries=countries,
                              start_year=2020L,end_year=2023L)
  # Identical canonical chain to Tables 1/2, including all five income groups.
  pipeline <- build_annual_product_gap(countries,cw,years=2021:2023)
  idx <- copy(pipeline$indices$dt)[category %in% quintiles & year %in% 2021:2022]
  stopifnot(setequal(unique(idx$category), quintiles),
            all(idx[, .N, by=.(category,year)]$N == 12L))
  cmp <- copy(pipeline$indices$dt_components)[year == 2022 & category %in% quintiles]
  code <- sub('^CP','',as.character(cmp$coicop))
  stopifnot(!any(startsWith(code,'041') | startsWith(code,'042')))
  cmp[, component := labels[4L]]
  cmp[startsWith(code,'01'), component := labels[1L]]
  cmp[startsWith(code,'04'), component := labels[2L]]
  cmp[startsWith(code,'07'), component := labels[3L]]
  prev <- idx[year == 2021, .(category, month, previous=price_index)]
  cmp <- merge(cmp,prev,by=c('category','month'),all.x=TRUE)
  stopifnot(all(is.finite(cmp$previous)),all(is.finite(cmp$contribution)))
  denom <- prev[, .(denominator=sum(previous)), by=category]
  # Exact annual-average decomposition, not a simple mean of monthly rates.
  annual <- cmp[, .(numerator=sum(contribution*previous)),by=.(category,component)]
  annual <- merge(annual,denom,by='category')
  annual[, contribution_pp := numerator/denominator]
  direct <- dcast(idx[, .(index=mean(price_index)),by=.(category,year)],
                  category~year,value.var='index')
  direct[, inflation_percent := 100*(`2022`/`2021`-1)]
  checks <- merge(annual[, .(component_sum=sum(contribution_pp)),by=category],
                  direct[, .(category,inflation_percent)],by='category')
  checks[, difference := component_sum-inflation_percent]
  stopifnot(all(is.finite(checks$difference)),max(abs(checks$difference)) < 1e-9)
  total <- copy(pipeline$total_indices$dt)[year %in% 2021:2022 & category=='Total',
             .(index=mean(price_index)),by=year]
  aggregate_rate <- 100*(total[year==2022,index]/total[year==2021,index]-1)
  stopifnot(length(aggregate_rate)==1L,is.finite(aggregate_rate))
  # Check against the existing paper table, without treating its rounded values
  # or the average of quintile rates as the aggregate inflation benchmark.
  ref <- fread(file.path(build_root,'cache/ea20_income_gap_contributions',
      'tab_EA20_income_gap_product_contributions_2021_06_2023_06.csv'))
  ref <- ref[`Product group`=='Total']
  gap <- direct[category==quintiles[1],inflation_percent] -
         direct[category==quintiles[5],inflation_percent]
  stopifnot(nrow(ref)==1L,
    abs(aggregate_rate-ref[['2022 average inflation']])<1e-9,
    abs(gap-ref[['2022 inflation inequality']])<1e-9)
  annual <- merge(annual,direct[,.(category,inflation_percent)],by='category')
  annual[, `:=`(year=2022L,quintile=match(category,quintiles),
                  aggregate_inflation_percent=aggregate_rate)]
  setorder(annual,quintile,component)
  fwrite(annual[,.(year,quintile,category,component,contribution_pp,
                    inflation_percent,aggregate_inflation_percent)],data_path)
  fwrite(checks,paste0(out,'_checks.csv'))
  dependencies <- c(script,file.path(build_root,'scripts',c(
    '87_hbs_micro_objects.R','88_build_scope_helpers.R','90_ras_default_helpers.R',
    '93_annual_product_contribution_helpers.R')))
  writeLines(c('EA20; calendar 2022 versus calendar 2021; rents 041/042 excluded.',
    'Income groups: national quintiles of total household net income (HBS 2020).',
    'RAS calibration; annual HICP country weights; canonical paper pipeline.',
    'IMF Figure 2.5 uses 2021Q2--2022Q2: period and population definitions differ.',
    'COICOP 01 = blue; 04 excluding rents = orange; 07 = grey; remainder = green.',
    'Furnishings (05) are in Other, consistent with the IMF four-category legend.',
    'Red dashed line: separately calculated EA20 aggregate on the same non-rent scope.',
    'Colours reconstructed from the local IMF raster, not an original vector palette.',
    paste('HBS source fingerprint:',getOption('HBS_micro.cache_tag')),
    paste('Generated:',Sys.time()),
    paste(names(tools::md5sum(dependencies)),tools::md5sum(dependencies)),
    capture.output(sessionInfo())),paste0(out,'_provenance.txt'))
}

d <- read.csv(data_path,check.names=FALSE)
stopifnot(nrow(d)==20L, setequal(d$quintile,1:5),setequal(d$component,labels))
heights <- sapply(1:5,function(q) {
  z <- d[d$quintile==q,]; z$contribution_pp[match(labels,z$component)]
})
totals <- colSums(heights)
aggregate_rate <- unique(d$aggregate_inflation_percent)
stopifnot(all(is.finite(heights)),all(heights>=0),length(aggregate_rate)==1L,
          max(abs(totals-sapply(1:5,function(q) unique(d$inflation_percent[d$quintile==q]))))<1e-9)
draw <- function() {
  par(mar=c(5.2,4,8.1,1),mgp=c(2.6,.7,0),las=1,family='sans',bty='l',cex=1.1)
  bp <- barplot(heights,col=palette,border=NA,space=.35,
       names.arg=c('Poorest','2','3','4','Richest'),ylim=c(0,12),axes=FALSE,
       xlab='Income quintile',ylab='Percent / percentage points')
  axis(2,at=seq(0,12,2),lwd=.6,col='#777777',tck=-.012)
  abline(h=0,col='#777777',lwd=.6)
  segments(bp[1]-.42,aggregate_rate,bp[5]+.42,aggregate_rate,
           col='#FF0000',lty=2,lwd=1.8)
  mtext('Euro area: inflation by income quintile in 2022',side=3,line=6.6,
        adj=0,font=2,cex=1.15)
  mtext('Annual-average inflation; rents excluded',side=3,line=5.2,adj=0,cex=.92)
  legend('topleft',inset=c(0,-.28),xpd=NA,bty='n',cex=.87,
    legend=c(rev(labels),'Aggregate annual inflation'),
    fill=c(rev(palette),NA),border=NA,
    lty=c(rep(NA,4),2),lwd=c(rep(NA,4),1.8),col=c(rep(NA,4),'#FF0000'),
    y.intersp=1.05)
  mtext('Source: Eurostat HICP and HBS; authors\' calculations. Layout: IMF Fiscal Monitor (April 2023), Fig. 2.5.',
        side=1,line=4.1,adj=0,cex=.65)
}
pdf(paste0(out,'.pdf'),width=9.5,height=7,family='sans',useDingbats=FALSE)
draw(); invisible(dev.off())
png(paste0(out,'.png'),width=9.5,height=7,units='in',res=240,type='cairo')
draw(); invisible(dev.off())
cat(sprintf('Q1 %.6f%%; Q5 %.6f%%; gap %.6f pp; aggregate %.6f%%\n',
            totals[1],totals[5],totals[1]-totals[5],aggregate_rate))
cat('Created ',out,'.pdf and .png\n',sep='')
