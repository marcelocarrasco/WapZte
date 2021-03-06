--------------------------------------------------------
--  DDL for Table TEC_CE_CM_TPS_DAY
--------------------------------------------------------

  CREATE TABLE TEC_CE_CM_TPS_DAY 
   (	FECHA DATE, 
	PAIS CHAR(3 CHAR), 
	MAX_TPS NUMBER, 
	MAX_CAP_HW NUMBER, 
	MAX_CAP_SW NUMBER, 
	UTIL_HW NUMBER(10,2), 
	UTIL_SW NUMBER(10,2)
   ) 
 NOCOMPRESS LOGGING
  TABLESPACE TBS_DAY ;
--------------------------------------------------------
--  DDL for Index TEC_CE_CM_TPS_DAY_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX TEC_CE_CM_TPS_DAY_PK ON TEC_CE_CM_TPS_DAY (PAIS, FECHA) 
  TABLESPACE TBS_DAY ;
--------------------------------------------------------
--  Constraints for Table TEC_CE_CM_TPS_DAY
--------------------------------------------------------

  ALTER TABLE TEC_CE_CM_TPS_DAY ADD CONSTRAINT TEC_CE_CM_TPS_DAY_PK PRIMARY KEY (PAIS, FECHA)  ENABLE;
  ALTER TABLE TEC_CE_CM_TPS_DAY MODIFY (UTIL_SW NOT NULL ENABLE);
  ALTER TABLE TEC_CE_CM_TPS_DAY MODIFY (UTIL_HW NOT NULL ENABLE);
  ALTER TABLE TEC_CE_CM_TPS_DAY MODIFY (MAX_CAP_SW NOT NULL ENABLE);
  ALTER TABLE TEC_CE_CM_TPS_DAY MODIFY (MAX_CAP_HW NOT NULL ENABLE);
  ALTER TABLE TEC_CE_CM_TPS_DAY MODIFY (MAX_TPS NOT NULL ENABLE);
  ALTER TABLE TEC_CE_CM_TPS_DAY MODIFY (PAIS NOT NULL ENABLE);
  ALTER TABLE TEC_CE_CM_TPS_DAY MODIFY (FECHA NOT NULL ENABLE);
