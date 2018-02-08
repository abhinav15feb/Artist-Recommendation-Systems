#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(httr)
options(scipen = 999)
# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  output$distPlot <- renderPlot({
    
    # generate bins based on input$bins from ui.R
    x    <- BaseData$listeners 
    bins <- seq(min(x), max(x), length.out = 15)
    
    # draw the histogram with the specified number of bins
    hist(x, breaks = bins, col = '#75AADB', border = 'white', xlab= "No. of songs", ylab = "Listener Frequency", main = "Distribution of Listener Frequency to No of songs" )
  })
  
  output$distDistribution <- renderPlot({
    
    # generate bins based on input$bins from ui.R
    x    <- BaseData[,c("listeners","playcount")]
    
    # draw the histogram with the specified number of bins
    boxplot(x, ylab='Times Played', col = "#75AADB", ylim= range(0:40000000), main = 'Long Tail in Last.FM data' )
  })
  output$Top10Artist <- renderPlot({
    
    # generate bins based on input$bins from ui.R
    
    x <- head(sort(BaseData$eigencentrality,decreasing=TRUE), n = 5)
    # draw the histogram with the specified number of bins
    barplot(x, names.arg = c('David Bowie', 'Radiohead','The Smiths','Beastie Boys','The Beatles') ,  col = '#75AADB', border = 'white', xlab= "Artist", ylab = "Eigen Vector", main = "Top 5 artists based on Eigen Vector Centrality" )
  })
  
  output$RecentData <- renderPlot({
    
    # generate bins based on input$bins from ui.R
    # draw the histogram with the specified number of bins
    
    r<-r[r$formatDate>as.Date('31/12/2012',"%d/%m/%Y"),]
    l<-l[l$formatedDate>as.Date('31/12/2012',"%d/%m/%Y"),]
    plot(y=r$count,x=r$formatDate,  col = '#75AADB', border = 'white', xlab= "Year", ylab = "No of Songs played", main = "Recent songs over time", type="o" ,ylim = range(0:500))
    lines(x=l$formatedDate,y=l$count,col="red")
  })
  
  output$summary <- renderPrint({summary(BaseData)})
  output$userOutput1 <- renderText({
    Artist1=input$Artist1
    Artist2=input$Artist2
    Artist3=input$Artist3
    
    
    rank.a1 <- dm[Artist1,]
    rank.a1[] <- rank(dm[Artist1,])
    
    rank.a2 <- dm[Artist2,]
    rank.a2[] <- rank(dm[Artist2,])
    
    rank.a3 <- dm[Artist3,]
    rank.a3[] <- rank(dm[Artist3,])
    
    
    
    totalsum<-matrix(mapply(sum, rank.a1,rank.a2,rank.a3, MoreArgs=list(na.rm=T)))
    totalsum.rank<-rank(totalsum,ties.method = c("random"))
    #row.names(totalsum)<-row.names(rank.a1)
    
    
    #row.names(totalsum_RF)<-row.names(d$Id)
    url1 <- trimws(BaseData$Id[which(totalsum.rank==1)], "both")
    url2 <- trimws(BaseData$Id[which(totalsum.rank==2)], "both")
    url3 <- trimws(BaseData$Id[which(totalsum.rank==3)], "both")
    str1 <-paste("<font size=\"5\">","Recommendation :<br>Artist<b>",a (BaseData$Id[which(totalsum.rank==1)],href= paste('https://www.last.fm/music/',url1, sep = ''),target="_blank"),"</b> Genre: ",BaseData$recent_tag_1[which(totalsum.rank==1)],"</font>")
    str2 <-paste("<font size=\"5\">","Artist<b>",a (BaseData$Id[which(totalsum.rank==2)],href= paste('https://www.last.fm/music/',url2, sep = ''),target="_blank"),"</b> Genre: ",BaseData$recent_tag_1[which(totalsum.rank==2)],"</font>")
    str3 <-paste("<font size=\"5\">","Artist<b>",a (BaseData$Id[which(totalsum.rank==3)],href= paste('https://www.last.fm/music/',url3, sep = ''),target="_blank"),"</b> Genre: ",BaseData$recent_tag_1[which(totalsum.rank==3)],"</font>")
    
    HTML(paste(str1, str2,str3, sep = '<br/>'))
    
  })
  output$userOutput2 <- renderPrint({
    Artist1=input$Artist1
    Artist2=input$Artist2
    Artist3=input$Artist3
    rank.a4 <- proxmat[Artist1,]
    rank.a4[] <- rank(-proxmat[Artist1,])
    
    rank.a5 <- proxmat[Artist2,]
    rank.a5[] <- rank(-proxmat[Artist2,])
    
    rank.a6 <- proxmat[Artist3,]
    rank.a6[] <- rank(-proxmat[Artist3,])
    
    totalsum_RF<-matrix(mapply(sum, rank.a4,rank.a5,rank.a6, MoreArgs=list(na.rm=T)))
    totalsum_RF.rank<-rank(totalsum_RF,ties.method = c("random"))
    
    url4 <- trimws(BaseData$Id[which(totalsum_RF.rank==1)], "both")
    url5 <- trimws(BaseData$Id[which(totalsum_RF.rank==2)], "both")
    url6 <- trimws(BaseData$Id[which(totalsum_RF.rank==3)], "both")
    str4 <-paste("<font size=\"5\">","Recommendation : <br/> Artist<b>",a (BaseData$Id[which(totalsum_RF.rank==1)],href= paste('https://www.last.fm/music/',url4, sep = ''),target="_blank"),"</b> Genre:",BaseData$recent_tag_1[which(totalsum_RF.rank==1)] ,"</font>")
    str5 <-paste("<font size=\"5\">","Artist<b>",a (BaseData$Id[which(totalsum_RF.rank==2)],href= paste('https://www.last.fm/music/',url5, sep = ''),target="_blank"),"</b> Genre:",BaseData$recent_tag_1[which(totalsum_RF.rank==2)] ,"</font>")
    str6 <-paste("<font size=\"5\">","Artist<b>",a (BaseData$Id[which(totalsum_RF.rank==3)],href= paste('https://www.last.fm/music/',url6, sep = ''),target="_blank"),"</b> Genre:",BaseData$recent_tag_1[which(totalsum_RF.rank==3)] ,"</font>")
   
    HTML(paste(str4,str5,str6, sep = '<br/>'))
    
  })
  output$ginger <- renderImage({
    return(list(
      src = "Rplot03.png",
      contentType = "image/png",
      width = 500,
      height = 400
    ))
  },deleteFile = FALSE)
})