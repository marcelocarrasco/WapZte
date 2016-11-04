--------------------------------------------------------
--  DDL for Table TEC_CE_CDC_TPS_AUX_TEMPLATE
--------------------------------------------------------

  CREATE TABLE TEC_CE_CDC_TPS_AUX_TEMPLATE 
   (	START_DTIME VARCHAR2(20 CHAR), 
	END_DTIME VARCHAR2(20 CHAR), 
	PAIS VARCHAR2(20 CHAR), 
	MAX_TPS NUMBER, 
	MAX_CAP_HW NUMBER DEFAULT 1, 
	MAX_CAP_SW NUMBER DEFAULT 1
   ) 
 NOCOMPRESS NOLOGGING
  TABLESPACE TBS_AUXILIAR ;
--------------------------------------------------------
--  DDL for Index TEC_CE_CDC_TPS_AUX_TEMPLATE_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX TEC_CE_CDC_TPS_AUX_TEMPLATE_PK ON TEC_CE_CDC_TPS_AUX_TEMPLATE (PAIS, START_DTIME, END_DTIME)  
  TABLESPACE TBS_AUXILIAR ;
--------------------------------------------------------
--  Constraints for Table TEC_CE_CDC_TPS_AUX_TEMPLATE
--------------------------------------------------------

  ALTER TABLE TEC_CE_CDC_TPS_AUX_TEMPLATE ADD CONSTRAINT TEC_CE_CDC_TPS_AUX_TEMPLATE_PK PRIMARY KEY (PAIS, START_DTIME, END_DTIME)
    ENABLE;
