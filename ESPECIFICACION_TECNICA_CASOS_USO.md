# 🔧 ARTEFACTO TÉCNICO: ESPECIFICACIÓN DE CASOS DE USO - FLYSOLO
## Documentación Técnica para Arquitectura Java Web

---

## 📋 **TEMPLATE DE ESPECIFICACIÓN TÉCNICA**

### **CU-001: REGISTRO DE USUARIO**

**🎯 INFORMACIÓN GENERAL:**
- **Actor:** Usuario (no registrado)
- **Tipo:** Funcionalidad Core
- **Prioridad:** Alta
- **Complejidad:** Media

**🔄 CAMINO BASICO:**

#### **PASO 1: Acceso a Formulario**
```
JSP: /jsp/auth/register.jsp
├── Variables enviadas: ninguna (GET inicial)
├── Elementos del formulario:
│   ├── email (input text)
│   ├── password (input password)
│   ├── confirmPassword (input password)
│   ├── nombre (input text)
│   ├── apellido (input text)
│   └── faccionId (select dropdown)
└── Action: /register (POST)
```

#### **PASO 2: Procesamiento en Servlet**
```
SERVLET: RegisterServlet.java
├── URL Pattern: /register
├── Método HTTP: POST
├── Parámetros recibidos:
│   ├── email (String)
│   ├── password (String)
│   ├── confirmPassword (String)
│   ├── nombre (String)
│   ├── apellido (String)
│   └── faccionId (int)
├── Validaciones básicas:
│   ├── ValidationUtil.validateEmail(email)
│   ├── ValidationUtil.validatePassword(password)
│   ├── ValidationUtil.validateName(nombre)
│   └── ValidationUtil.validateName(apellido)
└── Controller llamado: UserController.validateAndRegister()
```

#### **PASO 3: Lógica de Negocio en Controller**
```
CONTROLLER: UserController.java
├── Método: registerUser(UserRegistrationDTO userData)
├── Validaciones de negocio:
│   ├── Verificar email único usando UserDAO.existsByEmail()
│   ├── Validar facción existe usando FactionDAO.existsById()
│   ├── Hashear password usando BCrypt
│   └── Asignar valores por defecto (tipo='PASAJERO', activo=true)
├── DAO llamado: UserDAO.create(User user)
└── Retorna: User creado o lanza Exception
```

#### **PASO 4: Acceso a Datos**
```
DAO: UserDAO.java (Interface) / UserDAOImpl.java (Implementación)
├── Método: create(User user)
├── Método auxiliar: existsByEmail(String email)
├── Query SQL principal:
│   INSERT INTO usuarios (email, password_hash, nombre, apellido, 
│   faccion_id, tipo_usuario, activo, verificado) 
│   VALUES (?, ?, ?, ?, ?, 'PASAJERO', true, false)
├── Query auxiliar:
│   SELECT COUNT(*) FROM usuarios WHERE email = ?
├── Tabla afectada: usuarios
└── Retorna: User con ID generado o null si falla
```

#### **PASO 5: Respuesta al Usuario**
```
SERVLET: RegisterServlet.java (continuación)
├── Si éxito:
│   ├── Crear sesión HTTP
│   ├── Atributo: "user" = userCompleto
│   └── Redirect: response.sendRedirect("/flysolo/dashboard")
├── Si error:
│   ├── Atributo: "errorMessage" = mensaje específico
│   ├── Atributo: "formData" = datos del formulario
│   └── Forward: request.getRequestDispatcher("/jsp/auth/register.jsp")
└── Variables de respuesta:
    ├── success (boolean)
    ├── errorMessage (String)
    └── user (User object)
```

**🛡️ VALIDACIONES Y EXCEPCIONES:**
- **EmailExistenteException:** Email ya registrado
- **FaccionInvalidaException:** Facción no existe
- **PasswordDebildException:** Password no cumple criterios
- **SQLException:** Error de base de datos
- **ValidationException:** Datos de entrada inválidos

**📊 VARIABLES CLAVE:**
```java
// Request Parameters
String email = request.getParameter("email");
String password = request.getParameter("password");
String nombre = request.getParameter("nombre");
String apellido = request.getParameter("apellido");
int faccionId = Integer.parseInt(request.getParameter("faccionId"));

// Session Variables
HttpSession session = request.getSession();
session.setAttribute("usuario", usuarioCompleto);

// Request Attributes
request.setAttribute("error", "Mensaje de error");
request.setAttribute("facciones", listaFacciones);
```

**🔄 DIAGRAMA DE SECUENCIA SIMPLIFICADO:**
```
Usuario -> JSP -> Servlet -> Controller -> Service -> DAO -> DB
   |        |        |          |          |        |      |
   |--------|--------|----------|----------|--------|------|
   GET      POST     validate   process    verify   INSERT response
```

---

## 📋 **ESPECIFICACIONES TÉCNICAS COMPLETAS**

