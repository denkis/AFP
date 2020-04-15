--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*Identificar donde tenemos información de las licencias
Por ello consideramos la tabla TB_PLANILLA_MOVIPER
y los tipos de movimientos 3 (TRABAJADORES AFECTOS A SUBSIDIO POR INCPACIDAD LABORAL)

Los campos importante a rescatar de esta tabla son:
FEC_DESDE Y FEC_INI_LABORES
FEC_HASTA Y FEC_FIN_LABORES
ID_DET_PLANILLA

Con los datos rescados, vamos a buscar a la tabla TB_DET_PLANILLA el ID_MAE_PERSONA y el ID_MAE_PLANILLA

Luego con el ID_MAE_PLANILLA podemos rescatar en la TB_MAE_PLANILLA el PER_COT y el TIP_PLANILLA = 7 (Planilla de Pago de Cotizaciones Previsionales 
de Subsidio por Incapacidad Laboral Fondo de Pensiones y Seguro de Cesantia )

Luego con el ID_DET_PLANILLA vamos leer la tabla TB_DET_PLANILLA_CONCEPTO, donde se encuenta el monto y concepto (101: fondoPensiones.remuneracionImponible) 
pagado en la planilla para el calculo del Imponible
112: Renta Liquida por día

Consideraciones para el universo:
*FEC_DESDE Y FEC_INI_LABORES (en caso de no existir el primero, considerar el segundo campo y en caso de no existir ninguno de ambos, no considerar)
*FEC_HASTA Y FEC_FIN_LABORES (en caso de no existir el primero, considerar el segundo campo y en caso de no existir ninguno de ambos, no considerar)
*La fecha de Inicio debe ser menor a la Fecha de termino, ya que hay casos mal digitados y se encuentran con años superiores al 2020 o menores a la fecha de inicio
*/
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
select * into  #revisionLicencias
from DDS.tb_planilla_moviper 
where id_tip_moviper = 3


select * 
from DDS.tb_planilla_moviper 
where id_tip_moviper = 3

--select count(*) from #revisionLicencias
SELECT case when fec_desde is not null then fec_desde else fec_ini_labores end fechaInicioLicencia ,
case when fec_hasta is not null then fec_hasta else fec_fin_labores end fechaFinLicencia ,
id_det_planilla INTO #licencias
from DDS.tb_planilla_moviper
where (fec_desde is not NULL or fec_ini_labores is not null);


SELECT case when fec_desde is not null then fec_desde else fec_ini_labores end fechaInicioLicencia ,
case when fec_hasta is not null then fec_hasta else fec_fin_labores end fechaFinLicencia ,
tpm.id_det_planilla,datediff(day,fechainicioLicencia,fechafinLicencia)+1 diastotales,
tmp.PER_COT,tpc.MONTO,tpc.ID_TIP_CONCEPTO 
FROM DDS.tb_planilla_moviper tpm
INNER JOIN DDS.TB_DET_PLANILLA tdp ON tpm.ID_DET_PLANILLA  = tdp.ID_DET_PLANILLA 
inner join DDS.TB_MAE_PLANILLA  tmp on tmp.ID_MAE_PLANILLA = tdp.ID_MAE_PLANILLA  --per_cot, tipo planilla pago subsidio
INNER JOIN DDS.TB_MAE_PERSONA   tme on tme.ID_MAE_PERSONA  = tdp.ID_MAE_PERSONA 
inner join DDS.TB_DET_PLANILLA_CONCEPTO tpc on tpc.ID_DET_PLANILLA = tdp.ID_DET_PLANILLA 
WHERE tmp.ID_TIP_PLANILLA  = 7
and (tpm.fec_desde is not NULL or tpm.fec_ini_labores is not null)
and rut_mae_persona = 123263;

 select * from dds.TB_DET_PLANILLA_CONCEPTO
 

commit;
SELECT *
FROM DDS.AuditoriaStaging
where periodoInformado = '20200301'
order by id desc;

select * from dds.tb_det_planilla_concepto;


SELECT * FROM dchavez.subsidioPorlicencias sp 

select * FROM dchavez.resumenSubsidio rs 

