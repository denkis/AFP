  
  
---------------------------------CCICO--------------------------------------------------------------   
INSERT into dchavez.EmpleadoresRelacionAfiliadosFull
SELECT DISTINCT 
            a.idPeriodoInformado,
            a.periodoDevengRemuneracion,
            dpe.rut                                 rutPersona,
            dpa.rut                                 rutPagador,
            a.idMaePlanilla                         planilla,
            CONVERT(BIGINT, null)                   codigoActividadEconomica,
            CONVERT(CHAR(1),null)                   indSubsidio,
            CASE when a.periodoDevengRemuneracion IN ( '20191101', '20191201' ) THEN 'S' ELSE 'N' end cotizanteMes,
            b.nombreCorto AS TIPO,
            SUM( a.montoPesos )                     montoPesos,
            null,
            null
        INTO dchavez.EmpleadoresRelacionAfiliadosFull--#movimientosCuentaCCICO
        FROM dchavez.FctMovimientosCuentaCodAct a
            INNER JOIN DMGestion.DimPersona dpe ON ( a.idPersona = dpe.id)
            INNER JOIN DMGestion.DimPersona dpa ON ( a.idPagador = dpa.id )
            INNER JOIN DMGestion.DimTipoProducto b ON ( a.idTipoProducto = b.id ) 
            INNER JOIN DMGestion.DimGrupoMovimiento c ON ( a.idGrupoMovimiento = c.id )
        WHERE a.idPeriodoInformado = 114
        AND a.idPagador > 0
        --AND a.periodoDevengRemuneracion IN ( '20191101', '20191201' ) 
        AND b.codigo = 1 -- CCICO
        AND c.codigoSubgrupo IN ( 1101, 1105 )
        GROUP BY 
            a.idPeriodoInformado,
            a.periodoDevengRemuneracion,
            rutPersona,
            rutPagador,
            a.idMaePlanilla,
            b.nombreCorto;
            
       
---------------------------------CAV--------------------------------------------------------------        
  INSERT INTO dchavez.EmpleadoresRelacionAfiliadosFull
        SELECT DISTINCT
            a.idPeriodoInformado,
            a.periodoDevengRemuneracion,
            dpe.rut                                 rutPersona,
            dpa.rut                                 rutPagador,
            a.idMaePlanilla                         planilla,
            convert(bigint, null)                   codigoActividadEconomica,
            'N'                                     indSubsidio,
            CASE when a.periodoDevengRemuneracion IN ( '20191101', '20191201' ) THEN 'S' ELSE 'N' end cotizanteMes,
            b.nombreCorto AS TIPO,
            SUM( a.montoPesos )                     montoPesos,
            NULL,
            NULL 
        FROM dchavez.FctMovimientosCuentaCodAct a
            INNER JOIN DMGestion.DimPersona dpe ON ( a.idPersona = dpe.id )
            INNER JOIN DMGestion.DimPersona dpa ON ( a.idPagador = dpa.id )
            INNER JOIN DMGestion.DimTipoProducto b ON ( a.idTipoProducto = b.id ) 
            INNER JOIN DMGestion.DimGrupoMovimiento c ON ( a.idGrupoMovimiento = c.id )
        WHERE a.idPeriodoInformado = 114
        AND a.idPagador > 0
        --AND a.periodoDevengRemuneracion IN ( ldtPeriodoCotizacion, ldtPeriodoCotizacionAdelantado ) 
        AND b.codigo = 2 -- CAV
        AND c.codigoSubgrupo = 1101
        GROUP BY 
            a.idPeriodoInformado,
            a.periodoDevengRemuneracion,
            rutPersona,
            rutPagador,
            a.idMaePlanilla,
            b.nombreCorto;

        
