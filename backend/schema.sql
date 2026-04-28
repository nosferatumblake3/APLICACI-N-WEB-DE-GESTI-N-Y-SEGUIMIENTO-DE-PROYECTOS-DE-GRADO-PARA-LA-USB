-- Sistema de Gestión de Proyectos de Grado
-- Universidad Salesiana de Bolivia - Sede Cochabamba

-- Extensiones
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Tabla de Usuarios
CREATE TABLE usuarios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    rol VARCHAR(20) NOT NULL CHECK (rol IN ('estudiante', 'tutor', 'revisor', 'administrador')),
    es_tutor BOOLEAN NOT NULL DEFAULT FALSE,
    es_revisor BOOLEAN NOT NULL DEFAULT FALSE,
    estado VARCHAR(20) DEFAULT 'activo' CHECK (estado IN ('activo', 'inactivo')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Proyectos
CREATE TABLE proyectos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    titulo VARCHAR(500) NOT NULL,
    descripcion TEXT,
    estudiante_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    tutor_id UUID REFERENCES usuarios(id) ON DELETE SET NULL,
    estado VARCHAR(50) DEFAULT 'registrado' CHECK (estado IN (
        'registrado', 'en_proceso', 'en_desarrollo', 'en_revision', 
        'correcciones', 'completado', 'aprobado', 'sustentado', 'rechazado'
    )),
    fecha_entrega DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Entregas (Documentos)
CREATE TABLE entregas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    proyecto_id UUID NOT NULL REFERENCES proyectos(id) ON DELETE CASCADE,
    etapa VARCHAR(255) NOT NULL,
    archivo_url TEXT NOT NULL,
    archivo_nombre VARCHAR(255) NOT NULL,
    version INTEGER NOT NULL DEFAULT 1,
    estado_revision VARCHAR(50) DEFAULT 'pendiente' CHECK (estado_revision IN (
        'pendiente', 'en_revision', 'observado', 'aprobado', 'rechazado'
    )),
    estado_tutor VARCHAR(50) DEFAULT 'pendiente' CHECK (estado_tutor IN (
        'pendiente', 'en_revision', 'observado', 'aprobado', 'rechazado'
    )),
    estado_revisor VARCHAR(50) CHECK (estado_revisor IN (
        'pendiente', 'en_revision', 'observado', 'aprobado', 'rechazado'
    ) OR estado_revisor IS NULL),
    fecha_subida TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Observaciones (Retroalimentación)
CREATE TABLE observaciones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entrega_id UUID NOT NULL REFERENCES entregas(id) ON DELETE CASCADE,
    usuario_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    comentario TEXT NOT NULL,
    seccion_documento VARCHAR(200),
    tipo VARCHAR(50) DEFAULT 'observacion' CHECK (tipo IN ('observacion', 'aprobacion', 'rechazo')),
    estado_resuelto BOOLEAN DEFAULT FALSE,
    fecha TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Notificaciones
CREATE TABLE notificaciones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    tipo VARCHAR(50) NOT NULL CHECK (tipo IN (
        'nueva_observacion', 'nueva_entrega', 'proyecto_asignado',
        'entrega_aprobada', 'entrega_rechazada', 'proyecto_completado', 'recordatorio'
    )),
    mensaje TEXT NOT NULL,
    relacion_id UUID, -- ID del proyecto, entrega u observación relacionada
    relacion_tipo VARCHAR(50), -- 'proyecto', 'entrega', 'observacion'
    leida BOOLEAN DEFAULT FALSE,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Asignación de Revisores
CREATE TABLE proyecto_revisores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    proyecto_id UUID NOT NULL REFERENCES proyectos(id) ON DELETE CASCADE,
    revisor_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    asignado_por UUID REFERENCES usuarios(id),
    fecha_asignacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(proyecto_id, revisor_id)
);

