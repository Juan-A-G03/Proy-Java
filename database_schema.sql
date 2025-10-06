-- ===============================================
-- FLYINGOLO DATABASE SCHEMA
-- Sistema de Transporte Espacial con Facciones
-- Version: 1.0
-- MySQL 8.0+
-- ===============================================

CREATE DATABASE IF NOT EXISTS flysolo_db 
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE flysolo_db;

-- ===============================================
-- TABLA: FACCIONES
-- ===============================================
CREATE TABLE facciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    color_hex VARCHAR(7), -- Para UI: #FF0000, #0000FF, etc.
    activa BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Datos iniciales de facciones
INSERT INTO facciones (nombre, descripcion, color_hex) VALUES 
('IMPERIO', 'Imperio Galáctico - Gobierno autoritario central', '#FF0000'),
('REBELDES', 'Alianza Rebelde - Resistencia contra el Imperio', '#0066FF'),
('NEUTRALES', 'Ciudadanos independientes sin afiliación política', '#808080');

-- ===============================================
-- TABLA: USUARIOS (Tabla padre para todos los usuarios)
-- ===============================================
CREATE TABLE usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE,
    planeta_origen VARCHAR(100),
    telefono VARCHAR(20),
    faccion_id INT NOT NULL,
    tipo_usuario ENUM('PASAJERO', 'PILOTO', 'ADMIN') NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    verificado BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (faccion_id) REFERENCES facciones(id),
    INDEX idx_email (email),
    INDEX idx_faccion (faccion_id),
    INDEX idx_tipo (tipo_usuario)
);

-- ===============================================
-- TABLA: PERFILES_PILOTO (Datos específicos de pilotos)
-- ===============================================
CREATE TABLE perfiles_piloto (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT NOT NULL UNIQUE,
    estado_solicitud ENUM('PENDIENTE', 'APROBADO', 'RECHAZADO') DEFAULT 'PENDIENTE',
    
    -- Datos del formulario de solicitud
    años_experiencia INT NOT NULL,
    lugar_nacimiento VARCHAR(255),
    tiene_antecedentes BOOLEAN DEFAULT FALSE,
    detalles_antecedentes TEXT,
    
    -- Historial político
    tuvo_actividad_politica BOOLEAN DEFAULT FALSE,
    detalle_actividad_politica TEXT,
    años_actividad_politica VARCHAR(50),
    
    -- Preferencias laborales
    tipo_viajes_preferido ENUM('PASAJEROS', 'CARGA', 'MIXTO') DEFAULT 'MIXTO',
    distancias_preferidas ENUM('CORTAS', 'MEDIAS', 'LARGAS', 'CUALQUIERA') DEFAULT 'CUALQUIERA',
    disponibilidad_horaria VARCHAR(100),
    comentarios_adicionales TEXT,
    
    -- Referencias y licencias
    tipos_naves_manejadas JSON, -- Array de strings
    licencias_actuales JSON,     -- Array de strings
    referencias TEXT,
    
    -- Gestión del admin
    fecha_aprobacion TIMESTAMP NULL,
    admin_aprobador_id INT NULL,
    motivo_rechazo TEXT NULL,
    
    -- Reputación
    rating_promedio DECIMAL(3,2) DEFAULT 0.00,
    total_viajes_completados INT DEFAULT 0,
    total_reseñas INT DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (admin_aprobador_id) REFERENCES usuarios(id),
    INDEX idx_estado (estado_solicitud),
    INDEX idx_rating (rating_promedio)
);

