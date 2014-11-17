load('./data/HPAS_et_al.Rda')
library(gdata) # for trim to work 
library(ape)
library(distory)

Tissues.HPAS.Tree<-hclust(dist(HPAS,method="manhattan"))

Tissues.Expr.Tree <- hclust(dist(Expression,method="manhattan"))


save(list=c(ls(pattern='Tissues*'),'ids'),file='trees.Rda')

topoH2T<-dist.topo(as.phylo(Tissues.HPAS.Tree),as.phylo(Tissues.Expr.Tree))

cat(paste(c("Topological distance between HPAS tree and TF expression tree =",as.character(topoH2T),"\n"),sep=''))

tests.no<-1000

topoRH2T.v<-sapply(1:tests.no,function(n){
	HPAS.ran<-HPAS

	rownames(HPAS.ran)=sample(row.names(HPAS))

	Tissues.HPAS.ran.Tree<-hclust(dist(HPAS.ran,method="manhattan"))
	topoRH2T<-dist.topo(as.phylo(Tissues.HPAS.ran.Tree),as.phylo(Tissues.Expr.Tree))
	topoRH2T
})

cat(paste(c("We generated",as.character(tests.no),"random permutattion of HPAS tree and the distance \n from random tree to expression was <= then the original \n",as.character(sum(topoH2T>=topoRH2T.v)),' times\n',sep='')))

cat('Distances for randomised trees:\n')
print(topoRH2T.v)

