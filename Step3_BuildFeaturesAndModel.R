setwd('/Users/abhi/Desktop/Sem 3/BigData/Project')
library(cluster)
library(gower)
library(dplyr) 
library(randomForest)
library(ggplot2)
Artist="Avicii"

d <- read.csv('RecentArtist_FullData.csv')
row.names(d)<- d$Id

# Empty Column Removed
drop <-c("Label","timeset","indegree","outdegree","modularity_class") 
d<-d[ , !(names(d) %in% drop)]


recent <- read.csv('User_Recent_Track.csv')
recent$formatDate <- as.Date(paste(substring(recent$Date,1,2), substring(recent$Date,4,6), substring(recent$Date,7,11),sep ='-'),"%d-%b-%Y")
#summary(recent)
r <-aggregate(cbind(count = Artist) ~ formatDate, 
                   data = recent, 
                   FUN = function(x){NROW(x)})
l<-aggregate(cbind(count = Artist) ~ formatedDate, 
             data = loved, 
             FUN = function(x){NROW(x)})

loved$formatedDate <- as.Date(paste(substring(loved$Date,1,2), substring(loved$Date,4,6), substring(loved$Date,7,11),sep ='-'),"%d-%b-%Y")
#summary(loved)

LovedList <-read.csv('User_Loved_track.csv')


ul<-data.frame(UserList$User,UserList$Artist,UserList$Date)


q1<-quantile(d$listeners, 0.25)
m <- mean(d$listeners)
q2<-quantile(d$listeners, 0.75)

d$Hit<-ifelse(d$listeners>q2,3,ifelse(d$listeners>m,2,ifelse(d$listeners>q1,1,0)))
print (substring(ul$UserList.Date,7,11))
?case_when
d$recentpopularity<- case_when(
  d$Id %in% ul[as.numeric(substring(ul$UserList.Date,7,11))==2013,2]~2013,
  d$Id %in% ul[as.numeric(substring(ul$UserList.Date,7,11))==2014,2]~2014,
  d$Id %in% ul[as.numeric(substring(ul$UserList.Date,7,11))==2015,2]~2015,
  d$Id %in% ul[as.numeric(substring(ul$UserList.Date,7,11))==2016,2]~2016,
  d$Id %in% ul[as.numeric(substring(ul$UserList.Date,7,11))==2017,2]~2017,
  TRUE~2010
)  
summary(d)


# Removed Tags to create a non content based model; df name: NonContent

LovedCount<-aggregate(cbind(count = Source) ~ Artist, 
                      data = LovedList, 
                      FUN = function(x){NROW(x)})
names(LovedCount)
NonContent<-d
NonContent<-left_join(NonContent, LovedCount, by = c("Id"="Artist"))
NonContent$Id <-as.factor(NonContent$Id)

names(NonContent)
head(NonContent)
NonContent[is.na(NonContent)] <- 0
head(NonContent)
summary (NonContent)
BaseData<-NonContent

#write.csv(NonContent,"CompleteData.csv")

names(NonContent)
drop2<-c("recent_tag_1","recent_tag_2","recent_tag_3","recent_tag_4","recent_tag_5")
NonContent <- NonContent[ , !(names(NonContent) %in% drop2)]
names(NonContent)

#write.csv(d,'Artist_data_for_similarity.csv')

# Output of Gower
d.agr <-daisy(d, metric = 'gower', type=list(logratio=3))
#summary(d.agr)
#attributes(d.agr)
#head(d.agr)
dm<-as.matrix(d.agr)
head(dm)
#write.csv(dm,'Artist_similarity.csv')
# Print Column Names:
#attributes(d)
#attributes(dm)
#write.csv(x = dm,file = 'abc.csv')
# Print Row Names:
df= as.array(dm[Artist,])
#min(df[df !=min(df)])
#dim(df)


# Output of Cosine turns out to be the same value as gower

#d.agr2 <-daisy(d, metric = 'cosine', type=list(logratio=3))
#summary(d.agr2)
#attributes(d.agr2)
#head(d.agr2)
#dm2<-as.matrix(d.agr2)
#head(dm2)

# Print Row Names:
#df2= as.array(dm2[Artist,])
#max(df2)
#dim(df2)
#?dim
#df2[which(df2 ==min(df2[df2 !=min(df2)]))]




NC <- NonContent[ , !(names(NonContent) %in% c('Id'))]

P <- randomForest(count~.,NC, ntree = 1000, proximity=TRUE)
plot(P)
proximity.plot(P)
varImpPlot(P, main = "Variable Importance for Random Forest")
proxmat<-as.matrix(P$proximity)
colnames(proxmat)<-d$Id
row.names(proxmat)<-d$Id
#write.csv(proxmat,'RFArtistSimilarity.csv')
pmat= as.array(proxmat[Artist,])
pmat[which(pmat ==max(pmat[pmat !=max(pmat)]))]
pmat_a<-rank(-proxmat[Artist,])
pmat[which(pmat_a==2)]
df[which(df ==min(df[df !=min(df)]))]

Artist1='Post Malone'
Artist2='Post Malone'
Artist3='Post Malone'

rank.a1 <- dm[Artist1,]
rank.a1[] <- rank(dm[Artist1,])

rank.a2 <- dm[Artist2,]
rank.a2[] <- rank(dm[Artist2,])

rank.a3 <- dm[Artist3,]
rank.a3[] <- rank(dm[Artist3,])

rank.a4 <- proxmat[Artist1,]
rank.a4[] <- rank(-proxmat[Artist1,])

rank.a5 <- proxmat[Artist2,]
rank.a5[] <- rank(-proxmat[Artist2,])

rank.a6 <- proxmat[Artist3,]
rank.a6[] <- rank(-proxmat[Artist3,])

totalsum<-matrix(mapply(sum, rank.a1,rank.a2,rank.a3, MoreArgs=list(na.rm=T)))
totalsum.rank<-rank(totalsum,ties.method = c("random"))
row.names(totalsum)<-row.names(rank.a1)

totalsum_RF<-matrix(mapply(sum, rank.a4,rank.a5,rank.a6, MoreArgs=list(na.rm=T)))
totalsum_RF.rank<-rank(totalsum_RF,ties.method = c("random"))
row.names(totalsum_RF)<-row.names(d$Id)

rank.a2[which(totalsum.rank==1)]
rank.a2[which(totalsum.rank==2)]
rank.a2[which(totalsum.rank==3)]

d$Id[which(totalsum_RF.rank==1)]
d$Id[which(totalsum_RF.rank==2)]
d$Id[which(totalsum_RF.rank==3)]

rank.a5[(rownames(d)=='Post Malone')]
rank.a.rank
#save(,)
save(BaseData, dm, proxmat, file="Project.RData")
