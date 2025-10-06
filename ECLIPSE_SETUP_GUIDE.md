# 🌟 GUÍA COMPLETA: CREAR PROYECTO FLYSOLO EN ECLIPSE
## Configuración paso a paso para Java 21 + Maven + Tomcat

---

## 🚀 **PASO 1: PREPARAR ECLIPSE IDE**

### **✅ Verificaciones Previas**
1. **Eclipse IDE instalado** (preferiblemente Eclipse IDE for Enterprise Java and Web Developers)
2. **JDK 21 configurado** en el sistema
3. **Maven integrado** en Eclipse (viene por defecto)
4. **Tomcat 10.1** descargado (no instalado, solo descomprimido)

### **🔧 Configurar Eclipse:**

**A. Verificar JDK 21:**
```
Window → Preferences → Java → Installed JREs
→ Add... → Standard VM → Buscar JDK 21
→ Marcar como default
```

**B. Configurar Maven:**
```
Window → Preferences → Maven
→ User Settings → Browse... → Buscar settings.xml (si tienes)
→ ✅ Download repository index updates on startup
```

**C. Configurar Workspace:**
```
Window → Preferences → General → Workspace
→ Text file encoding: UTF-8
→ New text file line delimiter: Unix
```

---

## 📁 **PASO 2: CREAR PROYECTO MAVEN**

### **🆕 Nuevo Proyecto Maven:**

1. **File → New → Project...**
2. **Maven → Maven Project → Next**

### **📋 Configuración del Proyecto:**

**Página 1 - Project location:**
```
☑️ Use default Workspace location
⬜ Create a simple project (skip archetype selection) - NO marcar
→ Next
```

**Página 2 - Select an Archetype:**
```
Catalog: All Catalogs
Filter: webapp

Seleccionar:
GroupId: org.apache.maven.archetypes
ArtifactId: maven-archetype-webapp
Version: 1.4 (la más reciente)
→ Next
```

**Página 3 - Specify Archetype parameters:**
```
Group Id: com.flysolo
Artifact Id: flysolo-webapp
Version: 1.0.0
Package: com.flysolo
→ Finish
```

### **⏳ Esperar...**
Eclipse descargará las dependencias y creará la estructura base.

---

## ⚙️ **PASO 3: CONFIGURAR PROPIEDADES DEL PROYECTO**

### **A. Java Build Path:**
```
Click derecho en proyecto → Properties → Java Build Path

→ Libraries → Modulepath/Classpath
→ Remove JRE System Library (si no es JDK 21)
→ Add Library... → JRE System Library → Next → 
   Workspace default JRE (debe ser JDK 21) → Finish
```

### **B. Project Facets:**
```
Properties → Project Facets

Configurar:
☑️ Java = 21
☑️ JavaScript = 1.0
☑️ Dynamic Web Module = 6.0  ⚠️ IMPORTANTE
⬜ Desmarcar versiones anteriores

→ Apply and Close
```

### **C. Compiler Compliance:**
```
Properties → Java Compiler

Compiler compliance level: 21
☑️ Use default compliance settings
→ Apply and Close
```

---

## 🖥️ **PASO 4: CONFIGURAR TOMCAT**

### **A. Agregar Servidor Tomcat:**
```
Window → Show View → Servers
En vista Servers → Click derecho → New → Server

Server type: Apache → Tomcat v10.1 Server
Server name: Tomcat v10.1 Server
→ Next

Tomcat installation directory: [Ruta donde descomprimiste Tomcat]
JRE: Usar JRE 21
→ Next

Available projects: flysolo-webapp
→ Add → Configured projects
→ Finish
```

### **B. Configurar Puerto (Opcional):**
```
En Servers → Doble click en "Tomcat v10.1 Server"
→ Ports section:
   HTTP/1.1: 8080 (default, o cambiar si está ocupado)
→ Save
```

---

## 📦 **PASO 5: CONFIGURAR POM.XML**

