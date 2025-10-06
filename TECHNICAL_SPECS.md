# 🔧 ESPECIFICACIONES TÉCNICAS DETALLADAS - FLYSOLO
## Implementación Java de Flujos de Negocio

---

## 🎯 CASOS DE USO TÉCNICOS PRINCIPALES

### **📋 CU-001: REGISTRO DE USUARIO ESTÁNDAR**

**🔗 Actor:** Usuario no registrado  
**🎯 Objetivo:** Registrarse como pasajero en la plataforma  
**📋 Precondiciones:** Ninguna  
**✅ Postcondiciones:** Usuario registrado y logueado

**🔄 Flujo Principal:**
```java
// RegisterServlet.java
@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        // 1. Validar datos de entrada
        String email = ValidationUtil.validateEmail(request.getParameter("email"));
        String password = ValidationUtil.validatePassword(request.getParameter("password"));
        String nombre = ValidationUtil.validateName(request.getParameter("nombre"));
        String apellido = ValidationUtil.validateName(request.getParameter("apellido"));
        int faccionId = Integer.parseInt(request.getParameter("faccionId"));
        
        // 2. Verificar email no existe
        UsuarioService usuarioService = new UsuarioService();
        if (usuarioService.existeEmail(email)) {
            request.setAttribute("error", "Email ya registrado");
            request.getRequestDispatcher("/jsp/auth/register.jsp").forward(request, response);
            return;
        }
        
        // 3. Crear usuario
        Usuario usuario = new Usuario();
        usuario.setEmail(email);
        usuario.setPasswordHash(PasswordUtil.hashPassword(password));
        usuario.setNombre(nombre);
        usuario.setApellido(apellido);
        usuario.setFaccionId(faccionId);
        usuario.setTipoUsuario(TipoUsuario.PASAJERO);
        
        // 4. Guardar en DB
        boolean registrado = usuarioService.registrarUsuario(usuario);
        
        if (registrado) {
            // 5. Auto-login
            HttpSession session = request.getSession();
            session.setAttribute("usuario", usuario);
            response.sendRedirect("/flysolo/dashboard");
        } else {
            request.setAttribute("error", "Error al registrar usuario");
            request.getRequestDispatcher("/jsp/auth/register.jsp").forward(request, response);
        }
    }
}
```

**🛡️ Validaciones:**
- Email formato válido y único
- Password mínimo 8 caracteres, 1 mayúscula, 1 número
- Nombre/apellido solo letras y espacios
- Facción debe existir en DB

---

### **📋 CU-002: SOLICITUD PARA SER PILOTO**

**🔗 Actor:** Usuario registrado  
**🎯 Objetivo:** Solicitar upgrade a piloto  
**📋 Precondiciones:** Usuario logueado como PASAJERO  
**✅ Postcondiciones:** Solicitud creada en estado PENDIENTE

