SELECT * FROM REPORTING_SERVICES

UPDATE REPORTING_SERVICES SET
WebService = 'http://192.168.2.136/reportserver/ReportService2005.asmx?wsdl',
RenderReport = 'http://192.168.2.136/reportserver/',
ListReport = 'http://192.168.2.136/Teste/RSDisbby/Paginas/ReportViewer2012.aspx',
RenderReportManual = 'http://192.168.2.136/Teste/RSDisbby/Paginas/ReportViewer2012.aspx?Menu=false&report=',
usuario = 'USUARIO_SERVIÇO',
senha = 'SENHA_USUARIO_SERVIÇO',
dominio = 'hypofarma.mg.com.br',
versao_rs = '2008'

