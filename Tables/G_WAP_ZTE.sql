CREATE OR REPLACE PACKAGE G_WAP_ZTE AS 

  /**
  * Author: Carrasco Marcelo
  * Date: 02/06/2016
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
  * Extrae los datos de la tabla WAP_GATEWAY_KPI_ZTE_AUX y los inserta en la tabla WAP_GATEWAY_KPI_ZTE_RAW
  * transformando extrayendo de la columna NOMBRE_CSV la fecha.
  */ 
  FUNCTION F_WAP_GATEWAY_KPI_ZTE_RAW_INS RETURN NUMBER;
  
  /**
  *
  */
  FUNCTION F_WAP_GTW_SERVICE_ZTE_RAW_INS RETURN NUMBER;
  
  /**
  * Comment: Calcula la sumarización de los contadores a nivel de día y los guarda en la tabla WAP_GATEWAY_SERVICE_ZTE_DAY.
  * Param: P_FECHA fecha para hacer la sumarización.
  */
  PROCEDURE P_WAP_GATEWAY_SERVICE_ZTE_DAY(P_FECHA IN VARCHAR2);
  
  /**
  * Comment: calcula la Busy Hour (BH) y los guarda en la tabla WAP_GATEWAY_SERVICE_ZTE_BH
  * Param: P_FECHA fecha para calcular la BH.
  */
  PROCEDURE P_WAP_GATEWAY_SERVICE_ZTE_BH(P_FECHA IN VARCHAR2);
  
   /**
  * Comment: calcula la Busy Hour (BH) y los guarda en la tabla WAP_GATEWAY_SERVICE_ZTE_BH
  * Param: P_FECHA fecha para calcular la BH.
  */
  PROCEDURE P_WAP_GATEWAY_SERVICE_ZTE_IBHW(P_FECHA_DOMINGO IN VARCHAR2,P_FECHA_SABADO IN VARCHAR2);
  
  /**
  *
  */
  PROCEDURE P_CALCULAR_SUMARIZACIONES_ZTE(P_FECHA IN VARCHAR2);
END G_WAP_ZTE;
/


CREATE OR REPLACE PACKAGE BODY G_WAP_ZTE AS
  --
  FUNCTION F_WAP_GATEWAY_KPI_ZTE_RAW_INS RETURN NUMBER IS
  --
    cursor cur is
    SELECT  to_date((SUBSTR(SUBSTR(nombre_csv,INSTR(nombre_csv,'_',-1)+1,8),7,2)||
            '.'||
            SUBSTR(SUBSTR(nombre_csv,INSTR(nombre_csv,'_',-1)+1,8),5,2)||
            '.'||
            SUBSTR(SUBSTR(nombre_csv,INSTR(nombre_csv,'_',-1)+1,8),1,4)),'dd.mm.yyyy') fecha,
            GATEWAY,
            GATEWAY_REQUEST_NUMBER,
            TOTAL_NUMBER,
            GATEWAY_REQUEST_SUCCESS_NUMBER,
            GATEWAY_REQUEST_VIRTUAL_NUMBER,
            GATEWAY_TOP_REQUEST_NUMBER,
            GATEWAY_SUCCESS_RATE,
            GATEWAY_VIRTUAL_RATE,
            GATEWAY_TOP_AVERAGE_CPU_RATE,
            GATEWAY_AVERAGE_DELAY
    FROM  WAP_GATEWAY_KPI_ZTE_AUX;
    --
    type wap_gtw_kpi_tab is table of WAP_GATEWAY_KPI_ZTE_RAW%rowtype;
    v_wap_gtw_kpi_tab wap_gtw_kpi_tab;
    --
    l_errors number;
    l_errno  number;
    l_msg    VARCHAR2(4000 CHAR);
    l_idx    number;
    --
    vStatus NUMBER := -1;
  BEGIN
    --
    OPEN cur;
    LOOP
      FETCH cur bulk collect into v_wap_gtw_kpi_tab limit limit_in;
      BEGIN
        --FORALL indice in 1 .. v_wap_gtw_kpi_tab.COUNT SAVE EXCEPTIONS
        FORALL indice in indices of v_wap_gtw_kpi_tab SAVE EXCEPTIONS
          insert into  WAP_GATEWAY_KPI_ZTE_RAW (FECHA,
                                                GATEWAY,
                                                GATEWAY_REQUEST_NUMBER,
                                                TOTAL_NUMBER,
                                                GATEWAY_REQUEST_SUCCESS_NUMBER,
                                                GATEWAY_REQUEST_VIRTUAL_NUMBER,
                                                GATEWAY_TOP_REQUEST_NUMBER,
                                                GATEWAY_SUCCESS_RATE,
                                                GATEWAY_VIRTUAL_RATE,
                                                GATEWAY_TOP_AVERAGE_CPU_RATE,
                                                GATEWAY_AVERAGE_DELAY)
          VALUES  (v_wap_gtw_kpi_tab(indice).FECHA,
                  v_wap_gtw_kpi_tab(indice).GATEWAY,
                  v_wap_gtw_kpi_tab(indice).GATEWAY_REQUEST_NUMBER,
                  v_wap_gtw_kpi_tab(indice).TOTAL_NUMBER,
                  v_wap_gtw_kpi_tab(indice).GATEWAY_REQUEST_SUCCESS_NUMBER,
                  v_wap_gtw_kpi_tab(indice).GATEWAY_REQUEST_VIRTUAL_NUMBER,
                  v_wap_gtw_kpi_tab(indice).GATEWAY_TOP_REQUEST_NUMBER,
                  v_wap_gtw_kpi_tab(indice).GATEWAY_SUCCESS_RATE,
                  v_wap_gtw_kpi_tab(indice).GATEWAY_VIRTUAL_RATE,
                  v_wap_gtw_kpi_tab(indice).GATEWAY_TOP_AVERAGE_CPU_RATE,
                  v_wap_gtw_kpi_tab(indice).GATEWAY_AVERAGE_DELAY);
          EXCEPTION
          WHEN OTHERS THEN
            L_ERRORS := SQL%BULK_EXCEPTIONS.COUNT;
            vStatus := 1;
            FOR indice IN 1 .. L_ERRORS
            LOOP
              L_ERRNO := SQL%BULK_EXCEPTIONS(indice).ERROR_CODE;
              L_MSG   := SQLERRM(-L_ERRNO);
              L_IDX   := SQL%BULK_EXCEPTIONS(indice).ERROR_INDEX;
              --
              g_error_log_new.P_LOG_ERROR('F_WAP_GATEWAY_KPI_ZTE_RAW_INS',
                                          L_ERRNO,
                                          L_MSG,
                                          'FECHA => '                          ||v_wap_gtw_kpi_tab(indice).FECHA||
                                          ' GATEWAY => '                       ||v_wap_gtw_kpi_tab(indice).GATEWAY||
                                          ' GATEWAY_REQUEST_NUMBER => '        ||to_char(v_wap_gtw_kpi_tab(indice).GATEWAY_REQUEST_NUMBER)||
                                          ' TOTAL_NUMBER => '                  ||to_char(v_wap_gtw_kpi_tab(indice).TOTAL_NUMBER)||
                                          ' GATEWAY_REQUEST_SUCCESS_NUMBER => '||to_char(v_wap_gtw_kpi_tab(indice).GATEWAY_REQUEST_SUCCESS_NUMBER)||
                                          ' GATEWAY_REQUEST_VIRTUAL_NUMBER => '||to_char(v_wap_gtw_kpi_tab(indice).GATEWAY_REQUEST_VIRTUAL_NUMBER)||
                                          ' GATEWAY_TOP_REQUEST_NUMBER => '    ||to_char(v_wap_gtw_kpi_tab(indice).GATEWAY_TOP_REQUEST_NUMBER)||
                                          ' GATEWAY_SUCCESS_RATE => '          ||to_char(v_wap_gtw_kpi_tab(indice).GATEWAY_SUCCESS_RATE)||
                                          ' GATEWAY_VIRTUAL_RATE => '          ||to_char(v_wap_gtw_kpi_tab(indice).GATEWAY_VIRTUAL_RATE)||
                                          ' GATEWAY_TOP_AVERAGE_CPU_RATE => '  ||to_char(v_wap_gtw_kpi_tab(indice).GATEWAY_TOP_AVERAGE_CPU_RATE)||
                                          ' GATEWAY_AVERAGE_DELAY => '         ||to_char(v_wap_gtw_kpi_tab(indice).GATEWAY_AVERAGE_DELAY));
            END LOOP;
            RETURN vStatus;
      END;
      EXIT WHEN cur%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE cur;
    vStatus := 0;
    --
    RETURN vStatus;  
    exception
      when others then
        vStatus := 1;
        g_error_log_new.P_LOG_ERROR('F_WAP_GATEWAY_KPI_ZTE_RAW_INS',
                                    SQLCODE,
                                    SQLERRM,
                                    'Fallo al insertar los datos');
       RETURN vStatus;                 
  END F_WAP_GATEWAY_KPI_ZTE_RAW_INS;
  --
  FUNCTION F_WAP_GTW_SERVICE_ZTE_RAW_INS RETURN NUMBER IS
  --
    cursor cur is