**🔄 Flujo Principal:**
```java
// SolicitarPilotoServlet.java
@WebServlet("/solicitar-piloto")
public class SolicitarPilotoServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        // 1. Verificar usuario logueado
        Usuario usuario = (Usuario) request.getSession().getAttribute("usuario");
        if (usuario == null || usuario.getTipoUsuario() != TipoUsuario.PASAJERO) {
            response.sendRedirect("/flysolo/login");
            return;
        }
        
        // 2. Verificar no tiene solicitud pendiente
        PilotoService pilotoService = new PilotoService();
        if (pilotoService.tieneSolicitudPendiente(usuario.getId())) {
            request.setAttribute("error", "Ya tienes una solicitud pendiente");
            request.getRequestDispatcher("/jsp/piloto/solicitar.jsp").forward(request, response);
            return;
        }
        
        // 3. Crear perfil piloto
        PerfilPiloto perfil = new PerfilPiloto();
        perfil.setUsuarioId(usuario.getId());
        perfil.setAñosExperiencia(Integer.parseInt(request.getParameter("añosExperiencia")));
        perfil.setLugarNacimiento(request.getParameter("lugarNacimiento"));
        perfil.setTieneAntecedentes(Boolean.parseBoolean(request.getParameter("tieneAntecedentes")));
        perfil.setDetallesAntecedentes(request.getParameter("detallesAntecedentes"));
        
        // Historial político
        perfil.setTuvoActividadPolitica(Boolean.parseBoolean(request.getParameter("tuvoActividadPolitica")));
        perfil.setDetalleActividadPolitica(request.getParameter("detalleActividad"));
        perfil.setAñosActividadPolitica(request.getParameter("añosActividad"));
        
        // Preferencias laborales
        perfil.setTipoViajesPreferido(TipoViaje.valueOf(request.getParameter("tipoViajesPreferido")));
        perfil.setDistanciasPreferidas(DistanciaPreferida.valueOf(request.getParameter("distanciasPreferidas")));
        perfil.setDisponibilidadHoraria(request.getParameter("disponibilidadHoraria"));
        perfil.setComentariosAdicionales(request.getParameter("comentariosAdicionales"));
        
        // Experiencia
        String[] tiposNaves = request.getParameterValues("tiposNavesManejadas");
        perfil.setTiposNavesManejadas(Arrays.asList(tiposNaves));
        
        String[] licencias = request.getParameterValues("licenciasActuales");
        perfil.setLicenciasActuales(Arrays.asList(licencias));
        
        perfil.setReferencias(request.getParameter("referencias"));
        
        // 4. Guardar solicitud
        boolean guardado = pilotoService.crearSolicitudPiloto(perfil);
        
        if (guardado) {
            request.setAttribute("success", "Solicitud enviada correctamente. Recibirás una respuesta pronto.");
            request.getRequestDispatcher("/jsp/usuario/dashboard.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Error al enviar solicitud");
            request.getRequestDispatcher("/jsp/piloto/solicitar.jsp").forward(request, response);
        }
    }
}
```

---

### **📋 CU-003: CREACIÓN DE VIAJE**

**🔗 Actor:** Usuario registrado  
**🎯 Objetivo:** Crear solicitud de viaje  
**📋 Precondiciones:** Usuario logueado  
**✅ Postcondiciones:** Viaje creado en estado PENDIENTE

