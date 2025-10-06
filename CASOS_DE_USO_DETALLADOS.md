# 📋 CASOS DE USO DETALLADOS - FLYSOLO
## Especificación Completa con Actores, Flujos y Condiciones

---

## 🎯 **CU-001: REGISTRAR USUARIO**

### **📊 INFORMACIÓN GENERAL**
- **ID:** CU-001
- **Nombre:** Registrar Usuario
- **Actor Principal:** Usuario (No Registrado)
- **Otros Actores:** Sistema de Validación, Base de Datos
- **Nivel:** Subrutina
- **Complejidad:** Media

### **🚀 DISPARADOR**
Usuario accede a la página principal y selecciona "Registrarse"

### **👤 INICIADOR**
Usuario No Registrado

### **🎯 META**
Crear una nueva cuenta de usuario en el sistema con afiliación a una facción específica

### **📋 PRECONDICIONES**
**Del Sistema:**
- Sistema operativo y base de datos disponibles
- Conexión a internet activa
- Servidor web funcionando

**De Negocio:**
- Usuario no debe tener cuenta existente
- Debe existir al menos una facción disponible para selección
- Sistema de validación de emails operativo

### **🔄 CAMINO BÁSICO**
1. Usuario accede a `/jsp/auth/register.jsp`
2. Sistema muestra formulario de registro con:
   - Campo email (String, obligatorio)
   - Campo password (String, obligatorio, mín 8 caracteres)
   - Campo confirmar password (String, obligatorio)
   - Campo nombre (String, obligatorio)
   - Campo apellido (String, obligatorio)
   - Dropdown facción (Integer, obligatorio: 1=Imperio, 2=Rebeldes, 3=Neutrales)
3. Usuario completa todos los campos requeridos
4. Usuario hace clic en "Registrarse"
5. Sistema valida formato de email usando regex
6. Sistema verifica que passwords coincidan
7. Sistema verifica que email no existe en base de datos
8. Sistema hashea password usando BCrypt
9. Sistema inserta registro en tabla `usuarios` con:
   - email (String)
   - password_hash (String)
   - nombre (String)
   - apellido (String)
   - faccion_id (Integer)
   - tipo_usuario = 'PASAJERO' (fijo)
   - activo = true (fijo)
   - verificado = false (fijo)
10. Sistema crea sesión HTTP automáticamente
11. Sistema establece atributo session "usuario" con datos completos
12. Sistema redirige a `/dashboard`
13. Usuario ve dashboard de pasajero

### **🔀 CAMINOS ALTERNATIVOS**

**3a. Email con formato inválido:**
- 3a.1. Sistema detecta formato inválido
- 3a.2. Sistema muestra mensaje "Email inválido"
- 3a.3. Sistema mantiene otros datos ingresados
- 3a.4. Retorna a paso 3

**3b. Passwords no coinciden:**
- 3b.1. Sistema detecta discrepancia
- 3b.2. Sistema muestra mensaje "Las contraseñas no coinciden"
- 3b.3. Sistema limpia campos de password
- 3b.4. Retorna a paso 3

**3c. Password muy débil:**
- 3c.1. Sistema detecta password < 8 caracteres
- 3c.2. Sistema muestra mensaje "Password debe tener al menos 8 caracteres"
- 3c.3. Retorna a paso 3

**7a. Email ya existe:**
- 7a.1. Sistema encuentra email en base de datos
- 7a.2. Sistema muestra mensaje "Email ya registrado"
- 7a.3. Sistema mantiene otros datos excepto email
- 7a.4. Retorna a paso 3

**9a. Error de base de datos:**
- 9a.1. SQLException durante inserción
- 9a.2. Sistema muestra mensaje "Error interno, intente nuevamente"
- 9a.3. Sistema registra error en logs
- 9a.4. Retorna a paso 3

### **✅ POSTCONDICIONES**
**Del Sistema:**
- Nuevo registro creado en tabla `usuarios`
- Sesión HTTP iniciada automáticamente
- Usuario redirigido a dashboard principal

**De Negocio:**
- Usuario puede acceder a funcionalidades de pasajero
- Usuario afiliado a facción seleccionada
- Usuario puede solicitar upgrade a piloto posteriormente

### **📊 DATOS UTILIZADOS**
**Variables de Entrada:**
- email: String (temporal)
- password: String (temporal, se hashea)
- confirmPassword: String (temporal, se descarta)
- nombre: String (persistente)
- apellido: String (persistente)
- faccionId: Integer (persistente)

**Variables Fijas:**
- tipo_usuario: "PASAJERO" (constante del sistema)
- activo: true (constante del sistema)
- verificado: false (constante del sistema)

**Variables del Sistema:**
- created_at: TIMESTAMP (automático)
- id: INTEGER (auto_increment)

---

## 🎯 **CU-002: INICIAR SESIÓN**

### **📊 INFORMACIÓN GENERAL**
- **ID:** CU-002
- **Nombre:** Iniciar Sesión
- **Actor Principal:** Usuario Registrado
- **Otros Actores:** Sistema de Autenticación, Base de Datos
- **Nivel:** Subrutina
- **Complejidad:** Baja

### **🚀 DISPARADOR**
Usuario registrado accede a la aplicación o es redirigido por filtro de autenticación

### **👤 INICIADOR**
Usuario Registrado

### **🎯 META**
Autenticar usuario y establecer sesión activa para acceso a funcionalidades

### **📋 PRECONDICIONES**
**Del Sistema:**
- Usuario debe tener cuenta existente en base de datos
- Sistema de autenticación operativo
- Base de datos disponible

**De Negocio:**
- Usuario debe estar activo (activo = true)
- Cuenta no debe estar suspendida

### **🔄 CAMINO BÁSICO**
1. Usuario accede a `/jsp/auth/login.jsp`
2. Sistema muestra formulario con:
   - Campo email (String, obligatorio)
   - Campo password (String, obligatorio)
   - Checkbox "Recordarme" (Boolean, opcional)
3. Usuario ingresa credenciales válidas
4. Usuario hace clic en "Iniciar Sesión"
5. Sistema busca usuario por email en tabla `usuarios`
6. Sistema verifica password usando BCrypt.checkpw()
7. Sistema verifica que usuario esté activo
8. Sistema crea sesión HTTP
9. Sistema establece atributos de sesión:
   - "usuario": Objeto Usuario completo
   - "faccion": Objeto Facción del usuario
   - "tipo_usuario": Enum TipoUsuario
10. Sistema determina dashboard según tipo_usuario:
    - PASAJERO → `/jsp/usuario/dashboard.jsp`
    - PILOTO → `/jsp/piloto/dashboard-piloto.jsp`
    - ADMIN → `/jsp/admin/dashboard-admin.jsp`
11. Sistema redirige a dashboard correspondiente

### **🔀 CAMINOS ALTERNATIVOS**

**5a. Email no encontrado:**
- 5a.1. Sistema no encuentra email en base de datos
- 5a.2. Sistema muestra mensaje "Credenciales inválidas"
- 5a.3. Sistema registra intento fallido en logs
- 5a.4. Retorna a paso 3

**6a. Password incorrecto:**
- 6a.1. BCrypt.checkpw() retorna false
- 6a.2. Sistema muestra mensaje "Credenciales inválidas"
- 6a.3. Sistema incrementa contador de intentos fallidos
- 6a.4. Retorna a paso 3

**7a. Usuario inactivo:**
- 7a.1. Sistema detecta activo = false
- 7a.2. Sistema muestra mensaje "Cuenta deshabilitada, contacte al administrador"
- 7a.3. Sistema registra intento de acceso en logs
- 7a.4. Retorna a paso 3

**6b. Múltiples intentos fallidos (Extensión de seguridad):**
- 6b.1. Sistema detecta > 3 intentos fallidos en 15 minutos
- 6b.2. Sistema bloquea temporalmente IP
- 6b.3. Sistema muestra mensaje "Demasiados intentos, espere 15 minutos"
- 6b.4. Caso de uso termina

