--------------------------------------------------------
--  DDL for Table TEC_CE_CM_TPS_HOUR
--------------------------------------------------------

  CREATE TABLE TEC_CE_CM_TPS_HOUR 
   (	FECHA DATE, 
	PAIS CHAR(3 CHAR), 
	MAX_TPS NUMBER, 
	MAX_CAP_HW NUMBER DEFAULT 1, 
	MAX_CAP_SW NUMBER DEFAULT 1, 
	UTIL_HW NUMBER(10,2) GENERATED ALWAYS AS (MAX_TPS/MAX_CAP_HW) VIRTUAL , 
	UTIL_SW NUMBER(10,2) GENERATED ALWAYS AS (MAX_TPS/MAX_CAP_SW) VIRTUAL 
   ) 
 NOCOMPRESS LOGGING
  TABLESPACE TBS_HOUR ;
--------------------------------------------------------
--  DDL for Index TEC_CE_CM_TPS_HOUR_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX TEC_CE_CM_TPS_HOUR_PK ON TEC_CE_CM_TPS_HOUR (PAIS, FECHA) 
  TABLESPACE TBS_HOUR ;
--------------------------------------------------------
--  Constraints for Table TEC_CE_CM_TPS_HOUR
--------------------------------------------------------

  ALTER TABLE TEC_CE_CM_TPS_HOUR ADD CONSTRAINT TEC_CE_CM_TPS_HOUR_PK PRIMARY KEY (PAIS, FECHA) ENABLE;
  ALTER TABLE TEC_CE_CM_TPS_HOUR MODIFY (MAX_CAP_SW NOT NULL ENABLE);
  ALTER TABLE TEC_CE_CM_TPS_HOUR MODIFY (MAX_CAP_HW NOT NULL ENABLE);
  ALTER TABLE TEC_CE_CM_TPS_HOUR MODIFY (MAX_TPS NOT NULL ENABLE);
  ALTER TABLE TEC_CE_CM_TPS_HOUR MODIFY (PAIS NOT NULL ENABLE);
  ALTER TABLE TEC_CE_CM_TPS_HOUR MODIFY (FECHA NOT NULL ENABLE);