**🔄 Flujo Principal:**
```java
// CrearViajeServlet.java
@WebServlet("/crear-viaje")
public class CrearViajeServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        Usuario usuario = (Usuario) request.getSession().getAttribute("usuario");
        
        // 1. Recopilar datos del formulario
        int origenPlanetaId = Integer.parseInt(request.getParameter("origenPlanetaId"));
        int destinoPlanetaId = Integer.parseInt(request.getParameter("destinoPlanetaId"));
        TipoViaje tipoViaje = TipoViaje.valueOf(request.getParameter("tipoViaje"));
        TipoTiming tipoTiming = TipoTiming.valueOf(request.getParameter("tipoTiming"));
        
        LocalDateTime fechaHoraSolicitada;
        if (tipoTiming == TipoTiming.INMEDIATO) {
            fechaHoraSolicitada = LocalDateTime.now();
        } else {
            fechaHoraSolicitada = LocalDateTime.parse(request.getParameter("fechaHoraSolicitada"));
        }
        
        int numPasajeros = Integer.parseInt(request.getParameter("numPasajeros"));
        BigDecimal pesoCarga = new BigDecimal(request.getParameter("pesoCarga"));
        String descripcionCarga = request.getParameter("descripcionCarga");
        
        boolean esMisionEncubierta = Boolean.parseBoolean(request.getParameter("esMisionEncubierta"));
        List<Integer> faccionesAutorizadas = null;
        
        if (esMisionEncubierta) {
            String[] facciones = request.getParameterValues("faccionesAutorizadas");
            faccionesAutorizadas = Arrays.stream(facciones).map(Integer::parseInt).collect(Collectors.toList());
        }
        
        // 2. Validar datos
        ViajeService viajeService = new ViajeService();
        CalculadoraDistanciaService calculadora = new CalculadoraDistanciaService();
        
        // Validar planetas existen
        if (!viajeService.planetaExiste(origenPlanetaId) || !viajeService.planetaExiste(destinoPlanetaId)) {
            request.setAttribute("error", "Planetas seleccionados no válidos");
            cargarDatosFormulario(request);
            request.getRequestDispatcher("/jsp/usuario/crear-viaje.jsp").forward(request, response);
            return;
        }
        
        // 3. Calcular distancia y precio
        BigDecimal distancia = calculadora.calcularDistanciaEntrePlanetas(origenPlanetaId, destinoPlanetaId);
        int tiempoEstimado = calculadora.calcularTiempoViaje(distancia, tipoViaje);
        BigDecimal precioBase = calculadora.calcularPrecioBase(distancia, tipoViaje, numPasajeros, pesoCarga);
        BigDecimal precioPremium = precioBase.multiply(new BigDecimal("1.20")); // +20% para inmediatos
        BigDecimal precioFinal = (tipoTiming == TipoTiming.INMEDIATO) ? precioPremium : precioBase;
        
        // 4. Crear viaje
        Viaje viaje = new Viaje();
        viaje.setUsuarioId(usuario.getId());
        viaje.setOrigenPlanetaId(origenPlanetaId);
        viaje.setDestinoPlanetaId(destinoPlanetaId);
        viaje.setTipoViaje(tipoViaje);
        viaje.setTipoTiming(tipoTiming);
        viaje.setFechaHoraSolicitada(fechaHoraSolicitada);
        viaje.setNumPasajeros(numPasajeros);
        viaje.setPesoCarga(pesoCarga);
        viaje.setDescripcionCarga(descripcionCarga);
        viaje.setDistanciaCalculada(distancia);
        viaje.setTiempoEstimadoViaje(tiempoEstimado);
        viaje.setPrecioBase(precioBase);
        viaje.setPrecioPremium(precioPremium);
        viaje.setPrecioFinal(precioFinal);
        viaje.setEsMisionEncubierta(esMisionEncubierta);
        viaje.setFaccionesAutorizadas(faccionesAutorizadas);
        viaje.setEstado(EstadoViaje.PENDIENTE);
        
        // 5. Guardar en DB
        boolean creado = viajeService.crearViaje(viaje);
        
        if (creado) {
            // 6. Notificar pilotos disponibles
            NotificacionService notifService = new NotificacionService();
            notifService.notificarNuevoViaje(viaje);
            
            response.sendRedirect("/flysolo/mis-viajes?success=viaje-creado");
        } else {
            request.setAttribute("error", "Error al crear el viaje");
            cargarDatosFormulario(request);
            request.getRequestDispatcher("/jsp/usuario/crear-viaje.jsp").forward(request, response);
        }
    }
    
    private void cargarDatosFormulario(HttpServletRequest request) {
        ViajeService viajeService = new ViajeService();
        request.setAttribute("planetas", viajeService.obtenerTodosPlanetas());
        request.setAttribute("facciones", viajeService.obtenerTodasFacciones());
    }
}
```

---

### **📋 CU-004: MATCHING DE PILOTOS (Visualización de Viajes)**

**🔗 Actor:** Piloto aprobado  
**🎯 Objetivo:** Ver viajes disponibles según facción  
**📋 Precondiciones:** Piloto logueado y aprobado  
**✅ Postcondiciones:** Lista de viajes compatibles mostrada

