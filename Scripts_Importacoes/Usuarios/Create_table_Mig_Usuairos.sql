USE [WMSRX]
GO

/****** Object:  Table [dbo].[mig_usuarios]    Script Date: 03/06/2022 12:13:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mig_usuarios]') AND type in (N'U'))
DROP TABLE [dbo].[mig_usuarios]
GO


/****** Object:  Table [dbo].[mig_usuarios]    Script Date: 03/06/2022 12:13:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[mig_usuarios](
	[nome] [nvarchar](255) NULL,
	[login] [nvarchar](255) NULL,
	[funcao] [nvarchar](255) NULL,
	[tipo] [nvarchar](255) NULL,
	[subtipo] [nvarchar](255) NULL,
	[tipo_pessoa] [nvarchar](255) NULL,
	[grupo] [nvarchar](255) NULL
) ON [PRIMARY]
GO


