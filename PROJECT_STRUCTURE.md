# 🚀 ESTRUCTURA DEL PROYECTO FLYSOLO
## Arquitectura Maven + Java 21 + JSP + Servlets

```
flysolo/
├── pom.xml                                 # Configuración Maven
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/
│   │   │       └── flysolo/
│   │   │           ├── config/                  # Configuraciones
│   │   │           │   ├── DatabaseConfig.java
│   │   │           │   └── AppConfig.java
│   │   │           │
│   │   │           ├── models/                  # Entidades/DTOs
│   │   │           │   ├── Usuario.java
│   │   │           │   ├── Piloto.java
│   │   │           │   ├── Viaje.java
│   │   │           │   ├── Nave.java
│   │   │           │   ├── Faccion.java
│   │   │           │   ├── Planeta.java
│   │   │           │   ├── SistemaSolar.java
│   │   │           │   ├── Reseña.java
│   │   │           │   └── enums/
│   │   │           │       ├── TipoUsuario.java
│   │   │           │       ├── EstadoViaje.java
│   │   │           │       ├── TipoViaje.java
│   │   │           │       └── EstadoSolicitud.java
│   │   │           │
│   │   │           ├── dao/                     # Data Access Objects
│   │   │           │   ├── interfaces/
│   │   │           │   │   ├── UsuarioDAO.java
│   │   │           │   │   ├── ViajeDAO.java
│   │   │           │   │   ├── PilotoDAO.java
│   │   │           │   │   ├── NaveDAO.java
│   │   │           │   │   └── BaseDAO.java
│   │   │           │   │
│   │   │           │   └── impl/
│   │   │           │       ├── UsuarioDAOImpl.java
│   │   │           │       ├── ViajeDAOImpl.java
│   │   │           │       ├── PilotoDAOImpl.java
│   │   │           │       ├── NaveDAOImpl.java
│   │   │           │       └── BaseDAOImpl.java
│   │   │           │
│   │   │           ├── services/                # Lógica de negocio
│   │   │           │   ├── UsuarioService.java
│   │   │           │   ├── ViajeService.java
│   │   │           │   ├── PilotoService.java
│   │   │           │   ├── MatchingService.java
│   │   │           │   ├── FaccionService.java
│   │   │           │   ├── CalculadoraDistanciaService.java
│   │   │           │   └── NotificacionService.java
│   │   │           │
│   │   │           ├── controllers/             # Controladores web
│   │   │           │   ├── AuthController.java
│   │   │           │   ├── ViajeController.java
│   │   │           │   ├── PilotoController.java
│   │   │           │   ├── AdminController.java
│   │   │           │   └── BaseController.java
│   │   │           │
│   │   │           ├── servlets/                # Servlets HTTP
│   │   │           │   ├── auth/
│   │   │           │   │   ├── LoginServlet.java
│   │   │           │   │   ├── RegisterServlet.java
│   │   │           │   │   └── LogoutServlet.java
│   │   │           │   │
│   │   │           │   ├── viajes/
│   │   │           │   │   ├── CrearViajeServlet.java
│   │   │           │   │   ├── ListarViajesServlet.java
│   │   │           │   │   ├── AceptarViajeServlet.java
│   │   │           │   │   └── CancelarViajeServlet.java
│   │   │           │   │
│   │   │           │   ├── piloto/
│   │   │           │   │   ├── SolicitarPilotoServlet.java
│   │   │           │   │   ├── GestionNaveServlet.java
│   │   │           │   │   └── PerfilPilotoServlet.java
│   │   │           │   │
│   │   │           │   └── admin/
│   │   │           │       ├── AprobacionPilotoServlet.java
│   │   │           │       ├── GestionNavesServlet.java
│   │   │           │       └── ReportesServlet.java
│   │   │           │
│   │   │           ├── filters/                 # Filtros HTTP
│   │   │           │   ├── AuthenticationFilter.java
│   │   │           │   ├── FaccionFilter.java
│   │   │           │   └── CorsFilter.java
│   │   │           │
│   │   │           ├── listeners/               # Event Listeners
│   │   │           │   └── AppContextListener.java
│   │   │           │
│   │   │           └── utils/                   # Utilidades
│   │   │               ├── DatabaseUtil.java
│   │   │               ├── PasswordUtil.java
│   │   │               ├── ValidationUtil.java
│   │   │               ├── DateUtil.java
│   │   │               └── JsonUtil.java
│   │   │
│   │   ├── resources/                       # Recursos del classpath
│   │   │   ├── database.properties
│   │   │   ├── application.properties
│   │   │   └── log4j2.xml
│   │   │
│   │   └── webapp/                          # Recursos web
│   │       ├── WEB-INF/
│   │       │   ├── web.xml                  # Configuración web
│   │       │   ├── lib/                     # JARs adicionales
│   │       │   └── classes/                 # Clases compiladas
│   │       │
│   │       ├── jsp/                         # Páginas JSP
│   │       │   ├── auth/
│   │       │   │   ├── login.jsp
│   │       │   │   ├── register.jsp
│   │       │   │   └── register-piloto.jsp
│   │       │   │
│   │       │   ├── usuario/
│   │       │   │   ├── dashboard.jsp
│   │       │   │   ├── crear-viaje.jsp
│   │       │   │   ├── mis-viajes.jsp
│   │       │   │   └── perfil.jsp
│   │       │   │
│   │       │   ├── piloto/
│   │       │   │   ├── dashboard-piloto.jsp
│   │       │   │   ├── viajes-disponibles.jsp
│   │       │   │   ├── mis-viajes-piloto.jsp
│   │       │   │   ├── gestion-nave.jsp
│   │       │   │   └── solicitar-cambio-nave.jsp
│   │       │   │
│   │       │   ├── admin/
│   │       │   │   ├── dashboard-admin.jsp
│   │       │   │   ├── aprobar-pilotos.jsp
│   │       │   │   ├── gestion-naves.jsp
│   │       │   │   ├── gestion-armamento.jsp
│   │       │   │   └── reportes.jsp
│   │       │   │
│   │       │   ├── common/
│   │       │   │   ├── header.jsp
│   │       │   │   ├── footer.jsp
│   │       │   │   ├── navigation.jsp
│   │       │   │   └── error.jsp
│   │       │   │
│   │       │   └── includes/
│   │       │       ├── meta-tags.jsp
│   │       │       └── scripts.jsp
│   │       │
│   │       ├── css/                         # Estilos CSS
│   │       │   ├── main.css
│   │       │   ├── auth.css
│   │       │   ├── dashboard.css
│   │       │   ├── viajes.css
│   │       │   └── admin.css
│   │       │
│   │       ├── js/                          # JavaScript
│   │       │   ├── main.js
│   │       │   ├── auth.js
│   │       │   ├── viajes.js
│   │       │   ├── piloto.js
│   │       │   └── admin.js
│   │       │
│   │       ├── images/                      # Imágenes
│   │       │   ├── logo.png
│   │       │   ├── facciones/
│   │       │   │   ├── imperio.png
│   │       │   │   ├── rebeldes.png
│   │       │   │   └── neutrales.png
│   │       │   │
│   │       │   └── naves/
│   │       │       ├── yt-1300.png
│   │       │       ├── x-wing.png
│   │       │       └── tie-fighter.png
│   │       │
│   │       └── index.jsp                   # Página principal
│   │
│   └── test/                               # Tests
│       ├── java/
│       │   └── com/
│       │       └── flysolo/
│       │           ├── dao/
│       │           ├── services/
│       │           └── utils/
│       │
│       └── resources/
│           └── test-database.properties
│
├── target/                                 # Archivos compilados (Maven)
├── .gitignore
└── README.md
```