-- ===============================================
-- TABLA: TIPOS_NAVE
-- ===============================================
CREATE TABLE tipos_nave (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    clase VARCHAR(50), -- Freighter, Fighter, Transport, etc.
    capacidad_pasajeros INT DEFAULT 0,
    capacidad_carga INT DEFAULT 0, -- En toneladas
    velocidad_maxima INT, -- Factor de velocidad luz
    descripcion TEXT,
    imagen_url VARCHAR(500),
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Datos iniciales de naves
INSERT INTO tipos_nave (nombre, clase, capacidad_pasajeros, capacidad_carga, velocidad_maxima, descripcion) VALUES 
('YT-1300 Light Freighter', 'Freighter', 6, 100, 2, 'Carguero ligero modificable, ideal para contrabando'),
('Lambda-class Shuttle', 'Transport', 20, 80, 1, 'Transporte oficial del Imperio'),
('X-Wing Fighter', 'Fighter', 1, 5, 3, 'Caza estelar de la Alianza Rebelde'),
('TIE Fighter', 'Fighter', 1, 2, 4, 'Caza Imperial estándar'),
('Z-95 Headhunter', 'Fighter', 1, 3, 2, 'Caza básico ideal para pilotos novatos'),
('YT-2400 Light Freighter', 'Freighter', 8, 150, 2, 'Carguero ligero avanzado');

-- ===============================================
-- TABLA: NAVES (Instancias específicas de cada nave)
-- ===============================================
CREATE TABLE naves (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_personalizado VARCHAR(100), -- "Halcón Milenario"
    tipo_nave_id INT NOT NULL,
    piloto_id INT NULL, -- NULL = disponible para asignar
    estado ENUM('DISPONIBLE', 'ASIGNADA', 'EN_MANTENIMIENTO', 'DESTRUIDA') DEFAULT 'DISPONIBLE',
    
    -- Modificaciones
    escudos_nivel INT DEFAULT 1, -- 1-5
    motor_nivel INT DEFAULT 1,   -- 1-5
    blindaje_nivel INT DEFAULT 1, -- 1-5
    
    -- Coordenadas actuales
    sistema_solar VARCHAR(100),
    planeta VARCHAR(100),
    coordenada_x DECIMAL(10,2),
    coordenada_y DECIMAL(10,2),
    coordenada_z DECIMAL(10,2),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (tipo_nave_id) REFERENCES tipos_nave(id),
    FOREIGN KEY (piloto_id) REFERENCES usuarios(id),
    INDEX idx_piloto (piloto_id),
    INDEX idx_estado (estado),
    INDEX idx_ubicacion (sistema_solar, planeta)
);

-- ===============================================
-- TABLA: ARMAMENTO
-- ===============================================
CREATE TABLE armamento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    tipo ENUM('LASER', 'ION', 'MISIL', 'TORPEDO') NOT NULL,
    daño INT NOT NULL,
    alcance INT NOT NULL,
    descripcion TEXT,
    costo_instalacion DECIMAL(10,2),
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Datos iniciales de armamento
INSERT INTO armamento (nombre, tipo, daño, alcance, costo_instalacion) VALUES 
('Cañón Láser Básico', 'LASER', 10, 100, 1000.00),
('Cañón Láser Pesado', 'LASER', 25, 150, 5000.00),
('Cañón de Iones', 'ION', 15, 120, 3000.00),
('Misiles de Concusión', 'MISIL', 50, 200, 8000.00),
('Torpedos de Protones', 'TORPEDO', 80, 300, 15000.00);

-- ===============================================
-- TABLA: NAVES_ARMAMENTO (Relación N:M)
-- ===============================================
CREATE TABLE naves_armamento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nave_id INT NOT NULL,
    armamento_id INT NOT NULL,
    cantidad INT DEFAULT 1,
    fecha_instalacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (nave_id) REFERENCES naves(id) ON DELETE CASCADE,
    FOREIGN KEY (armamento_id) REFERENCES armamento(id),
    UNIQUE KEY unique_nave_armamento (nave_id, armamento_id)
);

