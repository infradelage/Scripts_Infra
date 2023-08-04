/****** Object:  Table [dbo].[mig_doca]    Script Date: 15/03/2021 16:32:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DROP TABLE mig_estoque

CREATE TABLE [dbo].mig_estoque(
endereco [nvarchar](255) NULL,
cod_prod_sku [nvarchar](255) NULL,
cod_barra  [nvarchar](255) NULL,
descricao [nvarchar](255) NULL,
estoque [nvarchar](255) NULL,
dt_validade	 [nvarchar](255) NULL,
dt_fabricacao	 [nvarchar](255) NULL,
lote [nvarchar](255) NULL

) ON [PRIMARY]
GO