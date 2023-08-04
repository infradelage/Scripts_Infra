delete migraestoque
insert migraestoque
select e.endereco_completo, pr.cod_produto_rel, pr.cod_produto, 1000, Convert(SMALLDATETIME, getdate() + 360, 103), 
 Convert(SMALLDATETIME, getdate() - 30, 6), 'UNICO'
from endereco e
inner join produto_endereco pe on e.id_endereco = pe.id_endereco
inner join produto_relacionado pr on pe.cod_produto = pr.cod_produto

/****** Object:  Table [dbo].[mig_doca]    Script Date: 15/03/2021 16:32:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[migraestoque](
	[endereco_completo] [nvarchar](255) NULL,
	[cod_produto_rel] [nvarchar](255) NULL,
	[cod_produto] [nvarchar](255) NULL,
	[saldo] [nvarchar](255) NULL,
	[dtvalidade] [nvarchar](255) NULL,
	[dtfabricacao] [nvarchar](255) NULL,
	[lote] [nvarchar](255) NULL,
	) ON [PRIMARY]
GO