### **CU-002: INICIAR SESIÓN**

**🔄 FLUJO TÉCNICO:**

#### **JSP → SERVLET:**
```
JSP: /jsp/auth/login.jsp
POST → /login
Parámetros:
├── email (String)
├── password (String)
└── recordarme (boolean)
```

#### **SERVLET → CONTROLLERS:**
```
LoginServlet.java
├── AuthController.validarCredenciales(email, password)
├── UsuarioController.obtenerUsuarioCompleto(email)
└── SessionController.crearSesion(usuario)
```

#### **CONTROLLERS → DAOs:**
```
AuthController:
├── UsuarioDAO.obtenerPorEmail(email)
└── PasswordUtil.verificarPassword(password, hash)

SessionController:
├── UsuarioDAO.actualizarUltimoAcceso(usuarioId)
└── FaccionDAO.obtenerPorId(faccionId)
```

#### **DAOs → QUERIES:**
```sql
-- UsuarioDAO.obtenerPorEmail()
SELECT id, email, password_hash, nombre, apellido, 
       faccion_id, tipo_usuario, activo, verificado
FROM usuarios WHERE email = ? AND activo = true

-- UsuarioDAO.actualizarUltimoAcceso()
UPDATE usuarios SET ultimo_acceso = CURRENT_TIMESTAMP 
WHERE id = ?
```

---

### **CU-003: CREAR SOLICITUD DE VIAJE**

**🔄 FLUJO TÉCNICO:**

#### **JSP → SERVLET:**
```
JSP: /jsp/usuario/crear-viaje.jsp
POST → /viajes/crear
Parámetros:
├── origenPlanetaId (int)
├── destinoPlanetaId (int)
├── tipoViaje (String: "PASAJERO"|"CARGA")
├── tipoTiming (String: "INMEDIATO"|"PROGRAMADO")
├── fechaHoraSolicitada (String - si programado)
├── numPasajeros (int)
├── pesoCarga (BigDecimal)
└── descripcionCarga (String)
```

#### **SERVLET → CONTROLLERS:**
```
CrearViajeServlet.java
├── ViajeController.validarDatosViaje()
├── CalculadoraController.calcularDistancia()
├── CalculadoraController.calcularPrecio()
├── ViajeController.crearViaje()
└── NotificacionController.notificarPilotos()
```

#### **CONTROLLERS → DAOs:**
```
ViajeController:
├── PlanetaDAO.obtenerPorId(origenId)
├── PlanetaDAO.obtenerPorId(destinoId)
├── ViajeDAO.insertar(viaje)
└── UsuarioDAO.obtenerPilotosCompatibles(faccionId)

CalculadoraController:
├── PlanetaDAO.obtenerCoordenadas(planetaId)
└── ConfiguracionDAO.obtenerTarifas()
```

#### **DAOs → QUERIES:**
```sql
-- ViajeDAO.insertar()
INSERT INTO viajes (
    usuario_id, origen_planeta_id, destino_planeta_id, 
    tipo_viaje, tipo_timing, fecha_hora_solicitada,
    num_pasajeros, peso_carga, descripcion_carga,
    distancia_calculada, precio_final, estado
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDIENTE')

-- CalculadoraController.calcularDistancia()
SELECT calcular_distancia_planetas(?, ?) as distancia

-- UsuarioDAO.obtenerPilotosCompatibles()
SELECT u.* FROM usuarios u 
JOIN perfiles_piloto pp ON u.id = pp.usuario_id 
WHERE u.tipo_usuario = 'PILOTO' 
AND pp.estado_solicitud = 'APROBADO'
AND u.activo = true
```

---

### **CU-004: SOLICITAR SER PILOTO**

**🔄 FLUJO TÉCNICO:**

#### **JSP → SERVLET:**
```
JSP: /jsp/piloto/solicitar-piloto.jsp
POST → /piloto/solicitar
Parámetros:
├── edad (int)
├── lugarNacimiento (String)
├── tieneAntecedentes (boolean)
├── detallesAntecedentes (String)
├── tuvoActividadPolitica (boolean)
├── detalleActividadPolitica (String)
├── añosActividadPolitica (String)
├── tipoViajesPreferido (String)
├── distanciasPreferidas (String)
├── disponibilidadHoraria (String)
├── añosExperiencia (int)
├── tiposNavesManejadas[] (String[])
├── licenciasActuales[] (String[])
└── referencias (String)
```

#### **SERVLET → CONTROLLERS:**
```
SolicitarPilotoServlet.java
├── PilotoController.validarSolicitud()
├── PilotoController.verificarSolicitudExistente()
├── PilotoController.crearSolicitud()
└── NotificacionController.notificarAdministradores()
```

#### **CONTROLLERS → DAOs:**
```
PilotoController:
├── PilotoDAO.existeSolicitudPendiente(usuarioId)
├── PilotoDAO.insertarSolicitud(perfilPiloto)
└── UsuarioDAO.obtenerAdministradores()
```

