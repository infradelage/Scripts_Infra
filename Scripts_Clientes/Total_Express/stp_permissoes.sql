

/***** Object:  StoredProcedure [dbo].[stp_permissoes]    Script Date: 12/04/2019 14:48:30 *****/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- taiany.coelho@2016-09-28 14:19:32: <auste pegar tipos uid = 1>
CREATE PROCEDURE [dbo].[stp_permissoes] AS
DECLARE @name char(100)
DECLARE @grupo char(100)
DECLARE crs_ContrItem CURSOR
   FOR SELECT name
       FROM sysobjects
       WHERE type in ('fn', 'p')
--         AND DATEDIFF(dd, crdate, getdate()) <= 2
DECLARE crs_grupos INSENSITIVE CURSOR FOR
  SELECT name
  FROM sysusers
  WHERE uid = gid --Grupos
    and name not like 'db_%'
OPEN crs_ContrItem
FETCH NEXT FROM crs_ContrItem INTO @name
BEGIN TRAN
   WHILE (@@FETCH_STATUS = 0)
      BEGIN
    OPEN crs_grupos
         FETCH NEXT FROM crs_grupos INTO @grupo
    WHILE (@@FETCH_STATUS = 0)
      BEGIN
        EXEC ('GRANT  EXECUTE  ON ' + @name+ ' TO ' + @grupo)
        FETCH NEXT FROM crs_grupos INTO @grupo
      END
         close crs_grupos
         FETCH NEXT FROM crs_ContrItem INTO @name
      END
COMMIT TRAN
DEALLOCATE crs_ContrItem
--TABELAS
DECLARE crs_ContrItem CURSOR
   FOR SELECT NAME
       FROM sysobjects
       WHERE type IN ('u', 'v')
       AND uid = 1
--       AND DATEDIFF(dd, crdate, getdate()) <= 2
OPEN crs_ContrItem
FETCH NEXT FROM crs_ContrItem INTO @name
BEGIN TRAN
   WHILE (@@FETCH_STATUS = 0)
      BEGIN
    OPEN crs_grupos
         FETCH NEXT FROM crs_grupos INTO @grupo
    WHILE (@@FETCH_STATUS = 0)
      BEGIN
        EXEC ('GRANT  SELECT ON ' + @name+ ' TO ' + @grupo)
      
   FETCH NEXT FROM crs_grupos INTO @grupo
      END
         close crs_grupos
         FETCH NEXT FROM crs_ContrItem INTO @name
      END
COMMIT TRAN
DEALLOCATE crs_ContrItem
DEALLOCATE crs_grupos

GO