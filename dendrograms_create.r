library(gdata)
library(gplots)
library(RColorBrewer)

#we have data for Promoter-to-Cluster association (HPAS) and
#we have data for transcription (coded in a starnge way)
#the way is a commos trancription+accos score -2,-1,0,1,2
#we turn it all to binary(tissue,TF) and bicluster.
#
load('data/HPAS_et_al.Rda')

cex.tissue<-0.15
cex.TF<-0.2
pollitra<-brewer.pal(9,"Greens")


Rowv.HPAS.dendro <- reorder(as.dendrogram(hclust(dist(HPAS,method="manhattan"))),rowMeans(HPAS))
Colv.HPAS.dendro <- reorder(as.dendrogram(hclust(dist(t(HPAS),method="manhattan"))),colMeans(HPAS))

pdf('HPAS.pdf',width=20,height=23)

heatmap(as.matrix(HPAS), col=pollitra, scale='none', Rowv=Rowv.HPAS.dendro, Colv=Colv.HPAS.dendro,main='HPAS',margins=c(3,20),cexRow=cex.tissue,cexCol=cex.TF)

dev.off()


Rowv.Expr.dendro <- reorder(as.dendrogram(hclust(dist(Expression,method="manhattan"))),rowMeans(Expression))
Colv.Expr.dendro <- reorder(as.dendrogram(hclust(dist(t(Expression),method="manhattan"))),colMeans(Expression))

pdf('TF_expr.pdf',width=20,height=23)

heatmap(as.matrix(Expression), col=pollitra, scale='none', Rowv=Rowv.Expr.dendro, Colv=Colv.Expr.dendro,main='TF expression',margins=c(3,20),cexRow=cex.tissue,cexCol=cex.TF)

dev.off()


save(list=c(ls(pattern='Rowv*'),'ids'),file='dendrograms.Rda')