### **🔄 Reemplazar pom.xml completo:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    
    <modelVersion>4.0.0</modelVersion>
    
    <!-- ===== INFORMACIÓN DEL PROYECTO ===== -->
    <groupId>com.flysolo</groupId>
    <artifactId>flysolo-webapp</artifactId>
    <version>1.0.0</version>
    <packaging>war</packaging>
    
    <name>FlySolo Transport Platform</name>
    <description>Sistema de transporte espacial con facciones - Universo Star Wars</description>
    
    <!-- ===== PROPIEDADES ===== -->
    <properties>
        <!-- Java Version -->
        <maven.compiler.source>21</maven.compiler.source>
        <maven.compiler.target>21</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        
        <!-- Dependency Versions -->
        <jakarta.servlet.version>6.0.0</jakarta.servlet.version>
        <jakarta.jsp.version>3.1.1</jakarta.jsp.version>
        <mysql.version>8.0.33</mysql.version>
        <hikari.version>5.0.1</hikari.version>
        <jackson.version>2.15.2</jackson.version>
        <bcrypt.version>0.10.2</bcrypt.version>
        <hibernate.validator.version>8.0.1.Final</hibernate.validator.version>
        <junit.version>4.13.2</junit.version>
        <log4j.version>2.20.0</log4j.version>
    </properties>
    
    <!-- ===== DEPENDENCIAS ===== -->
    <dependencies>
        
        <!-- Jakarta Servlet API -->
        <dependency>
            <groupId>jakarta.servlet</groupId>
            <artifactId>jakarta.servlet-api</artifactId>
            <version>${jakarta.servlet.version}</version>
            <scope>provided</scope>
        </dependency>
        
        <!-- Jakarta JSP API -->
        <dependency>
            <groupId>jakarta.servlet.jsp</groupId>
            <artifactId>jakarta.servlet.jsp-api</artifactId>
            <version>${jakarta.jsp.version}</version>
            <scope>provided</scope>
        </dependency>
        
        <!-- JSTL for JSP -->
        <dependency>
            <groupId>org.glassfish.web</groupId>
            <artifactId>jakarta.servlet.jsp.jstl</artifactId>
            <version>3.0.1</version>
        </dependency>
        
        <!-- MySQL Connector -->
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>${mysql.version}</version>
        </dependency>
        
        <!-- HikariCP Connection Pool -->
        <dependency>
            <groupId>com.zaxxer</groupId>
            <artifactId>HikariCP</artifactId>
            <version>${hikari.version}</version>
        </dependency>
        
        <!-- Jackson for JSON -->
        <dependency>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-databind</artifactId>
            <version>${jackson.version}</version>
        </dependency>
        
        <!-- BCrypt for Password Hashing -->
        <dependency>
            <groupId>at.favre.lib</groupId>
            <artifactId>bcrypt</artifactId>
            <version>${bcrypt.version}</version>
        </dependency>
        
        <!-- Bean Validation -->
        <dependency>
            <groupId>org.hibernate.validator</groupId>
            <artifactId>hibernate-validator</artifactId>
            <version>${hibernate.validator.version}</version>
        </dependency>
        
        <!-- Expression Language for Validation -->
        <dependency>
            <groupId>org.glassfish</groupId>
            <artifactId>jakarta.el</artifactId>
            <version>4.0.2</version>
        </dependency>
        
        <!-- Logging -->
        <dependency>
            <groupId>org.apache.logging.log4j</groupId>
            <artifactId>log4j-core</artifactId>
            <version>${log4j.version}</version>
        </dependency>
        
        <dependency>
            <groupId>org.apache.logging.log4j</groupId>
            <artifactId>log4j-slf4j-impl</artifactId>
            <version>${log4j.version}</version>
        </dependency>
        
        <!-- Testing -->
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>${junit.version}</version>
            <scope>test</scope>
        </dependency>
        
    </dependencies>
    
    <!-- ===== BUILD CONFIGURATION ===== -->
    <build>
        <finalName>flysolo</finalName>
        
        <plugins>
            
            <!-- Maven Compiler Plugin -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.11.0</version>
                <configuration>
                    <source>21</source>
                    <target>21</target>
                    <encoding>UTF-8</encoding>
                </configuration>
            </plugin>
            
            <!-- Maven War Plugin -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-war-plugin</artifactId>
                <version>3.4.0</version>
                <configuration>
                    <warSourceDirectory>src/main/webapp</warSourceDirectory>
                    <failOnMissingWebXml>false</failOnMissingWebXml>
                </configuration>
            </plugin>
            
            <!-- Maven Surefire Plugin (Testing) -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>3.1.2</version>
                <configuration>
                    <skipTests>false</skipTests>
                </configuration>
            </plugin>
            
        </plugins>
    </build>
    
</project>
```

### **🔄 Refrescar Maven:**
```
Click derecho en proyecto → Maven → Reload Projects
O: Alt + F5 → Force Update of Snapshots/Releases
```

---

## 📁 **PASO 6: CREAR ESTRUCTURA DE PACKAGES**

### **A. Java Source Structure:**
```
src/main/java/com/flysolo/
├── config/
├── models/
│   └── enums/
├── dao/
│   ├── interfaces/
│   └── impl/
├── services/
├── controllers/
├── servlets/
│   ├── auth/
│   ├── viajes/
│   ├── piloto/
│   └── admin/
├── filters/
├── listeners/
└── utils/
```

### **B. Crear Packages en Eclipse:**
```
src/main/java → Click derecho → New → Package

