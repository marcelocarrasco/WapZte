--------------------------------------------------------
--  DDL for Table WAP_GATEWAY_SERVICE_ZTE_AUX
--------------------------------------------------------

  CREATE TABLE WAP_GATEWAY_SERVICE_ZTE_AUX(	
  HORA VARCHAR2(5 CHAR), 
	WAP_BROWSER_REQUEST_NUMBER NUMBER, 
	WAP_BROWSER_REQ_SUCCESS_RATIO NUMBER(6,2), 
	HTTP_BROWSER_REQUEST_NUMBER NUMBER, 
	HTTP_BROWSER_REQ_SUCCESS_RATIO NUMBER(6,2), 
	JAVA_DNLD_REQ_SUCCESS_RATIO NUMBER(6,2), 
	JAVA_DOWNLOAD_REQUEST_NUMBER NUMBER(6,2), 
	MMS_POST_REQUEST_NUMBER NUMBER, 
	MMS_POST_REQUEST_SUCCESS_RATIO NUMBER(6,2), 
	MMS_GET_REQUEST_NUMBER NUMBER, 
	MMS_GET_REQUEST_RATIO NUMBER(6,2), 
	PUSH_REQUEST_NUMBER NUMBER, 
	PUSH_REQUEST_SUCCESS_RATIO NUMBER(6,2), 
	RADIUS_REQUEST_NUMBER NUMBER, 
	RADIUS_REQUEST_SUCCESS_RATIO NUMBER(6,2), 
	REQUEST_NUMBER NUMBER, 
	REQUEST_SUCCESS_RATIO NUMBER(6,2), 
	ONLINE_USER_NUMBER NUMBER, 
	GATEWAY_FORWARD_REQUEST_DELAY NUMBER, 
	GATEWAY_FORWARD_RESPONSE_DELAY NUMBER, 
	SP_DELAY NUMBER, 
	SERVICE_DELAY NUMBER, 
	NOMBRE_CSV VARCHAR2(500 CHAR), 
	TIME_ DATE GENERATED ALWAYS AS (TO_DATE(SUBSTR(SUBSTR(NOMBRE_CSV,INSTR(NOMBRE_CSV,'_',-1)+1,8),7,2)||'.'||SUBSTR(SUBSTR(NOMBRE_CSV,INSTR(NOMBRE_CSV,'_',-1)+1,8),5,2)||'.'||SUBSTR(SUBSTR(NOMBRE_CSV,INSTR(NOMBRE_CSV,'_',-1)+1,8),1,4)||' '||HORA,'dd.mm.yyyy HH24:MI')) VIRTUAL 
   )  
 NOCOMPRESS NOLOGGING
  TABLESPACE TBS_AUXILIAR ;

   COMMENT ON COLUMN WAP_GATEWAY_SERVICE_ZTE_AUX.HTTP_BROWSER_REQ_SUCCESS_RATIO IS 'Abreviatura de la colunma original HTTP_BROWSER_REQUEST_SUCCESS_RATIO';
   COMMENT ON COLUMN WAP_GATEWAY_SERVICE_ZTE_AUX.JAVA_DNLD_REQ_SUCCESS_RATIO IS 'Abreviatura de la colunma original JAVA_DOWNLOAD_REQUEST_SUCCESS_RATIO';
--------------------------------------------------------
--  Constraints for Table WAP_GATEWAY_SERVICE_ZTE_AUX
--------------------------------------------------------

  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_AUX MODIFY (SERVICE_DELAY NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_AUX MODIFY (SP_DELAY NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_AUX MODIFY (GATEWAY_FORWARD_RESPONSE_DELAY NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_AUX MODIFY (GATEWAY_FORWARD_REQUEST_DELAY NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_AUX MODIFY (ONLINE_USER_NUMBER NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_AUX MODIFY (REQUEST_SUCCESS_RATIO NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_AUX MODIFY (REQUEST_NUMBER NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_AUX MODIFY (RADIUS_REQUEST_SUCCESS_RATIO NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_AUX MODIFY (RADIUS_REQUEST_NUMBER NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_AUX MODIFY (PUSH_REQUEST_SUCCESS_RATIO NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_AUX MODIFY (PUSH_REQUEST_NUMBER NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_AUX MODIFY (MMS_GET_REQUEST_RATIO NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_AUX MODIFY (MMS_GET_REQUEST_NUMBER NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_AUX MODIFY (MMS_POST_REQUEST_SUCCESS_RATIO NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_AUX MODIFY (MMS_POST_REQUEST_NUMBER NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_AUX MODIFY (JAVA_DOWNLOAD_REQUEST_NUMBER NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_AUX MODIFY (JAVA_DNLD_REQ_SUCCESS_RATIO NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_AUX MODIFY (HTTP_BROWSER_REQ_SUCCESS_RATIO NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_AUX MODIFY (HTTP_BROWSER_REQUEST_NUMBER NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_AUX MODIFY (WAP_BROWSER_REQ_SUCCESS_RATIO NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_AUX MODIFY (WAP_BROWSER_REQUEST_NUMBER NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_AUX MODIFY (HORA NOT NULL ENABLE);