### **✅ POSTCONDICIONES**
**Del Sistema:**
- Sesión HTTP establecida con datos de usuario
- Usuario redirigido según su tipo y estado
- Timestamp de último acceso actualizado

**De Negocio:**
- Usuario puede acceder a funcionalidades según su rol
- Sistema reconoce facción del usuario para filtering

### **📊 DATOS UTILIZADOS**
**Variables de Entrada:**
- email: String (temporal)
- password: String (temporal)
- recordarme: Boolean (temporal)

**Variables del Sistema:**
- session_id: String (automático)
- ultimo_acceso: TIMESTAMP (actualizable)
- intentos_fallidos: Integer (temporal, en memoria)

---

## 🎯 **CU-003: CREAR SOLICITUD DE VIAJE**

### **📊 INFORMACIÓN GENERAL**
- **ID:** CU-003
- **Nombre:** Crear Solicitud de Viaje
- **Actor Principal:** Usuario Registrado (Pasajero)
- **Otros Actores:** Sistema de Cálculos, Servicio de Notificaciones, Pilotos
- **Nivel:** Objetivo del Usuario
- **Complejidad:** Alta

### **🚀 DISPARADOR**
Usuario registrado necesita transportarse de un planeta a otro

### **👤 INICIADOR**
Usuario Registrado (con rol PASAJERO o ADMIN)

### **🎯 META**
Crear una solicitud de viaje que será visible para pilotos compatibles según lógica de facciones

### **📋 PRECONDICIONES**
**Del Sistema:**
- Usuario debe estar autenticado
- Base de datos con planetas y sistemas solares cargados
- Servicio de cálculo de distancias operativo

**De Negocio:**
- Usuario debe tener perfil completo
- Origen y destino deben ser planetas diferentes
- Para viajes programados: fecha/hora debe ser futura

### **🔄 CAMINO BÁSICO**
1. Usuario accede a `/jsp/usuario/crear-viaje.jsp`
2. Sistema carga y muestra:
   - Dropdown planetas origen (de tabla `planetas`)
   - Dropdown planetas destino (de tabla `planetas`)
   - Radio buttons tipo viaje: PASAJERO/CARGA
   - Radio buttons timing: INMEDIATO/PROGRAMADO
3. Usuario selecciona planeta origen (Integer planetaOrigenId)
4. Usuario selecciona planeta destino (Integer planetaDestinoId)
5. Usuario selecciona tipo de viaje (String tipoViaje)
6. Usuario selecciona timing (String tipoTiming)
7. **SI** timing = PROGRAMADO:
   - Sistema muestra campos fecha/hora
   - Usuario selecciona fecha/hora futura (DateTime fechaHoraSolicitada)
8. **SI** tipo = PASAJERO:
   - Usuario ingresa número de pasajeros (Integer numPasajeros, default=1)
9. **SI** tipo = CARGA:
   - Usuario ingresa peso en toneladas (BigDecimal pesoCarga)
   - Usuario ingresa descripción opcional (String descripcionCarga)
10. Usuario hace clic en "Calcular Precio"
11. Sistema calcula distancia usando función `calcular_distancia_planetas(origen, destino)`
12. Sistema calcula precio base según fórmula:
    - Precio = distancia × tarifa_por_parsec × multiplicador_tipo × factor_urgencia
13. Sistema muestra resumen con:
    - Distancia calculada (BigDecimal)
    - Tiempo estimado (Integer minutos)
    - Precio base (BigDecimal)
    - Precio final (BigDecimal, +20% si inmediato)
14. Usuario confirma crear viaje
15. Sistema inserta registro en tabla `viajes` con estado PENDIENTE
16. Sistema envía notificaciones a pilotos elegibles según lógica de facciones
17. Sistema redirige a `/viajes/mis-viajes` con mensaje de éxito

### **🔀 CAMINOS ALTERNATIVOS**

**3a. Origen y destino iguales:**
- 3a.1. Sistema detecta planetaOrigenId = planetaDestinoId
- 3a.2. Sistema muestra mensaje "Origen y destino deben ser diferentes"
- 3a.3. Sistema deshabilita botón "Calcular Precio"
- 3a.4. Retorna a paso 4

**7a. Fecha/hora en el pasado:**
- 7a.1. Sistema detecta fechaHoraSolicitada < CURRENT_TIMESTAMP
- 7a.2. Sistema muestra mensaje "La fecha debe ser futura"
- 7a.3. Retorna a paso 7

**8a. Número de pasajeros inválido:**
- 8a.1. Usuario ingresa numPasajeros < 1 o > 50
- 8a.2. Sistema muestra mensaje "Debe ser entre 1 y 50 pasajeros"
- 8a.3. Retorna a paso 8

**9a. Peso de carga excesivo:**
- 9a.1. Usuario ingresa pesoCarga > 1000 toneladas
- 9a.2. Sistema muestra mensaje "Peso máximo: 1000 toneladas"
- 9a.3. Retorna a paso 9

**11a. Error en cálculo de distancia:**
- 11a.1. Función calcular_distancia_planetas() falla
- 11a.2. Sistema muestra mensaje "Error calculando ruta, intente nuevamente"
- 11a.3. Sistema registra error en logs
- 11a.4. Retorna a paso 10

**15a. Error al crear viaje:**
- 15a.1. INSERT en tabla viajes falla
- 15a.2. Sistema muestra mensaje "Error creando viaje, intente nuevamente"
- 15a.3. Sistema mantiene datos ingresados
- 15a.4. Retorna a paso 14

### **✅ POSTCONDICIONES**
**Del Sistema:**
- Nuevo registro en tabla `viajes` con estado PENDIENTE
- Distancia y precio calculados automáticamente
- Notificaciones enviadas a pilotos elegibles

**De Negocio:**
- Viaje visible para pilotos según lógica de facciones
- Timer automático para viajes inmediatos
- Métricas de demanda actualizadas

### **📊 DATOS UTILIZADOS**
**Variables de Entrada:**
- origenPlanetaId: Integer (persistente)
- destinoPlanetaId: Integer (persistente)
- tipoViaje: String ["PASAJERO", "CARGA"] (persistente)
- tipoTiming: String ["INMEDIATO", "PROGRAMADO"] (persistente)
- fechaHoraSolicitada: DateTime (persistente, NULL si inmediato)
- numPasajeros: Integer (persistente, default 1)
- pesoCarga: BigDecimal (persistente, default 0.00)
- descripcionCarga: String (persistente, opcional)

**Variables Calculadas:**
- distanciaCalculada: BigDecimal (persistente)
- tiempoEstimadoViaje: Integer (persistente, en minutos)
- precioBase: BigDecimal (persistente)
- precioPremium: BigDecimal (persistente)
- precioFinal: BigDecimal (persistente)

**Variables Fijas:**
- estado: "PENDIENTE" (constante inicial)
- usuario_id: Integer (de sesión)
- created_at: TIMESTAMP (automático)

---

## 🎯 **CU-004: SOLICITAR SER PILOTO**

### **📊 INFORMACIÓN GENERAL**
- **ID:** CU-004
- **Nombre:** Solicitar Ser Piloto
- **Actor Principal:** Usuario Registrado (Pasajero)
- **Otros Actores:** Administrador, Sistema de Validación
- **Nivel:** Objetivo del Usuario
- **Complejidad:** Alta

### **🚀 DISPARADOR**
Usuario pasajero decide solicitar upgrade a piloto para ofrecer servicios de transporte

### **👤 INICIADOR**
Usuario Registrado con tipo_usuario = PASAJERO

### **🎯 META**
Crear solicitud de piloto con información detallada para evaluación administrativa

### **📋 PRECONDICIONES**
**Del Sistema:**
- Usuario autenticado con tipo PASAJERO
- Usuario no debe tener solicitud pendiente previa

**De Negocio:**
- Usuario debe completar perfil básico
- Sistema de evaluación administrativa operativo

