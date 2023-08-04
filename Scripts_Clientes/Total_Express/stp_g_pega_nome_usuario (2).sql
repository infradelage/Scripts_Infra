/****** Object:  StoredProcedure [dbo].[stp_G_pega_nome_usuario]    Script Date: 12/04/2019 14:42:42 ******/ 

SET ANSI_NULLS ON 

GO 

 

SET QUOTED_IDENTIFIER ON 

GO 

 

CREATE PROCEDURE [dbo].[stp_G_pega_nome_usuario] 

AS 

 

SELECT nt_username 

  FROM master..sysprocesses 

 WHERE spid = @@spid 

 

 

GO 