#### **DAOs → QUERIES:**
```sql
-- PilotoDAO.existeSolicitudPendiente()
SELECT COUNT(*) FROM perfiles_piloto 
WHERE usuario_id = ? AND estado_solicitud = 'PENDIENTE'

-- PilotoDAO.insertarSolicitud()
INSERT INTO perfiles_piloto (
    usuario_id, edad, lugar_nacimiento, tiene_antecedentes,
    detalles_antecedentes, tuvo_actividad_politica,
    detalle_actividad_politica, años_actividad_politica,
    tipo_viajes_preferido, distancias_preferidas,
    disponibilidad_horaria, años_experiencia,
    tipos_naves_manejadas, licencias_actuales,
    referencias, estado_solicitud
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDIENTE')
```

---

### **CU-005: VER VIAJES DISPONIBLES (PILOTO)**

**🔄 FLUJO TÉCNICO:**

#### **JSP → SERVLET:**
```
JSP: /jsp/piloto/viajes-disponibles.jsp
GET → /piloto/viajes-disponibles
Parámetros opcionales:
├── filtroTipoViaje (String)
├── filtroDistancia (String)
├── filtroTiming (String)
├── filtroPrecioMin (BigDecimal)
├── filtroPrecioMax (BigDecimal)
├── ordenarPor (String)
└── page (int)
```

#### **SERVLET → CONTROLLERS:**
```
ViajesDisponiblesServlet.java
├── PilotoController.verificarEstadoPiloto()
├── MatchingController.aplicarLogicaFacciones()
├── ViajeController.obtenerViajesDisponibles()
└── PaginacionController.aplicarPaginacion()
```

#### **CONTROLLERS → DAOs:**
```
MatchingController:
├── UsuarioDAO.obtenerFaccionPiloto(usuarioId)
├── NaveDAO.obtenerNaveAsignada(pilotoId)
└── ViajeDAO.obtenerViajesCompatibles(filtros)

ViajeController:
├── PlanetaDAO.obtenerInfoCompleta(planetaId)
├── UsuarioDAO.obtenerInfoBasica(usuarioId)
└── ViajeDAO.contarViajesDisponibles(filtros)
```

#### **DAOs → QUERIES:**
```sql
-- ViajeDAO.obtenerViajesCompatibles()
SELECT v.*, po.nombre as origen_nombre, pd.nombre as destino_nombre,
       u.nombre as usuario_nombre, u.faccion_id
FROM viajes v
JOIN planetas po ON v.origen_planeta_id = po.id
JOIN planetas pd ON v.destino_planeta_id = pd.id
JOIN usuarios u ON v.usuario_id = u.id
WHERE v.estado = 'PENDIENTE'
AND v.fecha_hora_solicitada >= DATE_SUB(NOW(), INTERVAL 1 HOUR)
AND (v.es_mision_encubierta = false 
     OR JSON_CONTAINS(v.facciones_autorizadas, ?))
ORDER BY v.created_at DESC
LIMIT ? OFFSET ?

-- NaveDAO.obtenerNaveAsignada()
SELECT * FROM naves WHERE piloto_id = ? AND estado = 'ASIGNADA'
```

---

### **CU-006: ACEPTAR VIAJE**

**🔄 FLUJO TÉCNICO:**

#### **JSP → SERVLET:**
```
JSP: Desde lista de viajes disponibles
POST → /piloto/aceptar-viaje
Parámetros:
├── viajeId (int)
└── confirmacion (boolean)
```

#### **SERVLET → CONTROLLERS:**
```
AceptarViajeServlet.java
├── ViajeController.validarViajeDisponible()
├── PilotoController.verificarCapacidadNave()
├── ViajeController.asignarPiloto()
├── TimerController.iniciarContadorLlegada()
└── NotificacionController.notificarUsuario()
```

#### **CONTROLLERS → DAOs:**
```
ViajeController:
├── ViajeDAO.obtenerPorId(viajeId)
├── ViajeDAO.actualizarEstado(viajeId, pilotoId)
└── ViajeDAO.verificarViajeActivoPiloto(pilotoId)

PilotoController:
├── NaveDAO.obtenerCapacidad(pilotoId)
└── MatchingDAO.verificarAutorizacionFaccion()
```

#### **DAOs → QUERIES:**
```sql
-- ViajeDAO.actualizarEstado()
UPDATE viajes SET 
    piloto_id = ?, 
    estado = 'CONFIRMADO',
    fecha_confirmacion = CURRENT_TIMESTAMP
WHERE id = ? AND estado = 'PENDIENTE'

-- ViajeDAO.verificarViajeActivoPiloto()
SELECT COUNT(*) FROM viajes 
WHERE piloto_id = ? 
AND estado IN ('CONFIRMADO', 'EN_CURSO')

-- NaveDAO.obtenerCapacidad()
SELECT capacidad_pasajeros, capacidad_carga 
FROM naves WHERE piloto_id = ?
```