--    SELECT  to_date(SUBSTR(SUBSTR(nombre_csv,INSTR(nombre_csv,'_',-1)+1,8),7,2)||
--            '.'||
--            SUBSTR(SUBSTR(nombre_csv,INSTR(nombre_csv,'_',-1)+1,8),5,2)||
--            '.'||
--            SUBSTR(SUBSTR(nombre_csv,INSTR(nombre_csv,'_',-1)+1,8),1,4)||' '||HORA,'dd.mm.yyyy HH24:MI') 
    SELECT  TIME_,
            WAP_BROWSER_REQUEST_NUMBER,
            WAP_BROWSER_REQ_SUCCESS_RATIO,
            HTTP_BROWSER_REQUEST_NUMBER,
            HTTP_BROWSER_REQ_SUCCESS_RATIO,
            JAVA_DNLD_REQ_SUCCESS_RATIO,
            JAVA_DOWNLOAD_REQUEST_NUMBER,
            MMS_POST_REQUEST_NUMBER,
            MMS_POST_REQUEST_SUCCESS_RATIO,
            MMS_GET_REQUEST_NUMBER,
            MMS_GET_REQUEST_RATIO,
            PUSH_REQUEST_NUMBER,
            PUSH_REQUEST_SUCCESS_RATIO,
            RADIUS_REQUEST_NUMBER,
            RADIUS_REQUEST_SUCCESS_RATIO,
            REQUEST_NUMBER,
            REQUEST_SUCCESS_RATIO,
            ONLINE_USER_NUMBER,
            GATEWAY_FORWARD_REQUEST_DELAY,
            GATEWAY_FORWARD_RESPONSE_DELAY,
            SP_DELAY,
            SERVICE_DELAY
    FROM  WAP_GATEWAY_SERVICE_ZTE_AUX;
    --
    type wap_gtw_srv_tab is table of WAP_GATEWAY_SERVICE_ZTE_RAW%rowtype;
    v_wap_gtw_srv_tab wap_gtw_srv_tab;
    --
    l_errors number;
    l_errno  number;
    l_msg    VARCHAR2(4000 CHAR);
    l_idx    number;
    --
    vStatus NUMBER := -1;
  BEGIN
    --
    OPEN cur;
    LOOP
      FETCH cur bulk collect into v_wap_gtw_srv_tab limit limit_in;
      BEGIN
        --dbms_output.put_line('count '||to_char(v_wap_gtw_srv_tab.COUNT));
        FORALL indice in v_wap_gtw_srv_tab.first .. v_wap_gtw_srv_tab.last SAVE EXCEPTIONS
          insert into  WAP_GATEWAY_SERVICE_ZTE_RAW (TIME_,
                                                    WAP_BROWSER_REQUEST_NUMBER,
                                                    WAP_BROWSER_REQ_SUCCESS_RATIO,
                                                    HTTP_BROWSER_REQUEST_NUMBER,
                                                    HTTP_BROWSER_REQ_SUCCESS_RATIO,
                                                    JAVA_DNLD_REQ_SUCCESS_RATIO,
                                                    JAVA_DOWNLOAD_REQUEST_NUMBER,
                                                    MMS_POST_REQUEST_NUMBER,
                                                    MMS_POST_REQUEST_SUCCESS_RATIO,
                                                    MMS_GET_REQUEST_NUMBER,
                                                    MMS_GET_REQUEST_RATIO,
                                                    PUSH_REQUEST_NUMBER,
                                                    PUSH_REQUEST_SUCCESS_RATIO,
                                                    RADIUS_REQUEST_NUMBER,
                                                    RADIUS_REQUEST_SUCCESS_RATIO,
                                                    REQUEST_NUMBER,
                                                    REQUEST_SUCCESS_RATIO,
                                                    ONLINE_USER_NUMBER,
                                                    GATEWAY_FORWARD_REQUEST_DELAY,
                                                    GATEWAY_FORWARD_RESPONSE_DELAY,
                                                    SP_DELAY,
                                                    SERVICE_DELAY)
          VALUES  (v_wap_gtw_srv_tab(indice).TIME_,
                  v_wap_gtw_srv_tab(indice).WAP_BROWSER_REQUEST_NUMBER,
                  v_wap_gtw_srv_tab(indice).WAP_BROWSER_REQ_SUCCESS_RATIO,
                  v_wap_gtw_srv_tab(indice).HTTP_BROWSER_REQUEST_NUMBER,
                  v_wap_gtw_srv_tab(indice).HTTP_BROWSER_REQ_SUCCESS_RATIO,
                  v_wap_gtw_srv_tab(indice).JAVA_DNLD_REQ_SUCCESS_RATIO,
                  v_wap_gtw_srv_tab(indice).JAVA_DOWNLOAD_REQUEST_NUMBER,
                  v_wap_gtw_srv_tab(indice).MMS_POST_REQUEST_NUMBER,
                  v_wap_gtw_srv_tab(indice).MMS_POST_REQUEST_SUCCESS_RATIO,
                  v_wap_gtw_srv_tab(indice).MMS_GET_REQUEST_NUMBER,
                  v_wap_gtw_srv_tab(indice).MMS_GET_REQUEST_RATIO,
                  v_wap_gtw_srv_tab(indice).PUSH_REQUEST_NUMBER,
                  v_wap_gtw_srv_tab(indice).PUSH_REQUEST_SUCCESS_RATIO,
                  v_wap_gtw_srv_tab(indice).RADIUS_REQUEST_NUMBER,
                  v_wap_gtw_srv_tab(indice).RADIUS_REQUEST_SUCCESS_RATIO,
                  v_wap_gtw_srv_tab(indice).REQUEST_NUMBER,
                  v_wap_gtw_srv_tab(indice).REQUEST_SUCCESS_RATIO,
                  v_wap_gtw_srv_tab(indice).ONLINE_USER_NUMBER,
                  v_wap_gtw_srv_tab(indice).GATEWAY_FORWARD_REQUEST_DELAY,
                  v_wap_gtw_srv_tab(indice).GATEWAY_FORWARD_RESPONSE_DELAY,
                  v_wap_gtw_srv_tab(indice).SP_DELAY,
                  v_wap_gtw_srv_tab(indice).SERVICE_DELAY);
          EXCEPTION
          WHEN OTHERS THEN
            L_ERRORS := SQL%BULK_EXCEPTIONS.COUNT;
            vStatus := 1;
            FOR indice IN 1 .. L_ERRORS
            LOOP
              L_ERRNO := SQL%BULK_EXCEPTIONS(indice).ERROR_CODE;
              L_MSG   := SQLERRM(-L_ERRNO);
              L_IDX   := SQL%BULK_EXCEPTIONS(indice).ERROR_INDEX;
              --
              g_error_log_new.P_LOG_ERROR('F_WAP_GTW_SERVICE_ZTE_RAW_INS',
                                          L_ERRNO,
                                          L_MSG,
                                          'TIME_ => '                           ||v_wap_gtw_srv_tab(indice).TIME_||
                                          ' WAP_BROWSER_REQUEST_NUMBER => '     ||to_char(v_wap_gtw_srv_tab(indice).WAP_BROWSER_REQUEST_NUMBER)||
                                          ' WAP_BROWSER_REQ_SUCCESS_RATIO => '  ||to_char(v_wap_gtw_srv_tab(indice).WAP_BROWSER_REQ_SUCCESS_RATIO)||
                                          ' HTTP_BROWSER_REQUEST_NUMBER => '    ||to_char(v_wap_gtw_srv_tab(indice).HTTP_BROWSER_REQUEST_NUMBER)||
                                          ' HTTP_BROWSER_REQ_SUCCESS_RATIO => ' ||to_char(v_wap_gtw_srv_tab(indice).HTTP_BROWSER_REQ_SUCCESS_RATIO)||
                                          ' JAVA_DNLD_REQ_SUCCESS_RATIO => '    ||to_char(v_wap_gtw_srv_tab(indice).JAVA_DNLD_REQ_SUCCESS_RATIO)||
                                          ' JAVA_DNLD_REQ_SUCCESS_RATIO => '    ||to_char(v_wap_gtw_srv_tab(indice).JAVA_DOWNLOAD_REQUEST_NUMBER)||
                                          ' MMS_POST_REQUEST_NUMBER => '        ||to_char(v_wap_gtw_srv_tab(indice).MMS_POST_REQUEST_NUMBER)||
                                          ' MMS_POST_REQUEST_SUCCESS_RATIO => ' ||to_char(v_wap_gtw_srv_tab(indice).MMS_POST_REQUEST_SUCCESS_RATIO)||
                                          ' MMS_GET_REQUEST_NUMBER => '         ||to_char(v_wap_gtw_srv_tab(indice).MMS_GET_REQUEST_NUMBER)||
                                          ' MMS_GET_REQUEST_RATIO => '          ||to_char(v_wap_gtw_srv_tab(indice).MMS_GET_REQUEST_RATIO)||
                                          ' PUSH_REQUEST_NUMBER => '            ||to_char(v_wap_gtw_srv_tab(indice).PUSH_REQUEST_NUMBER)||
                                          ' PUSH_REQUEST_SUCCESS_RATIO => '     ||to_char(v_wap_gtw_srv_tab(indice).PUSH_REQUEST_SUCCESS_RATIO)||
                                          ' RADIUS_REQUEST_NUMBER => '          ||to_char(v_wap_gtw_srv_tab(indice).RADIUS_REQUEST_NUMBER)||
                                          ' RADIUS_REQUEST_SUCCESS_RATIO => '   ||to_char(v_wap_gtw_srv_tab(indice).RADIUS_REQUEST_SUCCESS_RATIO)||
                                          ' REQUEST_NUMBER => '                 ||to_char(v_wap_gtw_srv_tab(indice).REQUEST_NUMBER)||
                                          ' REQUEST_SUCCESS_RATIO => '          ||to_char(v_wap_gtw_srv_tab(indice).REQUEST_SUCCESS_RATIO)||
                                          ' ONLINE_USER_NUMBER => '             ||to_char(v_wap_gtw_srv_tab(indice).ONLINE_USER_NUMBER)||
                                          ' GATEWAY_FORWARD_REQUEST_DELAY => '  ||to_char(v_wap_gtw_srv_tab(indice).GATEWAY_FORWARD_REQUEST_DELAY)||
                                          ' GATEWAY_FORWARD_RESPONSE_DELAY => ' ||to_char(v_wap_gtw_srv_tab(indice).GATEWAY_FORWARD_RESPONSE_DELAY)||
                                          ' SP_DELAY => '                       ||to_char(v_wap_gtw_srv_tab(indice).SP_DELAY)||
                                          ' SERVICE_DELAY => '                  ||to_char(v_wap_gtw_srv_tab(indice).SERVICE_DELAY));
            END LOOP;
            RETURN vStatus;
      END;
      EXIT WHEN cur%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE cur;
    vStatus := 0;
    --
    RETURN vStatus;  
    exception
      when others then
        vStatus := 1;
        g_error_log_new.P_LOG_ERROR('F_WAP_GTW_SERVICE_ZTE_RAW_INS',
                                    SQLCODE,
                                    SQLERRM,
                                    'Fallo al insertar los datos');
       RETURN vStatus;
  END F_WAP_GTW_SERVICE_ZTE_RAW_INS;
  --
  PROCEDURE P_WAP_GATEWAY_SERVICE_ZTE_DAY(P_FECHA IN VARCHAR2) IS
  --
    TYPE t_wap_gtw_srv_zte_tab IS TABLE OF WAP_GATEWAY_SERVICE_ZTE_DAY%ROWTYPE;
    v_wap_gtw_srv_zte_tab t_wap_gtw_srv_zte_tab;
    --
    l_errors NUMBER;
    l_errno  NUMBER;
    l_msg    VARCHAR2(4000 CHAR);
    l_idx    NUMBER;
    --
    CURSOR cur (P_FECHA VARCHAR2) IS
    SELECT  trunc(TIME_)                                        FECHA,
            round(nvl(SUM(WAP_BROWSER_REQUEST_NUMBER),0),2)     WAP_BROWSER_REQUEST_NUMBER,
            round(nvl(SUM(WAP_BROWSER_REQ_SUCCESS_RATIO),0),2)  WAP_BROWSER_REQ_SUCCESS_RATIO,
            round(nvl(SUM(HTTP_BROWSER_REQUEST_NUMBER),0),2)    HTTP_BROWSER_REQUEST_NUMBER,
            round(nvl(AVG(HTTP_BROWSER_REQ_SUCCESS_RATIO),0),2) HTTP_BROWSER_REQ_SUCCESS_RATIO,
            round(nvl(AVG(JAVA_DNLD_REQ_SUCCESS_RATIO),0),2)    JAVA_DNLD_REQ_SUCCESS_RATIO,
            round(nvl(SUM(JAVA_DOWNLOAD_REQUEST_NUMBER),0),2)   JAVA_DOWNLOAD_REQUEST_NUMBER,
            round(nvl(SUM(MMS_POST_REQUEST_NUMBER),0),2)        MMS_POST_REQUEST_NUMBER,
            round(nvl(AVG(MMS_POST_REQUEST_SUCCESS_RATIO),0),2) MMS_POST_REQUEST_SUCCESS_RATIO,
            round(nvl(SUM(MMS_GET_REQUEST_NUMBER),0),2)         MMS_GET_REQUEST_NUMBER,
            round(nvl(AVG(MMS_GET_REQUEST_RATIO),0),2)          MMS_GET_REQUEST_RATIO,
            round(nvl(SUM(PUSH_REQUEST_NUMBER),0),2)            PUSH_REQUEST_NUMBER,
            round(nvl(AVG(PUSH_REQUEST_SUCCESS_RATIO),0),2)     PUSH_REQUEST_SUCCESS_RATIO,
            round(nvl(SUM(RADIUS_REQUEST_NUMBER),0),2)          RADIUS_REQUEST_NUMBER,
            round(nvl(AVG(RADIUS_REQUEST_SUCCESS_RATIO),0),2)   RADIUS_REQUEST_SUCCESS_RATIO,
            round(nvl(SUM(REQUEST_NUMBER),0),2)                 REQUEST_NUMBER,
            round(nvl(AVG(REQUEST_SUCCESS_RATIO),0),2)          REQUEST_SUCCESS_RATIO,
            round(nvl(SUM(ONLINE_USER_NUMBER),0),2)             ONLINE_USER_NUMBER,
            round(nvl(AVG(GATEWAY_FORWARD_REQUEST_DELAY),0),2)  GATEWAY_FORWARD_REQUEST_DELAY,
            round(nvl(AVG(GATEWAY_FORWARD_RESPONSE_DELAY),0),2) GATEWAY_FORWARD_RESPONSE_DELAY,
            round(nvl(AVG(SP_DELAY),0),2)                       SP_DELAY,
            round(nvl(AVG(SERVICE_DELAY),0),2)                  SERVICE_DELAY
    FROM  WAP_GATEWAY_SERVICE_ZTE_RAW
    WHERE trunc(TIME_) = TO_DATE(P_FECHA,'DD.MM.YYYY')
    GROUP BY trunc(TIME_);
    --
  BEGIN
    OPEN cur(P_FECHA);
    LOOP
      FETCH cur BULK COLLECT INTO v_wap_gtw_srv_zte_tab LIMIT limit_in;
      BEGIN
        FORALL indice IN INDICES OF v_wap_gtw_srv_zte_tab
          INSERT INTO WAP_GATEWAY_SERVICE_ZTE_DAY
          VALUES v_wap_gtw_srv_zte_tab(indice);
        
        EXCEPTION
          WHEN OTHERS THEN
            L_ERRORS := SQL%BULK_EXCEPTIONS.COUNT;
            FOR indice IN 1 .. L_ERRORS
            LOOP
              L_ERRNO := SQL%BULK_EXCEPTIONS(indice).ERROR_CODE;
              L_MSG   := SQLERRM(-L_ERRNO);
              L_IDX   := SQL%BULK_EXCEPTIONS(indice).ERROR_INDEX;
              --
              g_error_log_new.P_LOG_ERROR('P_WAP_GATEWAY_SERVICE_ZTE_DAY',
                                          L_ERRNO,
                                          L_MSG,
                                          'FECHA => '                           ||v_wap_gtw_srv_zte_tab(indice).FECHA||
                                          ' WAP_BROWSER_REQUEST_NUMBER => '     ||to_char(v_wap_gtw_srv_zte_tab(indice).WAP_BROWSER_REQUEST_NUMBER)||
                                          ' WAP_BROWSER_REQ_SUCCESS_RATIO => '  ||to_char(v_wap_gtw_srv_zte_tab(indice).WAP_BROWSER_REQ_SUCCESS_RATIO)||
                                          ' HTTP_BROWSER_REQUEST_NUMBER => '    ||to_char(v_wap_gtw_srv_zte_tab(indice).HTTP_BROWSER_REQUEST_NUMBER)||
                                          ' HTTP_BROWSER_REQ_SUCCESS_RATIO => ' ||to_char(v_wap_gtw_srv_zte_tab(indice).HTTP_BROWSER_REQ_SUCCESS_RATIO)||
                                          ' JAVA_DNLD_REQ_SUCCESS_RATIO => '    ||to_char(v_wap_gtw_srv_zte_tab(indice).JAVA_DNLD_REQ_SUCCESS_RATIO)||
                                          ' JAVA_DNLD_REQ_SUCCESS_RATIO => '    ||to_char(v_wap_gtw_srv_zte_tab(indice).JAVA_DOWNLOAD_REQUEST_NUMBER)||
                                          ' MMS_POST_REQUEST_NUMBER => '        ||to_char(v_wap_gtw_srv_zte_tab(indice).MMS_POST_REQUEST_NUMBER)||
                                          ' MMS_POST_REQUEST_SUCCESS_RATIO => ' ||to_char(v_wap_gtw_srv_zte_tab(indice).MMS_POST_REQUEST_SUCCESS_RATIO)||
                                          ' MMS_GET_REQUEST_NUMBER => '         ||to_char(v_wap_gtw_srv_zte_tab(indice).MMS_GET_REQUEST_NUMBER)||
                                          ' MMS_GET_REQUEST_RATIO => '          ||to_char(v_wap_gtw_srv_zte_tab(indice).MMS_GET_REQUEST_RATIO)||
                                          ' PUSH_REQUEST_NUMBER => '            ||to_char(v_wap_gtw_srv_zte_tab(indice).PUSH_REQUEST_NUMBER)||
                                          ' PUSH_REQUEST_SUCCESS_RATIO => '     ||to_char(v_wap_gtw_srv_zte_tab(indice).PUSH_REQUEST_SUCCESS_RATIO)||
                                          ' RADIUS_REQUEST_NUMBER => '          ||to_char(v_wap_gtw_srv_zte_tab(indice).RADIUS_REQUEST_NUMBER)||
                                          ' RADIUS_REQUEST_SUCCESS_RATIO => '   ||to_char(v_wap_gtw_srv_zte_tab(indice).RADIUS_REQUEST_SUCCESS_RATIO)||
                                          ' REQUEST_NUMBER => '                 ||to_char(v_wap_gtw_srv_zte_tab(indice).REQUEST_NUMBER)||
                                          ' REQUEST_SUCCESS_RATIO => '          ||to_char(v_wap_gtw_srv_zte_tab(indice).REQUEST_SUCCESS_RATIO)||
                                          ' ONLINE_USER_NUMBER => '             ||to_char(v_wap_gtw_srv_zte_tab(indice).ONLINE_USER_NUMBER)||
                                          ' GATEWAY_FORWARD_REQUEST_DELAY => '  ||to_char(v_wap_gtw_srv_zte_tab(indice).GATEWAY_FORWARD_REQUEST_DELAY)||
                                          ' GATEWAY_FORWARD_RESPONSE_DELAY => ' ||to_char(v_wap_gtw_srv_zte_tab(indice).GATEWAY_FORWARD_RESPONSE_DELAY)||
                                          ' SP_DELAY => '                       ||to_char(v_wap_gtw_srv_zte_tab(indice).SP_DELAY)||
                                          ' SERVICE_DELAY => '                  ||to_char(v_wap_gtw_srv_zte_tab(indice).SERVICE_DELAY));
            END LOOP;
      END;
      EXIT WHEN cur%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE cur;
    
    EXCEPTION
      WHEN OTHERS THEN
        g_error_log_new.P_LOG_ERROR('P_WAP_GATEWAY_SERVICE_ZTE_DAY',
                                    SQLCODE,
                                    SQLERRM,
                                    'Fallo al insertar los datos');
  END P_WAP_GATEWAY_SERVICE_ZTE_DAY;
  --
  PROCEDURE P_WAP_GATEWAY_SERVICE_ZTE_BH(P_FECHA IN VARCHAR2) IS
  --
    CURSOR cur(P_FECHA VARCHAR2) IS
    SELECT  FECHA,
            WAP_BROWSER_REQUEST_NUMBER,
            WAP_BROWSER_REQ_SUCCESS_RATIO,
            HTTP_BROWSER_REQUEST_NUMBER,
            HTTP_BROWSER_REQ_SUCCESS_RATIO,
            JAVA_DNLD_REQ_SUCCESS_RATIO,
            JAVA_DOWNLOAD_REQUEST_NUMBER,
            MMS_POST_REQUEST_NUMBER,
            MMS_POST_REQUEST_SUCCESS_RATIO,
            MMS_GET_REQUEST_NUMBER,
            MMS_GET_REQUEST_RATIO,
            PUSH_REQUEST_NUMBER,
            PUSH_REQUEST_SUCCESS_RATIO,
            RADIUS_REQUEST_NUMBER,
            RADIUS_REQUEST_SUCCESS_RATIO,
            REQUEST_NUMBER,
            REQUEST_SUCCESS_RATIO,
            ONLINE_USER_NUMBER,
            GATEWAY_FORWARD_REQUEST_DELAY,
            GATEWAY_FORWARD_RESPONSE_DELAY,
            SP_DELAY,
            SERVICE_DELAY
    FROM  (
          SELECT  to_char(TIME_,'dd.mm.yyyy HH24:MI') FECHA,
                  WAP_BROWSER_REQUEST_NUMBER,
                  WAP_BROWSER_REQ_SUCCESS_RATIO,
                  HTTP_BROWSER_REQUEST_NUMBER,
                  HTTP_BROWSER_REQ_SUCCESS_RATIO,
                  JAVA_DNLD_REQ_SUCCESS_RATIO,
                  JAVA_DOWNLOAD_REQUEST_NUMBER,
                  MMS_POST_REQUEST_NUMBER,
                  MMS_POST_REQUEST_SUCCESS_RATIO,
                  MMS_GET_REQUEST_NUMBER,
                  MMS_GET_REQUEST_RATIO,
                  PUSH_REQUEST_NUMBER,
                  PUSH_REQUEST_SUCCESS_RATIO,
                  RADIUS_REQUEST_NUMBER,
                  RADIUS_REQUEST_SUCCESS_RATIO,
                  REQUEST_NUMBER,
                  REQUEST_SUCCESS_RATIO,
                  ONLINE_USER_NUMBER,
                  GATEWAY_FORWARD_REQUEST_DELAY,
                  GATEWAY_FORWARD_RESPONSE_DELAY,
                  SP_DELAY,
                  SERVICE_DELAY,                 
                  ROW_NUMBER() OVER (PARTITION BY TRUNC(time_,'DAY')
                                                 --REQUEST_NUMBER
                              ORDER BY trunc(time_) DESC,
                                       REQUEST_NUMBER DESC NULLS LAST) SEQNUM
                FROM WAP_GATEWAY_SERVICE_ZTE_RAW
                WHERE trunc(time_) = TO_DATE(P_FECHA,'DD.MM.YYYY')
        )
        WHERE SEQNUM = 1;
    --
    TYPE t_wap_gateway_service_zte_tab IS TABLE OF WAP_GATEWAY_SERVICE_ZTE_BH%ROWTYPE;
    v_wap_gateway_service_zte_tab t_wap_gateway_service_zte_tab;
    --
    l_errors number;
    l_errno  number;
    l_msg    VARCHAR2(4000 CHAR);
    l_idx    number;
    --
  BEGIN
    OPEN cur(P_FECHA);
    LOOP
      FETCH cur BULK COLLECT INTO v_wap_gateway_service_zte_tab LIMIT limit_in;
      BEGIN
        FORALL indice IN INDICES OF v_wap_gateway_service_zte_tab
          INSERT INTO WAP_GATEWAY_SERVICE_ZTE_BH
          VALUES v_wap_gateway_service_zte_tab(indice);
        
        EXCEPTION
          WHEN OTHERS THEN
            L_ERRORS := SQL%BULK_EXCEPTIONS.COUNT;
            FOR indice IN 1 .. L_ERRORS
            LOOP
              L_ERRNO := SQL%BULK_EXCEPTIONS(indice).ERROR_CODE;
              L_MSG   := SQLERRM(-L_ERRNO);
              L_IDX   := SQL%BULK_EXCEPTIONS(indice).ERROR_INDEX;
              --
              g_error_log_new.P_LOG_ERROR('P_WAP_GATEWAY_SERVICE_ZTE_BH',
                                          L_ERRNO,
                                          L_MSG,
                                          'FECHA => '                           ||v_wap_gateway_service_zte_tab(L_IDX).FECHA||
                                          ' WAP_BROWSER_REQUEST_NUMBER => '     ||to_char(v_wap_gateway_service_zte_tab(L_IDX).WAP_BROWSER_REQUEST_NUMBER)||
                                          ' WAP_BROWSER_REQ_SUCCESS_RATIO => '  ||to_char(v_wap_gateway_service_zte_tab(L_IDX).WAP_BROWSER_REQ_SUCCESS_RATIO)||
                                          ' HTTP_BROWSER_REQUEST_NUMBER => '    ||to_char(v_wap_gateway_service_zte_tab(L_IDX).HTTP_BROWSER_REQUEST_NUMBER)||
                                          ' HTTP_BROWSER_REQ_SUCCESS_RATIO => ' ||to_char(v_wap_gateway_service_zte_tab(L_IDX).HTTP_BROWSER_REQ_SUCCESS_RATIO)||
                                          ' JAVA_DNLD_REQ_SUCCESS_RATIO => '    ||to_char(v_wap_gateway_service_zte_tab(L_IDX).JAVA_DNLD_REQ_SUCCESS_RATIO)||
                                          ' JAVA_DNLD_REQ_SUCCESS_RATIO => '    ||to_char(v_wap_gateway_service_zte_tab(L_IDX).JAVA_DOWNLOAD_REQUEST_NUMBER)||
                                          ' MMS_POST_REQUEST_NUMBER => '        ||to_char(v_wap_gateway_service_zte_tab(L_IDX).MMS_POST_REQUEST_NUMBER)||
                                          ' MMS_POST_REQUEST_SUCCESS_RATIO => ' ||to_char(v_wap_gateway_service_zte_tab(L_IDX).MMS_POST_REQUEST_SUCCESS_RATIO)||
                                          ' MMS_GET_REQUEST_NUMBER => '         ||to_char(v_wap_gateway_service_zte_tab(L_IDX).MMS_GET_REQUEST_NUMBER)||
                                          ' MMS_GET_REQUEST_RATIO => '          ||to_char(v_wap_gateway_service_zte_tab(L_IDX).MMS_GET_REQUEST_RATIO)||
                                          ' PUSH_REQUEST_NUMBER => '            ||to_char(v_wap_gateway_service_zte_tab(L_IDX).PUSH_REQUEST_NUMBER)||
                                          ' PUSH_REQUEST_SUCCESS_RATIO => '     ||to_char(v_wap_gateway_service_zte_tab(L_IDX).PUSH_REQUEST_SUCCESS_RATIO)||
                                          ' RADIUS_REQUEST_NUMBER => '          ||to_char(v_wap_gateway_service_zte_tab(L_IDX).RADIUS_REQUEST_NUMBER)||
                                          ' RADIUS_REQUEST_SUCCESS_RATIO => '   ||to_char(v_wap_gateway_service_zte_tab(L_IDX).RADIUS_REQUEST_SUCCESS_RATIO)||
                                          ' REQUEST_NUMBER => '                 ||to_char(v_wap_gateway_service_zte_tab(L_IDX).REQUEST_NUMBER)||
                                          ' REQUEST_SUCCESS_RATIO => '          ||to_char(v_wap_gateway_service_zte_tab(L_IDX).REQUEST_SUCCESS_RATIO)||
                                          ' ONLINE_USER_NUMBER => '             ||to_char(v_wap_gateway_service_zte_tab(L_IDX).ONLINE_USER_NUMBER)||
                                          ' GATEWAY_FORWARD_REQUEST_DELAY => '  ||to_char(v_wap_gateway_service_zte_tab(L_IDX).GATEWAY_FORWARD_REQUEST_DELAY)||
                                          ' GATEWAY_FORWARD_RESPONSE_DELAY => ' ||to_char(v_wap_gateway_service_zte_tab(L_IDX).GATEWAY_FORWARD_RESPONSE_DELAY)||
                                          ' SP_DELAY => '                       ||to_char(v_wap_gateway_service_zte_tab(L_IDX).SP_DELAY)||
                                          ' SERVICE_DELAY => '                  ||to_char(v_wap_gateway_service_zte_tab(L_IDX).SERVICE_DELAY));
            END LOOP;
      END;
      EXIT WHEN cur%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE cur;
    
    EXCEPTION
      WHEN OTHERS THEN
        g_error_log_new.P_LOG_ERROR('P_WAP_GATEWAY_SERVICE_ZTE_BH',
                                    SQLCODE,
                                    SQLERRM,
                                    'Fallo al insertar los datos');
  END P_WAP_GATEWAY_SERVICE_ZTE_BH;
  --
  PROCEDURE P_WAP_GATEWAY_SERVICE_ZTE_IBHW(P_FECHA_DOMINGO IN VARCHAR2,P_FECHA_SABADO IN VARCHAR2) IS
    --
    CURSOR cur(fecha_desde varchar2, fecha_hasta varchar2) IS
    SELECT  fecha_desde                                         FECHA,
            ROUND(NVL(AVG(WAP_BROWSER_REQUEST_NUMBER),0),2)      WAP_BROWSER_REQUEST_NUMBER,
            ROUND(NVL(AVG(WAP_BROWSER_REQ_SUCCESS_RATIO),0),2)   WAP_BROWSER_REQ_SUCCESS_RATIO,
            ROUND(NVL(AVG(HTTP_BROWSER_REQUEST_NUMBER),0),2)     HTTP_BROWSER_REQUEST_NUMBER,
            ROUND(NVL(AVG(HTTP_BROWSER_REQ_SUCCESS_RATIO),0),2)  HTTP_BROWSER_REQ_SUCCESS_RATIO,
            ROUND(NVL(AVG(JAVA_DNLD_REQ_SUCCESS_RATIO),0),2)     JAVA_DNLD_REQ_SUCCESS_RATIO,
            ROUND(NVL(AVG(JAVA_DOWNLOAD_REQUEST_NUMBER),0),2)    JAVA_DOWNLOAD_REQUEST_NUMBER,
            ROUND(NVL(AVG(MMS_POST_REQUEST_NUMBER),0),2)         MMS_POST_REQUEST_NUMBER,
            ROUND(NVL(AVG(MMS_POST_REQUEST_SUCCESS_RATIO),0),2)  MMS_POST_REQUEST_SUCCESS_RATIO,
            ROUND(NVL(AVG(MMS_GET_REQUEST_NUMBER),0),2)          MMS_GET_REQUEST_NUMBER,
            ROUND(NVL(AVG(MMS_GET_REQUEST_RATIO),0),2)           MMS_GET_REQUEST_RATIO,
            ROUND(NVL(AVG(PUSH_REQUEST_NUMBER),0),2)             PUSH_REQUEST_NUMBER,
            ROUND(NVL(AVG(PUSH_REQUEST_SUCCESS_RATIO),0),2)      PUSH_REQUEST_SUCCESS_RATIO,
            ROUND(NVL(AVG(RADIUS_REQUEST_NUMBER),0),2)           RADIUS_REQUEST_NUMBER,
            ROUND(NVL(AVG(RADIUS_REQUEST_SUCCESS_RATIO),0),2)    RADIUS_REQUEST_SUCCESS_RATIO,
            ROUND(NVL(AVG(REQUEST_NUMBER),0),2)                  REQUEST_NUMBER,
            ROUND(NVL(AVG(REQUEST_SUCCESS_RATIO),0),2)           REQUEST_SUCCESS_RATIO,
            ROUND(NVL(AVG(ONLINE_USER_NUMBER),0),2)              ONLINE_USER_NUMBER,
            ROUND(NVL(AVG(GATEWAY_FORWARD_REQUEST_DELAY),0),2)   GATEWAY_FORWARD_REQUEST_DELAY,
            ROUND(NVL(AVG(GATEWAY_FORWARD_RESPONSE_DELAY),0),2)  GATEWAY_FORWARD_RESPONSE_DELAY,
            ROUND(NVL(AVG(SP_DELAY),0),2)                        SP_DELAY,
            ROUND(NVL(AVG(SERVICE_DELAY),0),2)                   SERVICE_DELAY
    FROM (
          SELECT  trunc(fecha,'DAY') fecha,
                  WAP_BROWSER_REQUEST_NUMBER,
                  WAP_BROWSER_REQ_SUCCESS_RATIO,
                  HTTP_BROWSER_REQUEST_NUMBER,
                  HTTP_BROWSER_REQ_SUCCESS_RATIO,
                  JAVA_DNLD_REQ_SUCCESS_RATIO,
                  JAVA_DOWNLOAD_REQUEST_NUMBER,
                  MMS_POST_REQUEST_NUMBER,
                  MMS_POST_REQUEST_SUCCESS_RATIO,
                  MMS_GET_REQUEST_NUMBER,
                  MMS_GET_REQUEST_RATIO,
                  PUSH_REQUEST_NUMBER,
                  PUSH_REQUEST_SUCCESS_RATIO,
                  RADIUS_REQUEST_NUMBER,
                  RADIUS_REQUEST_SUCCESS_RATIO,
                  REQUEST_NUMBER,
                  REQUEST_SUCCESS_RATIO,
                  ONLINE_USER_NUMBER,
                  GATEWAY_FORWARD_REQUEST_DELAY,
                  GATEWAY_FORWARD_RESPONSE_DELAY,
                  SP_DELAY,
                  SERVICE_DELAY,
                  row_number() OVER (PARTITION BY trunc(fecha,'DAY')
                                        ORDER BY (REQUEST_NUMBER) DESC NULLS LAST) seqnum
          from WAP_GATEWAY_SERVICE_ZTE_BH)--BH
    where SEQNUM <= LIMIT_PROM
    AND fecha BETWEEN to_date(fecha_desde,'dd.mm.yyyy') AND to_date(fecha_hasta,'dd.mm.yyyy')
    GROUP BY fecha;
    --
    l_errors number;
    l_errno  number;
    l_msg    varchar2(4000);
    l_idx    number;
    --
    TYPE t_wap_gtw_srv_zte_ibhw_row IS TABLE OF WAP_GATEWAY_SERVICE_ZTE_IBHW%rowtype;
    v_wap_gtw_srv_zte_ibhw_tab t_wap_gtw_srv_zte_ibhw_row;
  BEGIN
  OPEN cur(P_FECHA_DOMINGO,P_FECHA_SABADO);
    LOOP
      FETCH cur bulk collect into v_wap_gtw_srv_zte_ibhw_tab limit limit_in;
      BEGIN
        FORALL indice IN 1 .. v_wap_gtw_srv_zte_ibhw_tab.COUNT SAVE EXCEPTIONS
          INSERT INTO WAP_GATEWAY_SERVICE_ZTE_IBHW values v_wap_gtw_srv_zte_ibhw_tab(indice);
        EXCEPTION
          WHEN OTHERS THEN
            L_ERRORS := SQL%BULK_EXCEPTIONS.COUNT;
            FOR indice IN 1 .. L_ERRORS
            LOOP
                L_ERRNO := SQL%BULK_EXCEPTIONS(indice).ERROR_CODE;
                L_MSG   := SQLERRM(-L_ERRNO);
                L_IDX   := SQL%BULK_EXCEPTIONS(indice).ERROR_INDEX;
                
                G_ERROR_LOG_NEW.P_LOG_ERROR('P_WAP_GATEWAY_SERVICE_ZTE_IBHW',
                                            l_errno,
                                            l_msg,
                                            'FECHA => '                           ||v_wap_gtw_srv_zte_ibhw_tab(L_IDX).FECHA||
                                            ' WAP_BROWSER_REQUEST_NUMBER => '     ||to_char(v_wap_gtw_srv_zte_ibhw_tab(L_IDX).WAP_BROWSER_REQUEST_NUMBER)||
                                            ' WAP_BROWSER_REQ_SUCCESS_RATIO => '  ||to_char(v_wap_gtw_srv_zte_ibhw_tab(L_IDX).WAP_BROWSER_REQ_SUCCESS_RATIO)||
                                            ' HTTP_BROWSER_REQUEST_NUMBER => '    ||to_char(v_wap_gtw_srv_zte_ibhw_tab(L_IDX).HTTP_BROWSER_REQUEST_NUMBER)||
                                            ' HTTP_BROWSER_REQ_SUCCESS_RATIO => ' ||to_char(v_wap_gtw_srv_zte_ibhw_tab(L_IDX).HTTP_BROWSER_REQ_SUCCESS_RATIO)||
                                            ' JAVA_DNLD_REQ_SUCCESS_RATIO => '    ||to_char(v_wap_gtw_srv_zte_ibhw_tab(L_IDX).JAVA_DNLD_REQ_SUCCESS_RATIO)||
                                            ' JAVA_DNLD_REQ_SUCCESS_RATIO => '    ||to_char(v_wap_gtw_srv_zte_ibhw_tab(L_IDX).JAVA_DOWNLOAD_REQUEST_NUMBER)||
                                            ' MMS_POST_REQUEST_NUMBER => '        ||to_char(v_wap_gtw_srv_zte_ibhw_tab(L_IDX).MMS_POST_REQUEST_NUMBER)||
                                            ' MMS_POST_REQUEST_SUCCESS_RATIO => ' ||to_char(v_wap_gtw_srv_zte_ibhw_tab(L_IDX).MMS_POST_REQUEST_SUCCESS_RATIO)||
                                            ' MMS_GET_REQUEST_NUMBER => '         ||to_char(v_wap_gtw_srv_zte_ibhw_tab(L_IDX).MMS_GET_REQUEST_NUMBER)||
                                            ' MMS_GET_REQUEST_RATIO => '          ||to_char(v_wap_gtw_srv_zte_ibhw_tab(L_IDX).MMS_GET_REQUEST_RATIO)||
                                            ' PUSH_REQUEST_NUMBER => '            ||to_char(v_wap_gtw_srv_zte_ibhw_tab(L_IDX).PUSH_REQUEST_NUMBER)||
                                            ' PUSH_REQUEST_SUCCESS_RATIO => '     ||to_char(v_wap_gtw_srv_zte_ibhw_tab(L_IDX).PUSH_REQUEST_SUCCESS_RATIO)||
                                            ' RADIUS_REQUEST_NUMBER => '          ||to_char(v_wap_gtw_srv_zte_ibhw_tab(L_IDX).RADIUS_REQUEST_NUMBER)||
                                            ' RADIUS_REQUEST_SUCCESS_RATIO => '   ||to_char(v_wap_gtw_srv_zte_ibhw_tab(L_IDX).RADIUS_REQUEST_SUCCESS_RATIO)||
                                            ' REQUEST_NUMBER => '                 ||to_char(v_wap_gtw_srv_zte_ibhw_tab(L_IDX).REQUEST_NUMBER)||
                                            ' REQUEST_SUCCESS_RATIO => '          ||to_char(v_wap_gtw_srv_zte_ibhw_tab(L_IDX).REQUEST_SUCCESS_RATIO)||
                                            ' ONLINE_USER_NUMBER => '             ||to_char(v_wap_gtw_srv_zte_ibhw_tab(L_IDX).ONLINE_USER_NUMBER)||
                                            ' GATEWAY_FORWARD_REQUEST_DELAY => '  ||to_char(v_wap_gtw_srv_zte_ibhw_tab(L_IDX).GATEWAY_FORWARD_REQUEST_DELAY)||
                                            ' GATEWAY_FORWARD_RESPONSE_DELAY => ' ||to_char(v_wap_gtw_srv_zte_ibhw_tab(L_IDX).GATEWAY_FORWARD_RESPONSE_DELAY)||
                                            ' SP_DELAY => '                       ||to_char(v_wap_gtw_srv_zte_ibhw_tab(L_IDX).SP_DELAY)||
                                            ' SERVICE_DELAY => '                  ||to_char(v_wap_gtw_srv_zte_ibhw_tab(L_IDX).SERVICE_DELAY));
            END LOOP;
      END;
      EXIT WHEN cur%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE cur;
    --
    EXCEPTION
      WHEN others THEN
        G_ERROR_LOG_NEW.P_LOG_ERROR('P_WAP_GATEWAY_SERVICE_ZTE_IBHW',
                                    SQLCODE,
                                    SQLERRM,
                                    'P_FECHA_DOMINGO '||P_FECHA_DOMINGO||' P_FECHA_SABADO => '||P_FECHA_SABADO);
  END P_WAP_GATEWAY_SERVICE_ZTE_IBHW;
  --
    PROCEDURE P_CALCULAR_SUMARIZACIONES_ZTE(P_FECHA IN VARCHAR2) IS
    BEGIN
    NULL;
    END P_CALCULAR_SUMARIZACIONES_ZTE;
END G_WAP_ZTE;
/
