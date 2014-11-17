HPAS.and.Expr = read.csv('ss_and_HPAS.tsv',sep="\t")
dim(HPAS.and.Expr)
rownames(HPAS.and.Expr)
colnames(HPAS.and.Expr)
max(HPAS.and.Expr)
min(HPAS.and.Expr)
save(file='HPAS.and.expr.Rda',list=c('HPAS.and.Expr'))
#read reom excel
Hpas_and_Expr_nozero=HPAS.and.Expr[!which(HPAS.and.Expr[1,]==0)]
Expression=ifelse(Hpas_and_Expr_nozero>0,1,0)
HPAS=ifelse((Hpas_and_Expr_nozero==-1|Hpas_and_Expr_nozero==2),1,0)
#decipher
# -2 - no TF, no HPAS
# -1 - no TF, HPAS
# 0 - TF not present in expression table
# 1 - TF, no HPAS
# 2 - TF, HPAS
noms.and.ids<-rownames(HPAS)
ids<-gsub(pattern='.*\\.CNhs[0-9]+\\.',replacement='',perl=TRUE,x=noms.and.ids)
noms<-gsub(pattern='\\.CNhs.*',replacement='',perl=TRUE,x=noms.and.ids)
rownames(HPAS)<-noms
rownames(Expression)<-noms
ids<-paste("FF:",trim(ids),sep="")
#we turn names to readable
#we turn ids to the format that is in OBO
names(ids)<-noms
save(file='HPAS_et_al.Rda',list=c('HPAS','Expression','ids'))