---

### **CU-007: APROBAR/RECHAZAR SOLICITUD DE PILOTO**

**🔄 FLUJO TÉCNICO:**

#### **JSP → SERVLET:**
```
JSP: /jsp/admin/aprobar-pilotos.jsp
POST → /admin/procesar-solicitud
Parámetros:
├── solicitudId (int)
├── decision (String: "APROBAR"|"RECHAZAR")
├── naveSeleccionada (int - si aprueba)
└── motivoRechazo (String - si rechaza)
```

#### **SERVLET → CONTROLLERS:**
```
AprobacionPilotoServlet.java
├── AdminController.validarPermisos()
├── PilotoController.evaluarSolicitud()
├── NavegacionController.asignarNave() [si aprueba]
├── UsuarioController.actualizarTipoUsuario() [si aprueba]
└── NotificacionController.notificarSolicitante()
```

#### **CONTROLLERS → DAOs:**
```
PilotoController:
├── PilotoDAO.obtenerSolicitudCompleta(solicitudId)
├── PilotoDAO.actualizarEstadoSolicitud()
└── NaveDAO.obtenerNavesDisponibles()

UsuarioController:
├── UsuarioDAO.actualizarTipoUsuario(usuarioId)
└── NaveDAO.asignarNave(naveId, pilotoId)
```

#### **DAOs → QUERIES:**
```sql
-- PilotoDAO.actualizarEstadoSolicitud()
UPDATE perfiles_piloto SET 
    estado_solicitud = ?,
    admin_aprobador_id = ?,
    fecha_aprobacion = CURRENT_TIMESTAMP,
    motivo_rechazo = ?
WHERE id = ?

-- UsuarioDAO.actualizarTipoUsuario()
UPDATE usuarios SET tipo_usuario = 'PILOTO' WHERE id = ?

-- NaveDAO.asignarNave()
UPDATE naves SET piloto_id = ?, estado = 'ASIGNADA' WHERE id = ?
```

---

### **CU-008: GESTIONAR ESTADO DE VIAJE**

**🔄 FLUJO TÉCNICO:**

#### **JSP → SERVLET:**
```
JSP: /jsp/piloto/mi-viaje-activo.jsp
POST → /piloto/actualizar-estado
Parámetros:
├── viajeId (int)
├── nuevoEstado (String)
├── motivoCancelacion (String - si cancela)
└── confirmacionCompletado (boolean)
```

#### **SERVLET → CONTROLLERS:**
```
GestionarEstadoServlet.java
├── ViajeController.validarTransicionEstado()
├── GeolocationController.verificarUbicacion() [para EN_CURSO]
├── TimerController.validarTiempoMinimo() [para COMPLETADO]
├── ViajeController.actualizarEstado()
├── MetricasController.actualizarEstadisticasPiloto()
└── NotificacionController.notificarUsuario()
```

#### **CONTROLLERS → DAOs:**
```
ViajeController:
├── ViajeDAO.obtenerViajeActivo(pilotoId)
├── ViajeDAO.actualizarEstadoViaje()
└── ViajeDAO.liberarNave(pilotoId)

MetricasController:
├── PilotoDAO.actualizarMetricas(pilotoId)
└── EstadisticasDAO.registrarEvento()
```

#### **DAOs → QUERIES:**
```sql
-- ViajeDAO.actualizarEstadoViaje()
UPDATE viajes SET 
    estado = ?,
    fecha_inicio = CASE WHEN ? = 'EN_CURSO' THEN CURRENT_TIMESTAMP ELSE fecha_inicio END,
    fecha_finalizacion = CASE WHEN ? = 'COMPLETADO' THEN CURRENT_TIMESTAMP ELSE fecha_finalizacion END,
    motivo_cancelacion = ?,
    cancelado_por = CASE WHEN ? = 'CANCELADO' THEN 'PILOTO' ELSE cancelado_por END
WHERE id = ?

-- PilotoDAO.actualizarMetricas()
UPDATE perfiles_piloto SET 
    total_viajes_completados = total_viajes_completados + 1
WHERE usuario_id = ?
```

---

### **CU-009: CREAR MISIÓN ENCUBIERTA**

**🔄 FLUJO TÉCNICO:**

#### **JSP → SERVLET:**
```
JSP: /jsp/usuario/crear-mision-encubierta.jsp
POST → /viajes/crear-encubierta
Parámetros:
├── [Todos los parámetros de viaje normal]
├── nivelDiscrecion (String)
├── faccionesAutorizadas[] (int[])
├── informacionOcultar[] (String[])
└── justificacionMision (String)
```

