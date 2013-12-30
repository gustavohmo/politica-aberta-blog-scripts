# Politica aberta
# Estatisticas

use politicaaberta;

# Para quantos partidos distintos as empresas doam?
CREATE TABLE `politicaaberta`.`stats_empresa_partidos` (
  `idStatsEmpresaPartidos` int(11) NOT NULL AUTO_INCREMENT,
  `cpf_cnpj_doador` varchar(14) DEFAULT NULL,
  `nome_doador` varchar(255) DEFAULT NULL,
  `nome_receita_doador` varchar(255) DEFAULT NULL,
  `sigla_partido` varchar(7) DEFAULT NULL,
  `new_prestacao_tse_ano` year(4) DEFAULT NULL,
  `new_prestacao_tse_tipo` varchar(9) DEFAULT NULL,
  `valor_total` decimal(13,2) DEFAULT NULL,
  PRIMARY KEY (`idStatsEmpresaPartidos`),
  UNIQUE KEY `cpf_cnpj_doador_ano_partido_UNIQUE` (`cpf_cnpj_doador`,`new_prestacao_tse_ano`,`new_prestacao_tse_tipo`,`sigla_partido`),

  KEY `sigla_partido_index` (`sigla_partido`),

  KEY `stats_empresa_partidos_convering_index` (`cpf_cnpj_doador`,`sigla_partido`,`new_prestacao_tse_ano`,`new_prestacao_tse_tipo`,`nome_doador`,`nome_receita_doador`,`valor_total`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `politicaaberta`.`stats_empresa_partidos` (cpf_cnpj_doador,nome_doador,nome_receita_doador,sigla_partido,new_prestacao_tse_ano,new_prestacao_tse_tipo,valor_total) (SELECT cpf_cnpj_doador,nome_doador,nome_receita_doador,sigla_partido,new_prestacao_tse_ano,new_prestacao_tse_tipo,SUM(new_valor) FROM prestacaocandidato WHERE tipo_receita="Recursos de pessoas jurídicas" GROUP BY cpf_cnpj_doador,new_prestacao_tse_ano,sigla_partido);

INSERT INTO `politicaaberta`.`stats_empresa_partidos` (cpf_cnpj_doador,nome_doador,nome_receita_doador,sigla_partido,new_prestacao_tse_ano,new_prestacao_tse_tipo,valor_total) (SELECT cpf_cnpj_doador,nome_doador,nome_receita_doador,sigla_partido,new_prestacao_tse_ano,new_prestacao_tse_tipo,SUM(new_valor) FROM prestacaocomite WHERE tipo_receita="Recursos de pessoas jurídicas" GROUP BY cpf_cnpj_doador,new_prestacao_tse_ano,sigla_partido);

INSERT INTO `politicaaberta`.`stats_empresa_partidos` (cpf_cnpj_doador,nome_doador,nome_receita_doador,sigla_partido,new_prestacao_tse_ano,new_prestacao_tse_tipo,valor_total) (SELECT cpf_cnpj_doador,nome_doador,nome_receita_doador,sigla_partido,new_prestacao_tse_ano,new_prestacao_tse_tipo,SUM(new_valor) FROM prestacaopartido WHERE tipo_receita="Recursos de pessoas jurídicas" GROUP BY cpf_cnpj_doador,new_prestacao_tse_ano,sigla_partido);

# Query de teste: o total de rows retornado deve ser o mesmo que o inserido acima:
SELECT count(*) ContaEmpresasPrestacaoCandidato FROM (
  SELECT count(*)
    FROM prestacaocandidato a
      LEFT JOIN prestacaocandidato b on (a.idprestacaocandidato=b.idprestacaocandidato)
    WHERE a.tipo_receita="Recursos de pessoas jurídicas" and b.tipo_receita="Recursos de pessoas jurídicas"
  GROUP BY a.cpf_cnpj_doador,b.sigla_partido) AS contador;

SELECT count(*) ContaEmpresasPrestacaoComite FROM (
  SELECT count(*)
    FROM prestacaocomite a
      LEFT JOIN prestacaocomite b on (a.idPrestacaoComite=b.idPrestacaoComite)
    WHERE a.tipo_receita="Recursos de pessoas jurídicas" and b.tipo_receita="Recursos de pessoas jurídicas"
  GROUP BY a.cpf_cnpj_doador,b.sigla_partido) AS contador;

SELECT count(*) ContaEmpresasPrestacaoPartido FROM (
  SELECT count(*)
    FROM prestacaopartido a
      LEFT JOIN prestacaopartido b on (a.idprestacaopartido=b.idprestacaopartido)
    WHERE a.tipo_receita="Recursos de pessoas jurídicas" and b.tipo_receita="Recursos de pessoas jurídicas"
  GROUP BY a.cpf_cnpj_doador,b.sigla_partido) AS contador;


# Query de exportacao dos dados para fazer a analise no R:
(SELECT 'cpf_cnpj_doador','nome_doador','nome_receita_doador','partidos_num','partidos','valor_total')
  UNION ALL
(SELECT cpf_cnpj_doador,nome_doador,nome_receita_doador,COUNT(DISTINCT sigla_partido) as c,GROUP_CONCAT(DISTINCT sigla_partido SEPARATOR ','),sum(valor_total) FROM stats_empresa_partidos WHERE new_prestacao_tse_ano = 2012 GROUP BY cpf_cnpj_doador ORDER BY c DESC INTO OUTFILE '/tmp/stats-partidos.csv' FIELDS TERMINATED BY ';' ENCLOSED BY '"' LINES TERMINATED BY '\n');


# Verificando as empresas mais relevantes
SELECT sum(valor_total_ccp) FROM (
  SELECT cod_doador,nome_receita_doador,nome_doador,valor_total_ccp,prestacao_total_ccp_count 
    FROM prestacaototais
  WHERE ano = 2012 ORDER BY valor_total_ccp DESC limit 10) AS soma;


mysql> SELECT sum(valor_total_ccp) FROM (
    ->   SELECT cod_doador,nome_receita_doador,nome_doador,valor_total_ccp,prestacao_total_ccp_count
    ->     FROM prestacaototais
    ->   WHERE ano = 2012 ORDER BY valor_total_ccp DESC limit 100) AS soma;
+----------------------+
| sum(valor_total_ccp) |
+----------------------+
|         760159215.60 |
+----------------------+
1 row in set (0.10 sec)

mysql> select 760159215.60/1867590018.37
    -> ;
+----------------------------+
| 760159215.60/1867590018.37 |
+----------------------------+
|                   0.407027 |
+----------------------------+
1 row in set (0.00 sec)


# Calculando o valor total doado por quem doou para apenas 1 partido

mysql> select sum(d),count(*) from (SELECT cpf_cnpj_doador,nome_doador,nome_receita_doador,COUNT(DISTINCT sigla_partido) as c,GROUP_CONCAT(DISTINCT sigla_partido SEPARATOR ','),sum(valor_total) as d FROM stats_empresa_partidos WHERE new_prestacao_tse_ano = 2012 GROUP BY cpf_cnpj_doador ) as soma where c = 1;
+--------------+----------+
| sum(d)       | count(*) |
+--------------+----------+
| 578273413.69 |    46160 |
+--------------+----------+
1 row in set (0.46 sec)

mysql> select 578273413.69/1867590018.37;
+----------------------------+
| 578273413.69/1867590018.37 |
+----------------------------+
|                   0.309636 |
+----------------------------+
1 row in set (0.00 sec)