**🔄 Flujo Principal:**
```java
// ViajesDisponiblesServlet.java
@WebServlet("/viajes-disponibles")
public class ViajesDisponiblesServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) {
        Usuario piloto = (Usuario) request.getSession().getAttribute("usuario");
        
        // 1. Verificar es piloto aprobado
        if (piloto.getTipoUsuario() != TipoUsuario.PILOTO) {
            response.sendRedirect("/flysolo/dashboard");
            return;
        }
        
        PilotoService pilotoService = new PilotoService();
        PerfilPiloto perfil = pilotoService.obtenerPerfilPiloto(piloto.getId());
        
        if (perfil.getEstadoSolicitud() != EstadoSolicitud.APROBADO) {
            request.setAttribute("error", "Tu solicitud de piloto aún está pendiente de aprobación");
            request.getRequestDispatcher("/jsp/piloto/dashboard-piloto.jsp").forward(request, response);
            return;
        }
        
        // 2. Aplicar lógica de matching por facciones
        MatchingService matchingService = new MatchingService();
        List<Viaje> viajesDisponibles = matchingService.obtenerViajesParaPiloto(piloto, request.getParameterMap());
        
        // 3. Cargar datos adicionales para cada viaje
        for (Viaje viaje : viajesDisponibles) {
            // Cargar detalles de planetas
            viaje.setOrigenPlaneta(matchingService.obtenerPlaneta(viaje.getOrigenPlanetaId()));
            viaje.setDestinoPlaneta(matchingService.obtenerPlaneta(viaje.getDestinoPlanetaId()));
            
            // Cargar usuario solicitante (si no es encubierta)
            if (!viaje.isEsMisionEncubierta()) {
                viaje.setUsuarioSolicitante(matchingService.obtenerUsuario(viaje.getUsuarioId()));
            }
        }
        
        // 4. Aplicar filtros opcionales
        String filtroTipo = request.getParameter("filtroTipo");
        String filtroDistancia = request.getParameter("filtroDistancia");
        String filtroTiming = request.getParameter("filtroTiming");
        
        if (filtroTipo != null && !filtroTipo.isEmpty()) {
            viajesDisponibles = viajesDisponibles.stream()
                .filter(v -> v.getTipoViaje().toString().equals(filtroTipo))
                .collect(Collectors.toList());
        }
        
        // 5. Ordenar por proximidad o precio
        String ordenamiento = request.getParameter("orden");
        if ("distancia".equals(ordenamiento)) {
            viajesDisponibles.sort(Comparator.comparing(Viaje::getDistanciaCalculada));
        } else if ("precio".equals(ordenamiento)) {
            viajesDisponibles.sort(Comparator.comparing(Viaje::getPrecioFinal).reversed());
        } else {
            // Por defecto: más recientes primero
            viajesDisponibles.sort(Comparator.comparing(Viaje::getCreatedAt).reversed());
        }
        
        // 6. Paginación
        int page = Integer.parseInt(request.getParameter("page") != null ? request.getParameter("page") : "1");
        int pageSize = 10;
        List<Viaje> viajesPaginados = viajesDisponibles.stream()
            .skip((page - 1) * pageSize)
            .limit(pageSize)
            .collect(Collectors.toList());
        
        // 7. Preparar respuesta
        request.setAttribute("viajes", viajesPaginados);
        request.setAttribute("totalViajes", viajesDisponibles.size());
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", (int) Math.ceil((double) viajesDisponibles.size() / pageSize));
        
        request.getRequestDispatcher("/jsp/piloto/viajes-disponibles.jsp").forward(request, response);
    }
}
```

**🔄 Lógica de Matching (MatchingService.java):**
```java
@Service
public class MatchingService {
    
    public List<Viaje> obtenerViajesParaPiloto(Usuario piloto, Map<String, String[]> filtros) {
        ViajeDAO viajeDAO = new ViajeDAOImpl();
        
        // Criterios base
        Map<String, Object> criterios = new HashMap<>();
        criterios.put("estado", EstadoViaje.PENDIENTE);
        criterios.put("fechaHoraSolicitada", LocalDateTime.now().plusHours(1)); // Mínimo 1 hora de anticipación
        
        // Obtener todos los viajes pendientes
        List<Viaje> todosPendientes = viajeDAO.buscarViajes(criterios);
        
        return todosPendientes.stream()
            .filter(viaje -> puedeVerViaje(piloto, viaje))
            .collect(Collectors.toList());
    }
    
    private boolean puedeVerViaje(Usuario piloto, Viaje viaje) {
        // REGLA CORREGIDA: Todos los pilotos ven viajes normales
        if (!viaje.isEsMisionEncubierta()) {
            return true; // ✅ VIAJES NORMALES: Visibles para TODOS
        }
        
        // MISIONES ENCUBIERTAS: Solo facciones específicas
        if (viaje.getFaccionesAutorizadas() == null || viaje.getFaccionesAutorizadas().isEmpty()) {
            return false;
        }
        
        return viaje.getFaccionesAutorizadas().contains(piloto.getFaccionId());
    }
}
```

---

### **📋 CU-005: ACEPTACIÓN DE VIAJE**

**🔗 Actor:** Piloto aprobado  
**🎯 Objetivo:** Aceptar un viaje disponible  
**📋 Precondiciones:** Viaje en estado PENDIENTE, piloto disponible  
**✅ Postcondiciones:** Viaje en estado CONFIRMADO, timer iniciado

