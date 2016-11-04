--------------------------------------------------------
--  DDL for Table WAP_GATEWAY_SERVICE_ZTE_DAY
--------------------------------------------------------

  CREATE TABLE WAP_GATEWAY_SERVICE_ZTE_DAY 
   (	FECHA DATE, 
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
	SERVICE_DELAY NUMBER
   ) 
 NOCOMPRESS NOLOGGING
  TABLESPACE TBS_DAY ;

   COMMENT ON COLUMN WAP_GATEWAY_SERVICE_ZTE_DAY.HTTP_BROWSER_REQ_SUCCESS_RATIO IS 'Abreviatura de la colunma original HTTP_BROWSER_REQUEST_SUCCESS_RATIO';
   COMMENT ON COLUMN WAP_GATEWAY_SERVICE_ZTE_DAY.JAVA_DNLD_REQ_SUCCESS_RATIO IS 'Abreviatura de la colunma original JAVA_DOWNLOAD_REQUEST_SUCCESS_RATIO';
--------------------------------------------------------
--  DDL for Index WAP_GATEWAY_SERVICE_ZTE_DAY_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX WAP_GATEWAY_SERVICE_ZTE_DAY_PK ON WAP_GATEWAY_SERVICE_ZTE_DAY (FECHA) 
  TABLESPACE TBS_DAY ;
--------------------------------------------------------
--  Constraints for Table WAP_GATEWAY_SERVICE_ZTE_DAY
--------------------------------------------------------

  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_DAY ADD CONSTRAINT WAP_GATEWAY_SERVICE_ZTE_DAY_PK PRIMARY KEY (FECHA)  ENABLE;
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_DAY MODIFY (SERVICE_DELAY NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_DAY MODIFY (SP_DELAY NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_DAY MODIFY (GATEWAY_FORWARD_RESPONSE_DELAY NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_DAY MODIFY (GATEWAY_FORWARD_REQUEST_DELAY NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_DAY MODIFY (ONLINE_USER_NUMBER NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_DAY MODIFY (REQUEST_SUCCESS_RATIO NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_DAY MODIFY (REQUEST_NUMBER NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_DAY MODIFY (RADIUS_REQUEST_SUCCESS_RATIO NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_DAY MODIFY (RADIUS_REQUEST_NUMBER NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_DAY MODIFY (PUSH_REQUEST_SUCCESS_RATIO NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_DAY MODIFY (PUSH_REQUEST_NUMBER NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_DAY MODIFY (MMS_GET_REQUEST_RATIO NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_DAY MODIFY (MMS_GET_REQUEST_NUMBER NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_DAY MODIFY (MMS_POST_REQUEST_SUCCESS_RATIO NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_DAY MODIFY (MMS_POST_REQUEST_NUMBER NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_DAY MODIFY (JAVA_DOWNLOAD_REQUEST_NUMBER NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_DAY MODIFY (JAVA_DNLD_REQ_SUCCESS_RATIO NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_DAY MODIFY (HTTP_BROWSER_REQ_SUCCESS_RATIO NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_DAY MODIFY (HTTP_BROWSER_REQUEST_NUMBER NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_DAY MODIFY (WAP_BROWSER_REQ_SUCCESS_RATIO NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_DAY MODIFY (WAP_BROWSER_REQUEST_NUMBER NOT NULL ENABLE);
  ALTER TABLE WAP_GATEWAY_SERVICE_ZTE_DAY MODIFY (FECHA NOT NULL ENABLE);