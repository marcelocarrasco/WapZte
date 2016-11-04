--------------------------------------------------------
--  DDL for Table TEC_CE_CM_TPS_IBHW
--------------------------------------------------------

  CREATE TABLE TEC_CE_CM_TPS_IBHW 
   (	FECHA DATE, 
	PAIS CHAR(3 CHAR), 
	MAX_TPS NUMBER, 
	MAX_CAP_HW NUMBER, 
	MAX_CAP_SW NUMBER, 
	UTIL_HW NUMBER(10,2), 
	UTIL_SW NUMBER(10,2)
   ) 
 NOCOMPRESS LOGGING
  TABLESPACE TBS_SUMMARY ;
--------------------------------------------------------
--  DDL for Index TEC_CE_CM_TPS_IBHW_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX TEC_CE_CM_TPS_IBHW_PK ON TEC_CE_CM_TPS_IBHW (PAIS, FECHA) 
  TABLESPACE TBS_SUMMARY ;
--------------------------------------------------------
--  Constraints for Table TEC_CE_CM_TPS_IBHW
--------------------------------------------------------

  ALTER TABLE TEC_CE_CM_TPS_IBHW ADD CONSTRAINT TEC_CE_CM_TPS_IBHW_PK PRIMARY KEY (PAIS, FECHA) ENABLE;
  ALTER TABLE TEC_CE_CM_TPS_IBHW MODIFY (UTIL_SW NOT NULL ENABLE);
  ALTER TABLE TEC_CE_CM_TPS_IBHW MODIFY (UTIL_HW NOT NULL ENABLE);
  ALTER TABLE TEC_CE_CM_TPS_IBHW MODIFY (MAX_CAP_SW NOT NULL ENABLE);
  ALTER TABLE TEC_CE_CM_TPS_IBHW MODIFY (MAX_CAP_HW NOT NULL ENABLE);
  ALTER TABLE TEC_CE_CM_TPS_IBHW MODIFY (MAX_TPS NOT NULL ENABLE);
  ALTER TABLE TEC_CE_CM_TPS_IBHW MODIFY (PAIS NOT NULL ENABLE);
  ALTER TABLE TEC_CE_CM_TPS_IBHW MODIFY (FECHA NOT NULL ENABLE);