#### **SERVLET → CONTROLLERS:**
```
CrearMisionEncubiertaServlet.java
├── AuthController.verificarPermisosEncubiertos()
├── ViajeController.validarConfiguracionEncubierta()
├── ViajeController.crearMisionEncubierta()
├── AdminController.enviarSolicitudAprobacion() [si no es admin]
└── NotificacionController.notificarPilotosAutorizados()
```

#### **CONTROLLERS → DAOs:**
```
ViajeController:
├── ViajeDAO.insertarMisionEncubierta()
└── UsuarioDAO.obtenerPilotosPorFacciones(facciones[])

AuthController:
├── UsuarioDAO.verificarPrivilegiosEncubiertos(usuarioId)
└── AdminDAO.obtenerAdministradores()
```

#### **DAOs → QUERIES:**
```sql
-- ViajeDAO.insertarMisionEncubierta()
INSERT INTO viajes (
    [campos normales],
    es_mision_encubierta, nivel_discrecion,
    facciones_autorizadas, informacion_ocultar,
    justificacion_mision, requiere_aprobacion
) VALUES ([valores], true, ?, ?, ?, ?, ?)

-- UsuarioDAO.obtenerPilotosPorFacciones()
SELECT u.* FROM usuarios u
JOIN perfiles_piloto pp ON u.id = pp.usuario_id
WHERE u.tipo_usuario = 'PILOTO'
AND u.faccion_id IN (?)
AND pp.estado_solicitud = 'APROBADO'
```

---

### **CU-010: GESTIONAR NAVES**

**🔄 FLUJO TÉCNICO:**

#### **JSP → SERVLET:**
```
JSP: /jsp/admin/gestion-naves.jsp
POST → /admin/gestionar-naves
Parámetros:
├── accion (String: "AGREGAR"|"MODIFICAR"|"ASIGNAR"|"MANTENIMIENTO")
├── naveId (int - para modificar/asignar)
├── tipoNaveId (int - para agregar)
├── nombrePersonalizado (String)
├── pilotoId (int - para asignación)
├── motivoMantenimiento (String)
└── duracionEstimada (int)
```

#### **SERVLET → CONTROLLERS:**
```
GestionNavesServlet.java
├── AdminController.validarPermisos()
├── NaveController.procesarAccion()
├── InventarioController.actualizarInventario()
└── NotificacionController.notificarPilotosAfectados()
```

#### **CONTROLLERS → DAOs:**
```
NaveController:
├── NaveDAO.insertar(nave) [AGREGAR]
├── NaveDAO.actualizar(nave) [MODIFICAR]
├── NaveDAO.cambiarAsignacion() [ASIGNAR]
├── NaveDAO.enviarMantenimiento() [MANTENIMIENTO]
└── TipoNaveDAO.obtenerTipos()

InventarioController:
├── NaveDAO.obtenerInventarioCompleto()
└── EstadisticasDAO.actualizarMetricasFlota()
```

#### **DAOs → QUERIES:**
```sql
-- NaveDAO.insertar()
INSERT INTO naves (
    tipo_nave_id, nombre_personalizado, 
    ubicacion_actual, estado
) VALUES (?, ?, ?, 'DISPONIBLE')

-- NaveDAO.cambiarAsignacion()
UPDATE naves SET 
    piloto_id = ?,
    fecha_asignacion = CURRENT_TIMESTAMP
WHERE id = ?

-- NaveDAO.enviarMantenimiento()
UPDATE naves SET 
    estado = 'EN_MANTENIMIENTO',
    motivo_mantenimiento = ?,
    fecha_inicio_mantenimiento = CURRENT_TIMESTAMP,
    duracion_estimada_dias = ?
WHERE id = ?
```

---

### **CU-011: DEJAR RESEÑA**

**🔄 FLUJO TÉCNICO:**

#### **JSP → SERVLET:**
```
JSP: /jsp/usuario/dejar-resena.jsp
POST → /usuario/crear-resena
Parámetros:
├── viajeId (int)
├── ratingGeneral (int 1-5)
├── ratingPuntualidad (int 1-5)
├── ratingProfesionalismo (int 1-5)
├── ratingNave (int 1-5)
├── comentario (String)
└── esAnonima (boolean)
```

#### **SERVLET → CONTROLLERS:**
```
DejarResenaServlet.java
├── ResenaController.validarElegibilidad()
├── ResenaController.validarContenido()
├── ResenaController.crearResena()
├── ReputacionController.actualizarMetricasPiloto()
└── NotificacionController.notificarPiloto()
```

#### **CONTROLLERS → DAOs:**
```
ResenaController:
├── ViajeDAO.verificarElegibilidad(viajeId, usuarioId)
├── ResenaDAO.existeResena(viajeId)
├── ResenaDAO.insertar(resena)
└── ContentFilterDAO.validarContenido(comentario)

ReputacionController:
├── PilotoDAO.recalcularRating(pilotoId)
└── ResenaDAO.obtenerEstadisticasPiloto(pilotoId)
```