### **🔄 CAMINO BÁSICO**
1. Usuario accede a `/jsp/piloto/solicitar-piloto.jsp`
2. Sistema verifica que usuario no tenga solicitud pendiente
3. Sistema muestra formulario extenso con secciones:

   **SECCIÓN A: Datos Personales**
   - Edad (Integer, obligatorio, 18-65)
   - Lugar de nacimiento (String, obligatorio)
   - ¿Tiene antecedentes? (Boolean)
   - Detalles de antecedentes (String, condicional)

   **SECCIÓN B: Historial Político**
   - ¿Tuvo actividad política? (Boolean)
   - Detalle de actividad (String, condicional)
   - Años de actividad (String, condicional)

   **SECCIÓN C: Preferencias Laborales**
   - Tipo viajes preferido (String: PASAJEROS/CARGA/MIXTO)
   - Distancias preferidas (String: CORTAS/MEDIAS/LARGAS/CUALQUIERA)
   - Disponibilidad horaria (String)
   - Comentarios adicionales (String, opcional)

   **SECCIÓN D: Experiencia de Pilotaje**
   - Años de experiencia (Integer, obligatorio, min 1)
   - Tipos de naves manejadas (String[], múltiple selección)
   - Licencias actuales (String[], múltiple selección)
   - Referencias (String, opcional)

4. Usuario completa todas las secciones obligatorias
5. Usuario hace clic en "Enviar Solicitud"
6. Sistema valida todos los campos obligatorios
7. Sistema valida reglas de negocio:
   - Edad entre 18-65 años
   - Si tiene antecedentes, debe especificar detalles
   - Si tuvo actividad política, debe especificar detalles
   - Años experiencia > 0
8. Sistema inserta registro en tabla `perfiles_piloto` con estado PENDIENTE
9. Sistema envía notificación a administradores
10. Sistema muestra mensaje de confirmación
11. Sistema redirige a dashboard con status de solicitud

### **🔀 CAMINOS ALTERNATIVOS**

**2a. Usuario ya tiene solicitud pendiente:**
- 2a.1. Sistema encuentra registro en `perfiles_piloto` con estado PENDIENTE
- 2a.2. Sistema muestra mensaje "Ya tienes una solicitud en proceso"
- 2a.3. Sistema muestra estado actual de la solicitud
- 2a.4. Caso de uso termina

**2b. Usuario ya es piloto aprobado:**
- 2b.1. Sistema encuentra usuario con tipo_usuario = PILOTO
- 2b.2. Sistema redirige automáticamente a dashboard de piloto
- 2b.3. Caso de uso termina

**7a. Edad fuera de rango:**
- 7a.1. Sistema detecta edad < 18 o > 65
- 7a.2. Sistema muestra mensaje "Edad debe estar entre 18 y 65 años"
- 7a.3. Retorna a paso 4

**7b. Antecedentes sin detalles:**
- 7b.1. Usuario marca tieneAntecedentes = true pero no completa detalles
- 7b.2. Sistema muestra mensaje "Debe especificar detalles de antecedentes"
- 7b.3. Retorna a paso 4

**7c. Actividad política sin detalles:**
- 7c.1. Usuario marca tuvoActividadPolitica = true pero no completa detalles
- 7c.2. Sistema muestra mensaje "Debe especificar detalles de actividad política"
- 7c.3. Retorna a paso 4

**8a. Error al crear solicitud:**
- 8a.1. INSERT en tabla perfiles_piloto falla
- 8a.2. Sistema muestra mensaje "Error enviando solicitud, intente nuevamente"
- 8a.3. Sistema mantiene datos ingresados
- 8a.4. Retorna a paso 5

### **✅ POSTCONDICIONES**
**Del Sistema:**
- Nuevo registro en tabla `perfiles_piloto` con estado PENDIENTE
- Solicitud visible en panel administrativo

**De Negocio:**
- Administrador puede evaluar y aprobar/rechazar solicitud
- Usuario notificado del estado de su solicitud

### **📊 DATOS UTILIZADOS**
**Variables de Entrada - Datos Personales:**
- edad: Integer (persistente, 18-65)
- lugarNacimiento: String (persistente)
- tieneAntecedentes: Boolean (persistente)
- detallesAntecedentes: String (persistente, condicional)

**Variables de Entrada - Historial Político:**
- tuvoActividadPolitica: Boolean (persistente)
- detalleActividadPolitica: String (persistente, condicional)
- añosActividadPolitica: String (persistente, condicional)

**Variables de Entrada - Preferencias:**
- tipoViajesPreferido: String (persistente)
- distanciasPreferidas: String (persistente)
- disponibilidadHoraria: String (persistente)
- comentariosAdicionales: String (persistente, opcional)

**Variables de Entrada - Experiencia:**
- añosExperiencia: Integer (persistente, min 1)
- tiposNavesManejadas: JSON Array (persistente)
- licenciasActuales: JSON Array (persistente)
- referencias: String (persistente, opcional)

**Variables Fijas:**
- usuario_id: Integer (de sesión)
- estado_solicitud: "PENDIENTE" (constante inicial)
- created_at: TIMESTAMP (automático)

---

## 🎯 **CU-005: VER VIAJES DISPONIBLES (PILOTO)**

### **📊 INFORMACIÓN GENERAL**
- **ID:** CU-005
- **Nombre:** Ver Viajes Disponibles
- **Actor Principal:** Piloto Aprobado
- **Otros Actores:** Sistema de Matching, Usuarios Solicitantes
- **Nivel:** Objetivo del Usuario
- **Complejidad:** Alta

### **🚀 DISPARADOR**
Piloto aprobado quiere buscar viajes disponibles para aceptar

### **👤 INICIADOR**
Usuario Registrado con tipo_usuario = PILOTO y estado_solicitud = APROBADO

### **🎯 META**
Mostrar lista de viajes disponibles según lógica de facciones y preferencias del piloto

### **📋 PRECONDICIONES**
**Del Sistema:**
- Usuario autenticado como piloto aprobado
- Piloto debe tener nave asignada
- Sistema de matching operativo

**De Negocio:**
- Deben existir viajes en estado PENDIENTE
- Piloto no debe tener viaje activo (CONFIRMADO o EN_CURSO)

### **🔄 CAMINO BÁSICO**
1. Piloto accede a `/jsp/piloto/viajes-disponibles.jsp`
2. Sistema verifica estado del piloto:
   - tipo_usuario = PILOTO
   - estado_solicitud = APROBADO en perfiles_piloto
   - No tiene viaje activo (CONFIRMADO/EN_CURSO)
3. Sistema aplica lógica de matching por facciones:
   - **VIAJES NORMALES:** Visibles para TODOS los pilotos
   - **MISIONES ENCUBIERTAS:** Solo para facciones autorizadas
4. Sistema consulta viajes con criterios:
   - estado = PENDIENTE
   - fecha_hora_solicitada >= CURRENT_TIMESTAMP - 1 HORA
   - Aplicar filtros de facción para misiones encubiertas
5. Sistema carga información complementaria para cada viaje:
   - Datos del planeta origen (nombre, sistema solar)
   - Datos del planeta destino (nombre, sistema solar)
   - Información del usuario solicitante (nombre, facción, rating)
   - Distancia y precio calculados
6. Sistema aplica filtros opcionales si están especificados:
   - Tipo de viaje (PASAJERO/CARGA)
   - Rango de distancia (CORTAS/MEDIAS/LARGAS)
   - Timing (INMEDIATO/PROGRAMADO)
   - Rango de precios
7. Sistema ordena lista según preferencia:
   - Por defecto: más recientes primero
   - Opcional: por proximidad, precio, o urgencia
8. Sistema aplica paginación (10 viajes por página)
9. Sistema muestra lista con información resumida:
   - Origen → Destino
   - Tipo y timing del viaje
   - Precio ofrecido
   - Usuario solicitante (si no es encubierta)
   - Tiempo límite para aceptar
10. Piloto puede hacer clic en "Ver Detalles" para información completa
11. Piloto puede hacer clic en "Aceptar Viaje" para CU-006

### **🔀 CAMINOS ALTERNATIVOS**

**2a. Piloto no está aprobado:**
- 2a.1. Sistema detecta estado_solicitud != APROBADO
- 2a.2. Sistema muestra mensaje "Tu solicitud está pendiente de aprobación"
- 2a.3. Sistema muestra estado actual de la solicitud
- 2a.4. Caso de uso termina

