IF NOT EXISTS (SELECT 1 FROM SYSCOLUMNS (NOLOCK) 
               WHERE name = 'bloqueia_digitacao_reabastecimento_RFCE' 
                     AND id = (SELECT id FROM SYSOBJECTS (NOLOCK) 
                               WHERE type = 'U' 
                                     AND name = 'param_estoque')) 
BEGIN 
   ALTER TABLE param_estoque ADD 
      bloqueia_digitacao_reabastecimento_RFCE BIT NOT NULL DEFAULT 0
END