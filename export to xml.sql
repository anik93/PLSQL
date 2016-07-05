CREATE DIRECTORY xt_dir AS 'c:\temp';
DECLARE
 rc sys_refcursor;
BEGIN
 OPEN rc FOR SELECT * FROM osoby;
 dbms_xslprocessor.clob2file( xmltype( rc ).getclobval( ) , 'XT_DIR','clob2file.xml');
END; 

DECLARE
 l_xmltype XMLTYPE;
 l_ctx dbms_xmlgen.ctxhandle;
BEGIN
 l_ctx := dbms_xmlgen.newcontext('SELECT *
                                  FROM osoby');
 dbms_xmlgen.setrowsettag(l_ctx, 'Tabela_osoby');                              
 dbms_xmlgen.setrowtag(l_ctx, 'Osoba');
 l_xmltype := dbms_xmlgen.getXmlType(l_ctx) ;
 dbms_xmlgen.closeContext(l_ctx);
 dbms_xslprocessor.clob2file( l_xmltype.getclobval( ) , 'XT_DIR','test.xml');
END;