**2b. Piloto tiene viaje activo:**
- 2b.1. Sistema encuentra viaje con estado CONFIRMADO o EN_CURSO
- 2b.2. Sistema muestra mensaje "Tienes un viaje activo"
- 2b.3. Sistema redirige a detalles del viaje activo
- 2b.4. Caso de uso termina

**2c. Piloto no tiene nave asignada:**
- 2c.1. Sistema no encuentra nave con piloto_id = usuario actual
- 2c.2. Sistema muestra mensaje "No tienes nave asignada, contacta al administrador"
- 2c.3. Caso de uso termina

**4a. No hay viajes disponibles:**
- 4a.1. Query retorna lista vacía
- 4a.2. Sistema muestra mensaje "No hay viajes disponibles en este momento"
- 4a.3. Sistema ofrece opción "Actualizar" y "Configurar notificaciones"
- 4a.4. Caso de uso termina

**6a. Filtros muy restrictivos:**
- 6a.1. Filtros aplicados resultan en lista vacía
- 6a.2. Sistema muestra mensaje "No hay viajes que coincidan con tus filtros"
- 6a.3. Sistema sugiere relajar filtros
- 6a.4. Retorna a paso 6

### **✅ POSTCONDICIONES**
**Del Sistema:**
- Lista de viajes filtrada y ordenada mostrada
- Información detallada de cada viaje disponible

**De Negocio:**
- Piloto puede evaluar y seleccionar viajes compatibles
- Sistema respeta lógica de visibilidad por facciones

### **📊 DATOS UTILIZADOS**
**Variables de Entrada (Filtros Opcionales):**
- filtroTipoViaje: String ["PASAJERO", "CARGA", "TODOS"] (temporal)
- filtroDistancia: String ["CORTAS", "MEDIAS", "LARGAS", "TODAS"] (temporal)
- filtroTiming: String ["INMEDIATO", "PROGRAMADO", "TODOS"] (temporal)
- filtroPrecioMin: BigDecimal (temporal, opcional)
- filtroPrecioMax: BigDecimal (temporal, opcional)
- ordenarPor: String ["FECHA", "PRECIO", "DISTANCIA"] (temporal)

**Variables del Sistema:**
- faccionPiloto: Integer (de sesión usuario)
- naveAsignada: Integer (de base datos)
- page: Integer (temporal, default 1)
- pageSize: Integer (fijo = 10)

**Variables de Respuesta:**
- listaViajes: List<Viaje> (temporal)
- totalViajes: Integer (temporal)
- totalPaginas: Integer (calculado)
- viajesVisibles: List<ViajeConDetalles> (temporal)

---

## 🎯 **CU-006: ACEPTAR VIAJE**

### **📊 INFORMACIÓN GENERAL**
- **ID:** CU-006
- **Nombre:** Aceptar Viaje
- **Actor Principal:** Piloto Aprobado
- **Otros Actores:** Usuario Solicitante, Sistema de Notificaciones, Sistema de Timer
- **Nivel:** Objetivo del Usuario
- **Complejidad:** Alta

### **🚀 DISPARADOR**
Piloto ve un viaje disponible de su interés y decide aceptarlo

### **👤 INICIADOR**
Usuario Registrado con tipo_usuario = PILOTO

### **🎯 META**
Asignar piloto a viaje específico y establecer compromiso temporal para inicio

### **📋 PRECONDICIONES**
**Del Sistema:**
- Piloto autenticado y aprobado
- Viaje debe estar en estado PENDIENTE
- Piloto no debe tener otro viaje activo

**De Negocio:**
- Nave del piloto debe tener capacidad suficiente
- Viaje debe ser visible según lógica de facciones
- Tiempo límite de aceptación no debe haber expirado

### **🔄 CAMINO BÁSICO**
1. Piloto hace clic en "Aceptar Viaje" desde lista de viajes disponibles
2. Sistema muestra modal de confirmación con:
   - Resumen completo del viaje
   - Tiempo límite para llegar al origen
   - Capacidad requerida vs disponible en nave
   - Precio final a recibir
3. Piloto confirma aceptación
4. Sistema ejecuta validaciones en transacción:
   - Verificar viaje sigue en estado PENDIENTE
   - Verificar piloto puede ver el viaje (lógica facciones)
   - Verificar piloto no tiene viaje activo
   - Verificar capacidad de nave suficiente
5. Sistema actualiza registro en tabla `viajes`:
   - piloto_id = id del piloto actual
   - estado = CONFIRMADO
   - fecha_confirmacion = CURRENT_TIMESTAMP
6. Sistema calcula tiempo límite según tipo:
   - INMEDIATO: 5 minutos para llegar
   - PROGRAMADO: 30 minutos antes de fecha_hora_solicitada
7. Sistema inicia timer automático para llegada
8. Sistema envía notificación al usuario solicitante:
   - "Tu viaje ha sido aceptado por [NombrePiloto]"
   - Información de contacto del piloto
   - Tiempo estimado de llegada
9. Sistema registra evento en logs del sistema
10. Sistema muestra confirmación al piloto:
    - "Viaje aceptado exitosamente"
    - Información de contacto del usuario
    - Instrucciones para llegar al origen
11. Sistema redirige a vista de "Mi Viaje Activo"

### **🔀 CAMINOS ALTERNATIVOS**

**4a. Viaje ya no está disponible:**
- 4a.1. Sistema detecta estado != PENDIENTE
- 4a.2. Sistema muestra mensaje "Este viaje ya no está disponible"
- 4a.3. Sistema actualiza lista de viajes
- 4a.4. Caso de uso termina

**4b. Piloto tiene viaje activo:**
- 4b.1. Sistema encuentra viaje activo del piloto
- 4b.2. Sistema muestra mensaje "Ya tienes un viaje activo"
- 4b.3. Sistema redirige a viaje activo
- 4b.4. Caso de uso termina

**4c. Capacidad de nave insuficiente:**
- 4c.1. Sistema detecta que nave no tiene capacidad para pasajeros/carga
- 4c.2. Sistema muestra mensaje específico:
   - "Tu nave solo puede transportar X pasajeros" o
   - "Tu nave solo puede cargar X toneladas"
- 4c.3. Sistema sugiere contactar admin para cambio de nave
- 4c.4. Caso de uso termina

**4d. Viaje encubierto no autorizado:**
- 4d.1. Sistema detecta que piloto no puede ver viaje encubierto
- 4d.2. Sistema muestra mensaje "No autorizado para este viaje"
- 4d.3. Sistema registra intento en logs de seguridad
- 4d.4. Caso de uso termina

**5a. Error en actualización de base de datos:**
- 5a.1. UPDATE de tabla viajes falla
- 5a.2. Sistema hace rollback de transacción
- 5a.3. Sistema muestra mensaje "Error aceptando viaje, intente nuevamente"
- 5a.4. Retorna a paso 3

**8a. Error en notificaciones:**
- 8a.1. Servicio de notificaciones falla
- 8a.2. Sistema registra error pero continúa flujo
- 8a.3. Sistema muestra warning "Viaje aceptado, pero notificación falló"
- 8a.4. Continúa con paso 10

### **✅ POSTCONDICIONES**
**Del Sistema:**
- Viaje cambia a estado CONFIRMADO
- Timer automático iniciado para llegada del piloto
- Notificación enviada al usuario solicitante

**De Negocio:**
- Piloto comprometido a llegar en tiempo límite
- Usuario solicitante puede hacer seguimiento del viaje
- Otros pilotos ya no pueden ver este viaje

### **📊 DATOS UTILIZADOS**
**Variables de Entrada:**
- viajeId: Integer (del request, temporal)
- confirmacion: Boolean (temporal, de modal)

**Variables de Validación:**
- estadoActualViaje: String (temporal)
- viajeActivoPiloto: Integer (temporal, nullable)
- capacidadNave: CapacidadNave object (temporal)
- faccionesAutorizadas: List<Integer> (temporal, para encubiertas)