-- Tabla de Bitácoras (Control de Versiones Detallado)
CREATE TABLE bitacoras (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entrega_id UUID NOT NULL REFERENCES entregas(id) ON DELETE CASCADE,
    usuario_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    accion VARCHAR(50) NOT NULL CHECK (accion IN ('creacion', 'modificacion', 'subida', 'descarga', 'revision', 'aprobacion', 'rechazo')),
    descripcion TEXT,
    cambios_detectados JSONB, -- Almacena cambios detectados entre versiones
    version_anterior INTEGER,
    version_actual INTEGER,
    fecha TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Índices para mejorar rendimiento
CREATE INDEX idx_proyectos_estudiante ON proyectos(estudiante_id);
CREATE INDEX idx_proyectos_tutor ON proyectos(tutor_id);
CREATE INDEX idx_proyectos_estado ON proyectos(estado);
CREATE INDEX idx_entregas_proyecto ON entregas(proyecto_id);
CREATE INDEX idx_entregas_etapa ON entregas(etapa);
CREATE INDEX idx_observaciones_entrega ON observaciones(entrega_id);
CREATE INDEX idx_observaciones_usuario ON observaciones(usuario_id);
CREATE INDEX idx_notificaciones_usuario ON notificaciones(usuario_id);
CREATE INDEX idx_notificaciones_leida ON notificaciones(leida);
CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_usuarios_rol ON usuarios(rol);
CREATE INDEX idx_bitacoras_entrega ON bitacoras(entrega_id);
CREATE INDEX idx_bitacoras_usuario ON bitacoras(usuario_id);
CREATE INDEX idx_bitacoras_fecha ON bitacoras(fecha);

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para updated_at
CREATE TRIGGER update_usuarios_updated_at BEFORE UPDATE ON usuarios
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_proyectos_updated_at BEFORE UPDATE ON proyectos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Función para crear notificación automática
CREATE OR REPLACE FUNCTION crear_notificacion_entrega()
RETURNS TRIGGER AS $$
BEGIN
    -- Notificar al tutor cuando hay una nueva entrega
    INSERT INTO notificaciones (usuario_id, tipo, mensaje, relacion_id, relacion_tipo)
    SELECT 
        p.tutor_id,
        'nueva_entrega',
        'Nueva entrega en el proyecto: ' || p.titulo,
        NEW.proyecto_id,
        'entrega'
    FROM proyectos p
    WHERE p.id = NEW.proyecto_id AND p.tutor_id IS NOT NULL;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER trigger_notificacion_entrega AFTER INSERT ON entregas
    FOR EACH ROW EXECUTE FUNCTION crear_notificacion_entrega();

-- Función para crear notificación de observación
CREATE OR REPLACE FUNCTION crear_notificacion_observacion()
RETURNS TRIGGER AS $$
BEGIN
    -- Notificar al estudiante cuando hay una nueva observación
    INSERT INTO notificaciones (usuario_id, tipo, mensaje, relacion_id, relacion_tipo)
    SELECT 
        p.estudiante_id,
        'nueva_observacion',
        'Nueva observación en tu proyecto: ' || p.titulo,
        NEW.entrega_id,
        'observacion'
    FROM entregas e
    JOIN proyectos p ON p.id = e.proyecto_id
    WHERE e.id = NEW.entrega_id;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER trigger_notificacion_observacion AFTER INSERT ON observaciones
    FOR EACH ROW EXECUTE FUNCTION crear_notificacion_observacion();

-- ==================== GESTIÓN DE ETAPAS ====================

-- Tabla de Etapas (configuradas por el administrador)
CREATE TABLE etapas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    numero_orden INTEGER UNIQUE,
    tipo VARCHAR(50) NOT NULL DEFAULT 'documento' CHECK (tipo IN (
        'documento',      -- Entrega de documento
        'revision',       -- Revisión por tutor/revisor
        'sustentacion',   -- Defensa oral
        'correcciones'    -- Periodo de correcciones
    )),
    estado VARCHAR(20) DEFAULT 'planificada' CHECK (estado IN (
        'planificada',    -- Aún no abierta
        'abierta',        -- Disponible para entregas
        'cerrada',        -- Ya no acepta entregas
        'archivada'       -- Eliminada lógicamente
    )),
    fecha_apertura TIMESTAMP WITH TIME ZONE,
    fecha_cierre TIMESTAMP WITH TIME ZONE,
    fecha_limite_entrega TIMESTAMP WITH TIME ZONE,
    permitir_entregas_fuera_tiempo BOOLEAN DEFAULT FALSE,
    descripcion_entrega TEXT,
    criterios_evaluacion JSONB,
    archivos_plantilla JSONB,
    requerimientos JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES usuarios(id) ON DELETE SET NULL
);

