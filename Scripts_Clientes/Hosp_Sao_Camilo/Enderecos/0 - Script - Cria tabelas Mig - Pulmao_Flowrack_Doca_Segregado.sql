
/****** Object:  Table [dbo].[mig_doca]    Script Date: 15/03/2021 16:32:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DROP TABLE [mig_doca]

CREATE TABLE [dbo].[mig_doca](
	[classificacao] [nvarchar](255) NULL,
	[ol] [nvarchar](255) NULL,
	--[separador1] [nvarchar](255) NULL,
	[doca] [nvarchar](255) NULL,	
	--[separador2] [nvarchar](255) NULL,
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
	[classificacao] [nvarchar](255) NULL,
	[ol] [nvarchar](255) NULL,
	[setor] [nvarchar](255) NULL,
	[rua] [nvarchar](255) NULL,
	[lado] [nvarchar](255) NULL,
	[predio] [nvarchar](255) NULL,
	[nivel] [nvarchar](255) NULL,
	[endereco_completo] [nvarchar](255) NULL,
	[classificacao_endereco] [nvarchar](255) NULL,
	[tipo_de_acesso] [nvarchar](255) NULL,
	[tipo_volume] [nvarchar](255) NULL,
	[tipo_de_armazenamento] [nvarchar](255) NULL,
	--[setor1] [nvarchar](255) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[mig_pulmao]    Script Date: 15/03/2021 16:32:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DROP TABLE [mig_pulmao]
GO

CREATE TABLE [dbo].[mig_pulmao](
	[classificacao] [nvarchar](255) NULL,
	[ol] [nvarchar](255) NULL,
	[setor] [nvarchar](255) NULL,
	[rua] [nvarchar](255) NULL,	
	[lado] [nvarchar](255) NULL,	
	[predio] [nvarchar](255) NULL,
	[nivel] [nvarchar](255) NULL,
	--[posicao] [nvarchar](255) NULL,
	[endereco_completo] [nvarchar](255) NULL,
	[classificacao_endereco] [nvarchar](255) NULL,
	[tipo_de_acesso] [nvarchar](255) NULL,
	[tipo_volume] [nvarchar](255) NULL,
	[tipo_de_armazenamento] [nvarchar](255) NULL,
	--[setor] [nvarchar](255) NULL
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
	[ol] [nvarchar](255) NULL,
	[setor] [nvarchar](255) NULL,
	[rua] [nvarchar](255) NULL,	
	--[lado] [nvarchar](255) NULL,	
	--[predio] [nvarchar](255) NULL,
	--[nivel] [nvarchar](255) NULL,
	--[posicao] [nvarchar](255) NULL,
	[endereco_completo] [nvarchar](255) NULL,
	[classificacao_endereco] [nvarchar](255) NULL,
	[tipo_de_acesso] [nvarchar](255) NULL,
	[tipo_volume] [nvarchar](255) NULL,
	[tipo_de_armazenamento] [nvarchar](255) NULL,
	--[setor] [nvarchar](255) NULL
) ON [PRIMARY]
GO


CREATE TABLE [dbo].[mig_box](
	[classificacao] [nvarchar](255) NULL,
	[linha] [nvarchar](255) NULL,
	[rua] [nvarchar](255) NULL,	
	[endereco_completo] [nvarchar](255) NULL,		
	[classificacao_endereco] [nvarchar](255) NULL,
	[tipo_de_acesso] [nvarchar](255) NULL,
	[tipo_volume] [nvarchar](255) NULL,
	[tipo_de_armazenamento] [nvarchar](255) NULL,	
	[setor] [nvarchar](255) NULL
) ON [PRIMARY]
GO