#### **DAOs → QUERIES:**
```sql
-- ResenaDAO.insertar()
INSERT INTO resenas (
    viaje_id, usuario_id, piloto_id,
    rating_general, rating_puntualidad,
    rating_profesionalismo, rating_nave,
    comentario, es_anonima
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)

-- PilotoDAO.recalcularRating() [via TRIGGER]
UPDATE perfiles_piloto SET 
    rating_promedio = (
        SELECT AVG(rating_general) FROM resenas 
        WHERE piloto_id = ?
    ),
    total_resenas = (
        SELECT COUNT(*) FROM resenas 
        WHERE piloto_id = ?
    )
WHERE usuario_id = ?

-- ViajeDAO.verificarElegibilidad()
SELECT COUNT(*) FROM viajes 
WHERE id = ? AND usuario_id = ? 
AND estado = 'COMPLETADO'
AND fecha_finalizacion >= DATE_SUB(NOW(), INTERVAL 7 DAY)
```

---

## 📋 **MATRIZ DE TRAZABILIDAD TÉCNICA COMPLETA**

| Caso de Uso | JSP Principal | Servlet | Controller | DAO Principal | Tabla DB Principal |
|-------------|---------------|---------|------------|---------------|-------------------|
| CU-001: Registro | register.jsp | RegisterServlet | UsuarioController | UsuarioDAO | usuarios |
| CU-002: Login | login.jsp | LoginServlet | AuthController | UsuarioDAO | usuarios |
| CU-003: Crear Viaje | crear-viaje.jsp | CrearViajeServlet | ViajeController | ViajeDAO | viajes |
| CU-004: Solicitar Piloto | solicitar-piloto.jsp | SolicitarPilotoServlet | PilotoController | PilotoDAO | perfiles_piloto |
| CU-005: Ver Viajes Disponibles | viajes-disponibles.jsp | ViajesDisponiblesServlet | MatchingController | ViajeDAO | viajes |
| CU-006: Aceptar Viaje | - | AceptarViajeServlet | ViajeController | ViajeDAO | viajes |
| CU-007: Aprobar Piloto | aprobar-pilotos.jsp | AprobacionPilotoServlet | AdminController | PilotoDAO | perfiles_piloto |
| CU-008: Gestionar Estado | mi-viaje-activo.jsp | GestionarEstadoServlet | ViajeController | ViajeDAO | viajes |
| CU-009: Misión Encubierta | crear-mision-encubierta.jsp | CrearMisionEncubiertaServlet | ViajeController | ViajeDAO | viajes |
| CU-010: Gestionar Naves | gestion-naves.jsp | GestionNavesServlet | NaveController | NaveDAO | naves |
| CU-011: Dejar Reseña | dejar-resena.jsp | DejarResenaServlet | ResenaController | ResenaDAO | resenas |

---

## 🎯 **CONTROLLERS PRINCIPALES Y SUS RESPONSABILIDADES**

### **AuthController**
```java
public class AuthController {
    // CU-002: Login
    public Usuario validarCredenciales(String email, String password)
    public boolean verificarPermisosEncubiertos(int usuarioId)
    
    // Métodos auxiliares
    private boolean verificarPassword(String password, String hash)
    private void registrarIntentoFallido(String email)
}
```

### **UsuarioController**
```java
public class UsuarioController {
    // CU-001: Registro
    public boolean registrarUsuario(UsuarioDTO usuario)
    
    // CU-007: Aprobar Piloto
    public boolean actualizarTipoUsuario(int usuarioId, TipoUsuario tipo)
    
    // Métodos auxiliares
    public Usuario obtenerUsuarioCompleto(int usuarioId)
    public List<Usuario> obtenerPilotosCompatibles(int faccionId)
}
```

### **ViajeController**
```java
public class ViajeController {
    // CU-003: Crear Viaje
    public boolean crearViaje(ViajeDTO viaje)
    
    // CU-005: Ver Viajes Disponibles
    public List<Viaje> obtenerViajesDisponibles(FiltrosDTO filtros)
    
    // CU-006: Aceptar Viaje
    public boolean asignarPiloto(int viajeId, int pilotoId)
    
    // CU-008: Gestionar Estado
    public boolean actualizarEstadoViaje(int viajeId, EstadoViaje estado)
    
    // CU-009: Misión Encubierta
    public boolean crearMisionEncubierta(MisionEncubiertaDTO mision)
}
```

### **PilotoController**
```java
public class PilotoController {
    // CU-004: Solicitar Piloto
    public boolean crearSolicitudPiloto(PerfilPilotoDTO perfil)
    
    // CU-007: Aprobar/Rechazar Piloto
    public boolean evaluarSolicitud(int solicitudId, DecisionDTO decision)
    
    // Métodos auxiliares
    public boolean verificarCapacidadNave(int pilotoId, ViajeDTO viaje)
    public boolean verificarEstadoPiloto(int pilotoId)
}
```