**Variables de Actualización:**
- fecha_confirmacion: TIMESTAMP (persistente)
- piloto_id: Integer (persistente)
- estado: "CONFIRMADO" (persistente)

**Variables de Timer:**
- tiempoLimite: Integer (temporal, minutos)
- fechaLimite: TIMESTAMP (calculada)

**Variables de Notificación:**
- usuarioSolicitante: Usuario object (temporal)
- pilotoAsignado: Usuario object (temporal)
- detallesViaje: Viaje object (temporal)

---

## 🎯 **CU-007: APROBAR/RECHAZAR SOLICITUD DE PILOTO**

### **📊 INFORMACIÓN GENERAL**
- **ID:** CU-007
- **Nombre:** Aprobar/Rechazar Solicitud de Piloto
- **Actor Principal:** Administrador
- **Otros Actores:** Solicitante (Piloto), Sistema de Notificaciones, Sistema de Naves
- **Nivel:** Objetivo del Usuario
- **Complejidad:** Alta

### **🚀 DISPARADOR**
Administrador recibe notificación de nueva solicitud de piloto pendiente de evaluación

### **👤 INICIADOR**
Usuario Registrado con tipo_usuario = ADMIN

### **🎯 META**
Evaluar solicitud de piloto y tomar decisión de aprobación o rechazo con asignación de nave

### **📋 PRECONDICIONES**
**Del Sistema:**
- Usuario autenticado como administrador
- Debe existir al menos una solicitud con estado PENDIENTE
- Sistema de gestión de naves operativo

**De Negocio:**
- Deben existir naves disponibles para asignar (si se aprueba)
- Criterios de evaluación establecidos

### **🔄 CAMINO BÁSICO**
1. Administrador accede a `/jsp/admin/aprobar-pilotos.jsp`
2. Sistema muestra lista de solicitudes PENDIENTES con información resumida:
   - Nombre del solicitante
   - Facción
   - Años de experiencia
   - Fecha de solicitud
   - Botones "Ver Detalles", "Aprobar", "Rechazar"
3. Administrador hace clic en "Ver Detalles" de una solicitud
4. Sistema muestra información completa del solicitante:
   - **Datos personales:** edad, lugar nacimiento, antecedentes
   - **Historial político:** actividad política detallada
   - **Preferencias laborales:** tipo viajes, distancias, disponibilidad
   - **Experiencia:** años, naves manejadas, licencias, referencias
5. Administrador evalúa según criterios:
   - Edad 18-65 años
   - Sin antecedentes graves de piratería/tráfico
   - Experiencia mínima 1 año
   - Referencias verificables
   - Licencias válidas
6. **SI** Administrador decide APROBAR:
   - Administrador hace clic en "Aprobar"
   - Sistema muestra modal de asignación de nave
   - Sistema lista naves disponibles según preferencias del solicitante
   - Administrador selecciona nave apropiada
   - Sistema confirma asignación
7. **SI** Administrador decide RECHAZAR:
   - Administrador hace clic en "Rechazar"
   - Sistema muestra modal de motivos de rechazo
   - Administrador ingresa motivo detallado (obligatorio)
   - Sistema confirma rechazo
8. Sistema actualiza registro en tabla `perfiles_piloto`:
   - estado_solicitud = APROBADO/RECHAZADO
   - admin_aprobador_id = id del admin actual
   - fecha_aprobacion = CURRENT_TIMESTAMP
   - motivo_rechazo = texto (si aplica)
9. **SI** fue APROBADO:
   - Sistema actualiza tabla `usuarios`: tipo_usuario = PILOTO
   - Sistema asigna nave en tabla `naves`: piloto_id = usuario_id
   - Sistema actualiza estado nave: estado = ASIGNADA
10. Sistema envía notificación al solicitante:
    - APROBADO: "Felicitaciones, tu solicitud ha sido aprobada"
    - RECHAZADO: "Tu solicitud ha sido rechazada: [motivo]"
11. Sistema registra evento en logs del sistema
12. Sistema actualiza lista de solicitudes pendientes
13. Administrador puede continuar evaluando otras solicitudes

### **🔀 CAMINOS ALTERNATIVOS**

**2a. No hay solicitudes pendientes:**
- 2a.1. Sistema no encuentra registros con estado PENDIENTE
- 2a.2. Sistema muestra mensaje "No hay solicitudes pendientes"
- 2a.3. Sistema ofrece opción "Actualizar" y enlaces a otras gestiones
- 2a.4. Caso de uso termina

**6a. No hay naves disponibles para asignar:**
- 6a.1. Sistema no encuentra naves con estado DISPONIBLE
- 6a.2. Sistema muestra mensaje "No hay naves disponibles para asignar"
- 6a.3. Sistema ofrece opciones:
   - "Gestionar naves existentes"
   - "Aprobar sin nave (asignar después)"
   - "Cancelar aprobación"
- 6a.4. Retorna a paso 6

**6b. Nave seleccionada no compatible:**
- 6b.1. Administrador selecciona nave incompatible con preferencias
- 6b.2. Sistema muestra warning "Esta nave no coincide con las preferencias"
- 6b.3. Sistema pregunta "¿Continuar con esta asignación?"
- 6b.4. Si admin confirma, continúa; si no, retorna a selección

**8a. Error en actualización de base de datos:**
- 8a.1. UPDATE de tabla perfiles_piloto falla
- 8a.2. Sistema hace rollback de transacción
- 8a.3. Sistema muestra mensaje "Error procesando solicitud, intente nuevamente"
- 8a.4. Retorna a paso 6

**10a. Error en notificaciones:**
- 10a.1. Servicio de notificaciones falla
- 10a.2. Sistema registra error pero continúa flujo
- 10a.3. Sistema muestra warning "Solicitud procesada, pero notificación falló"
- 10a.4. Continúa con paso 12

### **✅ POSTCONDICIONES**
**Del Sistema:**
- Solicitud actualizada con estado final y administrador responsable
- Si aprobado: usuario tipo cambiado a PILOTO y nave asignada
- Notificación enviada al solicitante

**De Negocio:**
- Piloto aprobado puede comenzar a ver y aceptar viajes
- Métricas de aprobación/rechazo actualizadas
- Flota de pilotos activos actualizada

### **📊 DATOS UTILIZADOS**
**Variables de Entrada:**
- solicitudId: Integer (del request, temporal)
- decision: String ["APROBAR", "RECHAZAR"] (temporal)
- naveSeleccionada: Integer (temporal, solo si aprueba)
- motivoRechazo: String (temporal, solo si rechaza, obligatorio)

**Variables de Evaluación:**
- criteriosEvaluacion: List<Criterio> (temporal)
- navesDisponibles: List<Nave> (temporal)
- compatibilidadNave: Boolean (calculado)

**Variables de Actualización:**
- estado_solicitud: String (persistente)
- admin_aprobador_id: Integer (persistente)
- fecha_aprobacion: TIMESTAMP (persistente)
- motivo_rechazo: String (persistente, condicional)

**Variables del Sistema:**
- usuarioActualizado: Usuario object (temporal)
- naveAsignada: Nave object (temporal)
- notificacionEnviada: Boolean (temporal)

---

## 🎯 **CU-008: GESTIONAR ESTADO DE VIAJE**

### **📊 INFORMACIÓN GENERAL**
- **ID:** CU-008
- **Nombre:** Gestionar Estado de Viaje
- **Actor Principal:** Piloto
- **Otros Actores:** Usuario Solicitante, Sistema de Timer, Sistema de Notificaciones
- **Nivel:** Objetivo del Usuario
- **Complejidad:** Alta

### **🚀 DISPARADOR**
Piloto necesita actualizar el estado de un viaje en curso según su progreso

### **👤 INICIADOR**
Usuario Registrado con tipo_usuario = PILOTO

### **🎯 META**
Actualizar estado del viaje siguiendo la máquina de estados definida y notificar al usuario

### **📋 PRECONDICIONES**
**Del Sistema:**
- Piloto debe tener viaje asignado en estado CONFIRMADO o EN_CURSO
- Sistema de geolocalización/timer operativo

