/****** Object:  Table [dbo].[mig_kanban]    Script Date: 3/14/2023 9:33:27 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mig_kanban]') AND type in (N'U'))
DROP TABLE [dbo].[mig_kanban]
GO
/****** Object:  Table [dbo].[mig_kanban]    Script Date: 3/14/2023 9:33:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[mig_kanban](
	[endereco_completo] [nvarchar](255) NULL,
	[cod_sku] [nvarchar](255) NULL,
	[descricao] [nvarchar](255) NULL,
	[capacidade_p_caixa_bin] [nvarchar](255) NULL,
	[caixas_bin_endereco] [nvarchar](255) NULL,
	[minimo] [nvarchar](255) NULL,
	[maximo] [nvarchar](255) NULL,
	[multiplo] [nvarchar](255) NULL
) ON [PRIMARY]
GO