-- Tabla de relación entre Etapas y Proyectos
CREATE TABLE etapa_proyecto (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    etapa_id UUID NOT NULL REFERENCES etapas(id) ON DELETE CASCADE,
    proyecto_id UUID NOT NULL REFERENCES proyectos(id) ON DELETE CASCADE,
    fecha_apertura_proyecto TIMESTAMP WITH TIME ZONE,
    fecha_cierre_proyecto TIMESTAMP WITH TIME ZONE,
    fecha_limite_entrega_proyecto TIMESTAMP WITH TIME ZONE,
    activa BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(etapa_id, proyecto_id)
);

-- Tabla de Historial de cambios en etapas
CREATE TABLE etapas_historial (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    etapa_id UUID NOT NULL REFERENCES etapas(id) ON DELETE CASCADE,
    accion VARCHAR(50) NOT NULL CHECK (accion IN (
        'creacion', 'cambio_estado', 'cambio_fechas', 'cambio_criterios',
        'apertura', 'cierre', 'archivo'
    )),
    datos_antiguos JSONB,
    datos_nuevos JSONB,
    razon_cambio TEXT,
    realizado_por UUID NOT NULL REFERENCES usuarios(id) ON DELETE SET NULL,
    fecha TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Índices para etapas
CREATE INDEX idx_etapas_estado ON etapas(estado);
CREATE INDEX idx_etapas_numero_orden ON etapas(numero_orden);
CREATE INDEX idx_etapas_fechas ON etapas(fecha_apertura, fecha_cierre);
CREATE INDEX idx_etapa_proyecto_etapa ON etapa_proyecto(etapa_id);
CREATE INDEX idx_etapa_proyecto_proyecto ON etapa_proyecto(proyecto_id);
CREATE INDEX idx_etapa_proyecto_activa ON etapa_proyecto(activa);
CREATE INDEX idx_etapas_historial_etapa ON etapas_historial(etapa_id);
CREATE INDEX idx_etapas_historial_fecha ON etapas_historial(fecha);

-- Triggers
CREATE TRIGGER update_etapas_updated_at BEFORE UPDATE ON etapas
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_etapa_proyecto_updated_at BEFORE UPDATE ON etapa_proyecto
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Función para registrar cambios en historial
CREATE OR REPLACE FUNCTION registrar_cambio_etapa()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        INSERT INTO etapas_historial (
            etapa_id, accion, datos_antiguos, datos_nuevos, realizado_por
        ) VALUES (
            NEW.id,
            CASE 
                WHEN OLD.estado != NEW.estado THEN 'cambio_estado'
                WHEN OLD.fecha_apertura != NEW.fecha_apertura OR OLD.fecha_cierre != NEW.fecha_cierre THEN 'cambio_fechas'
                WHEN OLD.criterios_evaluacion != NEW.criterios_evaluacion THEN 'cambio_criterios'
                ELSE 'actualizacion'
            END,
            row_to_json(OLD),
            row_to_json(NEW),
            CURRENT_USER::UUID
        );
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO etapas_historial (
            etapa_id, accion, datos_nuevos, realizado_por
        ) VALUES (
            NEW.id,
            'creacion',
            row_to_json(NEW),
            CURRENT_USER::UUID
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_registrar_cambio_etapa AFTER INSERT OR UPDATE ON etapas
    FOR EACH ROW EXECUTE FUNCTION registrar_cambio_etapa();
-- ==================== GESTIÓN DE MATERIAS ====================

-- Tabla de Gestiones (Configuradas por el administrador para cada materia/semestre)
CREATE TABLE gestiones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(255) NOT NULL,
    semestre INTEGER NOT NULL CHECK (semestre IN (7, 8, 9, 10)),
    materia VARCHAR(255) NOT NULL,
    codigo_materia VARCHAR(50),
    estado VARCHAR(20) DEFAULT 'activa' CHECK (estado IN ('activa', 'inactiva', 'archivada')),
    descripcion TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES usuarios(id) ON DELETE SET NULL
);

-- Tabla de relación entre Gestiones y Etapas
CREATE TABLE gestion_etapas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    gestion_id UUID NOT NULL REFERENCES gestiones(id) ON DELETE CASCADE,
    etapa_id UUID NOT NULL REFERENCES etapas(id) ON DELETE CASCADE,
    orden_ejecucion INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(gestion_id, etapa_id)
);

