--------------------------------------------------------
--  DDL for Package Body G_ERROR_LOG_NEW
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY G_ERROR_LOG_NEW AS
 /**
  * @author: Carrasco Marcelo
  * @date: 14/02/2016
  * @comment: Procedure para insertar las excepciones ocurridas durante la ejecuci?n de procedures y/o fucntions;
  */
  procedure P_LOG_ERROR(P_OBJETO in varchar,
                        P_SQL_CODE in number,
                        P_SQL_ERRM IN VARCHAR2,
                        P_COMENTARIO IN VARCHAR2)as
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO ERROR_LOG_NEW (OBJETO,SQL_CODE,SQL_ERRM,COMENTARIO)
    VALUES (P_OBJETO,P_SQL_CODE,P_SQL_ERRM,P_COMENTARIO);
    commit;
  END P_LOG_ERROR;
  
  PROCEDURE clean_up (p_fecha IN VARCHAR2 DEFAULT SYSDATE) AS
    v_fecha varchar2(10 char) := to_char(sysdate -1,'dd.mm.yyyy');
  BEGIN
    IF P_FECHA IS NOT NULL THEN
      v_fecha := P_FECHA;
    END IF;
    DELETE FROM ERROR_LOG_NEW WHERE to_char(FECHA,'dd.mm.yyyy') <= v_fecha;
    COMMIT;
  end;
end g_error_log_new;

/