-- ===============================================
-- TABLA: SISTEMAS_SOLARES (Para cálculo de distancias)
-- ===============================================
CREATE TABLE sistemas_solares (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    coordenada_x DECIMAL(10,2) NOT NULL,
    coordenada_y DECIMAL(10,2) NOT NULL,
    coordenada_z DECIMAL(10,2) NOT NULL,
    faccion_controladora_id INT NULL, -- Qué facción controla el sistema
    descripcion TEXT,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (faccion_controladora_id) REFERENCES facciones(id),
    INDEX idx_coordenadas (coordenada_x, coordenada_y, coordenada_z)
);

-- Datos iniciales de sistemas solares
INSERT INTO sistemas_solares (nombre, coordenada_x, coordenada_y, coordenada_z, faccion_controladora_id) VALUES 
('Coruscant', 0.00, 0.00, 0.00, 1),     -- Centro galáctico, Imperio
('Alderaan', -50.00, 30.00, 0.00, 2),   -- Rebeldes
('Tatooine', 120.00, -85.00, 10.00, 3), -- Neutral
('Hoth', -200.00, 150.00, -50.00, 2),   -- Rebeldes
('Endor', 300.00, 200.00, 100.00, 1),   -- Imperio
('Yavin', -100.00, -200.00, 0.00, 2);   -- Rebeldes

-- ===============================================
-- TABLA: PLANETAS
-- ===============================================
CREATE TABLE planetas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    sistema_solar_id INT NOT NULL,
    coordenada_x DECIMAL(10,2) NOT NULL,
    coordenada_y DECIMAL(10,2) NOT NULL,
    coordenada_z DECIMAL(10,2) NOT NULL,
    tipo ENUM('URBANO', 'DESERTICO', 'HELADO', 'BOSQUE', 'OCEANO', 'INDUSTRIAL') DEFAULT 'URBANO',
    poblacion BIGINT,
    descripcion TEXT,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (sistema_solar_id) REFERENCES sistemas_solares(id),
    INDEX idx_sistema (sistema_solar_id),
    INDEX idx_coordenadas (coordenada_x, coordenada_y, coordenada_z)
);

-- Datos iniciales de planetas
INSERT INTO planetas (nombre, sistema_solar_id, coordenada_x, coordenada_y, coordenada_z, tipo, poblacion) VALUES 
('Coruscant', 1, 0.00, 0.00, 0.00, 'URBANO', 1000000000000),
('Aldera', 2, -50.00, 30.00, 0.00, 'URBANO', 2000000000),
('Tatooine', 3, 120.00, -85.00, 10.00, 'DESERTICO', 200000),
('Hoth', 4, -200.00, 150.00, -50.00, 'HELADO', 0),
('Endor', 5, 300.00, 200.00, 100.00, 'BOSQUE', 30000000),
('Yavin 4', 6, -100.00, -200.00, 0.00, 'BOSQUE', 1000);

-- ===============================================
-- TABLA: VIAJES
-- ===============================================
CREATE TABLE viajes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT NOT NULL, -- Quien solicita el viaje
    piloto_id INT NULL,      -- Quien acepta el viaje
    
    -- Ubicaciones
    origen_planeta_id INT NOT NULL,
    destino_planeta_id INT NOT NULL,
    
    -- Detalles del viaje
    tipo_viaje ENUM('PASAJERO', 'CARGA') NOT NULL,
    tipo_timing ENUM('INMEDIATO', 'PROGRAMADO') NOT NULL,
    fecha_hora_solicitada DATETIME NOT NULL,
    num_pasajeros INT DEFAULT 1,
    peso_carga DECIMAL(8,2) DEFAULT 0.00, -- En toneladas
    descripcion_carga TEXT,
    
    -- Cálculos automáticos
    distancia_calculada DECIMAL(10,2), -- En parsecs
    tiempo_estimado_viaje INT,          -- En minutos
    precio_base DECIMAL(10,2),
    precio_premium DECIMAL(10,2),      -- Para viajes inmediatos
    precio_final DECIMAL(10,2),
    
    -- Estados y tiempos
    estado ENUM('PENDIENTE', 'CONFIRMADO', 'EN_CURSO', 'COMPLETADO', 'CANCELADO', 'EXPIRADO') DEFAULT 'PENDIENTE',
    fecha_confirmacion DATETIME NULL,
    fecha_inicio DATETIME NULL,
    fecha_finalizacion DATETIME NULL,
    
    -- Misiones encubiertas
    es_mision_encubierta BOOLEAN DEFAULT FALSE,
    facciones_autorizadas JSON, -- Array de IDs de facciones que pueden ver la misión
    detalles_encubiertos TEXT,
    
    -- Motivos de cancelación/expiración
    motivo_cancelacion TEXT,
    cancelado_por ENUM('USUARIO', 'PILOTO', 'SISTEMA') NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    FOREIGN KEY (piloto_id) REFERENCES usuarios(id),
    FOREIGN KEY (origen_planeta_id) REFERENCES planetas(id),
    FOREIGN KEY (destino_planeta_id) REFERENCES planetas(id),
    
    INDEX idx_usuario (usuario_id),
    INDEX idx_piloto (piloto_id),
    INDEX idx_estado (estado),
    INDEX idx_fecha (fecha_hora_solicitada),
    INDEX idx_tipo (tipo_viaje),
    INDEX idx_mision_encubierta (es_mision_encubierta)
);

