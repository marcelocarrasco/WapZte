--------------------------------------------------------
--  DDL for Table SVA_OBJECTS
--------------------------------------------------------

  CREATE TABLE SVA_OBJECTS 
   (	FECHA DATE DEFAULT SYSDATE, 
	MAX_CAP_HW NUMBER, 
	MAX_CAP_SW NUMBER, 
	TECNOLOGIA VARCHAR2(100 CHAR), 
	PAIS CHAR(3 CHAR), 
	ACTIVO NUMBER(1,0) DEFAULT 1
   ) 
 NOCOMPRESS NOLOGGING
  TABLESPACE TBS_AUXILIAR ;
--------------------------------------------------------
--  DDL for Index SVA_OBJECTS_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX SVA_OBJECTS_PK ON SVA_OBJECTS (FECHA, TECNOLOGIA, PAIS)
  TABLESPACE TBS_AUXILIAR ;
--------------------------------------------------------
--  Constraints for Table SVA_OBJECTS
--------------------------------------------------------

  ALTER TABLE SVA_OBJECTS ADD CONSTRAINT SVA_OBJECTS_PK PRIMARY KEY (FECHA, TECNOLOGIA, PAIS)  ENABLE;
  ALTER TABLE SVA_OBJECTS ADD CHECK (ACTIVO IN (1,0)) ENABLE;
  ALTER TABLE SVA_OBJECTS MODIFY (ACTIVO NOT NULL ENABLE);
  ALTER TABLE SVA_OBJECTS MODIFY (PAIS NOT NULL ENABLE);
  ALTER TABLE SVA_OBJECTS MODIFY (TECNOLOGIA NOT NULL ENABLE);
  ALTER TABLE SVA_OBJECTS MODIFY (MAX_CAP_SW NOT NULL ENABLE);
  ALTER TABLE SVA_OBJECTS MODIFY (MAX_CAP_HW NOT NULL ENABLE);
  ALTER TABLE SVA_OBJECTS MODIFY (FECHA NOT NULL ENABLE);