**De Negocio:**
- Transiciones de estado deben seguir reglas de negocio
- Piloto debe estar en ubicación correcta para ciertas transiciones

### **🔄 CAMINO BÁSICO**
1. Piloto accede a `/jsp/piloto/mi-viaje-activo.jsp`
2. Sistema muestra detalles del viaje activo:
   - Estado actual del viaje
   - Información del usuario solicitante
   - Detalles origen/destino
   - Tiempo límite y progreso
   - Botones de acción disponibles según estado
3. Piloto selecciona acción según estado actual:
   - **CONFIRMADO:** "He llegado al origen" → EN_CURSO
   - **EN_CURSO:** "Viaje completado" → COMPLETADO
   - **Cualquier estado:** "Cancelar viaje" → CANCELADO
4. **SI** transición es CONFIRMADO → EN_CURSO:
   - Sistema verifica que piloto esté en planeta origen
   - Sistema actualiza estado = EN_CURSO
   - Sistema registra fecha_inicio = CURRENT_TIMESTAMP
   - Sistema notifica usuario: "Tu piloto ha llegado, viaje iniciado"
5. **SI** transición es EN_CURSO → COMPLETADO:
   - Sistema verifica que haya transcurrido tiempo mínimo
   - Sistema actualiza estado = COMPLETADO
   - Sistema registra fecha_finalizacion = CURRENT_TIMESTAMP
   - Sistema libera nave del piloto
   - Sistema habilita sistema de reseñas para el usuario
   - Sistema notifica usuario: "Viaje completado exitosamente"
6. **SI** transición es a CANCELADO:
   - Sistema muestra modal de confirmación con motivos
   - Piloto selecciona motivo de cancelación
   - Sistema actualiza estado = CANCELADO
   - Sistema registra motivo_cancelacion y cancelado_por = PILOTO
   - Sistema libera nave del piloto
   - Sistema notifica usuario: "Viaje cancelado: [motivo]"
7. Sistema actualiza métricas del piloto:
   - Si COMPLETADO: incrementa total_viajes_completados
   - Si CANCELADO: registra en historial para evaluación
8. Sistema redirige según resultado:
   - COMPLETADO: Dashboard con mensaje de éxito
   - CANCELADO: Dashboard con formulario de feedback
   - EN_CURSO: Vista de viaje en progreso

### **🔀 CAMINOS ALTERNATIVOS**

**1a. Piloto no tiene viaje activo:**
- 1a.1. Sistema no encuentra viaje CONFIRMADO o EN_CURSO
- 1a.2. Sistema muestra mensaje "No tienes viajes activos"
- 1a.3. Sistema redirige a "Viajes Disponibles"
- 1a.4. Caso de uso termina

**4a. Piloto no está en ubicación correcta:**
- 4a.1. Sistema detecta que piloto no está en planeta origen
- 4a.2. Sistema muestra mensaje "Debes estar en [NombrePlaneta] para iniciar el viaje"
- 4a.3. Sistema mantiene estado CONFIRMADO
- 4a.4. Retorna a paso 3

**5a. Tiempo de viaje demasiado corto:**
- 5a.1. Sistema detecta tiempo < tiempo_minimo_estimado / 2
- 5a.2. Sistema muestra confirmación "¿Viaje realmente completado?"
- 5a.3. Si piloto confirma, continúa; si no, retorna a paso 3
- 5a.4. Sistema registra flag para revisión posterior

**4b. Timer de llegada expirado:**
- 4b.1. Sistema detecta que tiempo límite fue superado
- 4b.2. Sistema cambia automáticamente estado a EXPIRADO
- 4b.3. Sistema libera viaje y notifica usuario
- 4b.4. Sistema muestra al piloto "Viaje expirado por no llegar a tiempo"

**6a. Motivo de cancelación requerido:**
- 6a.1. Piloto intenta cancelar sin seleccionar motivo
- 6a.2. Sistema muestra mensaje "Debe seleccionar motivo de cancelación"
- 6a.3. Retorna a paso 6

**7a. Error actualizando métricas:**
- 7a.1. UPDATE de perfiles_piloto falla
- 7a.2. Sistema registra error pero continúa flujo principal
- 7a.3. Sistema programa tarea para actualizar métricas después
- 7a.4. Continúa con paso 8

### **✅ POSTCONDICIONES**
**Del Sistema:**
- Estado del viaje actualizado según máquina de estados
- Timestamps relevantes registrados
- Notificaciones enviadas a usuario solicitante

**De Negocio:**
- Viaje progresa según flujo de negocio definido
- Métricas de rendimiento actualizadas
- Usuario informado del progreso

### **📊 DATOS UTILIZADOS**
**Variables de Entrada:**
- viajeId: Integer (de sesión/URL, temporal)
- nuevoEstado: String (temporal)
- motivoCancelacion: String (temporal, condicional)
- confirmacionCompletado: Boolean (temporal)

**Variables de Validación:**
- estadoActual: String (temporal)
- ubicacionPiloto: Coordenadas (temporal)
- tiempoTranscurrido: Integer (temporal, minutos)
- tiempoMinimo: Integer (calculado)

**Variables de Actualización:**
- estado: String (persistente)
- fecha_inicio: TIMESTAMP (persistente, condicional)
- fecha_finalizacion: TIMESTAMP (persistente, condicional)
- motivo_cancelacion: String (persistente, condicional)
- cancelado_por: String (persistente, condicional)

**Variables de Métricas:**
- total_viajes_completados: Integer (persistente)
- historial_cancelaciones: Integer (calculado)

---

## 🎯 **CU-009: CREAR MISIÓN ENCUBIERTA**

### **📊 INFORMACIÓN GENERAL**
- **ID:** CU-009
- **Nombre:** Crear Misión Encubierta
- **Actor Principal:** Usuario Verificado/Admin
- **Otros Actores:** Administrador, Sistema de Autorización, Pilotos Específicos
- **Nivel:** Objetivo del Usuario
- **Complejidad:** Muy Alta

### **🚀 DISPARADOR**
Usuario con privilegios especiales necesita crear viaje con visibilidad restringida por facciones

### **👤 INICIADOR**
Usuario Registrado con permisos especiales o ADMIN

### **🎯 META**
Crear viaje encubierto visible solo para facciones específicas seleccionadas

### **📋 PRECONDICIONES**
**Del Sistema:**
- Usuario debe tener privilegios para misiones encubiertas
- Sistema de autorización por facciones operativo

**De Negocio:**
- Usuario debe estar verificado o ser administrador
- Misión debe tener justificación válida
- Facciones seleccionadas deben ser compatibles

### **🔄 CAMINO BÁSICO**
1. Usuario accede a `/jsp/usuario/crear-mision-encubierta.jsp`
2. Sistema verifica permisos del usuario:
   - tipo_usuario = ADMIN o usuario_verificado = true
   - Usuario tiene historial de misiones exitosas
3. Sistema muestra formulario especializado con:
   - **Campos estándar de viaje:** origen, destino, tipo, timing
   - **Configuración de encubierto:**
     - Nivel de discretion (BAJO/MEDIO/ALTO)
     - Facciones autorizadas (checkboxes múltiple)
     - Información a ocultar (nombre, contacto, destino)
   - **Justificación:** motivo de la misión encubierta
4. Usuario completa información básica del viaje
5. Usuario configura aspectos encubiertos:
   - Selecciona facciones que pueden ver la misión
   - Define nivel de información visible
   - Ingresa justificación de la misión
6. Sistema valida configuración:
   - Al menos una facción debe estar seleccionada
   - Justificación debe tener mínimo 50 caracteres
   - Configuración debe ser lógicamente coherente
7. Sistema calcula precio con recargo encubierto (+50%)
8. Usuario confirma crear misión encubierta
9. **SI** usuario NO es ADMIN:
   - Sistema marca misión como PENDIENTE_APROBACION
   - Sistema envía solicitud a administradores
   - Sistema muestra mensaje "Misión enviada para aprobación"