---------------------------------APV--------------------------------------------------------------        
        INSERT INTO dchavez.EmpleadoresRelacionAfiliadosFull
        SELECT DISTINCT
            a.idPeriodoInformado,
            a.periodoDevengRemuneracion,
            dpe.rut                                 rutPersona,
            dpa.rut                                 rutPagador,
            a.idMaePlanilla                         planilla,
            convert(bigint, null)                   codigoActividadEconomica,
            'N'                                     indSubsidio,
            CASE when a.periodoDevengRemuneracion IN ( '20191101', '20191201' ) THEN 'S' ELSE 'N' end cotizanteMes,
            b.nombreCorto AS TIPO,
            SUM( a.montoPesos )                     montoPesos,
            NULL,
            NULL
         FROM dchavez.FctMovimientosCuentaCodAct a
            INNER JOIN DMGestion.DimPersona dpe ON ( a.idPersona = dpe.id )
            INNER JOIN DMGestion.DimPersona dpa ON ( a.idPagador = dpa.id )
            INNER JOIN DMGestion.DimTipoProducto b ON ( a.idTipoProducto = b.id ) 
            INNER JOIN DMGestion.DimGrupoMovimiento c ON ( a.idGrupoMovimiento = c.id )
        WHERE a.idPeriodoInformado = 114
        AND a.idPagador > 0
        --AND a.periodoDevengRemuneracion IN ( ldtPeriodoCotizacion, ldtPeriodoCotizacionAdelantado ) 
        AND b.codigo IN ( 4, 5 ) -- APV
        AND c.codigoSubgrupo IN ( 1101, 1111 )
        GROUP BY 
            a.idPeriodoInformado,
            a.periodoDevengRemuneracion,
            rutPersona,
            rutPagador,
            a.idMaePlanilla,
            b.nombreCorto;

        SELECT A.rutPersona,a.rutPagador,isnull(tca.COD_ACT_ECONOMICA,0)COD_ACT_ECONOMICA,a.planilla into #codAct
        FROM dchavez.EmpleadoresRelacionAfiliadosFull a
        INNER JOIN DDS.TB_PERSONA_PLANILLA ppl ON (ppl.ID_MAE_PLANILLA = a.Planilla and ind_tipo = 0)
        LEFT OUTER JOIN DDS.TB_COD_ACT_ECONOMICA tca ON (tca.ID_COD_ACT_ECONOMICA = ppl.ID_COD_ACT_ECONOMICA AND tca.IND_ESTADO = 1);
        
    
        --Agrega el código de actividad económico valido para el periodo   
        UPDATE dchavez.EmpleadoresRelacionAfiliadosFull
        SET codigoActividadEconomica = ISNULL(b.COD_ACT_ECONOMICA,0)
        FROM dchavez.EmpleadoresRelacionAfiliadosFull a
        LEFT OUTER JOIN #codAct b on b.rutPersona = a.rutPersona AND a.rutpagador = b.rutPagador and a.planilla = b.planilla;
                         

---------------------------------subsidio--------------------------------------------------------------
            SELECT DISTINCT
            mccico.idPeriodoInformado,
            mccico.rutPersona,
            mccico.rutPagador,
            mccico.periodoDevengRemuneracion
        INTO #relacionAfiliadoSubsidios
        FROM DMGestion.FctRecaudacion a
            INNER JOIN DMGestion.DimPersona dpe ON ( a.idPersona = dpe.id )
            INNER JOIN DMGestion.DimPersona dpa ON ( a.idPagador = dpa.id )
            INNER JOIN DMGestion.DimTipoProducto dtip ON ( a.idTipoProducto = dtip.id )    
            INNER JOIN DMGestion.DimTipoPlanilla dtp ON ( a.idTipoPlanilla = dtp.id ) 
            INNER JOIN dchavez.EmpleadoresRelacionAfiliadosFull mccico ON ( dpe.rut = mccico.rutPersona
                                                 AND dpa.rut = mccico.rutPagador
                                                 AND a.idPeriodoInformado = mccico.idPeriodoInformado
                                                 AND a.periodoCotizacion = mccico.periodoDevengRemuneracion
                                                 AND mccico.tipo = 'CCICO')
        WHERE dtip.codigo = 1 -- CCICO
        AND dtp.codigo = 'S';
        
    
        UPDATE  dchavez.EmpleadoresRelacionAfiliadosFull
        SET indSubsidio = CASE WHEN b.rutPersona is not null then 'S' ELSE 'N' END 
        FROM dchavez.EmpleadoresRelacionAfiliadosFull a 
        LEFT OUTER JOIN #relacionAfiliadoSubsidios b ON (a.rutPersona = b.rutPersona
                                                    AND a.rutPagador = b.rutPagador
                                                    AND a.periodoDevengRemuneracion = b.periodoDevengRemuneracion)
        WHERE a.tipo = 'CCICO'; 
                                                    