**🔄 Flujo Principal:**
```java
// AceptarViajeServlet.java
@WebServlet("/aceptar-viaje")
public class AceptarViajeServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        Usuario piloto = (Usuario) request.getSession().getAttribute("usuario");
        int viajeId = Integer.parseInt(request.getParameter("viajeId"));
        
        ViajeService viajeService = new ViajeService();
        
        try {
            // 1. Verificar viaje existe y está disponible
            Viaje viaje = viajeService.obtenerViaje(viajeId);
            
            if (viaje == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"error\":\"Viaje no encontrado\"}");
                return;
            }
            
            if (viaje.getEstado() != EstadoViaje.PENDIENTE) {
                response.setStatus(HttpServletResponse.SC_CONFLICT);
                response.getWriter().write("{\"error\":\"Viaje ya no disponible\"}");
                return;
            }
            
            // 2. Verificar piloto puede ver este viaje (lógica de facciones)
            MatchingService matchingService = new MatchingService();
            if (!matchingService.puedeVerViaje(piloto, viaje)) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.getWriter().write("{\"error\":\"No autorizado para este viaje\"}");
                return;
            }
            
            // 3. Verificar piloto no tiene otro viaje activo
            if (viajeService.pilotoTieneViajeActivo(piloto.getId())) {
                response.setStatus(HttpServletResponse.SC_CONFLICT);
                response.getWriter().write("{\"error\":\"Ya tienes un viaje activo\"}");
                return;
            }
            
            // 4. Verificar capacidad de nave
            NaveService naveService = new NaveService();
            Nave nave = naveService.obtenerNaveDelPiloto(piloto.getId());
            
            if (nave == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\":\"No tienes nave asignada\"}");
                return;
            }
            
            if (!naveService.tieneCapacidadSuficiente(nave, viaje)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\":\"Tu nave no tiene capacidad suficiente\"}");
                return;
            }
            
            // 5. Aceptar viaje (transacción atómica)
            boolean aceptado = viajeService.aceptarViaje(viaje, piloto);
            
            if (aceptado) {
                // 6. Iniciar timer para llegada
                TimerService timerService = new TimerService();
                int tiempoLimite = (viaje.getTipoTiming() == TipoTiming.INMEDIATO) ? 5 : 30; // 5 min inmediato, 30 min programado
                timerService.iniciarTimerLlegada(viaje.getId(), tiempoLimite);
                
                // 7. Notificar usuario
                NotificacionService notifService = new NotificacionService();
                notifService.notificarViajeAceptado(viaje);
                
                response.getWriter().write("{\"success\":true, \"message\":\"Viaje aceptado correctamente\"}");
                
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\":\"Error al aceptar viaje\"}");
            }
            
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Error interno del servidor\"}");
        }
    }
}
```

---

### **📋 CU-006: GESTIÓN DE ESTADOS DE VIAJE**