Crear uno por uno:
com.flysolo.config
com.flysolo.models
com.flysolo.models.enums
com.flysolo.dao.interfaces
com.flysolo.dao.impl
com.flysolo.services
com.flysolo.controllers
com.flysolo.servlets.auth
com.flysolo.servlets.viajes
com.flysolo.servlets.piloto
com.flysolo.servlets.admin
com.flysolo.filters
com.flysolo.listeners
com.flysolo.utils
```

### **C. Resources Structure:**
```
src/main/resources → Click derecho → New → Folder

Crear:
- src/main/resources (si no existe)
```

### **D. Webapp Structure:**
```
src/main/webapp/
├── WEB-INF/
│   └── web.xml (ya existe)
├── jsp/
│   ├── auth/
│   ├── usuario/
│   ├── piloto/
│   ├── admin/
│   ├── common/
│   └── includes/
├── css/
├── js/
├── images/
│   ├── facciones/
│   └── naves/
└── index.jsp
```

**Crear directorios webapp:**
```
src/main/webapp → Click derecho → New → Folder

Crear:
jsp, css, js, images
jsp/auth, jsp/usuario, jsp/piloto, jsp/admin, jsp/common, jsp/includes
images/facciones, images/naves
```

---

## ⚙️ **PASO 7: CONFIGURAR WEB.XML**

### **📝 Reemplazar web.xml:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="https://jakarta.ee/xml/ns/jakartaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="https://jakarta.ee/xml/ns/jakartaee
         https://jakarta.ee/xml/ns/jakartaee/web-app_6_0.xsd"
         version="6.0">

    <!-- ===== INFORMACIÓN DE LA APLICACIÓN ===== -->
    <display-name>FlySolo Transport Platform</display-name>
    <description>Sistema de transporte espacial con sistema de facciones</description>

    <!-- ===== CONFIGURACIÓN DE SESIÓN ===== -->
    <session-config>
        <session-timeout>30</session-timeout>
        <cookie-config>
            <http-only>true</http-only>
            <secure>false</secure> <!-- true en producción con HTTPS -->
        </cookie-config>
    </session-config>

    <!-- ===== WELCOME FILES ===== -->
    <welcome-file-list>
        <welcome-file>index.jsp</welcome-file>
        <welcome-file>jsp/auth/login.jsp</welcome-file>
    </welcome-file-list>

    <!-- ===== CONTEXT PARAMETERS ===== -->
    <context-param>
        <param-name>database.config.file</param-name>
        <param-value>/database.properties</param-value>
    </context-param>

    <!-- ===== LISTENERS ===== -->
    <listener>
        <listener-class>com.flysolo.listeners.AppContextListener</listener-class>
    </listener>

    <!-- ===== FILTERS ===== -->
    
    <!-- Filtro de Autenticación -->
    <filter>
        <filter-name>AuthenticationFilter</filter-name>
        <filter-class>com.flysolo.filters.AuthenticationFilter</filter-class>
    </filter>
    
    <filter-mapping>
        <filter-name>AuthenticationFilter</filter-name>
        <url-pattern>/dashboard/*</url-pattern>
        <url-pattern>/viajes/*</url-pattern>
        <url-pattern>/piloto/*</url-pattern>
        <url-pattern>/admin/*</url-pattern>
    </filter-mapping>

    <!-- Filtro de Facción -->
    <filter>
        <filter-name>FaccionFilter</filter-name>
        <filter-class>com.flysolo.filters.FaccionFilter</filter-class>
    </filter>
    
    <filter-mapping>
        <filter-name>FaccionFilter</filter-name>
        <url-pattern>/viajes/*</url-pattern>
        <url-pattern>/piloto/*</url-pattern>
    </filter-mapping>

    <!-- Filtro CORS -->
    <filter>
        <filter-name>CorsFilter</filter-name>
        <filter-class>com.flysolo.filters.CorsFilter</filter-class>
    </filter>
    
    <filter-mapping>
        <filter-name>CorsFilter</filter-name>
        <url-pattern>/api/*</url-pattern>
    </filter-mapping>

    <!-- ===== SERVLETS MAPPING ===== -->
    
    <!-- Auth Servlets -->
    <servlet>
        <servlet-name>LoginServlet</servlet-name>
        <servlet-class>com.flysolo.servlets.auth.LoginServlet</servlet-class>
    </servlet>
    <servlet-mapping>
        <servlet-name>LoginServlet</servlet-name>
        <url-pattern>/login</url-pattern>
    </servlet-mapping>

    <servlet>
        <servlet-name>RegisterServlet</servlet-name>
        <servlet-class>com.flysolo.servlets.auth.RegisterServlet</servlet-class>
    </servlet>
    <servlet-mapping>
        <servlet-name>RegisterServlet</servlet-name>
        <url-pattern>/register</url-pattern>
    </servlet-mapping>

    <servlet>
        <servlet-name>LogoutServlet</servlet-name>
        <servlet-class>com.flysolo.servlets.auth.LogoutServlet</servlet-class>
    </servlet>
    <servlet-mapping>
        <servlet-name>LogoutServlet</servlet-name>
        <url-pattern>/logout</url-pattern>
    </servlet-mapping>

    <!-- Viajes Servlets -->
    <servlet>
        <servlet-name>CrearViajeServlet</servlet-name>
        <servlet-class>com.flysolo.servlets.viajes.CrearViajeServlet</servlet-class>
    </servlet>
    <servlet-mapping>
        <servlet-name>CrearViajeServlet</servlet-name>
        <url-pattern>/viajes/crear</url-pattern>
    </servlet-mapping>

    <!-- ===== ERROR PAGES ===== -->
    <error-page>
        <error-code>404</error-code>
        <location>/jsp/common/error.jsp</location>
    </error-page>

    <error-page>
        <error-code>500</error-code>
        <location>/jsp/common/error.jsp</location>
    </error-page>

    <error-page>
        <exception-type>java.lang.Throwable</exception-type>
        <location>/jsp/common/error.jsp</location>
    </error-page>

</web-app>
```

