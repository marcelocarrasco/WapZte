CREATE OR REPLACE PACKAGE G_MOBILEUM_ASP AS 

  /**
  * Author: Carrasco Marcelo
  * Date: 15/06/2016
  * Comment: Contiene los procedimientos y funciones necesrios para la carga y sumarizaciones involucradas
  */ 
  
  /**
  * Constant: limit_in, numero máximo de filas por iteracion en los bulk collect.
  */
  limit_in    pls_integer := 100;
  
  /**
  * Constant: limit_prom, cantidad de valores promedio a tomar en cuenta para calcular IBHW (Isab).
  */
  limit_prom  pls_integer := 3;
  /**
  * Comment: Calcula la sumarización de los contadores a nivel de día y los guarda en la tabla MOBILEUM_ASP_DAY.
  * Param: P_FECHA fecha para hacer la sumarización.
  */
  PROCEDURE P_MOBILEUM_ASP_DAY(P_FECHA IN VARCHAR2);
  
  /**
  * Comment: calcula la Busy Hour (BH) y los guarda en la tabla MOBILEUM_ASP_BH
  * Param: P_FECHA fecha para calcular la BH.
  */
  PROCEDURE P_MOBILEUM_ASP_BH(P_FECHA IN VARCHAR2);
  
   /**
  * Comment: calcula la Busy Hour (BH) y los guarda en la tabla MOBILEUM_ASP_BH
  * Param: P_FECHA fecha para calcular la BH.
  */
  PROCEDURE P_MOBILEUM_ASP_IBHW(P_FECHA_DOMINGO IN VARCHAR2,P_FECHA_SABADO IN VARCHAR2);
  
  /**
  * Comment: Procedimiento para calcular las sumarizaciones una vez importados los datos a la tabla RAW.
  * Param: P_FECHA, fecha para la cual calcular las sumarizaciones, usualmente, hace referencia al dia anterior, no el
  * actual.
  */
  PROCEDURE P_CALCULAR_SUMARIZACIONES_MOB(P_FECHA IN VARCHAR2);
  
END G_MOBILEUM_ASP;
/


