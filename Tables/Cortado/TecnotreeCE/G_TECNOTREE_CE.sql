CREATE OR REPLACE PACKAGE G_TECNOTREE_CE AS 

  /**
  * Author: Carrasco Marcelo
  * Date: 01/07/2016
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
  *
  */
  PROCEDURE P_POPULAR_PLANTILLA(P_FECHA_INI IN VARCHAR2,P_RESULTADO OUT NUMBER);
  /**
  * Comment: Calcula la sumarización de los contadores a nivel de día y los guarda en la tabla TEC_CE_CDC_TPS_DAY.
  * Param: P_FECHA fecha para hacer la sumarización.
  */
  PROCEDURE P_TEC_CE_CDC_TPS_DAY(P_FECHA IN VARCHAR2);
  
  /**
  * Comment: calcula la Busy Hour (BH) y los guarda en la tabla TEC_CE_CDC_TPS_BH
  * Param: P_FECHA fecha para calcular la BH.
  */
  PROCEDURE P_TEC_CE_CDC_TPS_BH(P_FECHA IN VARCHAR2);
  
   /**
  * Comment: calcula la Busy Hour (BH) y los guarda en la tabla TEC_CE_CDC_TPS_IBHW
  * Param: P_FECHA fecha para calcular la BH.
  */
  PROCEDURE P_TEC_CE_CDC_TPS_IBHW(P_FECHA_DOMINGO IN VARCHAR2,P_FECHA_SABADO IN VARCHAR2);
  
  /**
  * Comment: Calcula la sumarización de los contadores a nivel de día y los guarda en la tabla TEC_CE_CM_TPS_DAY.
  * Param: P_FECHA fecha para hacer la sumarización.
  */
  PROCEDURE P_TEC_CE_CM_TPS_DAY(P_FECHA IN VARCHAR2);
  
  /**
  * Comment: calcula la Busy Hour (BH) y los guarda en la tabla TEC_CE_CM_TPS_BH
  * Param: P_FECHA fecha para calcular la BH.
  */
  PROCEDURE P_TEC_CE_CM_TPS_BH(P_FECHA IN VARCHAR2);
  
   /**
  * Comment: calcula la Busy Hour (BH) y los guarda en la tabla TEC_CE_CM_TPS_IBHW
  * Param: P_FECHA fecha para calcular la BH.
  */
  PROCEDURE P_TEC_CE_CM_TPS_IBHW(P_FECHA_DOMINGO IN VARCHAR2,P_FECHA_SABADO IN VARCHAR2);
  
  /**
  * Comment: Procedimiento para calcular las sumarizaciones una vez importados los datos a la tabla HOUR.
  * Param: P_FECHA, fecha para la cual calcular las sumarizaciones, usualmente, hace referencia al dia anterior, no el
  * actual.
  */
  PROCEDURE P_CALCULAR_SUM_TEC_CM_CDC(P_FECHA IN VARCHAR2);
 
END G_TECNOTREE_CE;