---

## 📋 **PASO 8: CREAR ARCHIVOS DE CONFIGURACIÓN**

### **A. database.properties:**
```
src/main/resources → Click derecho → New → File → database.properties
```

```properties
# ===== CONFIGURACIÓN BASE DE DATOS MYSQL =====
db.driver=com.mysql.cj.jdbc.Driver
db.url=jdbc:mysql://localhost:3306/flysolo_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
db.username=root
db.password=tu_password_mysql

# ===== CONFIGURACIÓN HIKARI CONNECTION POOL =====
db.pool.maximumPoolSize=20
db.pool.minimumIdle=5
db.pool.connectionTimeout=30000
db.pool.idleTimeout=600000
db.pool.maxLifetime=1800000
db.pool.leakDetectionThreshold=60000

# ===== CONFIGURACIÓN APLICACIÓN =====
app.name=FlySolo Transport Platform
app.version=1.0.0
app.environment=development
app.session.timeout=30
```

### **B. application.properties:**
```properties
# ===== CONFIGURACIÓN GENERAL =====
app.debug=true
app.timezone=UTC
app.dateFormat=yyyy-MM-dd HH:mm:ss

# ===== CONFIGURACIÓN VIAJES =====
viaje.timer.inmediato.minutos=5
viaje.timer.programado.minutos=30
viaje.precio.base.por.parsec=100.00
viaje.precio.premium.multiplicador=1.20

# ===== CONFIGURACIÓN SEGURIDAD =====
security.bcrypt.rounds=12
security.session.secure=false
security.password.min.length=8

# ===== CONFIGURACIÓN NOTIFICACIONES =====
notification.enabled=true
notification.email.enabled=false
```

### **C. log4j2.xml (opcional pero recomendado):**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Configuration status="WARN">
    <Appenders>
        <Console name="Console" target="SYSTEM_OUT">
            <PatternLayout pattern="%d{HH:mm:ss.SSS} [%t] %-5level %logger{36} - %msg%n"/>
        </Console>
        
        <File name="FileAppender" fileName="logs/flysolo.log">
            <PatternLayout pattern="%d{yyyy-MM-dd HH:mm:ss.SSS} [%t] %-5level %logger{36} - %msg%n"/>
        </File>
    </Appenders>
    
    <Loggers>
        <Logger name="com.flysolo" level="DEBUG" additivity="false">
            <AppenderRef ref="Console"/>
            <AppenderRef ref="FileAppender"/>
        </Logger>
        
        <Root level="INFO">
            <AppenderRef ref="Console"/>
        </Root>
    </Loggers>
</Configuration>
```

---

## 🎯 **PASO 9: VERIFICAR CONFIGURACIÓN**

### **✅ Checklist Final:**

1. **Proyecto se compila sin errores**
   ```
   Click derecho → Run As → Maven clean
   Click derecho → Run As → Maven install
   ```

2. **Tomcat se puede iniciar**
   ```
   En Servers → Start server
   Verificar que no haya errores en Console
   ```

3. **Estructura de directorios correcta**
   ```
   Verificar que todos los packages existen
   Verificar que webapp tiene todas las carpetas
   ```

4. **Archivos de configuración creados**
   ```
   database.properties
   application.properties
   web.xml actualizado
   ```

---

## 🚀 **PRÓXIMOS PASOS**

Una vez completada toda esta configuración:

1. **Crear la base de datos** con el script SQL que te proporcioné
2. **Implementar las clases modelo** (Usuario, Viaje, etc.)
3. **Crear los DAOs básicos**
4. **Implementar el primer servlet** (LoginServlet)
5. **Crear las primeras JSPs**

¿Necesitas ayuda con algún paso específico de esta configuración?