### **AdminController**
```java
public class AdminController {
    // CU-007: Aprobar Piloto
    public List<SolicitudPiloto> obtenerSolicitudesPendientes()
    
    // CU-010: Gestionar Naves
    public boolean procesarAccionNave(AccionNaveDTO accion)
    
    // Métodos auxiliares
    public boolean validarPermisos(int usuarioId)
    public void registrarAccionAdministrativa(String accion, int adminId)
}
```

### **NaveController**
```java
public class NaveController {
    // CU-010: Gestionar Naves
    public boolean agregarNave(NaveDTO nave)
    public boolean modificarNave(int naveId, NaveDTO datosNuevos)
    public boolean cambiarAsignacion(int naveId, int pilotoId)
    public boolean enviarMantenimiento(int naveId, MantenimientoDTO datos)
    
    // Métodos auxiliares
    public List<Nave> obtenerInventarioCompleto()
    public List<Nave> obtenerNavesDisponibles()
}
```

### **ResenaController**
```java
public class ResenaController {
    // CU-011: Dejar Reseña
    public boolean crearResena(ResenaDTO resena)
    public boolean validarElegibilidad(int viajeId, int usuarioId)
    
    // Métodos auxiliares
    public boolean validarContenido(String comentario)
    public void actualizarReputacionPiloto(int pilotoId)
}
```

---

## 🎯 **DAOS PRINCIPALES Y SUS MÉTODOS**

### **UsuarioDAO**
```java
public interface UsuarioDAO {
    // CU-001, CU-002
    boolean insertar(Usuario usuario);
    Usuario obtenerPorEmail(String email);
    boolean actualizarUltimoAcceso(int usuarioId);
    
    // CU-007
    boolean actualizarTipoUsuario(int usuarioId, TipoUsuario tipo);
    List<Usuario> obtenerAdministradores();
    
    // Auxiliares
    List<Usuario> obtenerPilotosCompatibles(int faccionId);
    int obtenerFaccionPiloto(int usuarioId);
}
```

### **ViajeDAO**
```java
public interface ViajeDAO {
    // CU-003, CU-009
    boolean insertar(Viaje viaje);
    boolean insertarMisionEncubierta(MisionEncubierta mision);
    
    // CU-005
    List<Viaje> obtenerViajesCompatibles(FiltrosDTO filtros);
    int contarViajesDisponibles(FiltrosDTO filtros);
    
    // CU-006, CU-008
    boolean actualizarEstado(int viajeId, EstadoViaje estado, int pilotoId);
    Viaje obtenerViajeActivo(int pilotoId);
    boolean verificarViajeActivoPiloto(int pilotoId);
    
    // Auxiliares
    boolean verificarElegibilidadResena(int viajeId, int usuarioId);
}
```

### **PilotoDAO**
```java
public interface PilotoDAO {
    // CU-004
    boolean insertarSolicitud(PerfilPiloto perfil);
    boolean existeSolicitudPendiente(int usuarioId);
    
    // CU-007
    List<SolicitudPiloto> obtenerSolicitudesPendientes();
    boolean actualizarEstadoSolicitud(int solicitudId, EstadoSolicitud estado);
    
    // CU-008, CU-011
    boolean actualizarMetricas(int pilotoId);
    boolean recalcularRating(int pilotoId);
}
```

### **NaveDAO**
```java
public interface NaveDAO {
    // CU-010
    boolean insertar(Nave nave);
    boolean actualizar(Nave nave);
    boolean cambiarAsignacion(int naveId, int pilotoId);
    boolean enviarMantenimiento(int naveId, MantenimientoDTO datos);
    
    // Auxiliares
    List<Nave> obtenerNavesDisponibles();
    Nave obtenerNaveAsignada(int pilotoId);
    CapacidadNave obtenerCapacidad(int pilotoId);
}
```

### **ResenaDAO**
```java
public interface ResenaDAO {
    // CU-011
    boolean insertar(Resena resena);
    boolean existeResena(int viajeId);
    
    // Auxiliares
    List<Resena> obtenerPorPiloto(int pilotoId);
    EstadisticasResena obtenerEstadisticasPiloto(int pilotoId);
}
```

---

## 🎯 **QUERIES SQL PRINCIPALES POR FUNCIONALIDAD**

### **Gestión de Usuarios**
```sql
-- Registro (CU-001)
INSERT INTO usuarios (email, password_hash, nombre, apellido, faccion_id, tipo_usuario, activo, verificado) 
VALUES (?, ?, ?, ?, ?, 'PASAJERO', true, false);

-- Login (CU-002)
SELECT id, email, password_hash, nombre, apellido, faccion_id, tipo_usuario, activo, verificado
FROM usuarios WHERE email = ? AND activo = true;
```