---------------------------------------------------------------------------------------------
 
 UPDATE EmpleadoresRelacionAfiliadosFull
 SET calcular = 'N'
 WHERE cotizanteMes = 'N';
 
 
UPDATE  dchavez.EmpleadoresRelacionAfiliadosFull
SET calcular = 'N'
FROM dchavez.EmpleadoresRelacionAfiliadosFull a
where  tipo <> 'CCICO' AND cotizanteMes = 'S'
and rutPErsona in (select rutPersona from dchavez.EmpleadoresRelacionAfiliadosFull
                    where tipo ='CCICO' AND cotizanteMes = 'S');

UPDATE  dchavez.EmpleadoresRelacionAfiliadosFull
SET calcular = 'N'
FROM dchavez.EmpleadoresRelacionAfiliadosFull a
where cotizanteMes = 'S'
and indSubsidio = 'S'
and rutPErsona in (select rutPErsona from dchavez.EmpleadoresRelacionAfiliadosFull
                   where indSubsidio = 'N' AND cotizanteMes = 'S' and TIPO = 'CCICO');               
                
 UPDATE dchavez.EmpleadoresRelacionAfiliadosFull
 SET calcular = 'S'
 WHERE cotizanteMes = 'S'
 AND calcular IS NULL ; 
 

 
  -- A.1.a - Afiliados con una cotizacion en el mes.
        
        SELECT
            rutPersona,
            COUNT(*)        numEmpleador
        INTO #numEmpleador
        FROM dchavez.EmpleadoresRelacionAfiliadosFull
        WHERE calcular = 'S'
        AND cotizanteMes = 'S'
        GROUP BY 
        rutPersona;
    
   
    UPDATE dchavez.EmpleadoresRelacionAfiliadosFull
    SET principal =  'S'
    from dchavez.EmpleadoresRelacionAfiliadosFull a
    inner join #numEmpleador b on a.rutPersona = b.rutPersona and b.numEmpleador = 1
    where a.cotizanteMes= 'S' and a.calcular = 'S';
    

   -- A.1.a - Afiliados con mas de una cotizacion en el mes.
  
    SELECT A.rutPersona,rutPagador,periodoDevengRemuneracion,codigoActividadEconomica,sum(montoPesos) montoPesos, count(planilla)totPlanilla 
    into #EmpleadorRelAfi
    from dchavez.EmpleadoresRelacionAfiliadosFull a
    inner join #numEmpleador b on a.rutPersona = b.rutPersona and b.numEmpleador > 1
    where a.cotizanteMes= 'S' and a.calcular = 'S'
    GROUP by A.rutPersona,rutPagador,periodoDevengRemuneracion,codigoActividadEconomica;
    
    
    select rutPersona,max(montoPesos) montoMayor into #principal2      
    from #EmpleadorRelAfi
    group by rutPersona;

    select a.rutPersona,montoPesos, count(*) into #montosIguales
    from dchavez.EmpleadoresRelacionAfiliadosFull a
    where principal is null
    and cotizanteMes = 'S'
    and a.rutPersona in (select rutPersona from #principal2)
    group by a.rutPersona,montoPesos
    having count(*)> 1;
    
    UPDATE dchavez.EmpleadoresRelacionAfiliadosFull
    SET principal = 'S'
    from dchavez.EmpleadoresRelacionAfiliadosFull a
    INNER JOIN #principal2 p2 on a.rutPersona = p2.rutPersona and a.montoPesos = p2.montoMayor
    where a.cotizanteMes= 'S' and a.calcular = 'S'
    and principal is null
    AND a.rutPersona not in (select rutPersona 
                                from #EmpleadorRelAfi
                                where totPlanilla > 1)
     AND a.rutPersona not in (select rutPersona 
                                from #montosIguales);
                                
    select a.rutpersona,a.planilla,rank() over (partition by a.rutPersona,a.rutPagador order by a.montoPesos,a.planilla) rank into #paso
    From dchavez.EmpleadoresRelacionAfiliadosFull a
    INNER JOIN #principal2 p2 on a.rutPersona = p2.rutPersona
    INNER JOIN #EmpleadorRelAfi afi on afi.rutPersona = p2.rutPersona 
                                       and afi.codigoActividadEconomica = a.codigoActividadEconomica 
                                       and afi.totPlanilla > 1
                                       and afi.rutPagador = a.rutPagador
    where a.cotizanteMes= 'S' and a.calcular = 'S'
    and principal is null;
    
  UPDATE dchavez.EmpleadoresRelacionAfiliadosFull
  SET principal = 'S'
  FROM dchavez.EmpleadoresRelacionAfiliadosFull a
  inner join #paso b on a.rutPersona = b.rutPersona and a.planilla = b.planilla and b.rank=1;
  
  
  ---------------------------------------------MONTOS IGUALES------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------------------------------------------------------------
  select a.rutpersona,a.planilla,rank() over (partition by a.rutPersona order by a.montoPesos,a.planilla) rank into #paso2
    From dchavez.EmpleadoresRelacionAfiliadosFull a
    INNER JOIN #montosIguales p2 on a.rutPersona = p2.rutPersona
    where a.cotizanteMes= 'S' and a.calcular = 'S'
    and principal is null;
    
  UPDATE dchavez.EmpleadoresRelacionAfiliadosFull
  SET principal = 'S'
  FROM dchavez.EmpleadoresRelacionAfiliadosFull a
  inner join #paso2 b on a.rutPersona = b.rutPersona and a.planilla = b.planilla and b.rank=1;
  
                                                         
  UPDATE dchavez.EmpleadoresRelacionAfiliadosFull
  set principal = 'N'
  from dchavez.EmpleadoresRelacionAfiliadosFull
  where cotizanteMes = 'S'
  and calcular = 'S'
  and principal is NULL;
  
  

  
  INSERT INTO dchavez.FctEmpleadorRelacionAfiliado_new
  SELECT  DISTINCT fra.idPeriodoInformado,dpe.id idPersona,dpa.id idEmpleador,fra.planilla identificadorPlanilla,daco.id idActividadEconomica,
  prod.id idTipoProducto,fra.cotizanteMes indCotizanteMes,fra.indSubsidio indEmpleadorSubsidio,
  deca.id idEscalaCalidad,0 idEstadoContractual 
  --into  dchavez.FctEmpleadorRelacionAfiliado_new--#revision
  FROM dchavez.EmpleadoresRelacionAfiliadosFull fra
  LEFT OUTER JOIN DMGestion.DimPersona dpa ON ( fra.rutPagador = dpa.rut 
                                                    AND dpa.fechaVigencia >= '21991231' )
  INNER JOIN DMGestion.DimPersona dpe ON ( fra.rutPersona = dpe.rut AND dpe.fechaVigencia >= '21991231')
  LEFT OUTER JOIN DMGestion.DimActividadEconomica   daco ON (daco.codigo = fra.codigoActividadEconomica AND daco.fechaVigencia >= '21991231' )
  LEFT OUTER JOIN DMGestion.DimTipoProducto         prod ON (prod.nombreCorto  = fra.tipo and prod.fechaVigencia >= '21991231')
  LEFT OUTER JOIN dchavez.DimEscalaCalidad          deca ON ( CASE WHEN indCotizanteMes = 'N' THEN 3 
                                                                   WHEN principal = 'S'       THEN 1 
                                                                   WHEN principal = 'N'       THEN 2
                                                                   WHEN indCotizanteMes = 'S'AND TIPO <>'CCICO' THEN 4
                                                                   ELSE 0 END =  deca.codigo )
                                   
                                                                   
commit;