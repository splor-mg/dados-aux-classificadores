library(data.table)
library(checksplanejamento)
library(openxlsx)
library(dplyr)

dp <- read_datapackage("datapackage.json")


#acao

names(dp$acao)


acao_msg <- dp$acao[c(72,73, 151, 152)]
acao_na <- dp$acao[is.na(acao_cod) | is.na(acao_desc)]

acao <- cbind(acao_msg, acao_na)

write.xlsx(acao, "_temp/acao_check.xlsx", overwrite = TRUE)

#======================================================================
#elemento_item

names(dp$elemento_item)


##na em elemento_item_cod

ei_cod_linhas_na <- which(is.na(dp$elemento_item$elemento_item_cod))
ei_cod_linhas_na_ant <- ei_cod_linhas_na -1

ei_cod_linhas_filtrar <- unique(c(ei_cod_linhas_na, ei_cod_linhas_na_ant))

elemento_item_cod <- dp$elemento_item[ei_cod_linhas_filtrar]

##na em elemento_item_desc

ei_desc_linhas_na <- which(is.na(dp$elemento_item$elemento_item_desc))
ei_desc_linhas_na_ant <- ei_desc_linhas_na -1

ei_desc_linhas_filtrar <- unique(c(ei_desc_linhas_na, ei_desc_linhas_na_ant))

elemento_item_desc <- dp$elemento_item[ei_desc_linhas_filtrar]


elemento_item <- cbind(elemento_item_cod, elemento_item_desc)

write.xlsx(elemento_item, "_temp/elemento_item_check.xlsx", overwrite = TRUE)



#======================================================================
#funcional_programatica

names(dp$funcional_programatica)

funcional_msg <- dp$funcional_programatica[c(245, 242)] #linhas retornadas no frictionless validate

#analise demonstra que os demais classificadores estão poluindo a análise da primaryKey


#======================================================================
#uo
names(dp$uo)

uo_msg <- dp$uo[c(5, 6)] #linhas retornadas no frictionless validate


uo_chave <- dp$uo[, chave := paste0(ano, uo_cod)]

Uo_duplicadas <- uo_chave[duplicated(chave)]

write.xlsx(Uo_duplicadas, "_temp/uo_check.xlsx", overwrite = TRUE)