CREATE OR REPLACE PACKAGE BODY G_MOBILEUM_ASP AS

  PROCEDURE P_MOBILEUM_ASP_DAY(P_FECHA IN VARCHAR2) AS
    --
    TYPE t_mobileum_asp_tab IS TABLE OF MOBILEUM_ASP_DAY%ROWTYPE;
    v_mobileum_asp_tab t_mobileum_asp_tab;
    --
    l_errors NUMBER;
    l_errno  NUMBER;
    l_msg    VARCHAR2(4000 CHAR);
    l_idx    NUMBER;
    --
    CURSOR cur (P_FECHA VARCHAR2) IS
    SELECT  PAIS,
            trunc(FECHA)                                      FECHA,
            round(NVL(AVG(CNT_LLAMADAS),0),2)                 CNT_LLAMADAS,
            round(NVL(AVG(CNT_POLITICA_RESTRICCION),0),2)     CNT_POLITICA_RESTRICCION,
            round(NVL(AVG(CNT_BOLQ_REL_TIPO_GEST),0),2)       CNT_BOLQ_REL_TIPO_GEST,
            round(NVL(AVG(CNT_BLOQ_RAN_REL),0),2)             CNT_BLOQ_RAN_REL,
            round(NVL(AVG(CNT_PERMITIERON_CONTINUAR),0),2)    CNT_PERMITIERON_CONTINUAR,
            round(NVL(AVG(CNT_CONECTADAS_VOICE_MAIL),0),2)    CNT_CONECTADAS_VOICE_MAIL,
            round(NVL(AVG(CNT_CONECTADA_ANUNCIO_SWITCH),0),2) CNT_CONECTADA_ANUNCIO_SWITCH
    FROM  MOBILEUM_ASP_HOUR
    WHERE trunc(FECHA) = TO_DATE(P_FECHA,'DD.MM.YYYY')
    GROUP BY PAIS,trunc(FECHA);
    --
  BEGIN
    OPEN cur(P_FECHA);
    LOOP
      FETCH cur BULK COLLECT INTO v_mobileum_asp_tab LIMIT limit_in;
      BEGIN
        FORALL indice IN INDICES OF v_mobileum_asp_tab
          INSERT INTO MOBILEUM_ASP_DAY
          VALUES v_mobileum_asp_tab(indice);
        
        EXCEPTION
          WHEN OTHERS THEN
            L_ERRORS := SQL%BULK_EXCEPTIONS.COUNT;
            FOR indice IN 1 .. L_ERRORS
            LOOP
              L_ERRNO := SQL%BULK_EXCEPTIONS(indice).ERROR_CODE;
              L_MSG   := SQLERRM(-L_ERRNO);
              L_IDX   := SQL%BULK_EXCEPTIONS(indice).ERROR_INDEX;
              --
              g_error_log_new.P_LOG_ERROR('P_MOBILEUM_ASP_DAY',
                                          L_ERRNO,
                                          L_MSG,
                                          'FECHA => '                         ||v_mobileum_asp_tab(L_IDX).FECHA||
                                          ' PAIS => '                         ||v_mobileum_asp_tab(L_IDX).PAIS||
                                          ' CNT_LLAMADAS => '                 ||to_char(v_mobileum_asp_tab(L_IDX).CNT_LLAMADAS)||
                                          ' CNT_POLITICA_RESTRICCION => '     ||to_char(v_mobileum_asp_tab(L_IDX).CNT_POLITICA_RESTRICCION)||
                                          ' CNT_BOLQ_REL_TIPO_GEST => '       ||to_char(v_mobileum_asp_tab(L_IDX).CNT_BOLQ_REL_TIPO_GEST)||
                                          ' CNT_BLOQ_RAN_REL => '             ||to_char(v_mobileum_asp_tab(L_IDX).CNT_BLOQ_RAN_REL)||
                                          ' CNT_PERMITIERON_CONTINUAR => '    ||to_char(v_mobileum_asp_tab(L_IDX).CNT_PERMITIERON_CONTINUAR)||
                                          ' CNT_CONECTADAS_VOICE_MAIL => '    ||to_char(v_mobileum_asp_tab(L_IDX).CNT_CONECTADAS_VOICE_MAIL)||
                                          ' CNT_CONECTADA_ANUNCIO_SWITCH => ' ||to_char(v_mobileum_asp_tab(L_IDX).CNT_CONECTADA_ANUNCIO_SWITCH));
            END LOOP;
      END;
      EXIT WHEN cur%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE cur;
    
    EXCEPTION
      WHEN OTHERS THEN
        g_error_log_new.P_LOG_ERROR('P_MOBILEUM_ASP_DAY',
                                    SQLCODE,
                                    SQLERRM,
                                    'Fallo al insertar los datos');
  END P_MOBILEUM_ASP_DAY;

  PROCEDURE P_MOBILEUM_ASP_BH(P_FECHA IN VARCHAR2) AS
  --
    CURSOR cur(P_FECHA VARCHAR2) IS
    SELECT  PAIS,
            FECHA,
            CNT_LLAMADAS,
            CNT_POLITICA_RESTRICCION,
            CNT_BOLQ_REL_TIPO_GEST,
            CNT_BLOQ_RAN_REL,
            CNT_PERMITIERON_CONTINUAR,
            CNT_CONECTADAS_VOICE_MAIL,
            CNT_CONECTADA_ANUNCIO_SWITCH
    FROM  (
          SELECT  PAIS,
                  to_char(FECHA,'dd.mm.yyyy HH24:MI') FECHA,
                  CNT_LLAMADAS,
                  CNT_POLITICA_RESTRICCION,
                  CNT_BOLQ_REL_TIPO_GEST,
                  CNT_BLOQ_RAN_REL,
                  CNT_PERMITIERON_CONTINUAR,
                  CNT_CONECTADAS_VOICE_MAIL,
                  CNT_CONECTADA_ANUNCIO_SWITCH,                 
                  ROW_NUMBER()  OVER (PARTITION BY  PAIS,
                                                    TRUNC(FECHA,'DAY')
                                ORDER BY trunc(FECHA) DESC,
                                         PAIS DESC, 
                                         CNT_LLAMADAS DESC NULLS LAST) SEQNUM
                FROM MOBILEUM_ASP_HOUR
                WHERE trunc(FECHA) = TO_DATE(P_FECHA,'dd.mm.yyyy')
        )
        WHERE SEQNUM = 1;
    --
    TYPE t_mobileum_asp_tab IS TABLE OF MOBILEUM_ASP_BH%ROWTYPE;
    v_mobileum_asp_tab t_mobileum_asp_tab;
    --
    l_errors number;
    l_errno  number;
    l_msg    VARCHAR2(4000 CHAR);
    l_idx    number;
    --
  BEGIN
    execute immediate 'alter session set nls_date_format = ''DD.MM.YYYY HH24:MI:SS''';
    OPEN cur(P_FECHA);
    LOOP
      FETCH cur BULK COLLECT INTO v_mobileum_asp_tab LIMIT limit_in;
      BEGIN
        FORALL indice IN INDICES OF v_mobileum_asp_tab
          INSERT INTO MOBILEUM_ASP_BH
          VALUES v_mobileum_asp_tab(indice);
        
        EXCEPTION
          WHEN OTHERS THEN
            L_ERRORS := SQL%BULK_EXCEPTIONS.COUNT;
            FOR indice IN 1 .. L_ERRORS
            LOOP
              L_ERRNO := SQL%BULK_EXCEPTIONS(indice).ERROR_CODE;
              L_MSG   := SQLERRM(-L_ERRNO);
              L_IDX   := SQL%BULK_EXCEPTIONS(indice).ERROR_INDEX;
              --
              g_error_log_new.P_LOG_ERROR('P_MOBILEUM_ASP_BH',
                                          L_ERRNO,
                                          L_MSG,
                                          'FECHA => '                         ||v_mobileum_asp_tab(L_IDX).FECHA||
                                          ' PAIS => '                         ||v_mobileum_asp_tab(L_IDX).PAIS||
                                          ' CNT_LLAMADAS => '                 ||to_char(v_mobileum_asp_tab(L_IDX).CNT_LLAMADAS)||
                                          ' CNT_POLITICA_RESTRICCION => '     ||to_char(v_mobileum_asp_tab(L_IDX).CNT_POLITICA_RESTRICCION)||
                                          ' CNT_BOLQ_REL_TIPO_GEST => '       ||to_char(v_mobileum_asp_tab(L_IDX).CNT_BOLQ_REL_TIPO_GEST)||
                                          ' CNT_BLOQ_RAN_REL => '             ||to_char(v_mobileum_asp_tab(L_IDX).CNT_BLOQ_RAN_REL)||
                                          ' CNT_PERMITIERON_CONTINUAR => '    ||to_char(v_mobileum_asp_tab(L_IDX).CNT_PERMITIERON_CONTINUAR)||
                                          ' CNT_CONECTADAS_VOICE_MAIL => '    ||to_char(v_mobileum_asp_tab(L_IDX).CNT_CONECTADAS_VOICE_MAIL)||
                                          ' CNT_CONECTADA_ANUNCIO_SWITCH => ' ||to_char(v_mobileum_asp_tab(L_IDX).CNT_CONECTADA_ANUNCIO_SWITCH));
            END LOOP;
      END;
      EXIT WHEN cur%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE cur;
    
    EXCEPTION
      WHEN OTHERS THEN
        g_error_log_new.P_LOG_ERROR('P_MOBILEUM_ASP_BH',
                                    SQLCODE,
                                    SQLERRM,
                                    'Fallo al abrir el cursor');
  END P_MOBILEUM_ASP_BH;

  PROCEDURE P_MOBILEUM_ASP_IBHW(P_FECHA_DOMINGO IN VARCHAR2,P_FECHA_SABADO IN VARCHAR2) AS
    --
    CURSOR cur(fecha_desde varchar2, fecha_hasta varchar2) IS
    SELECT  PAIS,
            fecha_desde FECHA,
            round(NVL(AVG(CNT_LLAMADAS),0),2) CNT_LLAMADAS,
            round(NVL(AVG(CNT_POLITICA_RESTRICCION),0),2) CNT_POLITICA_RESTRICCION,
            round(NVL(AVG(CNT_BOLQ_REL_TIPO_GEST),0),2) CNT_BOLQ_REL_TIPO_GEST,
            round(NVL(AVG(CNT_BLOQ_RAN_REL),0),2) CNT_BLOQ_RAN_REL,
            round(NVL(AVG(CNT_PERMITIERON_CONTINUAR),0),2) CNT_PERMITIERON_CONTINUAR,
            round(NVL(AVG(CNT_CONECTADAS_VOICE_MAIL),0),2) CNT_CONECTADAS_VOICE_MAIL,
            round(NVL(AVG(CNT_CONECTADA_ANUNCIO_SWITCH),0),2)  CNT_CONECTADA_ANUNCIO_SWITCH
    FROM (
          SELECT  PAIS,
                  to_char(FECHA,'dd.mm.yyyy HH24:MI') FECHA,
                  CNT_LLAMADAS,
                  CNT_POLITICA_RESTRICCION,
                  CNT_BOLQ_REL_TIPO_GEST,
                  CNT_BLOQ_RAN_REL,
                  CNT_PERMITIERON_CONTINUAR,
                  CNT_CONECTADAS_VOICE_MAIL,
                  CNT_CONECTADA_ANUNCIO_SWITCH,                 
                  ROW_NUMBER()  OVER (PARTITION BY  PAIS,
                                                    TRUNC(FECHA,'DAY')
                                ORDER BY --trunc(FECHA) DESC,
                                         PAIS DESC, 
                                         CNT_LLAMADAS DESC NULLS LAST) SEQNUM
                FROM MOBILEUM_ASP_BH
                WHERE TRUNC(fecha) BETWEEN to_date(fecha_desde,'dd.mm.yyyy') AND to_date(fecha_hasta,'dd.mm.yyyy'))
    where SEQNUM <= LIMIT_PROM
    --AND TRUNC(fecha) BETWEEN to_date(fecha_desde,'dd.mm.yyyy') AND to_date(fecha_hasta,'dd.mm.yyyy')
    GROUP BY PAIS; --,fecha;
    --
    l_errors number;
    l_errno  number;
    l_msg    varchar2(4000);
    l_idx    number;
    --
    TYPE t_mobileum_asp_ibhw_row IS TABLE OF MOBILEUM_ASP_IBHW%rowtype;
    v_mobileum_asp_ibhw_tab t_mobileum_asp_ibhw_row;
    --
  BEGIN
  OPEN cur(P_FECHA_DOMINGO,P_FECHA_SABADO);
    LOOP
      FETCH cur bulk collect into v_mobileum_asp_ibhw_tab limit limit_in;
      BEGIN
        FORALL indice IN 1 .. v_mobileum_asp_ibhw_tab.COUNT SAVE EXCEPTIONS
          INSERT INTO MOBILEUM_ASP_IBHW values v_mobileum_asp_ibhw_tab(indice);
        EXCEPTION
          WHEN OTHERS THEN
            L_ERRORS := SQL%BULK_EXCEPTIONS.COUNT;
            FOR indice IN 1 .. L_ERRORS
            LOOP
                L_ERRNO := SQL%BULK_EXCEPTIONS(indice).ERROR_CODE;
                L_MSG   := SQLERRM(-L_ERRNO);
                L_IDX   := SQL%BULK_EXCEPTIONS(indice).ERROR_INDEX;
                --
                G_ERROR_LOG_NEW.P_LOG_ERROR('P_MOBILEUM_ASP_IBHW',
                                            l_errno,
                                            l_msg,
                                            'FECHA => '                         ||v_mobileum_asp_ibhw_tab(L_IDX).FECHA||
                                            ' PAIS => '                         ||v_mobileum_asp_ibhw_tab(L_IDX).PAIS||
                                            ' CNT_LLAMADAS => '                 ||to_char(v_mobileum_asp_ibhw_tab(L_IDX).CNT_LLAMADAS)||
                                            ' CNT_POLITICA_RESTRICCION => '     ||to_char(v_mobileum_asp_ibhw_tab(L_IDX).CNT_POLITICA_RESTRICCION)||
                                            ' CNT_BOLQ_REL_TIPO_GEST => '       ||to_char(v_mobileum_asp_ibhw_tab(L_IDX).CNT_BOLQ_REL_TIPO_GEST)||
                                            ' CNT_BLOQ_RAN_REL => '             ||to_char(v_mobileum_asp_ibhw_tab(L_IDX).CNT_BLOQ_RAN_REL)||
                                            ' CNT_PERMITIERON_CONTINUAR => '    ||to_char(v_mobileum_asp_ibhw_tab(L_IDX).CNT_PERMITIERON_CONTINUAR)||
                                            ' CNT_CONECTADAS_VOICE_MAIL => '    ||to_char(v_mobileum_asp_ibhw_tab(L_IDX).CNT_CONECTADAS_VOICE_MAIL)||
                                            ' CNT_CONECTADA_ANUNCIO_SWITCH => ' ||to_char(v_mobileum_asp_ibhw_tab(L_IDX).CNT_CONECTADA_ANUNCIO_SWITCH));
            END LOOP;
      END;
      EXIT WHEN cur%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE cur;
    --
    EXCEPTION
      WHEN others THEN
        G_ERROR_LOG_NEW.P_LOG_ERROR('P_MOBILEUM_ASP_IBHW',
                                    SQLCODE,
                                    SQLERRM,
                                    'P_FECHA_DOMINGO '||P_FECHA_DOMINGO||' P_FECHA_SABADO => '||P_FECHA_SABADO);
  END P_MOBILEUM_ASP_IBHW;

  PROCEDURE P_CALCULAR_SUMARIZACIONES_MOB(P_FECHA IN VARCHAR2) AS
    v_dia VARCHAR2(10 CHAR) := '';
  BEGIN
    --
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_MOBILEUM_ASP_DAY',0,'NO ERROR','COMIENZO DE SUMARIZACION DAY P_MOBILEUM_ASP_DAY('||P_FECHA||')');
    P_MOBILEUM_ASP_DAY(P_FECHA);
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_MOBILEUM_ASP_DAY',0,'NO ERROR','FIN DE SUMARIZACION DAY');
    --
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_MOBILEUM_ASP_BH',0,'NO ERROR','COMIENZO CALCULO BH P_MOBILEUM_ASP_BH('||P_FECHA||')');
    P_MOBILEUM_ASP_BH(P_FECHA);
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_MOBILEUM_ASP_BH',0,'NO ERROR','FIN CALCULO BH');
    --
    -- Si el dia actual es DOMINGO, entonces calcular sumarizacion IBHW de la semana anterior,
    -- siempre de domingo a sabado
    --
    SELECT TO_CHAR(TO_DATE(P_FECHA,'DD.MM.YYYY'),'DAY')
    INTO V_DIA
    FROM DUAL;
    
    IF (TRIM(V_DIA) = 'SUNDAY') OR (TRIM(V_DIA) = 'DOMINGO') THEN
      G_ERROR_LOG_NEW.P_LOG_ERROR('P_MOBILEUM_ASP_IBHW',0,'NO ERROR','COMIENZO DE SUMARIZACION IBHW P_FECHA_DOMINGO => '||
                                  to_char(to_date(P_FECHA,'DD.MM.YYYY')-7,'DD.MM.YYYY')||
                                  ' P_FECHA_SABADO => '||TO_CHAR(TO_DATE(P_FECHA,'DD.MM.YYYY')-1,'DD.MM.YYYY'));
      --
      P_MOBILEUM_ASP_IBHW(to_char(to_date(P_FECHA,'DD.MM.YYYY')-7,'DD.MM.YYYY'),TO_CHAR(TO_DATE(P_FECHA,'DD.MM.YYYY')-1,'DD.MM.YYYY'));
      --
      G_ERROR_LOG_NEW.P_LOG_ERROR('P_MOBILEUM_ASP_IBHW',0,'NO ERROR','FIN DE SUMARIZACION IBHW');
    END IF;
  END P_CALCULAR_SUMARIZACIONES_MOB;

END G_MOBILEUM_ASP;
/