### **Gestión de Viajes**
```sql
-- Crear viaje (CU-003)
INSERT INTO viajes (usuario_id, origen_planeta_id, destino_planeta_id, tipo_viaje, tipo_timing, 
                   fecha_hora_solicitada, num_pasajeros, peso_carga, descripcion_carga,
                   distancia_calculada, precio_final, estado) 
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDIENTE');

-- Ver viajes disponibles (CU-005)
SELECT v.*, po.nombre as origen_nombre, pd.nombre as destino_nombre,
       u.nombre as usuario_nombre, u.faccion_id
FROM viajes v
JOIN planetas po ON v.origen_planeta_id = po.id
JOIN planetas pd ON v.destino_planeta_id = pd.id
JOIN usuarios u ON v.usuario_id = u.id
WHERE v.estado = 'PENDIENTE'
AND v.fecha_hora_solicitada >= DATE_SUB(NOW(), INTERVAL 1 HOUR)
AND (v.es_mision_encubierta = false OR JSON_CONTAINS(v.facciones_autorizadas, ?));

-- Aceptar viaje (CU-006)
UPDATE viajes SET piloto_id = ?, estado = 'CONFIRMADO', fecha_confirmacion = CURRENT_TIMESTAMP
WHERE id = ? AND estado = 'PENDIENTE';
```

### **Gestión de Pilotos**
```sql
-- Solicitar ser piloto (CU-004)
INSERT INTO perfiles_piloto (usuario_id, edad, lugar_nacimiento, tiene_antecedentes,
                           años_experiencia, tipo_viajes_preferido, estado_solicitud) 
VALUES (?, ?, ?, ?, ?, ?, 'PENDIENTE');

-- Aprobar piloto (CU-007)
UPDATE perfiles_piloto SET estado_solicitud = ?, admin_aprobador_id = ?, 
                          fecha_aprobacion = CURRENT_TIMESTAMP, motivo_rechazo = ?
WHERE id = ?;
```

### **Gestión de Estados y Reseñas**
```sql
-- Actualizar estado viaje (CU-008)
UPDATE viajes SET estado = ?, 
                 fecha_inicio = CASE WHEN ? = 'EN_CURSO' THEN CURRENT_TIMESTAMP ELSE fecha_inicio END,
                 fecha_finalizacion = CASE WHEN ? = 'COMPLETADO' THEN CURRENT_TIMESTAMP ELSE fecha_finalizacion END
WHERE id = ?;

-- Crear reseña (CU-011)
INSERT INTO resenas (viaje_id, usuario_id, piloto_id, rating_general, rating_puntualidad,
                    rating_profesionalismo, rating_nave, comentario, es_anonima) 
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
```

---

## 🎯 **BENEFICIOS DE ESTE ARTEFACTO COMPLETO:**

1. **Trazabilidad total:** Desde JSP hasta base de datos para todos los casos de uso
2. **Implementación guiada:** Sabes exactamente qué métodos crear en cada capa
3. **Testing facilitado:** Cada paso es verificable y testeable independientemente
4. **Documentación técnica profesional:** Ideal para presentar al profesor
5. **Mantenimiento simplificado:** Fácil localizar componentes y dependencias
6. **Arquitectura clara:** Separación de responsabilidades bien definida
7. **Escalabilidad:** Base sólida para agregar nuevas funcionalidades

---

## 📝 **CÓMO USAR ESTE DOCUMENTO PARA IMPLEMENTACIÓN:**

### **Fase 1: Preparación**
1. **Crear estructura de packages** según los controllers identificados
2. **Definir interfaces DAO** con todos los métodos listados
3. **Crear DTOs** para transferencia de datos entre capas
4. **Configurar base de datos** con el schema ya definido

### **Fase 2: Implementación por Capas**
1. **DAOs primero:** Implementar acceso a datos con queries específicas
2. **Controllers después:** Lógica de negocio usando DAOs
3. **Servlets luego:** Manejo de requests/responses usando Controllers  
4. **JSPs finalmente:** Interfaces de usuario llamando Servlets

### **Fase 3: Testing**
1. **Unit tests:** Para cada método DAO y Controller
2. **Integration tests:** Para flujos completos de casos de uso
3. **UI tests:** Para validar JSPs y flujos de usuario

### **Fase 4: Documentación Final**
1. **JavaDoc:** Para todas las clases públicas
2. **README técnico:** Con arquitectura y setup
3. **Manual de usuario:** Para funcionalidades principales

---

## 🎓 **PARA PRESENTACIÓN ACADÉMICA:**

Este artefacto demuestra:
- **Análisis completo** de requerimientos funcionales
- **Diseño arquitectónico** con separación de capas
- **Mapeo objeto-relacional** bien estructurado
- **Patrones de diseño** aplicados (DAO, MVC, DTO)
- **Escalabilidad** y mantenibilidad del código
- **Documentación técnica** profesional

**Ideal para defender** el diseño técnico ante el profesor y demostrar dominio completo de tecnologías Java Web.