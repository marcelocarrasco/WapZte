--------------------------------------------------------
--  DDL for Table TEC_CE_CDC_TPS_AUX
--------------------------------------------------------

  CREATE TABLE TEC_CE_CDC_TPS_AUX 
   (	START_DTIME VARCHAR2(20 CHAR), 
	END_DTIME VARCHAR2(20 CHAR), 
	PAIS CHAR(3 CHAR) GENERATED ALWAYS AS (CASE   WHEN INSTR(ARCHIVO,'/arce/')<>0 THEN 'ARG' 
                                                WHEN INSTR(ARCHIVO,'/pyce/')<>0 THEN 'PRY' 
                                                WHEN INSTR(ARCHIVO,'/uyce/')<>0 THEN 'URY' 
                                                ELSE 'S/P' END) VIRTUAL , 
	MAX_TPS NUMBER, 
	MAX_CAP_HW NUMBER DEFAULT 1, 
	MAX_CAP_SW NUMBER DEFAULT 1, 
	ARCHIVO VARCHAR2(500 CHAR)
   ) 
 NOCOMPRESS NOLOGGING
  TABLESPACE TBS_AUXILIAR ;
--------------------------------------------------------
--  Constraints for Table TEC_CE_CDC_TPS_AUX
--------------------------------------------------------

  ALTER TABLE TEC_CE_CDC_TPS_AUX MODIFY (ARCHIVO NOT NULL ENABLE);
