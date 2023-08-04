-- RODAR NO SERVIDOR DO WMS AVANCADO.


--USE WMSRX
GO

--select * from pedido

--commit tran aaa
--rollback tran aaa
begin tran aaa

declare @cod_pedido int

insert pedido (cod_entidade,operacao,cod_situacao,digitacao,termino_digitacao,data_liberacao,encerramento_PN,faturamento,quem_liberou,quem_digitou,cod_origem_ped,cod_operacao_logistica,obs_PN,data_exportacao)
values (1, 2, 4, getdate(), getdate(), getdate(), getdate(), getdate(), 'delage','delage', 1, 1, 'Migração inicial de estoque', getdate()  )

set @cod_pedido = scope_identity()
select @cod_pedido
insert pedido_item(cod_pedido,cod_produto,quantidade,separado)
select @cod_pedido, l.cod_produto, sum(le.estoque), sum(le.estoque)
from lote_estoque_LPN le inner join
     lote l on l.id_lote = le.id_lote
	 inner join lpn on le.id_LPN = lpn.id_LPN --and lpn.numero is not null
group by l.cod_produto


insert pedido_item_lote_endereco(cod_pedido,cod_produto,id_lote,id_lote_dest,id_endereco,id_endereco_dest,quantidade)
select @cod_pedido, l.cod_produto, l.id_lote, l.id_lote, NULL, LPN.id_endereco , sum(le.estoque)
from lote_estoque_LPN le inner join
     lote l on l.id_lote = le.id_lote inner join
	 LPN on le.id_LPN = LPN.id_LPN --and lpn.numero is not null
	 --and lpn.id_LPN = 890
group by l.cod_produto, l.id_lote, LPN.id_endereco

INSERT pedido_item_lote_endereco_baixa
SELECT pile.id_pedido_item_lote_endereco, pe.digitacao AS data_baixa, quem_baixou = 'MIGRACAO INICIAL', obs = 'CARGA INICIAL MIGRACAO', exporta_div = 0, pe.digitacao AS data_exportacao, null as id_auditoria_inventario_documento
FROM pedido_item_lote_endereco pile INNER JOIN
	 pedido pe ON pe.cod_pedido = pile.cod_pedido
WHERE NOT EXISTS (SELECT * FROM pedido_item_lote_endereco_baixa WHERE id_pedido_item_lote_endereco = pile.id_pedido_item_lote_endereco)
and pe.cod_pedido = @cod_pedido

commit tran aaa



--stp_wms_divergencia--