10. **SI** usuario ES ADMIN:
    - Sistema crea misión directamente
    - Sistema establece es_mision_encubierta = true
    - Sistema guarda facciones_autorizadas en JSON
11. Sistema registra evento especial en logs de seguridad
12. Sistema notifica solo a pilotos de facciones autorizadas
13. Sistema redirige con confirmación de creación

### **🔀 CAMINOS ALTERNATIVOS**

**2a. Usuario sin permisos:**
- 2a.1. Sistema detecta usuario sin privilegios encubiertos
- 2a.2. Sistema muestra mensaje "No autorizado para misiones encubiertas"
- 2a.3. Sistema redirige a crear viaje normal
- 2a.4. Caso de uso termina

**5a. Configuración de facciones inválida:**
- 5a.1. Usuario no selecciona ninguna facción
- 5a.2. Sistema muestra mensaje "Debe seleccionar al menos una facción"
- 5a.3. Retorna a paso 5

**5b. Conflicto de facciones:**
- 5b.1. Usuario selecciona facciones enemigas (IMPERIO + REBELDES)
- 5b.2. Sistema muestra warning "Facciones seleccionadas son enemigas"
- 5b.3. Sistema pregunta "¿Continuar con esta configuración?"
- 5b.4. Si confirma, continúa; si no, retorna a paso 5

**6a. Justificación insuficiente:**
- 6a.1. Sistema detecta justificación < 50 caracteres
- 6a.2. Sistema muestra mensaje "Justificación debe tener al menos 50 caracteres"
- 6a.3. Retorna a paso 5

**9a. Límite de misiones encubiertas alcanzado:**
- 9a.1. Usuario tiene > 3 misiones encubiertas activas
- 9a.2. Sistema muestra mensaje "Máximo 3 misiones encubiertas simultáneas"
- 9a.3. Sistema sugiere completar misiones existentes
- 9a.4. Caso de uso termina

**12a. Error en notificaciones selectivas:**
- 12a.1. Sistema falla al filtrar pilotos por facción
- 12a.2. Sistema registra error crítico
- 12a.3. Sistema revierte creación de misión
- 12a.4. Sistema muestra mensaje "Error configurando misión, intente nuevamente"

### **✅ POSTCONDICIONES**
**Del Sistema:**
- Misión encubierta creada con configuración específica
- Visibilidad restringida según facciones seleccionadas
- Eventos de seguridad registrados

**De Negocio:**
- Solo pilotos autorizados pueden ver la misión
- Información sensible protegida según configuración
- Rastreo de actividad encubierta para auditoría

### **📊 DATOS UTILIZADOS**
**Variables de Entrada - Estándar:**
- origenPlanetaId: Integer (persistente)
- destinoPlanetaId: Integer (persistente)
- tipoViaje: String (persistente)
- tipoTiming: String (persistente)
- Resto de campos de viaje normal

**Variables de Entrada - Encubierto:**
- nivelDiscrecion: String ["BAJO", "MEDIO", "ALTO"] (persistente)
- faccionesAutorizadas: Integer[] (persistente, JSON)
- informacionOcultar: String[] (persistente, JSON)
- justificacionMision: String (persistente)

**Variables de Configuración:**
- es_mision_encubierta: Boolean = true (persistente)
- requiere_aprobacion: Boolean (calculado según usuario)
- precio_recargo: BigDecimal (+50%) (calculado)

**Variables de Seguridad:**
- usuario_creador: Integer (persistente)
- fecha_aprobacion: TIMESTAMP (persistente, condicional)
- admin_aprobador: Integer (persistente, condicional)

---

## 🎯 **CU-010: GESTIONAR NAVES**

### **📊 INFORMACIÓN GENERAL**
- **ID:** CU-010
- **Nombre:** Gestionar Naves
- **Actor Principal:** Administrador
- **Otros Actores:** Sistema de Inventario, Pilotos
- **Nivel:** Objetivo del Usuario
- **Complejidad:** Alta

### **🚀 DISPARADOR**
Administrador necesita gestionar la flota de naves disponibles

### **👤 INICIADOR**
Usuario Registrado con tipo_usuario = ADMIN

### **🎯 META**
Administrar inventario de naves, asignaciones, modificaciones y mantenimiento

### **📋 PRECONDICIONES**
**Del Sistema:**
- Usuario autenticado como administrador
- Base de datos de naves y tipos operativa

**De Negocio:**
- Debe existir al menos un tipo de nave definido
- Sistema de gestión de inventario operativo

### **🔄 CAMINO BÁSICO**
1. Administrador accede a `/jsp/admin/gestion-naves.jsp`
2. Sistema muestra dashboard de gestión con secciones:
   - **Inventario General:** Total naves por estado
   - **Naves Disponibles:** Para asignar a nuevos pilotos
   - **Naves Asignadas:** Con información del piloto
   - **Naves en Mantenimiento:** Con fechas y motivos
   - **Solicitudes Pendientes:** Cambios y modificaciones
3. Administrador selecciona acción específica:
   - **A:** Agregar nueva nave
   - **B:** Modificar nave existente
   - **C:** Cambiar asignación de nave
   - **D:** Enviar nave a mantenimiento
   - **E:** Aprobar modificaciones/armamento
4. **SI** acción es AGREGAR NUEVA NAVE:
   - Sistema muestra formulario de nueva nave
   - Administrador selecciona tipo de nave
   - Administrador ingresa nombre personalizado (opcional)
   - Administrador establece ubicación inicial
   - Sistema crea nave con estado DISPONIBLE
5. **SI** acción es MODIFICAR NAVE:
   - Administrador selecciona nave del inventario
   - Sistema muestra detalles editables
   - Administrador modifica: nombre, ubicación, nivel de componentes
   - Sistema valida modificaciones y actualiza registro
6. **SI** acción es CAMBIAR ASIGNACIÓN:
   - Administrador selecciona nave asignada
   - Sistema muestra piloto actual y motivo del cambio
   - Administrador selecciona nuevo piloto o desasigna
   - Sistema actualiza asignaciones y notifica a pilotos afectados
7. **SI** acción es MANTENIMIENTO:
   - Administrador selecciona nave operativa
   - Sistema solicita motivo y duración estimada
   - Sistema cambia estado a EN_MANTENIMIENTO
   - Si nave estaba asignada, sistema busca reemplazo temporal
8. **SI** acción es APROBAR MODIFICACIONES:
   - Administrador revisa solicitudes de cambios pendientes
   - Para cada solicitud: aprobar o rechazar con motivo
   - Sistema ejecuta modificaciones aprobadas
   - Sistema notifica a piloto solicitante
9. Sistema actualiza inventario en tiempo real
10. Sistema registra todas las acciones en logs administrativos
11. Administrador puede continuar con otras gestiones

### **🔀 CAMINOS ALTERNATIVOS**

**4a. Tipo de nave no disponible:**
- 4a.1. No hay tipos de nave definidos en el sistema
- 4a.2. Sistema muestra mensaje "Debe definir tipos de nave primero"
- 4a.3. Sistema redirige a gestión de tipos de nave
- 4a.4. Retorna a paso 4

**5a. Nave en uso activo:**
- 5a.1. Nave seleccionada tiene viaje EN_CURSO
- 5a.2. Sistema muestra mensaje "Nave en viaje activo, no se puede modificar"
- 5a.3. Sistema sugiere esperar o cancelar viaje
- 5a.4. Retorna a paso 5

**6a. Nuevo piloto no compatible:**
- 6a.1. Piloto seleccionado no tiene licencias para tipo de nave
- 6a.2. Sistema muestra warning "Piloto no calificado para esta nave"
- 6a.3. Sistema pregunta "¿Asignar de todas formas?"
- 6a.4. Si confirma, continúa; si no, retorna a paso 6

**7a. No hay nave de reemplazo:**
- 7a.1. Nave asignada va a mantenimiento pero no hay reemplazo
- 7a.2. Sistema muestra opciones:
   - "Mantener piloto sin nave temporalmente"
   - "Reasignar piloto a otra nave"
   - "Cancelar mantenimiento"
