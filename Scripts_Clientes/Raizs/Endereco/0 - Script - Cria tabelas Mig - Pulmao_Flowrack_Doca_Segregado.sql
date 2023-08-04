USE [WMSRX]
GO

/****** Object:  Table [dbo].[mig_doca]    Script Date: 15/03/2021 16:32:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DROP TABLE [dbo].[mig_doca]
GO

CREATE TABLE [dbo].[mig_doca](
	[classificacao] [nvarchar](255) NULL,
	[doca] [nvarchar](255) NULL,
	[conf] [nvarchar](255) NULL,
	[palete] [nvarchar](255) NULL,
	[endereco_completo] [nvarchar](255) NULL,
	[classificacao_endereco] [nvarchar](255) NULL,
	[tipo_de_acesso] [nvarchar](255) NULL,
	[tipo_volume] [nvarchar](255) NULL,
	[tipo_de_armazenamento] [nvarchar](255) NULL,
	[setor] [nvarchar](255) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[mig_flowrack]    Script Date: 15/03/2021 16:32:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DROP TABLE [mig_flowrack]
GO

CREATE TABLE [dbo].[mig_flowrack](
	--[OL] [nvarchar](255) NULL,
	[classificacao] [nvarchar](255) NULL,
	[linha] [nvarchar](255) NULL,
	[rua] [nvarchar](255) NULL,
	--[separador1] [nvarchar](255) NULL,
	--[tipo] [nvarchar](255) NULL,
	--[separador2] [nvarchar](255) NULL,
	--[predio] [nvarchar](255) NULL,
	--[separador3] [nvarchar](255) NULL,
	--[nivel] [nvarchar](255) NULL,
	--[separador4] [nvarchar](255) NULL,
	[posicao] [nvarchar](255) NULL,
	[endereco_completo] [nvarchar](255) NULL,
	[classificacao_endereco] [nvarchar](255) NULL,
	[tipo_de_acesso] [nvarchar](255) NULL,
	[tipo_volume] [nvarchar](255) NULL,
	[tipo_de_armazenamento] [nvarchar](255) NULL,
	[setor] [nvarchar](255) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[mig_pulmao]    Script Date: 15/03/2021 16:32:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DROP TABLE [dbo].[mig_pulmao]
GO

CREATE TABLE [dbo].[mig_pulmao](
	[classificacao] [nvarchar](255) NULL,
	--[linha] [nvarchar](255) NULL,
	[rua] [nvarchar](255) NULL,
	[predio] [nvarchar](255) NULL,
	[nivel] [nvarchar](255) NULL,
	[posicao] [nvarchar](255) NULL,
	[endereco_completo] [nvarchar](255) NULL,
	[classificacao_endereco] [nvarchar](255) NULL,
	[tipo_de_acesso] [nvarchar](255) NULL,
	[tipo_volume] [nvarchar](255) NULL,
	[tipo_de_armazenamento] [nvarchar](255) NULL,
	[setor] [nvarchar](255) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[mig_segregado]    Script Date: 15/03/2021 16:32:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DROP TABLE [mig_segregado]
GO

CREATE TABLE [dbo].[mig_segregado](
	[classificacao] [nvarchar](255) NULL,
	setor [nvarchar](255) NULL,
	rua [nvarchar](255) NULL,
	predio [nvarchar](255) NULL,
	nivel [nvarchar](255) NULL,
	posicao [nvarchar](255) NULL,
	[endereco_completo] [nvarchar](255) NULL,
	[classificacao_endereco] [nvarchar](255) NULL,
	[tipo_de_acesso] [nvarchar](255) NULL,
	[tipo_volume] [nvarchar](255) NULL,
	[tipo_de_armazenamento] [nvarchar](255) NULL,
	[setor2] [nvarchar](255) NULL
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[mig_kanban](
	[endereco] [nvarchar](255) NULL,
	[cod_produto] [nvarchar](255) NULL,
	[descricao] [nvarchar](255) NULL,
	[capacidade] [nvarchar](255) NULL,
	[qtd_endereco] [nvarchar](255) NULL,
	[minimo] [nvarchar](255) NULL,
	[maximo] [nvarchar](255) NULL,
	[multiplo] [nvarchar](255) NULL,
	[ean] [nvarchar](255) NULL
) ON [PRIMARY]
GO


SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[mig_kit](
	[cod_produto] [nvarchar](255) NULL,
	[cod_produto_filho] [nvarchar](255) NULL,
	[cod_agrupador] [nvarchar](255) NULL,
	[numero_volume] [nvarchar](255) NULL	
) ON [PRIMARY]
GO