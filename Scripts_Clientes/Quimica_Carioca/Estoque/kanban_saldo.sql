USE [WMSRXDaki]
GO

/****** Object:  Table [dbo].[kanban_saldo]    Script Date: 4/24/2023 4:29:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DROP TABLE [kanban_saldo]
GO

CREATE TABLE [dbo].[kanban_saldo](
	[cod_prod_delage] [nvarchar](255) NULL,
	--[descricao] [nvarchar](255) NULL,
	[cod_prod_daki] [nvarchar](255) NULL,
	[estoque] [nvarchar](255) NULL,
	[endereco_completo] [nvarchar](255) NULL,
	[minimo] [nvarchar](255) NULL,
	[maximo] [nvarchar](255) NULL,
	[fabricacao] [nvarchar](255) NULL,
	validade [nvarchar](255) NULL,
	lote [nvarchar](255) NULL,
	[multiplo] [nvarchar](255) NULL
) ON [PRIMARY]
GO