## 📋 DEPENDENCIAS PRINCIPALES (pom.xml)

```xml
<!-- Java EE/Jakarta EE -->
<dependency>
    <groupId>jakarta.servlet</groupId>
    <artifactId>jakarta.servlet-api</artifactId>
    <version>6.0.0</version>
</dependency>

<!-- MySQL -->
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>8.0.33</version>
</dependency>

<!-- Connection Pool -->
<dependency>
    <groupId>com.zaxxer</groupId>
    <artifactId>HikariCP</artifactId>
    <version>5.0.1</version>
</dependency>

<!-- JSON Processing -->
<dependency>
    <groupId>com.fasterxml.jackson.core</groupId>
    <artifactId>jackson-databind</artifactId>
    <version>2.15.2</version>
</dependency>

<!-- Validation -->
<dependency>
    <groupId>org.hibernate.validator</groupId>
    <artifactId>hibernate-validator</artifactId>
    <version>8.0.1.Final</version>
</dependency>

<!-- Password Hashing -->
<dependency>
    <groupId>org.springframework.security</groupId>
    <artifactId>spring-security-crypto</artifactId>
    <version>6.1.3</version>
</dependency>

<!-- Testing -->
<dependency>
    <groupId>junit</groupId>
    <artifactId>junit</artifactId>
    <version>4.13.2</version>
    <scope>test</scope>
</dependency>
```

## 🎯 PRÓXIMOS PASOS RECOMENDADOS

1. **Abre una carpeta vacía** en VS Code
2. **Ejecutar** el generador de workspace Maven
3. **Configurar** la base de datos con el script SQL
4. **Implementar** las clases base (modelos y DAOs)
5. **Crear** el primer servlet (Login)
6. **Configurar** Tomcat en Eclipse