**🔄 Máquina de Estados:**
```java
// ViajeService.java
@Service
public class ViajeService {
    
    public boolean cambiarEstadoViaje(int viajeId, EstadoViaje nuevoEstado, Usuario usuario) {
        Viaje viaje = obtenerViaje(viajeId);
        
        // Validar transición de estado permitida
        if (!esTransicionValida(viaje.getEstado(), nuevoEstado, usuario)) {
            return false;
        }
        
        // Aplicar lógica específica por estado
        switch (nuevoEstado) {
            case CONFIRMADO:
                return confirmarViaje(viaje, usuario);
            case EN_CURSO:
                return iniciarViaje(viaje, usuario);
            case COMPLETADO:
                return completarViaje(viaje, usuario);
            case CANCELADO:
                return cancelarViaje(viaje, usuario);
            case EXPIRADO:
                return expirarViaje(viaje);
            default:
                return false;
        }
    }
    
    private boolean esTransicionValida(EstadoViaje estadoActual, EstadoViaje nuevoEstado, Usuario usuario) {
        switch (estadoActual) {
            case PENDIENTE:
                return nuevoEstado == EstadoViaje.CONFIRMADO || 
                       nuevoEstado == EstadoViaje.CANCELADO ||
                       nuevoEstado == EstadoViaje.EXPIRADO;
                       
            case CONFIRMADO:
                return nuevoEstado == EstadoViaje.EN_CURSO || 
                       nuevoEstado == EstadoViaje.CANCELADO ||
                       nuevoEstado == EstadoViaje.EXPIRADO;
                       
            case EN_CURSO:
                return nuevoEstado == EstadoViaje.COMPLETADO;
                
            default:
                return false; // Estados finales no pueden cambiar
        }
    }
    
    private boolean iniciarViaje(Viaje viaje, Usuario piloto) {
        // Verificar piloto llegó a ubicación de origen
        NaveService naveService = new NaveService();
        Nave nave = naveService.obtenerNaveDelPiloto(piloto.getId());
        
        Planeta origenPlaneta = obtenerPlaneta(viaje.getOrigenPlanetaId());
        
        if (!naveService.estaEnPlaneta(nave, origenPlaneta)) {
            return false;
        }
        
        // Actualizar estado y timestamp
        viaje.setEstado(EstadoViaje.EN_CURSO);
        viaje.setFechaInicio(LocalDateTime.now());
        
        return viajeDAO.actualizar(viaje);
    }
}
```

---

## 🏗️ SERVICIOS PRINCIPALES

### **CalculadoraDistanciaService.java**
```java
@Service
public class CalculadoraDistanciaService {
    
    public BigDecimal calcularDistanciaEntrePlanetas(int origenId, int destinoId) {
        PlanetaDAO planetaDAO = new PlanetaDAOImpl();
        
        Planeta origen = planetaDAO.obtenerPorId(origenId);
        Planeta destino = planetaDAO.obtenerPorId(destinoId);
        
        // Fórmula de distancia euclidiana 3D
        double deltaX = destino.getCoordenadaX().doubleValue() - origen.getCoordenadaX().doubleValue();
        double deltaY = destino.getCoordenadaY().doubleValue() - origen.getCoordenadaY().doubleValue();
        double deltaZ = destino.getCoordenadaZ().doubleValue() - origen.getCoordenadaZ().doubleValue();
        
        double distancia = Math.sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ);
        
        return new BigDecimal(distancia).setScale(2, RoundingMode.HALF_UP);
    }
    
    public BigDecimal calcularPrecioBase(BigDecimal distancia, TipoViaje tipoViaje, int numPasajeros, BigDecimal pesoCarga) {
        // Precio base por parsec
        BigDecimal precioBasePorParsec = new BigDecimal("100.00");
        
        // Multiplicadores por tipo
        BigDecimal multiplicadorTipo = switch (tipoViaje) {
            case PASAJERO -> new BigDecimal("1.0");
            case CARGA -> new BigDecimal("0.8");
        };
        
        // Cálculo base
        BigDecimal precioBase = distancia.multiply(precioBasePorParsec).multiply(multiplicadorTipo);
        
        // Ajustes por pasajeros/carga
        if (tipoViaje == TipoViaje.PASAJERO) {
            precioBase = precioBase.multiply(new BigDecimal(numPasajeros));
        } else {
            // Carga: +5% por cada tonelada adicional después de la primera
            if (pesoCarga.compareTo(BigDecimal.ONE) > 0) {
                BigDecimal toneladasAdicionales = pesoCarga.subtract(BigDecimal.ONE);
                BigDecimal incremento = toneladasAdicionales.multiply(new BigDecimal("0.05"));
                precioBase = precioBase.multiply(BigDecimal.ONE.add(incremento));
            }
        }
        
        return precioBase.setScale(2, RoundingMode.HALF_UP);
    }
}
```

---

## 🔄 PRÓXIMOS PASOS DE IMPLEMENTACIÓN

1. **Implementar modelos base** (Usuario, Viaje, etc.)
2. **Crear DAOs con conexión MySQL**
3. **Desarrollar servicios de negocio**
4. **Implementar servlets principales**
5. **Crear JSPs básicas**
6. **Configurar filtros de seguridad**
7. **Integrar sistema de notificaciones**
8. **Testing y refinamiento**

¿Te gustaría que empiece implementando algún componente específico?