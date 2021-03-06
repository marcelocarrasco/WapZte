--------------------------------------------------------
--  DDL for Table MOBILEUM_ASP_IBHW
--------------------------------------------------------

  CREATE TABLE MOBILEUM_ASP_IBHW 
   (	PAIS CHAR(3 CHAR), 
	FECHA DATE, 
	CNT_LLAMADAS NUMBER, 
	CNT_POLITICA_RESTRICCION NUMBER, 
	CNT_BOLQ_REL_TIPO_GEST NUMBER, 
	CNT_BLOQ_RAN_REL NUMBER, 
	CNT_PERMITIERON_CONTINUAR NUMBER, 
	CNT_CONECTADAS_VOICE_MAIL NUMBER, 
	CNT_CONECTADA_ANUNCIO_SWITCH NUMBER
   ) 
 NOCOMPRESS NOLOGGING
  TABLESPACE TBS_SUMMARY ;

   COMMENT ON TABLE MOBILEUM_ASP_IBHW  IS 'Sumarizaciones del MOBILEUM_ASP a nivel IBHW';
--------------------------------------------------------
--  Constraints for Table MOBILEUM_ASP_IBHW
--------------------------------------------------------

  ALTER TABLE MOBILEUM_ASP_IBHW MODIFY (CNT_CONECTADA_ANUNCIO_SWITCH NOT NULL ENABLE);
  ALTER TABLE MOBILEUM_ASP_IBHW MODIFY (CNT_CONECTADAS_VOICE_MAIL NOT NULL ENABLE);
  ALTER TABLE MOBILEUM_ASP_IBHW MODIFY (CNT_PERMITIERON_CONTINUAR NOT NULL ENABLE);
  ALTER TABLE MOBILEUM_ASP_IBHW MODIFY (CNT_BLOQ_RAN_REL NOT NULL ENABLE);
  ALTER TABLE MOBILEUM_ASP_IBHW MODIFY (CNT_BOLQ_REL_TIPO_GEST NOT NULL ENABLE);
  ALTER TABLE MOBILEUM_ASP_IBHW MODIFY (CNT_POLITICA_RESTRICCION NOT NULL ENABLE);
  ALTER TABLE MOBILEUM_ASP_IBHW MODIFY (CNT_LLAMADAS NOT NULL ENABLE);
  ALTER TABLE MOBILEUM_ASP_IBHW MODIFY (FECHA NOT NULL ENABLE);
  ALTER TABLE MOBILEUM_ASP_IBHW MODIFY (PAIS NOT NULL ENABLE);