-- Tabla de Historial de cambios en gestiones
CREATE TABLE gestiones_historial (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    gestion_id UUID NOT NULL REFERENCES gestiones(id) ON DELETE CASCADE,
    accion VARCHAR(50) NOT NULL CHECK (accion IN (
        'creacion', 'cambio_estado', 'cambio_datos', 'actualizacion'
    )),
    datos_antiguos JSONB,
    datos_nuevos JSONB,
    razon_cambio TEXT,
    realizado_por UUID NOT NULL REFERENCES usuarios(id) ON DELETE SET NULL,
    fecha TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Índices para gestiones
CREATE INDEX idx_gestiones_semestre ON gestiones(semestre);
CREATE INDEX idx_gestiones_estado ON gestiones(estado);
CREATE INDEX idx_gestion_etapas_gestion ON gestion_etapas(gestion_id);
CREATE INDEX idx_gestion_etapas_etapa ON gestion_etapas(etapa_id);
CREATE INDEX idx_gestiones_historial_gestion ON gestiones_historial(gestion_id);
CREATE INDEX idx_gestiones_historial_fecha ON gestiones_historial(fecha);

-- Triggers
CREATE TRIGGER update_gestiones_updated_at BEFORE UPDATE ON gestiones
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_gestion_etapas_updated_at BEFORE UPDATE ON gestion_etapas
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Función para registrar cambios en historial de gestiones
CREATE OR REPLACE FUNCTION registrar_cambio_gestion()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        INSERT INTO gestiones_historial (
            gestion_id, accion, datos_antiguos, datos_nuevos, realizado_por
        ) VALUES (
            NEW.id,
            CASE 
                WHEN OLD.estado != NEW.estado THEN 'cambio_estado'
                ELSE 'cambio_datos'
            END,
            row_to_json(OLD),
            row_to_json(NEW),
            CURRENT_USER::UUID
        );
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO gestiones_historial (
            gestion_id, accion, datos_nuevos, realizado_por
        ) VALUES (
            NEW.id,
            'creacion',
            row_to_json(NEW),
            CURRENT_USER::UUID
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_registrar_cambio_gestion AFTER INSERT OR UPDATE ON gestiones
    FOR EACH ROW EXECUTE FUNCTION registrar_cambio_gestion();

-- ==================== LINEAMIENTOS ====================

-- Publicaciones de lineamientos para todos los usuarios
CREATE TABLE lineamientos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    titulo VARCHAR(255) NOT NULL,
    archivo_nombre VARCHAR(255) NOT NULL,
    archivo_ruta TEXT NOT NULL,
    archivo_mime VARCHAR(150),
    archivo_size BIGINT,
    publicado_por UUID REFERENCES usuarios(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_lineamientos_created_at ON lineamientos(created_at DESC);
CREATE INDEX idx_lineamientos_publicado_por ON lineamientos(publicado_por);

CREATE TRIGGER update_lineamientos_updated_at BEFORE UPDATE ON lineamientos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();