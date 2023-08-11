/****** Object:  Table [dbo].[migraestoque]    Script Date: 5/6/2022 11:25:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
DROP TABLE mig_estoque
GO

CREATE TABLE [dbo].mig_estoque(
	[endereco_completo] [nvarchar](255) NULL,
	[cod_produto_polo] [nvarchar](255) NULL,
	--[ean] [nvarchar](255) NULL,
	[descricao] [nvarchar](255) NULL,
	[estoque] [nvarchar](255) NULL,
	[data_validade] [nvarchar](255) NULL,
	[data_fabricacao] [nvarchar](255) NULL,
	[lote] [nvarchar](255) NULL,
		[finalidade] [nvarchar](255) NULL
) ON [PRIMARY]
GO

insert [migraestoque]
select 3978, pr.cod_produto_rel, cf.cod_barra, null as decricao, 1000000, '2024/05/04', '2022/05/04', 'UNICO'
from produto_relacionado pr
--inner join produto_endereco pe on pr.cod_produto = pe.cod_produto
inner join caixa_fechada cf on pr.cod_produto = cf.cod_produto and cf.principal = -1
--inner join endereco e on pe.id_endereco = e.id_endereco
--group by e.endereco_completo, pr.cod_produto_rel, cf.cod_barra, lote

1.000.000

select * from endereco where id_def = 1 and nivel = 7

