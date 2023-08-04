-- DELAGE\claudio.lopes@2022-06-20 15:06:57: <Criacao>  
CREATE OR ALTER PROCEDURE stp_WMS_etiqueta_picking_embarque  
 @cod_pedido INT  
AS  
   
SELECT   
 p.cod_pedido * 10 + dbo.CalcDigitoMod11(p.cod_pedido) AS cod_pedido,  
 REPLICATE('0', 7 - LEN(p.cod_prenota * 10 + dbo.CalcDigitoMod11(p.cod_prenota))) + p.cod_prenota * 10 + dbo.CalcDigitoMod11(p.cod_prenota) AS cod_picking,  
 dbo.TRIM(e.razao_social) AS razao_social,  
 CASE  
 WHEN pe.cod_rota IS NOT NULL THEN '0000' + pe.cod_rota  
 WHEN ee.cod_rota IS NOT NULL THEN '0000' + ee.cod_rota  
 ELSE '000_'  
 END AS Rota,  
 CASE  
 WHEN pe.cod_rota IS NOT NULL THEN CASE  
          WHEN LEN(pe.cod_rota) - 5 < 0 THEN 0  
          ELSE LEFT(pe.cod_rota, LEN(pe.cod_rota) - 5)  
           END  
 WHEN ee.cod_rota IS NOT NULL THEN CASE  
          WHEN LEN(ee.cod_rota) - 5 < 0 THEN 0  
          ELSE LEFT(ee.cod_rota, LEN(ee.cod_rota) - 5)  
           END  
 ELSE 0  
 END AS rota_custom_1,  
 CASE  
 WHEN pe.cod_rota IS NOT NULL THEN LEFT(pe.cod_rota, 3)  
 WHEN ee.cod_rota IS NOT NULL THEN LEFT(ee.cod_rota, 3)  
 ELSE '000'  
 END AS rota_descricao_custom_1,  
 CASE  
 WHEN pe.endereco IS NOT NULL THEN dbo.TRIM(pe.endereco)  
 WHEN ee.endereco IS NOT NULL THEN dbo.TRIM(ee.endereco)  
 ELSE ''  
 END AS Endereco,  
 CASE  
 WHEN cp.cidade IS NOT NULL THEN dbo.TRIM(cp.cidade)  
 WHEN cep.cidade IS NOT NULL THEN dbo.TRIM(cep.cidade)  
 ELSE ''  
 END AS Cidade,  
 CASE  
 WHEN pe.bairro IS NOT NULL THEN dbo.TRIM(pe.bairro)  
 WHEN ee.bairro IS NOT NULL THEN dbo.TRIM(ee.bairro)  
 ELSE ''  
 END AS Bairro,  
 CASE  
 WHEN pe.bairro IS NOT NULL THEN dbo.TRIM(pe.bairro) + ' - ' + dbo.TRIM(cp.cidade) + ' - ' + dbo.TRIM(cp.sigla_estado)  
 WHEN ee.bairro IS NOT NULL THEN dbo.TRIM(ee.bairro) + ' - ' + dbo.TRIM(cep.cidade) + ' - ' + dbo.TRIM(cep.sigla_estado)  
 ELSE ''  
 END AS bairro_cid_uf,  
 CASE  
 WHEN cp.sigla_estado IS NOT NULL THEN cp.sigla_estado  
 WHEN cep.sigla_estado IS NOT NULL THEN cep.sigla_estado  
 ELSE ''  
 END AS estado,  
 CASE  
 WHEN pe.cep IS NOT NULL THEN pe.cep  
 ELSE ee.cep  
 END AS cep,  
 CASE  
 WHEN pe.complemento IS NOT NULL THEN dbo.TRIM(pe.complemento)  
 WHEN ee.complemento IS NOT NULL THEN dbo.TRIM(ee.complemento)  
 ELSE ' . '  
 END AS complemento,  
 CASE  
 WHEN pe.observacao IS NOT NULL THEN pe.observacao + '- CEP ' + pe.cep  
 WHEN ee.observacao IS NOT NULL THEN ee.observacao + '- CEP ' + ee.cep  
 ELSE 'CEP ' +  CASE  
      WHEN pe.cep IS NOT NULL THEN pe.cep  
      ELSE ee.cep  
       END  
 END AS obs_cep,  
 CASE  
 WHEN def.descricao = 'Nota Fiscal' THEN 'NF'  
 WHEN def.descricao = 'Nota Fiscal\Troco' THEN 'NFT'  
 WHEN def.descricao = 'Troco' THEN 'T'  
 WHEN def.descricao = 'Nota Fiscal\Devolucao' THEN 'NFD'  
 WHEN def.descricao = 'Troco\Devolucao' THEN 'TD'  
 WHEN def.descricao = 'Nota Fiscal\Troco\Devolucao' THEN 'NFDT'  
 ELSE ' . '  
 END AS suboperacao,  
 CASE  
 WHEN p.cod_pedido_polo IS NOT NULL THEN SUBSTRING(LEFT(p.cod_pedido_polo + REPLICATE(' ', 12), 12), 4, 8)  
 ELSE ''  
 END AS cod_pedido_legado_reduzido,  
 CASE  
 WHEN p.cod_pedido_polo IS NOT NULL THEN SUBSTRING(LEFT(p.cod_pedido_polo + REPLICATE(' ', 4), 4), 2, 2) + '/' + SUBSTRING(LEFT(p.cod_pedido_polo + REPLICATE(' ', 12), 12), 4, 8) + SUBSTRING(LEFT(p.cod_pedido_polo + REPLICATE(' ', 14), 14), 12, 2)  
 ELSE ''  
 END AS cod_pedido_legado_custon,  
 CASE  
 WHEN p.urgente = 1 THEN 'PR'  
 WHEN p.urgente = 0 THEN '01'  
 WHEN p.urgente IS NULL THEN 'BB'  
 ELSE ''  
 END AS Classificacao,  
 CONVERT(VARCHAR(12), p.digitacao, 101) + ' ' + CONVERT(VARCHAR(12), p.digitacao, 108) AS data_pedido,  
 CASE  
 WHEN p.termino_digitacao IS NOT NULL THEN CONVERT(VARCHAR(12), p.termino_digitacao, 101)   
 ELSE CONVERT(VARCHAR(12), p.digitacao, 101)  
 END AS data_pedido_custom_1,  
 CASE  
 WHEN p.obs_PN IS NOT NULL THEN p.obs_PN  
 ELSE '_'  
 END AS Obs_PN,  
 CASE  
 WHEN p.obs_liberacao IS NULL OR p.obs_liberacao = '' THEN CASE  
                WHEN mp.descricao IS NOT NULL THEN mp.descricao  
                ELSE 'SEM MODALIDADE'  
                 END  
 ELSE 'ENTREGA PROGRAMADA'  
 END AS Modalidade,  
 CASE  
 WHEN p.valor_total IS NOT NULL THEN REPLACE(REPLACE(CONVERT(VARCHAR(20), p.valor_total), '.', ''), ',', '')  
 ELSE 0  
 END AS valor_total,  
 CASE  
 WHEN EXISTS (SELECT 1 FROM produto prod (NOLOCK)  
     INNER JOIN pedido_item pi (NOLOCK) ON prod.cod_produto = pi.cod_produto  
     INNER JOIN SubGrupo sg (NOLOCK) ON prod.cod_subgrupo = sg.cod_subgrupo  
     WHERE pi.cod_pedido = p.cod_pedido AND sg.controlado = 1)  
  THEN 'RETIRA RECEITA'  
 ELSE '_'  
 END AS Obs_3,  
 CASE  
 WHEN EXISTS (SELECT 1 FROM produto prod (NOLOCK)  
     INNER JOIN pedido_item pi (NOLOCK) ON prod.cod_produto = pi.cod_produto  
     INNER JOIN SubGrupo sg (NOLOCK) ON prod.cod_subgrupo = sg.cod_subgrupo  
     WHERE pi.cod_pedido = p.cod_pedido AND sg.cod_subgrupo = 163)  
  THEN 'BEL/TB'  
 ELSE '_'  
 END AS Obs_4,  
 ce.descricao AS Caixa,  
 CONVERT(VARCHAR(12), GETDATE(), 101) AS data_impressao_sem_horas,  
 CASE  
 WHEN p.cod_onda IS NOT NULL THEN p.cod_onda  
 ELSE ''  
 END AS cod_onda,  
 CASE   
 WHEN t.chave_acesso IS NOT NULL THEN t.chave_acesso  
 ELSE '_'  
 END AS NFe,  
 (SELECT COUNT(1) FROM pedido ped (NOLOCK)  
  INNER JOIN pedido_volume pvp (NOLOCK) ON ped.cod_pedido = pvp.cod_pedido  
  WHERE ped.cod_onda = p.cod_onda) AS volumes_onda,  
 CASE   
 WHEN def.cod_suboperacao = 1 OR def.cod_suboperacao = 11 OR def.cod_suboperacao = 14 THEN '_'  
 WHEN mp.cod_modalidade = 3 OR mp.cod_modalidade = 6 THEN 'Pedido D+1'  
 WHEN p.obs_liberacao IS NOT NULL AND p.obs_liberacao <> '' THEN p.obs_liberacao  
 ELSE 'Entr. Max: ' + CONVERT(VARCHAR(12), DATEADD(HOUR, 4, p.digitacao), 101) + ' ' + CONVERT(VARCHAR(12), DATEADD(HOUR, 4, p.digitacao), 108)  
 END AS entrega_maxima,  
 CASE  
 WHEN et.fantasia IS NOT NULL THEN dbo.TRIM(et.fantasia)  
 ELSE '_'  
 END AS transportadora_custom_1,  
 CASE  
 WHEN mp.cod_modalidade = 1 OR mp.cod_modalidade = 11 OR mp.cod_modalidade = 14 THEN 'CORREIO'  
 ELSE dbo.TRIM(et.fantasia)  
 END AS transportadora,  
 CASE   
 WHEN p.obs_liberacao IS NOT NULL THEN p.obs_inventario  
 ELSE CONVERT(VARCHAR(12), DATEADD(DAY, p.dias_entrega, p.termino_digitacao), 101)  
 END AS data_prevista_entrega,  
 dbo.TRIM(p.cod_pedido_polo) AS cod_pedido_legado,  
 SUBSTRING('000000000' + p.cod_pedido_polo, 0, LEN('000000000' + p.cod_pedido_polo) - 9) + SUBSTRING('00' + CONVERT(VARCHAR(20), pv.Volume), 0, LEN('00' + CONVERT(VARCHAR(20), pv.Volume)) - 3) AS picking_volume_custom_1,  
 SUBSTRING(LEFT(e.razao_social + REPLICATE(' ', 21), 21), 0, 21) + '(' + CONVERT(VARCHAR(20), (e.cod_entidade * 10 + dbo.CalcDigitoMod11(e.cod_entidade))) + ')' AS ent_c_cod,  
 (SELECT st.sigla FROM sigla_transportadora st (NOLOCK)  
  INNER JOIN municipio m (NOLOCK) ON st.id_municipio = m.id_municipio  
  WHERE st.cod_transportadora = p.cod_transportadora  
 AND st.id_pais = CASE  
     WHEN ep.id_pais IS NOT NULL THEN ep.id_pais  
     WHEN ese.sigla_estado IS NOT NULL THEN ese.id_pais  
     ELSE 1  
      END  
 AND (st.sigla_estado IS NULL OR st.sigla_estado =  CASE  
             WHEN cp.sigla_estado IS NOT NULL THEN cp.sigla_estado  
             WHEN cep.sigla_estado IS NOT NULL THEN cep.sigla_estado  
             ELSE ''  
             END)  
 AND (m.nome IS NULL OR m.nome =  CASE  
          WHEN cp.cidade IS NOT NULL THEN dbo.TRIM(cp.cidade)  
          WHEN cep.cidade IS NOT NULL THEN dbo.TRIM(cep.cidade)  
          ELSE ''  
          END)  
 AND ((st.cep_inicial IS NULL OR st.cep_inicial =  CASE  
              WHEN pe.cep IS NOT NULL THEN pe.cep  
              ELSE ee.cep  
              END)  
   AND (st.cep_final IS NULL OR st.cep_final =  CASE  
              WHEN pe.cep IS NOT NULL THEN pe.cep  
              ELSE ee.cep  
              END))  
 ) AS sigla,  
 (SELECT st.cod_externo FROM sigla_transportadora st (NOLOCK)  
  INNER JOIN municipio m (NOLOCK) ON st.id_municipio = m.id_municipio  
  WHERE st.cod_transportadora = p.cod_transportadora  
 AND st.id_pais = CASE  
     WHEN ep.id_pais IS NOT NULL THEN ep.id_pais  
     WHEN ese.sigla_estado IS NOT NULL THEN ese.id_pais  
     ELSE 1  
      END  
 AND (st.sigla_estado IS NULL OR st.sigla_estado =  CASE  
             WHEN cp.sigla_estado IS NOT NULL THEN cp.sigla_estado  
             WHEN cep.sigla_estado IS NOT NULL THEN cep.sigla_estado  
             ELSE ''  
             END)  
 AND (m.nome IS NULL OR m.nome =  CASE  
          WHEN cp.cidade IS NOT NULL THEN dbo.TRIM(cp.cidade)  
          WHEN cep.cidade IS NOT NULL THEN dbo.TRIM(cep.cidade)  
          ELSE ''  
          END)  
 AND ((st.cep_inicial IS NULL OR st.cep_inicial =  CASE  
              WHEN pe.cep IS NOT NULL THEN pe.cep  
              ELSE ee.cep  
              END)  
   AND (st.cep_final IS NULL OR st.cep_final =  CASE  
              WHEN pe.cep IS NOT NULL THEN pe.cep  
              ELSE ee.cep  
              END))  
 ) AS cod_externo,  
 '7' + CONVERT(VARCHAR(7), REPLICATE('0', 7 - LEN(p.cod_prenota * 10 + dbo.CalcDigitoMod11(p.cod_prenota)))) + CONVERT(VARCHAR(20), (p.cod_prenota * 10 + dbo.CalcDigitoMod11(p.cod_prenota)))  
     + CONVERT(VARCHAR(4), REPLICATE('0', 4 - LEN(pv.Volume)) + CONVERT(VARCHAR(20), pv.Volume)) + '0' AS cod_barra_PN,  
 CASE  
 WHEN pe.observacao IS NOT NULL THEN UPPER(pe.observacao)  
 WHEN ee.observacao IS NOT NULL THEN UPPER(ee.observacao)  
 ELSE UPPER(e.razao_social)  
 END AS razao_ou_destinatario,  
 CONVERT(VARCHAR(20), pv.Volume) + '/' + CONVERT(VARCHAR(20), (SELECT COUNT(1) FROM pedido_volume WHERE cod_pedido = p.cod_pedido)) AS volume_volumes,  
 pv.Volume AS volume, 
 CASE   
  WHEN ee.complemento IS NULL  
   THEN ' . '  
  ELSE dbo.RemoveAcentos(ee.complemento)  
  END AS complemento_custom_1  