-- ===============================================
-- TABLA: RESEÑAS
-- ===============================================
CREATE TABLE reseñas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    viaje_id INT NOT NULL UNIQUE, -- Un viaje solo puede tener una reseña
    usuario_id INT NOT NULL,      -- Quien deja la reseña
    piloto_id INT NOT NULL,       -- Quien recibe la reseña
    
    -- Calificaciones (1-5)
    rating_general INT NOT NULL CHECK (rating_general BETWEEN 1 AND 5),
    rating_puntualidad INT CHECK (rating_puntualidad BETWEEN 1 AND 5),
    rating_profesionalismo INT CHECK (rating_profesionalismo BETWEEN 1 AND 5),
    rating_nave INT CHECK (rating_nave BETWEEN 1 AND 5),
    
    -- Comentarios
    comentario TEXT,
    es_anonima BOOLEAN DEFAULT FALSE, -- Para misiones encubiertas
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (viaje_id) REFERENCES viajes(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    FOREIGN KEY (piloto_id) REFERENCES usuarios(id),
    
    INDEX idx_piloto (piloto_id),
    INDEX idx_rating (rating_general)
);

-- ===============================================
-- TABLA: SOLICITUDES_CAMBIO_NAVE
-- ===============================================
CREATE TABLE solicitudes_cambio_nave (
    id INT PRIMARY KEY AUTO_INCREMENT,
    piloto_id INT NOT NULL,
    nave_actual_id INT NULL,
    nave_solicitada_id INT NOT NULL,
    motivo TEXT NOT NULL,
    estado ENUM('PENDIENTE', 'APROBADO', 'RECHAZADO') DEFAULT 'PENDIENTE',
    admin_revisor_id INT NULL,
    motivo_rechazo TEXT NULL,
    fecha_aprobacion TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (piloto_id) REFERENCES usuarios(id),
    FOREIGN KEY (nave_actual_id) REFERENCES naves(id),
    FOREIGN KEY (nave_solicitada_id) REFERENCES naves(id),
    FOREIGN KEY (admin_revisor_id) REFERENCES usuarios(id),
    
    INDEX idx_piloto (piloto_id),
    INDEX idx_estado (estado)
);

-- ===============================================
-- TABLA: SOLICITUDES_ARMAMENTO
-- ===============================================
CREATE TABLE solicitudes_armamento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    piloto_id INT NOT NULL,
    nave_id INT NOT NULL,
    armamento_id INT NOT NULL,
    cantidad_solicitada INT DEFAULT 1,
    motivo TEXT,
    estado ENUM('PENDIENTE', 'APROBADO', 'RECHAZADO') DEFAULT 'PENDIENTE',
    admin_revisor_id INT NULL,
    motivo_rechazo TEXT NULL,
    fecha_aprobacion TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (piloto_id) REFERENCES usuarios(id),
    FOREIGN KEY (nave_id) REFERENCES naves(id),
    FOREIGN KEY (armamento_id) REFERENCES armamento(id),
    FOREIGN KEY (admin_revisor_id) REFERENCES usuarios(id),
    
    INDEX idx_piloto (piloto_id),
    INDEX idx_estado (estado)
);