CREATE OR REPLACE PACKAGE BODY G_TECNOTREE_CE AS 
  
  /**
  * FORMATO ENTRADA FECHAS DD-MON-YYYY 00:00:00, ej. 06-JAN-2016 00:00:00
  */
  PROCEDURE P_POPULAR_PLANTILLA(P_FECHA_INI IN VARCHAR2,P_RESULTADO OUT NUMBER) AS
    V_START_DTIME VARCHAR2(20 CHAR) := P_FECHA_INI;
    V_END         VARCHAR2(20 CHAR) := '';
    MAX_TPS       NUMBER            := 0;
    START_DTIME   VARCHAR2(20 CHAR) := '';
    END_DTIME     VARCHAR2(20 CHAR) := '';
    ESTA          BOOLEAN           := FALSE;
  BEGIN
    -- Calcular fecha fin
    SELECT  TO_CHAR(TO_DATE(V_START_DTIME,'DD-MON-YYYY HH24:MI:SS')+1,'DD-MON-YYYY HH24:MI:SS')
    INTO    V_END
    FROM DUAL;
    --
    WHILE (v_start_dtime != v_end AND NOT ESTA) LOOP
    BEGIN
      SELECT  to_char(TO_DATE(v_start_dtime,'DD-MON-YYYY HH24:MI:SS'),'DD-MON-YYYY HH24:MI:SS') start_dtime,
              to_char(TO_DATE(v_start_dtime,'DD-MON-YYYY HH24:MI:SS')+INTERVAL '5' MINUTE,'DD-MON-YYYY HH24:MI:SS') END_DTIME
      INTO  start_dtime,
            end_dtime
      FROM dual;
      --
      INSERT INTO TEC_CE_CDC_TPS_AUX_TEMPLATE(start_dtime,END_DTIME,pais,max_tps,max_cap_hw,max_cap_sw)
      VALUES (START_DTIME,END_DTIME,'ARG',0,1,1);
      --
      INSERT INTO TEC_CE_CDC_TPS_AUX_TEMPLATE(start_dtime,END_DTIME,pais,max_tps,max_cap_hw,max_cap_sw)
      VALUES (START_DTIME,END_DTIME,'PRY',0,1,1);
      --
      INSERT INTO TEC_CE_CDC_TPS_AUX_TEMPLATE(start_dtime,END_DTIME,pais,max_tps,max_cap_hw,max_cap_sw)
      VALUES (START_DTIME,END_DTIME,'URY',0,1,1);
  
      v_start_dtime := end_dtime;
      EXCEPTION
        WHEN OTHERS THEN
          G_ERROR_LOG_NEW.P_LOG_ERROR('P_POPULAR_PLANTILLA',
                        0,
                        'ERROR',
                        'Error en la insercion de datos en la plantilla '||v_start_dtime||' '||v_end);
          P_RESULTADO := 1;
          ESTA := TRUE;
      --dbms_output.put_line(v_start_dtime||' '||end_dtime||' '||v_end);
    END;
    END LOOP;
    COMMIT;
    IF NOT ESTA THEN 
      P_RESULTADO := 0;   
    END IF;    
    
  END P_POPULAR_PLANTILLA;
  --
  PROCEDURE P_TEC_CE_CDC_TPS_DAY(P_FECHA IN VARCHAR2) IS
  --
    TYPE t_tec_ce_cdc_tps_day_tab IS TABLE OF TEC_CE_CDC_TPS_DAY%ROWTYPE;
    v_tec_ce_cdc_tps_day_tab t_tec_ce_cdc_tps_day_tab;
    --
    l_errors NUMBER;
    l_errno  NUMBER;
    l_msg    VARCHAR2(4000 CHAR);
    l_idx    NUMBER;
    --
    CURSOR cur (P_FECHA VARCHAR2) IS
    SELECT  trunc(FECHA)                  FECHA,
            PAIS,
            round(nvl(SUM(MAX_TPS),0),2)  MAX_TPS,
            MAX_CAP_HW,
            MAX_CAP_SW,
            round(nvl(AVG(UTIL_HW),0),2)  UTIL_HW,
            round(nvl(AVG(UTIL_SW),0),2)  UTIL_SW
    FROM  TEC_CE_CDC_TPS_HOUR
    WHERE trunc(FECHA) = TO_DATE(P_FECHA,'DD.MM.YYYY')
    GROUP BY trunc(FECHA),PAIS,MAX_CAP_HW,
            MAX_CAP_SW;
    --
  BEGIN
    OPEN cur(P_FECHA);
    LOOP
      FETCH cur BULK COLLECT INTO v_tec_ce_cdc_tps_day_tab LIMIT limit_in;
      BEGIN
        FORALL indice IN INDICES OF v_tec_ce_cdc_tps_day_tab
          INSERT INTO TEC_CE_CDC_TPS_DAY
          VALUES v_tec_ce_cdc_tps_day_tab(indice);
        
        EXCEPTION
          WHEN OTHERS THEN
            L_ERRORS := SQL%BULK_EXCEPTIONS.COUNT;
            FOR indice IN 1 .. L_ERRORS
            LOOP
              L_ERRNO := SQL%BULK_EXCEPTIONS(indice).ERROR_CODE;
              L_MSG   := SQLERRM(-L_ERRNO);
              L_IDX   := SQL%BULK_EXCEPTIONS(indice).ERROR_INDEX;
              --
              g_error_log_new.P_LOG_ERROR('P_TEC_CE_CDC_TPS_DAY',
                                          L_ERRNO,
                                          L_MSG,
                                          'FECHA => '       ||v_tec_ce_cdc_tps_day_tab(indice).FECHA||
                                          ' PAIS => '       ||v_tec_ce_cdc_tps_day_tab(indice).PAIS||
                                          ' MAX_TPS => '    ||to_char(v_tec_ce_cdc_tps_day_tab(indice).MAX_TPS)||
                                          ' MAX_CAP_HW => ' ||to_char(v_tec_ce_cdc_tps_day_tab(indice).MAX_CAP_HW)||
                                          ' MAX_CAP_SW => ' ||to_char(v_tec_ce_cdc_tps_day_tab(indice).MAX_CAP_SW)||
                                          ' UTIL_HW => '    ||to_char(v_tec_ce_cdc_tps_day_tab(indice).UTIL_HW)||
                                          ' UTIL_SW => '    ||to_char(v_tec_ce_cdc_tps_day_tab(indice).UTIL_SW)
                                          );
            END LOOP;
      END;
      EXIT WHEN cur%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE cur;
    
    EXCEPTION
      WHEN OTHERS THEN
        g_error_log_new.P_LOG_ERROR('P_TEC_CE_CDC_TPS_DAY',
                                    SQLCODE,
                                    SQLERRM,
                                    'Fallo al insertar los datos');
  END P_TEC_CE_CDC_TPS_DAY;
  --
  PROCEDURE P_TEC_CE_CDC_TPS_BH(P_FECHA IN VARCHAR2) AS
  --
    CURSOR cur(P_FECHA VARCHAR2) IS
    SELECT  FECHA,
            PAIS,
            MAX_TPS,
            MAX_CAP_HW,
            MAX_CAP_SW,
            UTIL_HW,
            UTIL_SW
    FROM  (
          SELECT  to_char(FECHA,'dd.mm.yyyy HH24:MI') FECHA,
                  PAIS,
                  MAX_TPS,
                  MAX_CAP_HW,
                  MAX_CAP_SW,
                  UTIL_HW,
                  UTIL_SW,                
                  ROW_NUMBER() OVER (PARTITION BY TRUNC(FECHA,'DAY'),
                                                 PAIS
                              ORDER BY trunc(FECHA) DESC,
                                       PAIS DESC,
                                       MAX_TPS DESC NULLS LAST) SEQNUM
                FROM TEC_CE_CDC_TPS_HOUR
                WHERE trunc(FECHA) = TO_DATE(P_FECHA,'DD.MM.YYYY')
        )
        WHERE SEQNUM = 1;
    --
    TYPE t_tec_ce_cdc_tps_tab IS TABLE OF TEC_CE_CDC_TPS_BH%ROWTYPE;
    v_tec_ce_cdc_tps_tab t_tec_ce_cdc_tps_tab;
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
      FETCH cur BULK COLLECT INTO v_tec_ce_cdc_tps_tab LIMIT limit_in;
      BEGIN
        FORALL indice IN INDICES OF v_tec_ce_cdc_tps_tab
          INSERT INTO TEC_CE_CDC_TPS_BH
          VALUES v_tec_ce_cdc_tps_tab(indice);
        
        EXCEPTION
          WHEN OTHERS THEN
            L_ERRORS := SQL%BULK_EXCEPTIONS.COUNT;
            FOR indice IN 1 .. L_ERRORS
            LOOP
              L_ERRNO := SQL%BULK_EXCEPTIONS(indice).ERROR_CODE;
              L_MSG   := SQLERRM(-L_ERRNO);
              L_IDX   := SQL%BULK_EXCEPTIONS(indice).ERROR_INDEX;
              --
              g_error_log_new.P_LOG_ERROR('P_TEC_CE_CDC_TPS_BH',
                                          L_ERRNO,
                                          L_MSG,
                                          'FECHA => '       ||v_tec_ce_cdc_tps_tab(L_IDX).FECHA||
                                          ' PAIS => '       ||v_tec_ce_cdc_tps_tab(L_IDX).PAIS||
                                          ' MAX_TPS => '    ||to_char(v_tec_ce_cdc_tps_tab(L_IDX).MAX_TPS)||
                                          ' MAX_CAP_HW => ' ||to_char(v_tec_ce_cdc_tps_tab(L_IDX).MAX_CAP_HW)||
                                          ' MAX_CAP_SW => ' ||to_char(v_tec_ce_cdc_tps_tab(L_IDX).MAX_CAP_SW)||
                                          ' UTIL_HW => '    ||to_char(v_tec_ce_cdc_tps_tab(L_IDX).UTIL_HW)||
                                          ' UTIL_SW => '    ||to_char(v_tec_ce_cdc_tps_tab(L_IDX).UTIL_SW)
                                          );
            
            END LOOP;
      END;
      EXIT WHEN cur%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE cur;
    
    EXCEPTION
      WHEN OTHERS THEN
        g_error_log_new.P_LOG_ERROR('P_TEC_CE_CDC_TPS_BH',
                                    SQLCODE,
                                    SQLERRM,
                                    'Fallo al abrir el cursor');
  END P_TEC_CE_CDC_TPS_BH;
  --
  PROCEDURE P_TEC_CE_CDC_TPS_IBHW(P_FECHA_DOMINGO IN VARCHAR2,P_FECHA_SABADO IN VARCHAR2)AS
  --
    CURSOR cur(fecha_desde varchar2, fecha_hasta varchar2) IS
    SELECT  fecha_desde FECHA,
            PAIS,
            round(NVL(AVG(MAX_TPS),0),2) MAX_TPS,
            MAX_CAP_HW,
            MAX_CAP_SW,
            round(NVL(AVG(UTIL_HW),0),2) UTIL_HW,
            round(NVL(AVG(UTIL_SW),0),2) UTIL_SW
    FROM (
          SELECT  to_char(FECHA,'DD.MM.YYYY HH24:MI') FECHA,
                  PAIS,
                  MAX_TPS,
                  MAX_CAP_HW,
                  MAX_CAP_SW,
                  UTIL_HW,
                  UTIL_SW,                
                  ROW_NUMBER() OVER (PARTITION BY TRUNC(FECHA,'DAY'),
                                                 PAIS
                              ORDER BY --trunc(FECHA) DESC,
                                       --PAIS DESC,
                                       MAX_TPS DESC NULLS LAST) SEQNUM
                FROM TEC_CE_CDC_TPS_BH
                WHERE trunc(fecha) BETWEEN TO_DATE(fecha_desde,'DD.MM.YYYY') AND TO_DATE(fecha_hasta,'DD.MM.YYYY'))
    where SEQNUM <= LIMIT_PROM
    --AND fecha BETWEEN to_date(fecha_desde,'DD.MM.YYYY') AND to_date(fecha_hasta,'DD.MM.YYYY')
    GROUP BY PAIS,MAX_CAP_HW,
            MAX_CAP_SW; --,fecha;
    --
    l_errors number;
    l_errno  number;
    l_msg    varchar2(4000);
    l_idx    number;
    --
    TYPE t_tec_ce_cdc_tps_ibhw_row IS TABLE OF TEC_CE_CDC_TPS_IBHW%rowtype;
    v_tec_ce_cdc_tps_ibhw_tab t_tec_ce_cdc_tps_ibhw_row;
    --
  BEGIN
  OPEN cur(P_FECHA_DOMINGO,P_FECHA_SABADO);
    LOOP
      FETCH cur bulk collect into v_tec_ce_cdc_tps_ibhw_tab limit limit_in;
      BEGIN
        FORALL indice IN 1 .. v_tec_ce_cdc_tps_ibhw_tab.COUNT SAVE EXCEPTIONS
          INSERT INTO TEC_CE_CDC_TPS_IBHW values v_tec_ce_cdc_tps_ibhw_tab(indice);
        EXCEPTION
          WHEN OTHERS THEN
            L_ERRORS := SQL%BULK_EXCEPTIONS.COUNT;
            FOR indice IN 1 .. L_ERRORS
            LOOP
                L_ERRNO := SQL%BULK_EXCEPTIONS(indice).ERROR_CODE;
                L_MSG   := SQLERRM(-L_ERRNO);
                L_IDX   := SQL%BULK_EXCEPTIONS(indice).ERROR_INDEX;
                --
                G_ERROR_LOG_NEW.P_LOG_ERROR('P_TEC_CE_CDC_TPS_IBHW',
                                            l_errno,
                                            l_msg,
                                            'FECHA => '       ||v_tec_ce_cdc_tps_ibhw_tab(L_IDX).FECHA||
                                            ' PAIS => '       ||v_tec_ce_cdc_tps_ibhw_tab(L_IDX).PAIS||
                                            ' MAX_TPS => '    ||to_char(v_tec_ce_cdc_tps_ibhw_tab(L_IDX).MAX_TPS)||
                                            ' MAX_CAP_HW => ' ||to_char(v_tec_ce_cdc_tps_ibhw_tab(L_IDX).MAX_CAP_HW)||
                                            ' MAX_CAP_SW => ' ||to_char(v_tec_ce_cdc_tps_ibhw_tab(L_IDX).MAX_CAP_SW)||
                                            ' UTIL_HW => '    ||to_char(v_tec_ce_cdc_tps_ibhw_tab(L_IDX).UTIL_HW)||
                                            ' UTIL_SW => '    ||to_char(v_tec_ce_cdc_tps_ibhw_tab(L_IDX).UTIL_SW));
            END LOOP;
      END;
      EXIT WHEN cur%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE cur;
    --
    EXCEPTION
      WHEN others THEN
        G_ERROR_LOG_NEW.P_LOG_ERROR('P_TEC_CE_CDC_TPS_IBHW',
                                    SQLCODE,
                                    SQLERRM,
                                    'P_FECHA_DOMINGO '||P_FECHA_DOMINGO||' P_FECHA_SABADO => '||P_FECHA_SABADO);
  END P_TEC_CE_CDC_TPS_IBHW;
  --
  PROCEDURE P_TEC_CE_CM_TPS_DAY(P_FECHA IN VARCHAR2)AS
  --
    TYPE t_tec_ce_cm_tps_day_tab IS TABLE OF TEC_CE_CM_TPS_DAY%ROWTYPE;
    v_tec_ce_cm_tps_day_tab t_tec_ce_cm_tps_day_tab;
    --
    l_errors NUMBER;
    l_errno  NUMBER;
    l_msg    VARCHAR2(4000 CHAR);
    l_idx    NUMBER;
    --
    CURSOR cur (P_FECHA VARCHAR2) IS
    SELECT  trunc(FECHA)                  FECHA,
            PAIS,
            round(nvl(SUM(MAX_TPS),0),2)  MAX_TPS,
            MAX_CAP_HW,
            MAX_CAP_SW,
            round(nvl(AVG(UTIL_HW),0),2)  UTIL_HW,
            round(nvl(AVG(UTIL_SW),0),2)  UTIL_SW
    FROM  TEC_CE_CM_TPS_HOUR
    WHERE trunc(FECHA) = TO_DATE(P_FECHA,'DD.MM.YYYY')
    GROUP BY trunc(FECHA),PAIS,MAX_CAP_HW,
            MAX_CAP_SW;
    --
  BEGIN
    OPEN cur(P_FECHA);
    LOOP
      FETCH cur BULK COLLECT INTO v_tec_ce_cm_tps_day_tab LIMIT limit_in;
      BEGIN
        FORALL indice IN INDICES OF v_tec_ce_cm_tps_day_tab
          INSERT INTO TEC_CE_CM_TPS_DAY
          VALUES v_tec_ce_cm_tps_day_tab(indice);
        
        EXCEPTION
          WHEN OTHERS THEN
            L_ERRORS := SQL%BULK_EXCEPTIONS.COUNT;
            FOR indice IN 1 .. L_ERRORS
            LOOP
              L_ERRNO := SQL%BULK_EXCEPTIONS(indice).ERROR_CODE;
              L_MSG   := SQLERRM(-L_ERRNO);
              L_IDX   := SQL%BULK_EXCEPTIONS(indice).ERROR_INDEX;
              --
              g_error_log_new.P_LOG_ERROR('P_TEC_CE_CM_TPS_DAY',
                                          L_ERRNO,
                                          L_MSG,
                                          'FECHA => '       ||v_tec_ce_cm_tps_day_tab(indice).FECHA||
                                          ' PAIS => '       ||v_tec_ce_cm_tps_day_tab(indice).PAIS||
                                          ' MAX_TPS => '    ||to_char(v_tec_ce_cm_tps_day_tab(indice).MAX_TPS)||
                                          ' MAX_CAP_HW => ' ||to_char(v_tec_ce_cm_tps_day_tab(indice).MAX_CAP_HW)||
                                          ' MAX_CAP_SW => ' ||to_char(v_tec_ce_cm_tps_day_tab(indice).MAX_CAP_SW)||
                                          ' UTIL_HW => '    ||to_char(v_tec_ce_cm_tps_day_tab(indice).UTIL_HW)||
                                          ' UTIL_SW => '    ||to_char(v_tec_ce_cm_tps_day_tab(indice).UTIL_SW)
                                          );
            END LOOP;
      END;
      EXIT WHEN cur%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE cur;
    
    EXCEPTION
      WHEN OTHERS THEN
        g_error_log_new.P_LOG_ERROR('P_TEC_CE_CM_TPS_DAY',
                                    SQLCODE,
                                    SQLERRM,
                                    'Fallo al insertar los datos');
  END P_TEC_CE_CM_TPS_DAY;
  --
  PROCEDURE P_TEC_CE_CM_TPS_BH(P_FECHA IN VARCHAR2)AS
  --
    CURSOR cur(P_FECHA VARCHAR2) IS
    SELECT  FECHA,
            PAIS,
            MAX_TPS,
            MAX_CAP_HW,
            MAX_CAP_SW,
            UTIL_HW,
            UTIL_SW
    FROM  (
          SELECT  to_char(FECHA,'DD.MM.YYYY HH24:MI') FECHA,
                  PAIS,
                  MAX_TPS,
                  MAX_CAP_HW,
                  MAX_CAP_SW,
                  UTIL_HW,
                  UTIL_SW,                
                  ROW_NUMBER() OVER (PARTITION BY TRUNC(FECHA,'DAY'),
                                                 PAIS
                              ORDER BY trunc(FECHA) DESC,
                                       PAIS DESC,
                                       MAX_TPS DESC NULLS LAST) SEQNUM
                FROM TEC_CE_CM_TPS_HOUR
                WHERE trunc(FECHA) = TO_DATE(P_FECHA,'DD.MM.YYYY')
        )
        WHERE SEQNUM = 1;
    --
    TYPE t_tec_ce_cm_tps_tab IS TABLE OF TEC_CE_CM_TPS_BH%ROWTYPE;
    v_tec_ce_cm_tps_tab t_tec_ce_cm_tps_tab;
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
      FETCH cur BULK COLLECT INTO v_tec_ce_cm_tps_tab LIMIT limit_in;
      BEGIN
        FORALL indice IN INDICES OF v_tec_ce_cm_tps_tab
          INSERT INTO TEC_CE_CM_TPS_BH
          VALUES v_tec_ce_cm_tps_tab(indice);
        
        EXCEPTION
          WHEN OTHERS THEN
            L_ERRORS := SQL%BULK_EXCEPTIONS.COUNT;
            FOR indice IN 1 .. L_ERRORS
            LOOP
              L_ERRNO := SQL%BULK_EXCEPTIONS(indice).ERROR_CODE;
              L_MSG   := SQLERRM(-L_ERRNO);
              L_IDX   := SQL%BULK_EXCEPTIONS(indice).ERROR_INDEX;
              --
              g_error_log_new.P_LOG_ERROR('P_TEC_CE_CM_TPS_BH',
                                          L_ERRNO,
                                          L_MSG,
                                          'FECHA => '       ||v_tec_ce_cm_tps_tab(L_IDX).FECHA||
                                          ' PAIS => '       ||v_tec_ce_cm_tps_tab(L_IDX).PAIS||
                                          ' MAX_TPS => '    ||to_char(v_tec_ce_cm_tps_tab(L_IDX).MAX_TPS)||
                                          ' MAX_CAP_HW => ' ||to_char(v_tec_ce_cm_tps_tab(L_IDX).MAX_CAP_HW)||
                                          ' MAX_CAP_SW => ' ||to_char(v_tec_ce_cm_tps_tab(L_IDX).MAX_CAP_SW)||
                                          ' UTIL_HW => '    ||to_char(v_tec_ce_cm_tps_tab(L_IDX).UTIL_HW)||
                                          ' UTIL_SW => '    ||to_char(v_tec_ce_cm_tps_tab(L_IDX).UTIL_SW)
                                          );
            
            END LOOP;
      END;
      EXIT WHEN cur%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE cur;
    
    EXCEPTION
      WHEN OTHERS THEN
        g_error_log_new.P_LOG_ERROR('P_TEC_CE_CM_TPS_BH',
                                    SQLCODE,
                                    SQLERRM,
                                    'Fallo al abrir el cursor');
  END P_TEC_CE_CM_TPS_BH;
  --
  PROCEDURE P_TEC_CE_CM_TPS_IBHW(P_FECHA_DOMINGO IN VARCHAR2,P_FECHA_SABADO IN VARCHAR2)AS
  --
    CURSOR cur(fecha_desde varchar2, fecha_hasta varchar2) IS
    SELECT  fecha_desde FECHA,
            PAIS,
            round(NVL(AVG(MAX_TPS),0),2) MAX_TPS,
            MAX_CAP_HW,
            MAX_CAP_SW,
            round(NVL(AVG(UTIL_HW),0),2) UTIL_HW,
            round(NVL(AVG(UTIL_SW),0),2) UTIL_SW
    FROM (
          SELECT  to_char(FECHA,'DD.MM.YYYY HH24:MI') FECHA,
                  PAIS,
                  MAX_TPS,
                  MAX_CAP_HW,
                  MAX_CAP_SW,
                  UTIL_HW,
                  UTIL_SW,                
                  ROW_NUMBER() OVER (PARTITION BY TRUNC(FECHA,'DAY'),
                                                 PAIS
                              ORDER BY --trunc(FECHA) DESC,
                                       --PAIS DESC,
                                       MAX_TPS DESC NULLS LAST) SEQNUM
                FROM TEC_CE_CM_TPS_BH
                WHERE trunc(fecha) BETWEEN TO_DATE(fecha_desde,'DD.MM.YYYY') AND TO_DATE(fecha_hasta,'DD.MM.YYYY'))
    where SEQNUM <= LIMIT_PROM
    --AND fecha BETWEEN to_date(fecha_desde,'DD.MM.YYYY') AND to_date(fecha_hasta,'DD.MM.YYYY')
    GROUP BY PAIS,MAX_CAP_HW,
            MAX_CAP_SW; --,fecha;
    --
    l_errors number;
    l_errno  number;
    l_msg    varchar2(4000);
    l_idx    number;
    --
    TYPE t_tec_ce_cm_tps_ibhw_row IS TABLE OF TEC_CE_CM_TPS_IBHW%rowtype;
    v_tec_ce_cm_tps_ibhw_tab t_tec_ce_cm_tps_ibhw_row;
    --
  BEGIN
  OPEN cur(P_FECHA_DOMINGO,P_FECHA_SABADO);
    LOOP
      FETCH cur bulk collect into v_tec_ce_cm_tps_ibhw_tab limit limit_in;
      BEGIN
        FORALL indice IN 1 .. v_tec_ce_cm_tps_ibhw_tab.COUNT SAVE EXCEPTIONS
          INSERT INTO TEC_CE_CM_TPS_IBHW values v_tec_ce_cm_tps_ibhw_tab(indice);
        EXCEPTION
          WHEN OTHERS THEN
            L_ERRORS := SQL%BULK_EXCEPTIONS.COUNT;
            FOR indice IN 1 .. L_ERRORS
            LOOP
                L_ERRNO := SQL%BULK_EXCEPTIONS(indice).ERROR_CODE;
                L_MSG   := SQLERRM(-L_ERRNO);
                L_IDX   := SQL%BULK_EXCEPTIONS(indice).ERROR_INDEX;
                --
                G_ERROR_LOG_NEW.P_LOG_ERROR('P_TEC_CE_CM_TPS_IBHW',
                                            l_errno,
                                            l_msg,
                                            'FECHA => '       ||v_tec_ce_cm_tps_ibhw_tab(L_IDX).FECHA||
                                            ' PAIS => '       ||v_tec_ce_cm_tps_ibhw_tab(L_IDX).PAIS||
                                            ' MAX_TPS => '    ||to_char(v_tec_ce_cm_tps_ibhw_tab(L_IDX).MAX_TPS)||
                                            ' MAX_CAP_HW => ' ||to_char(v_tec_ce_cm_tps_ibhw_tab(L_IDX).MAX_CAP_HW)||
                                            ' MAX_CAP_SW => ' ||to_char(v_tec_ce_cm_tps_ibhw_tab(L_IDX).MAX_CAP_SW)||
                                            ' UTIL_HW => '    ||to_char(v_tec_ce_cm_tps_ibhw_tab(L_IDX).UTIL_HW)||
                                            ' UTIL_SW => '    ||to_char(v_tec_ce_cm_tps_ibhw_tab(L_IDX).UTIL_SW));
            END LOOP;
      END;
      EXIT WHEN cur%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE cur;
    --
    EXCEPTION
      WHEN others THEN
        G_ERROR_LOG_NEW.P_LOG_ERROR('P_TEC_CE_CM_TPS_IBHW',
                                    SQLCODE,
                                    SQLERRM,
                                    'P_FECHA_DOMINGO '||P_FECHA_DOMINGO||' P_FECHA_SABADO => '||P_FECHA_SABADO);
  END P_TEC_CE_CM_TPS_IBHW;
  --
  PROCEDURE P_CALCULAR_SUM_TEC_CM_CDC(P_FECHA IN VARCHAR2)AS
    v_dia VARCHAR2(10 CHAR) := '';
  BEGIN
    --
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_TEC_CE_CM_TPS_DAY',0,'NO ERROR','COMIENZO DE SUMARIZACION DAY P_TEC_CE_CM_TPS_DAY('||P_FECHA||')');
    P_TEC_CE_CM_TPS_DAY(P_FECHA);
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_TEC_CE_CM_TPS_DAY',0,'NO ERROR','FIN DE SUMARIZACION DAY');
    --
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_TEC_CE_CDC_TPS_DAY',0,'NO ERROR','COMIENZO DE SUMARIZACION DAY P_TEC_CE_CDC_TPS_DAY('||P_FECHA||')');
    P_TEC_CE_CDC_TPS_DAY(P_FECHA);
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_TEC_CE_CDC_TPS_DAY',0,'NO ERROR','FIN DE SUMARIZACION DAY');
    --
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_TEC_CE_CM_TPS_BH',0,'NO ERROR','COMIENZO CALCULO BH P_TEC_CE_CM_TPS_BH('||P_FECHA||')');
    P_TEC_CE_CM_TPS_BH(P_FECHA);
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_TEC_CE_CM_TPS_BH',0,'NO ERROR','FIN CALCULO BH');
    --
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_TEC_CE_CDC_TPS_BH',0,'NO ERROR','COMIENZO CALCULO BH P_TEC_CE_CDC_TPS_BH('||P_FECHA||')');
    P_TEC_CE_CDC_TPS_BH(P_FECHA);
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_TEC_CE_CDC_TPS_BH',0,'NO ERROR','FIN CALCULO BH');
    --
    -- Si el dia actual es DOMINGO, entonces calcular sumarizacion IBHW de la semana anterior,
    -- siempre de domingo a sabado
    --
    SELECT TO_CHAR(TO_DATE(P_FECHA,'DD.MM.YYYY'),'DAY')
    INTO V_DIA
    FROM DUAL;
    
    IF (TRIM(V_DIA) = 'SUNDAY') OR (TRIM(V_DIA) = 'DOMINGO') THEN
      G_ERROR_LOG_NEW.P_LOG_ERROR('P_TEC_CE_CM_TPS_IBHW',0,'NO ERROR','COMIENZO DE SUMARIZACION IBHW P_FECHA_DOMINGO => '||
                                  to_char(to_date(P_FECHA,'DD.MM.YYYY')-7,'DD.MM.YYYY')||
                                  ' P_FECHA_SABADO => '||TO_CHAR(TO_DATE(P_FECHA,'DD.MM.YYYY')-1,'DD.MM.YYYY'));
      --
      P_TEC_CE_CM_TPS_IBHW(to_char(to_date(P_FECHA,'DD.MM.YYYY')-7,'DD.MM.YYYY'),TO_CHAR(TO_DATE(P_FECHA,'DD.MM.YYYY')-1,'DD.MM.YYYY'));
      --
      G_ERROR_LOG_NEW.P_LOG_ERROR('P_TEC_CE_CM_TPS_IBHW',0,'NO ERROR','FIN DE SUMARIZACION IBHW');
      --
      G_ERROR_LOG_NEW.P_LOG_ERROR('P_TEC_CE_CDC_TPS_IBHW',0,'NO ERROR','COMIENZO DE SUMARIZACION IBHW P_FECHA_DOMINGO => '||
                                  to_char(to_date(P_FECHA,'DD.MM.YYYY')-7,'DD.MM.YYYY')||
                                  ' P_FECHA_SABADO => '||TO_CHAR(TO_DATE(P_FECHA,'DD.MM.YYYY')-1,'DD.MM.YYYY'));
      --
      P_TEC_CE_CDC_TPS_IBHW(to_char(to_date(P_FECHA,'DD.MM.YYYY')-7,'DD.MM.YYYY'),TO_CHAR(TO_DATE(P_FECHA,'DD.MM.YYYY')-1,'DD.MM.YYYY'));
      --
      G_ERROR_LOG_NEW.P_LOG_ERROR('P_TEC_CE_CDC_TPS_IBHW',0,'NO ERROR','FIN DE SUMARIZACION IBHW');
    END IF;
  END P_CALCULAR_SUM_TEC_CM_CDC;
  --
END G_TECNOTREE_CE;