FROM pedido p (NOLOCK)  
INNER JOIN pedido_volume pv (NOLOCK) ON p.cod_pedido = pv.cod_pedido  
INNER JOIN entidade e (NOLOCK) ON p.cod_entidade = e.cod_entidade  
LEFT JOIN def_suboperacao def (NOLOCK) ON p.cod_suboperacao = def.cod_suboperacao  
LEFT JOIN def_modalidade_pedido mp (NOLOCK) ON p.cod_modalidade = mp.cod_modalidade  
LEFT JOIN caixa_esteira ce (NOLOCK) ON pv.Tipo_caixa = ce.id_caixa  
LEFT JOIN entidade_ender ee (NOLOCK) ON e.cod_entidade = ee.cod_entidade  
LEFT JOIN rota re (NOLOCK) ON ee.cod_rota = re.cod_rota  
LEFT JOIN cep cep (NOLOCK) ON ee.cep = cep.cep  
LEFT JOIN estado ese (NOLOCK) ON cep.sigla_estado = ese.sigla_estado  
LEFT JOIN transportadora_rota tre ON ee.cod_rota = tre.cod_rota  
LEFT JOIN pedido_ender pe (NOLOCK) ON p.cod_pedido = pe.cod_pedido  
LEFT JOIN rota rp (NOLOCK) ON pe.cod_rota = rp.cod_rota  
LEFT JOIN cep cp (NOLOCK) ON pe.cep = cp.cep  
LEFT JOIN estado ep (NOLOCK) ON cp.sigla_estado = ep.sigla_estado  
LEFT JOIN transportadora_rota trp (NOLOCK) ON pe.cod_rota = trp.cod_rota  
LEFT JOIN pedido_titulo pt (NOLOCK) ON p.cod_pedido = pt.cod_pedido  
LEFT JOIN entidade et (NOLOCK) ON p.cod_transportadora = et.cod_entidade  
LEFT JOIN titulo t (NOLOCK) ON pt.cod_titulo = t.cod_titulo  
WHERE p.cod_pedido = @cod_pedido  
 AND (ee.cod_entidade_ender IS NULL OR ee.principal = -1)  
 AND (tre.cod_transportadora_rota IS NULL OR tre.transportadora_principal = 1)  
 AND (trp.cod_transportadora_rota IS NULL OR trp.transportadora_principal = 1)  