-- ===============================================
-- TABLA: LOGS_SISTEMA (Para auditoría)
-- ===============================================
CREATE TABLE logs_sistema (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT NULL,
    accion VARCHAR(100) NOT NULL,
    tabla_afectada VARCHAR(50),
    registro_id INT,
    detalles JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    INDEX idx_usuario (usuario_id),
    INDEX idx_accion (accion),
    INDEX idx_fecha (created_at)
);

-- ===============================================
-- TRIGGERS PARA ACTUALIZAR RATING DE PILOTOS
-- ===============================================
DELIMITER //

CREATE TRIGGER update_piloto_rating_after_review
AFTER INSERT ON reseñas
FOR EACH ROW
BEGIN
    UPDATE perfiles_piloto 
    SET 
        rating_promedio = (
            SELECT AVG(rating_general) 
            FROM reseñas 
            WHERE piloto_id = NEW.piloto_id
        ),
        total_reseñas = (
            SELECT COUNT(*) 
            FROM reseñas 
            WHERE piloto_id = NEW.piloto_id
        )
    WHERE usuario_id = NEW.piloto_id;
END//

CREATE TRIGGER update_piloto_viajes_completados
AFTER UPDATE ON viajes
FOR EACH ROW
BEGIN
    IF NEW.estado = 'COMPLETADO' AND OLD.estado != 'COMPLETADO' THEN
        UPDATE perfiles_piloto 
        SET total_viajes_completados = total_viajes_completados + 1
        WHERE usuario_id = NEW.piloto_id;
    END IF;
END//

DELIMITER ;

-- ===============================================
-- VISTAS ÚTILES PARA LA APLICACIÓN
-- ===============================================

-- Vista: Pilotos disponibles con detalles de nave
CREATE VIEW vista_pilotos_disponibles AS
SELECT 
    u.id as piloto_id,
    u.nombre,
    u.apellido,
    u.email,
    f.nombre as faccion,
    f.color_hex as faccion_color,
    pp.rating_promedio,
    pp.total_viajes_completados,
    pp.tipo_viajes_preferido,
    n.id as nave_id,
    n.nombre_personalizado as nave_nombre,
    tn.nombre as tipo_nave,
    tn.capacidad_pasajeros,
    tn.capacidad_carga,
    n.sistema_solar,
    n.planeta
FROM usuarios u
JOIN facciones f ON u.faccion_id = f.id
JOIN perfiles_piloto pp ON u.id = pp.usuario_id
LEFT JOIN naves n ON u.id = n.piloto_id
LEFT JOIN tipos_nave tn ON n.tipo_nave_id = tn.id
WHERE u.tipo_usuario = 'PILOTO' 
  AND u.activo = TRUE 
  AND u.verificado = TRUE
  AND pp.estado_solicitud = 'APROBADO'
  AND (n.estado = 'DISPONIBLE' OR n.estado IS NULL);

-- Vista: Viajes con detalles completos
CREATE VIEW vista_viajes_completos AS
SELECT 
    v.id,
    v.estado,
    v.tipo_viaje,
    v.fecha_hora_solicitada,
    v.precio_final,
    v.distancia_calculada,
    
    -- Usuario que solicita
    u.nombre as usuario_nombre,
    u.apellido as usuario_apellido,
    uf.nombre as usuario_faccion,
    
    -- Piloto asignado
    p.nombre as piloto_nombre,
    p.apellido as piloto_apellido,
    pf.nombre as piloto_faccion,
    
    -- Ubicaciones
    po.nombre as origen_planeta,
    so.nombre as origen_sistema,
    pd.nombre as destino_planeta,
    sd.nombre as destino_sistema,
    
    -- Detalles del viaje
    v.num_pasajeros,
    v.peso_carga,
    v.es_mision_encubierta,
    
    v.created_at,
    v.fecha_finalizacion
    