- 7a.3. Administrador selecciona opción y continúa

**8a. Modificación técnicamente imposible:**
- 8a.1. Solicitud de armamento incompatible con tipo de nave
- 8a.2. Sistema muestra mensaje "Modificación no compatible"
- 8a.3. Sistema permite rechazo automático con motivo técnico
- 8a.4. Continúa con siguiente solicitud

### **✅ POSTCONDICIONES**
**Del Sistema:**
- Inventario de naves actualizado según acciones realizadas
- Estados y asignaciones reflejados correctamente
- Logs administrativos registrados

**De Negocio:**
- Flota optimizada según necesidades operativas
- Pilotos notificados de cambios que los afectan
- Solicitudes de modificaciones procesadas

### **📊 DATOS UTILIZADOS**
**Variables de Gestión:**
- accionSeleccionada: String (temporal)
- naveSeleccionada: Integer (temporal)
- tipoNaveId: Integer (temporal, para nuevas naves)
- nombrePersonalizado: String (persistente, opcional)

**Variables de Asignación:**
- pilotoActual: Integer (temporal)
- pilotoNuevo: Integer (temporal)
- motivoCambio: String (persistente)
- fechaCambio: TIMESTAMP (persistente)

**Variables de Mantenimiento:**
- motivoMantenimiento: String (persistente)
- duracionEstimada: Integer (persistente, días)
- fechaInicioMantenimiento: TIMESTAMP (persistente)
- naveReemplazo: Integer (temporal, opcional)

**Variables de Modificaciones:**
- solicitudId: Integer (temporal)
- tipoModificacion: String (temporal)
- decisionAdmin: String ["APROBAR", "RECHAZAR"] (temporal)
- motivoDecision: String (persistente)

---

## 🎯 **CU-011: DEJAR RESEÑA**

### **📊 INFORMACIÓN GENERAL**
- **ID:** CU-011
- **Nombre:** Dejar Reseña
- **Actor Principal:** Usuario (Pasajero)
- **Otros Actores:** Piloto Evaluado, Sistema de Reputación
- **Nivel:** Objetivo del Usuario
- **Complejidad:** Media

### **🚀 DISPARADOR**
Usuario completó un viaje y desea evaluar el servicio del piloto

### **👤 INICIADOR**
Usuario Registrado que fue pasajero en viaje COMPLETADO

### **🎯 META**
Crear reseña detallada sobre la experiencia del viaje para ayudar a otros usuarios

### **📋 PRECONDICIONES**
**Del Sistema:**
- Usuario debe haber completado viaje recientemente
- Viaje debe estar en estado COMPLETADO
- No debe existir reseña previa para este viaje

**De Negocio:**
- Máximo 7 días después de completado el viaje
- Usuario fue efectivamente pasajero del viaje
- Piloto debe estar activo para recibir reseñas

### **🔄 CAMINO BÁSICO**
1. Usuario accede a `/jsp/usuario/mis-viajes.jsp`
2. Sistema muestra lista de viajes completados con opción "Dejar Reseña"
3. Usuario hace clic en "Dejar Reseña" de viaje específico
4. Sistema verifica elegibilidad:
   - Viaje en estado COMPLETADO
   - Menos de 7 días desde finalización
   - No existe reseña previa
5. Sistema muestra formulario de reseña con:
   - **Información del viaje:** origen, destino, fecha, piloto
   - **Calificaciones (1-5 estrellas):**
     - Rating General (obligatorio)
     - Puntualidad (opcional)
     - Profesionalismo (opcional)
     - Estado de la Nave (opcional)
   - **Comentario escrito:** (opcional, máx 500 caracteres)
   - **Checkbox:** "Reseña anónima" (para misiones encubiertas)
6. Usuario completa calificaciones requeridas
7. Usuario opcionalmente escribe comentario descriptivo
8. Usuario hace clic en "Enviar Reseña"
9. Sistema valida formulario:
   - Rating general entre 1-5
   - Comentario sin contenido inapropiado
   - Longitud de comentario ≤ 500 caracteres
10. Sistema inserta registro en tabla `reseñas`:
    - viaje_id, usuario_id, piloto_id
    - ratings específicos por categoría
    - comentario y flag de anonimato
11. Sistema actualiza automáticamente métricas del piloto:
    - Recalcula rating_promedio usando trigger
    - Incrementa total_reseñas
12. Sistema notifica al piloto (si reseña no es anónima):
    - "Has recibido una nueva reseña: [rating] estrellas"
13. Sistema muestra confirmación al usuario
14. Sistema redirige a lista de viajes con reseña marcada como enviada

### **🔀 CAMINOS ALTERNATIVOS**

**4a. Viaje no elegible para reseña:**
- 4a.1. Sistema detecta viaje no COMPLETADO o > 7 días
- 4a.2. Sistema muestra mensaje "No se puede reseñar este viaje"
- 4a.3. Sistema explica motivo específico
- 4a.4. Caso de uso termina

**4b. Reseña ya existe:**
- 4b.1. Sistema encuentra reseña previa para este viaje
- 4b.2. Sistema muestra reseña existente en modo solo lectura
- 4b.3. Sistema muestra mensaje "Ya reseñaste este viaje"
- 4b.4. Caso de uso termina

**9a. Rating general no seleccionado:**
- 9a.1. Usuario intenta enviar sin rating general
- 9a.2. Sistema muestra mensaje "Rating general es obligatorio"
- 9a.3. Sistema resalta campo requerido
- 9a.4. Retorna a paso 6

**9b. Comentario con contenido inapropiado:**
- 9b.1. Sistema detecta palabras prohibidas o lenguaje ofensivo
- 9b.2. Sistema muestra mensaje "Comentario contiene lenguaje inapropiado"
- 9b.3. Sistema sugiere revisar y modificar
- 9b.4. Retorna a paso 7

**9c. Comentario demasiado largo:**
- 9c.1. Sistema detecta comentario > 500 caracteres
- 9c.2. Sistema muestra contador y mensaje "Máximo 500 caracteres"
- 9c.3. Sistema no permite envío hasta reducir texto
- 9c.4. Retorna a paso 7

**10a. Error al crear reseña:**
- 10a.1. INSERT en tabla reseñas falla
- 10a.2. Sistema muestra mensaje "Error enviando reseña, intente nuevamente"
- 10a.3. Sistema mantiene datos ingresados
- 10a.4. Retorna a paso 8

**12a. Error en notificación:**
- 12a.1. Notificación al piloto falla
- 12a.2. Sistema registra error pero continúa flujo
- 12a.3. Sistema programa reintento de notificación
- 12a.4. Continúa con paso 13

### **✅ POSTCONDICIONES**
**Del Sistema:**
- Nueva reseña registrada en base de datos
- Métricas del piloto actualizadas automáticamente
- Usuario no puede reseñar nuevamente el mismo viaje

**De Negocio:**
- Reputación del piloto reflejada en su perfil público
- Otros usuarios pueden consultar reseñas para tomar decisiones
- Sistema de feedback operativo para mejora continua

### **📊 DATOS UTILIZADOS**
**Variables de Entrada:**
- viajeId: Integer (del request, temporal)
- ratingGeneral: Integer [1-5] (persistente, obligatorio)
- ratingPuntualidad: Integer [1-5] (persistente, opcional)
- ratingProfesionalismo: Integer [1-5] (persistente, opcional)
- ratingNave: Integer [1-5] (persistente, opcional)
- comentario: String (persistente, opcional, máx 500)
- esAnonima: Boolean (persistente, default false)

**Variables de Validación:**
- viajeElegible: Boolean (temporal)
- tiempoTranscurrido: Integer (temporal, días)
- reseñaExistente: Boolean (temporal)
- contenidoApropiado: Boolean (temporal)

**Variables de Actualización:**
- viaje_id: Integer (persistente)
- usuario_id: Integer (persistente, de sesión)
- piloto_id: Integer (persistente, del viaje)
- created_at: TIMESTAMP (automático)

**Variables de Notificación:**
- pilotoNotificado: Boolean (temporal)
- detallesNotificacion: String (temporal)
