# Blog - Analise 1 - Empresas por partidos

# Importando o dataset
setwd("DIRETORIO")
Data <- read.csv ("stats-partidos.csv",sep=";")

# Verificando se a importação foi OK:
str(Data)

# Verificando stats descritivos dos partidos:
summary(Data$partidos_num)

# Traçando um histograma
opar=par(ps=24) 
hist(Data$partidos_num,breaks=30,xlab="No. de partidos distintos",ylab="No. de P. Jurídicas",main="Doações a partidos distintos",col="lightgreen")


# Tabela de frequencia
freq(Data$partidos_num)

# Calculando o total de empresas que doaram entre 10 e 24
45 + 37 + 32 + 19 + 16 + 15 + 8 + 3 + 5 + 5 + 3 + 1

## Calculando o percentual
8.073e-02 + 6.637e-02 + 5.741e-02 + 3.408e-02 + 2.870e-02 + 2.691e-02 + 1.435e-02 + 5.382e-03 + 8.970e-03 + 8.970e-03 + 5.382e-03 + 1.794e-03

# Empresas de 1 a 3 partidos:
46160 + 5467 + 1827

## percentual
8.281e+01 + 9.807e+00 + 3.277e+00


# Criando o subset para apenas as 100 maiores empresas
Data100 <- subset(Data,Data$valor_total >= 2110000)
summary(Data100$partidos_num)
hist(Data100$partidos_num,breaks=20,xlab="No. de partidos distintos",ylab="No. de Empresas",main="Doações a partidos distintos",col="lightgreen")