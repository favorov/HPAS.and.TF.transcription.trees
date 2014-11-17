load('./data/HPAS_et_al.Rda')
load('./dendrograms.Rda')
#loade dendro files; their names are in dendromes (see below)
is.a.rel<-read.table('./obo/isarelations.txt',header=TRUE,sep="\t",as.is=TRUE)
is.a.rel.category.ids<-read.table('./obo/isarelations.txt',header=FALSE,sep="\t",as.is=TRUE,nrows=1)
colnames(is.a.rel)<-is.a.rel.category.ids
#is.a.rel is a binary tissue-to-category relation;
#rows are tissues, columns are categories
#rownames are tissue ids (not names) colnames are category ids

category.names<-read.table('./obo/idnames.txt',header=FALSE,sep='\t',as.is=TRUE,quote=NULL)
rownames(category.names)<-category.names[,1]
#category ids to icategory names


tissue.names<-read.table('./obo/tissuenames.txt',header=FALSE,sep='\t',as.is=TRUE,quote=NULL )

dendronames<-c("HPAS","Expr")

common.datframe<-data.frame(ID=I(colnames(is.a.rel)),category.name=I(category.names[colnames(is.a.rel),2]))

test_p<-function(dendro,rel.vector) #rel_vector is is.a.rel[,i]
{	
	ListL<-ids[labels(dendro[[1]])]
	ListR<-ids[labels(dendro[[2]])]
	L<-length(ListL)
	R<-length(ListR)
	L1<-sum(rel.vector[ListL])
	R1<-sum(rel.vector[ListR])
	#cat("\n",L," ",R," ",L1," ",R1,"\n")
	pval<-fisher.test(matrix(c(L1,L-L1,R1,R-R1),2,2))$p.value
	p.1<-p.2<-pval #for mininum call in return
	#cat('+')
	if (length(dendro[[1]])>1 && L1>0)
	{
		#cat('$')
		p.1<-test_p(dendro[[1]],rel.vector)
		#cat('%')
	}
	if (length(dendro[[2]])>1 && R1>0)
	{
		#cat('^')
		p.2<-test_p(dendro[[2]],rel.vector)
		#cat('#')
	}
	#cat('-')
	return(min(p.1,p.2,pval))
}

#is.a.rel: rows (coord1) are tissues; colunms (coord2) are categories

for (dendroname in dendronames)
{
	dendrogram<-get(paste0("Rowv.",dendroname,".dendro"))
	pval<-rep(1,dim(is.a.rel)[2])
	names(pval)<-colnames(is.a.rel)
	for (i in 1:dim(is.a.rel)[2])
	{
		rel.vect<-is.a.rel[,i]
		names(rel.vect)<-rownames(is.a.rel)
		pval[i]<-test_p(dendrogram,rel.vect)
	}
	#the datframe is for the current dendrogram
	datframe<-data.frame(p.value=pval,ID=I(colnames(is.a.rel)),category.name=I(category.names[colnames(is.a.rel),2]))
	#common.datframe is the conveged table for all the dendrograms
	colname<-paste0(dendroname,'p-value')
	common.datframe=cbind(common.datframe,newcol = pval)
	names(common.datframe)[which(names(common.datframe)=='newcol')] = colname
	datframe<-datframe[order(datframe[,'p.value']),]
	sink(paste0(dendroname,'.p-values.recursive.txt'))
	write.table(datframe,sep='\t',quote=FALSE,row.names=FALSE)
	#we wrote the table for current dendro
	sink()
}

common.datframe<-common.datframe[order((apply(common.datframe,1,function(row){min(as.numeric(row[3:6]))}))),]
sink('p-values.recursive.txt')
write.table(common.datframe,sep='\t',quote=FALSE,row.names=FALSE)
sink()

