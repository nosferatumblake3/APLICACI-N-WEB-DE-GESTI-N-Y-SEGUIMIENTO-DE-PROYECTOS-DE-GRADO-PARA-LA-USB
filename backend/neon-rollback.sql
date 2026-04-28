-- ============================================
-- ROLLBACK COMPLETO: Restaurar estructura original
-- Ejecutar en Neon SQL Editor
-- ============================================

-- Paso 1: Verificar estado actual
SELECT 
  column_name,
  data_type
FROM information_schema.columns 
WHERE table_name = 'gestiones'
ORDER BY ordinal_position;

-- Paso 2: Restaurar columnas antiguas si no existen
ALTER TABLE gestiones ADD COLUMN IF NOT EXISTS semestre INTEGER;
ALTER TABLE gestiones ADD COLUMN IF NOT EXISTS materia VARCHAR(255);
ALTER TABLE gestiones ADD COLUMN IF NOT EXISTS codigo_materia VARCHAR(50);

-- Paso 3: Migrar datos de vuelta desde gestion_materias si existe
DO $$
DECLARE
  gestion_record RECORD;
  materia_record RECORD;
  materias_count INTEGER;
BEGIN
  -- Verificar si gestion_materias existe
  IF EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_name='gestion_materias'
  ) THEN
    RAISE NOTICE '🔄 Migrando datos de gestion_materias de vuelta a gestiones...';
    
    -- Para cada gestión que tenga materias
    FOR gestion_record IN 
      SELECT DISTINCT gestion_id 
      FROM gestion_materias 
    LOOP
      -- Contar materias para esta gestión
      SELECT COUNT(*) INTO materias_count
      FROM gestion_materias
      WHERE gestion_id = gestion_record.gestion_id;
      
      IF materias_count = 1 THEN
        -- Si solo tiene 1 materia, actualizar la gestión directamente
        SELECT * INTO materia_record
        FROM gestion_materias
        WHERE gestion_id = gestion_record.gestion_id
        LIMIT 1;
        
        UPDATE gestiones
        SET 
          semestre = materia_record.semestre,
          materia = materia_record.materia,
          codigo_materia = materia_record.codigo_materia
        WHERE id = gestion_record.gestion_id;
        
      ELSIF materias_count > 1 THEN
        -- Si tiene múltiples materias, tomar la primera
        SELECT * INTO materia_record
        FROM gestion_materias
        WHERE gestion_id = gestion_record.gestion_id
        ORDER BY semestre
        LIMIT 1;
        
        UPDATE gestiones
        SET 
          semestre = materia_record.semestre,
          materia = materia_record.materia,
          codigo_materia = materia_record.codigo_materia
        WHERE id = gestion_record.gestion_id;
      END IF;
    END LOOP;
  END IF;
END $$;

-- Paso 4: Limpiar columnas de otras tablas
ALTER TABLE etapas DROP COLUMN IF EXISTS materia_id CASCADE;
ALTER TABLE entregas DROP COLUMN IF EXISTS materia_id CASCADE;
ALTER TABLE tareas DROP COLUMN IF EXISTS gestion_materia_id CASCADE;

-- Paso 5: Eliminar tablas nuevas
DROP TABLE IF EXISTS materia_etapas CASCADE;
DROP TABLE IF EXISTS gestion_materias CASCADE;

-- Paso 6: Verificación final
SELECT 
  '✅ ROLLBACK COMPLETADO' as estado,
  COUNT(*) as total_gestiones
FROM gestiones;

SELECT 
  'Estructura final de gestiones:' as info,
  column_name,
  data_type
FROM information_schema.columns 
WHERE table_name = 'gestiones'
ORDER BY ordinal_position;

-- Mostrar algunos datos de gestiones
SELECT 
  id,
  nombre,
  semestre,
  materia,
  codigo_materia,
  estado
FROM gestiones
LIMIT 5;