FROM viajes v
JOIN usuarios u ON v.usuario_id = u.id
JOIN facciones uf ON u.faccion_id = uf.id
LEFT JOIN usuarios p ON v.piloto_id = p.id
LEFT JOIN facciones pf ON p.faccion_id = pf.id
JOIN planetas po ON v.origen_planeta_id = po.id
JOIN sistemas_solares so ON po.sistema_solar_id = so.id
JOIN planetas pd ON v.destino_planeta_id = pd.id
JOIN sistemas_solares sd ON pd.sistema_solar_id = sd.id;

-- ===============================================
-- FUNCIONES ÚTILES
-- ===============================================

DELIMITER //

-- Función para calcular distancia entre dos planetas
CREATE FUNCTION calcular_distancia_planetas(
    planeta1_id INT,
    planeta2_id INT
) RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE x1, y1, z1, x2, y2, z2 DECIMAL(10,2);
    DECLARE distancia DECIMAL(10,2);
    
    SELECT coordenada_x, coordenada_y, coordenada_z 
    INTO x1, y1, z1 
    FROM planetas 
    WHERE id = planeta1_id;
    
    SELECT coordenada_x, coordenada_y, coordenada_z 
    INTO x2, y2, z2 
    FROM planetas 
    WHERE id = planeta2_id;
    
    SET distancia = SQRT(POWER(x2-x1, 2) + POWER(y2-y1, 2) + POWER(z2-z1, 2));
    
    RETURN distancia;
END//

DELIMITER ;

-- ===============================================
-- ÍNDICES ADICIONALES PARA OPTIMIZACIÓN
-- ===============================================
CREATE INDEX idx_viajes_busqueda ON viajes (estado, tipo_viaje, fecha_hora_solicitada);
CREATE INDEX idx_usuarios_activos ON usuarios (activo, verificado, tipo_usuario);
CREATE INDEX idx_naves_disponibles ON naves (estado, piloto_id);

-- ===============================================
-- USUARIO ADMIN POR DEFECTO
-- ===============================================
INSERT INTO usuarios (email, password_hash, nombre, apellido, faccion_id, tipo_usuario, verificado) 
VALUES ('admin@flysolo.com', '$2a$10$example_hash_here', 'Administrador', 'Sistema', 3, 'ADMIN', TRUE);

-- ===============================================
-- COMENTARIOS FINALES
-- ===============================================
/*
NOTAS IMPORTANTES:

1. **Seguridad**: 
   - Todos los passwords deben hashearse con BCrypt
   - Implementar validación de entrada en Java
   - Usar prepared statements para evitar SQL injection

2. **Rendimiento**:
   - Los índices están optimizados para las consultas principales
   - La función de distancia puede cachear resultados
   - Las vistas materializadas pueden mejorar consultas complejas

3. **Escalabilidad**:
   - El campo JSON permite flexibilidad sin cambios de schema
   - Los logs de sistema ayudan a debugging y auditoría
   - La estructura permite agregar nuevas facciones fácilmente

4. **Lógica de Negocio en Java**:
   - Validar compatibilidad de facciones antes de mostrar viajes
   - Calcular precios basado en distancia, tipo de viaje y urgencia
   - Implementar timeouts para viajes no confirmados
   - Manejar estados de viaje con máquina de estados

5. **Próximos pasos**:
   - Crear stored procedures para operaciones complejas
   - Implementar soft deletes para datos críticos
   - Agregar campos de geolocalización en tiempo real
   - Considerar particionamiento por fechas en tablas grandes
*/