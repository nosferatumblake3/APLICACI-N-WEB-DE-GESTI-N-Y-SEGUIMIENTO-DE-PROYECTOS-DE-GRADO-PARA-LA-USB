# Sistema de Gestión de Proyectos de Grado
## Universidad Salesiana de Bolivia - Sede Cochabamba

Aplicación web full-stack para la gestión y seguimiento de proyectos de grado desarrollada con React.js, Node.js/Express, TypeScript y PostgreSQL (Neon).

---

## 📋 Tabla de Contenidos

- [Características](#-características)
- [Requisitos Previos](#-requisitos-previos)
- [Instalación](#-instalación)
- [Configuración](#-configuración)
- [Ejecución Local](#-ejecución-local)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Roles del Sistema](#-roles-del-sistema)
- [API Endpoints](#-api-endpoints)
- [Base de Datos](#-base-de-datos)
- [Seguridad](#-seguridad)
- [Tecnologías Utilizadas](#-tecnologías-utilizadas)
- [Scripts Disponibles](#-scripts-disponibles)
- [Tests Unitarios](#-tests-unitarios)
- [Diagramas UML](#-diagramas-uml)
- [Despliegue](#-despliegue)
- [Documentación Adicional](#-documentación-adicional)

---

## 🚀 Características

### Funcionalidades Principales

- ✅ **Autenticación y Autorización**
  - Sistema de autenticación seguro con JWT
  - Roles diferenciados: Estudiante, Tutor, Revisor, Administrador
  - Protección de rutas basada en roles
  - Hash seguro de contraseñas con bcryptjs

- ✅ **Gestión de Proyectos**
  - Registro completo de proyectos de grado
  - Asignación de tutores y revisores
  - Control de estados del proyecto
  - Dashboard personalizado por rol

- ✅ **Control de Versiones de Documentos**
  - Sistema de versionado automático
  - Comparación visual entre versiones
  - Detección automática de cambios (nombre, tamaño, fecha)
  - Historial completo de versiones

- ✅ **Sistema de Bitácoras**
  - Registro automático de todas las acciones
  - Trazabilidad completa de cambios
  - Historial detallado con información de usuario y fecha
  - Almacenamiento de cambios detectados en formato JSONB

- ✅ **Retroalimentación Centralizada**
  - Observaciones por sección del documento
  - Tipos de observaciones: observación, aprobación, rechazo
  - Marcado de observaciones como resueltas
  - Historial completo de retroalimentación

- ✅ **Notificaciones Automáticas**
  - Notificaciones en tiempo real mediante triggers de base de datos
  - Diferentes tipos de notificaciones según el evento
  - Sistema de lectura/no lectura
  - Contador de notificaciones no leídas

- ✅ **Reportes y Estadísticas**
  - Reportes de tareas pendientes personalizados por rol
  - Reportes de tareas cumplidas
  - Estadísticas administrativas completas
  - Reportes de avance por proyecto
  - Reportes de tiempos y plazos

- ✅ **Gestión de Etapas (Nuevo)**
  - Administrador crea y configura etapas del proyecto
  - Control de fechas de apertura y cierre de etapas
  - Delimitación de tiempos de entrega por etapa
  - Validación automática de entregas según estado de etapa
  - Historial de cambios en etapas
  - Personalización de fechas por proyecto
  - Permite/Bloquea entregas fuera de tiempo

- ✅ **Interfaz de Usuario**
  - Diseño responsive y moderno
  - Interfaz intuitiva y fácil de usar
  - Dashboard personalizado según el rol
  - Navegación clara y organizada

---

## 📋 Requisitos Previos

Antes de comenzar, asegúrate de tener instalado:

- **Node.js** 18.x o superior
- **npm** o **yarn** (gestor de paquetes)
- **Git** (control de versiones)
- **Cuenta de Neon** (gratuita) - [https://neon.tech](https://neon.tech)
- **Editor de código** (recomendado: Visual Studio Code)

---

## 🛠️ Instalación

### 1. Clonar el Repositorio

```bash
git clone <repository-url>
cd proyectojosue
```

### 2. Configurar Base de Datos (Neon)

1. Crea una cuenta gratuita en [Neon](https://neon.tech)
2. Crea un nuevo proyecto en el dashboard de Neon
3. Copia la cadena de conexión (connection string) que te proporciona Neon
4. Ejecuta el esquema SQL en Neon:
   - Ve al **SQL Editor** en el dashboard de Neon
   - Copia y pega el contenido completo del archivo `backend/schema.sql`
   - Ejecuta el script (esto creará todas las tablas, índices, triggers y funciones necesarias)

### 3. Configurar Backend

```bash
cd backend
npm install
```

Crea un archivo `.env` en la carpeta `backend/`:

```bash
# En Windows (PowerShell)
New-Item .env

# En Linux/Mac
touch .env
```

Edita el archivo `.env` con las siguientes variables:

```env
# Base de Datos
DATABASE_URL=postgresql://usuario:password@host.neon.tech/database?sslmode=require

# Autenticación JWT
JWT_SECRET=tu-secret-key-super-segura-y-aleatoria-minimo-32-caracteres
JWT_EXPIRES_IN=7d

# Servidor
PORT=3001
NODE_ENV=development

# Frontend
FRONTEND_URL=http://localhost:5173

# Almacenamiento de Archivos
UPLOAD_DIR=./uploads
MAX_FILE_SIZE=10485760
```

**Nota:** Reemplaza `DATABASE_URL` con tu cadena de conexión de Neon y genera un `JWT_SECRET` seguro y aleatorio.

### 4. Configurar Frontend

```bash
cd frontend
npm install
```

Crea un archivo `.env` en la carpeta `frontend/` (opcional, si necesitas variables de entorno):

```env
VITE_API_URL=http://localhost:3001/api
```

---

## 🚀 Ejecución Local

### Desarrollo

Abre **dos terminales** separadas:

**Terminal 1 - Backend:**
```bash
cd backend
npm run dev
```

El servidor backend estará corriendo en `http://localhost:3001`

**Terminal 2 - Frontend:**
```bash
cd frontend
npm run dev
```

El servidor frontend estará corriendo en `http://localhost:5173`

### Acceso a la Aplicación

- **Frontend:** [http://localhost:5173](http://localhost:5173)
- **Backend API:** [http://localhost:3001](http://localhost:3001)
- **Health Check:** [http://localhost:3001/health](http://localhost:3001/health)

### Crear Usuario Inicial

1. Abre la aplicación en `http://localhost:5173`
2. Haz clic en "Registrarse"
3. Completa el formulario de registro
4. Selecciona el rol deseado (estudiante, tutor, revisor o administrador)
5. Inicia sesión con tus credenciales

---

## 📁 Estructura del Proyecto

```
proyectojosue/
├── backend/
│   ├── src/
│   │   ├── db/
│   │   │   ├── connection.ts      # Conexión a PostgreSQL
│   │   │   └── migrate.ts          # Script de migración
│   │   ├── middleware/
│   │   │   ├── auth.ts             # Autenticación JWT
│   │   │   └── errorHandler.ts     # Manejo centralizado de errores
│   │   ├── routes/
│   │   │   ├── auth.ts             # Rutas de autenticación
│   │   │   ├── proyectos.ts        # Rutas de proyectos
│   │   │   ├── entregas.ts         # Rutas de entregas y comparación
│   │   │   ├── observaciones.ts    # Rutas de observaciones
│   │   │   ├── notificaciones.ts   # Rutas de notificaciones
│   │   │   ├── usuarios.ts         # Rutas de usuarios
│   │   │   ├── bitacoras.ts        # Rutas de bitácoras
│   │   │   └── reportes.ts         # Rutas de reportes y estadísticas
│   │   └── index.ts                # Servidor Express principal
│   ├── migrations/                 # Migraciones SQL
│   │   ├── 001_update_proyectos_fecha_entrega.sql
│   │   ├── 002_add_estados_proyecto.sql
│   │   └── 003_add_estados_tutor_revisor.sql
│   ├── uploads/                    # Archivos subidos (se crea automáticamente)
│   ├── schema.sql                  # Esquema completo de base de datos
│   ├── package.json
│   ├── tsconfig.json
│   └── .env                        # Variables de entorno (no incluido en repo)
│
├── frontend/
│   ├── src/
│   │   ├── components/            # Componentes reutilizables
│   │   │   ├── Layout.tsx         # Layout principal
│   │   │   ├── ProtectedRoute.tsx # Protección de rutas
│   │   │   └── Toast.tsx          # Notificaciones toast
│   │   ├── pages/                  # Páginas principales
│   │   │   ├── Dashboard.tsx      # Dashboard principal
│   │   │   ├── Login.tsx          # Página de inicio de sesión
│   │   │   ├── Register.tsx       # Página de registro
│   │   │   ├── Proyectos.tsx      # Lista de proyectos
│   │   │   ├── NuevoProyecto.tsx  # Crear nuevo proyecto
│   │   │   ├── ProyectoDetail.tsx # Detalle de proyecto
│   │   │   ├── Reportes.tsx       # Reportes y estadísticas
│   │   │   └── Usuarios.tsx       # Gestión de usuarios (admin)
│   │   ├── store/                  # Estado global (Zustand)
│   │   │   ├── authStore.ts       # Estado de autenticación
│   │   │   └── toastStore.ts      # Estado de notificaciones
│   │   ├── lib/                    # Utilidades
│   │   │   └── api.ts             # Cliente API con Axios
│   │   ├── App.tsx                # Componente raíz
│   │   └── main.tsx               # Punto de entrada
│   ├── package.json
│   ├── vite.config.ts
│   └── tsconfig.json
│
├── documento.md                    # Documento completo del proyecto de grado
├── HAPPY_PATH_ESTUDIANTE.md       # Flujo del estudiante
├── HAPPY_PATH_TUTOR.md            # Flujo del tutor
├── HAPPY_PATH_REVISOR.md          # Flujo del revisor
├── HAPPY_PATH_ADMINISTRADOR.md    # Flujo del administrador
└── README.md                      # Este archivo
```

---

## 👥 Roles del Sistema

### 👨‍🎓 Estudiante

**Funcionalidades:**
- Registrar nuevos proyectos de grado
- Subir documentos en diferentes etapas (anteproyecto, entregas parciales, versión final)
- Ver observaciones y retroalimentación de tutores y revisores
- Ver historial completo de versiones de documentos
- Comparar diferentes versiones de documentos
- Ver bitácoras de cambios realizados
- Marcar observaciones como resueltas
- Ver reportes de tareas pendientes y cumplidas
- Descargar documentos anteriores

### 👨‍🏫 Tutor

**Funcionalidades:**
- Ver todos los proyectos asignados
- Revisar documentos subidos por estudiantes
- Comparar versiones de documentos
- Agregar observaciones detalladas por sección
- Aprobar o rechazar entregas
- Ver historial completo de revisiones
- Ver bitácoras de cambios
- Ver reportes de tareas pendientes (entregas sin revisar)
- Ver reportes de tareas cumplidas

### 👨‍⚖️ Revisor

**Funcionalidades:**
- Revisar proyectos asignados
- Comparar versiones de documentos
- Agregar observaciones y evaluaciones
- Evaluar entregas con estados independientes
- Ver estado de proyectos asignados
- Ver bitácoras de cambios
- Ver reportes de tareas pendientes (proyectos asignados sin revisar)
- Ver reportes de tareas cumplidas

### 👨‍💼 Administrador

**Funcionalidades:**
- Gestionar usuarios del sistema
- Asignar tutores a proyectos
- Asignar revisores a proyectos (múltiples revisores por proyecto)
- Ver todos los proyectos del sistema
- Ver reportes y estadísticas completas del sistema
- Dashboard de estadísticas administrativas
- Ver todas las bitácoras del sistema
- Gestionar el sistema completo

---

## 📝 API Endpoints

### 🔐 Autenticación (`/api/auth`)

| Método | Endpoint | Descripción | Autenticación |
|--------|----------|-------------|---------------|
| POST | `/api/auth/register` | Registro de nuevo usuario | No |
| POST | `/api/auth/login` | Inicio de sesión (retorna JWT) | No |
| GET | `/api/auth/me` | Obtener usuario actual autenticado | Sí |

**Ejemplo de Registro:**
```json
POST /api/auth/register
{
  "nombre": "Juan",
  "apellidos": "Pérez",
  "email": "juan@example.com",
  "password": "password123",
  "rol": "estudiante"
}
```

**Ejemplo de Login:**
```json
POST /api/auth/login
{
  "email": "juan@example.com",
  "password": "password123"
}
```

### 📚 Proyectos (`/api/proyectos`)

| Método | Endpoint | Descripción | Rol Requerido |
|--------|----------|-------------|---------------|
| GET | `/api/proyectos` | Listar proyectos (filtrado por rol) | Todos |
| GET | `/api/proyectos/:id` | Obtener proyecto específico | Todos |
| POST | `/api/proyectos` | Crear nuevo proyecto | Estudiante |
| PUT | `/api/proyectos/:id` | Actualizar proyecto | Estudiante/Admin |
| POST | `/api/proyectos/:id/assign-tutor` | Asignar tutor a proyecto | Administrador |
| POST | `/api/proyectos/:id/assign-reviewer` | Asignar revisor a proyecto | Administrador |

### 📄 Entregas (`/api/entregas`)

| Método | Endpoint | Descripción | Rol Requerido |
|--------|----------|-------------|---------------|
| GET | `/api/entregas/proyecto/:proyectoId` | Listar entregas de un proyecto | Todos |
| GET | `/api/entregas/:id` | Obtener entrega específica | Todos |
| POST | `/api/entregas` | Subir nueva entrega (multipart/form-data) | Estudiante |
| PUT | `/api/entregas/:id/status` | Actualizar estado de entrega | Tutor/Revisor |
| GET | `/api/entregas/:id1/compare/:id2` | Comparar dos versiones de entregas | Todos |

**Ejemplo de Subida de Entrega:**
```bash
POST /api/entregas
Content-Type: multipart/form-data

{
  "proyecto_id": "uuid-del-proyecto",
  "etapa": "anteproyecto",
  "archivo": <archivo.pdf o .docx>
}
```

### 💬 Observaciones (`/api/observaciones`)

| Método | Endpoint | Descripción | Rol Requerido |
|--------|----------|-------------|---------------|
| GET | `/api/observaciones/entrega/:entregaId` | Listar observaciones de una entrega | Todos |
| POST | `/api/observaciones` | Crear nueva observación | Tutor/Revisor |
| PUT | `/api/observaciones/:id/resolve` | Marcar observación como resuelta | Estudiante |

**Ejemplo de Crear Observación:**
```json
POST /api/observaciones
{
  "entrega_id": "uuid-de-la-entrega",
  "comentario": "Revisar la sección de metodología",
  "seccion_documento": "Capítulo 3 - Metodología",
  "tipo": "observacion"
}
```

### 🔔 Notificaciones (`/api/notificaciones`)

| Método | Endpoint | Descripción | Rol Requerido |
|--------|----------|-------------|---------------|
| GET | `/api/notificaciones` | Listar notificaciones del usuario | Todos |
| GET | `/api/notificaciones/unread` | Contar notificaciones no leídas | Todos |
| PUT | `/api/notificaciones/:id/read` | Marcar notificación como leída | Todos |
| PUT | `/api/notificaciones/read-all` | Marcar todas como leídas | Todos |

### 📊 Bitácoras (`/api/bitacoras`)

| Método | Endpoint | Descripción | Rol Requerido |
|--------|----------|-------------|---------------|
| GET | `/api/bitacoras/entrega/:entregaId` | Obtener bitácoras de una entrega | Todos |
| POST | `/api/bitacoras` | Crear entrada de bitácora (automático) | Todos |

### 📈 Reportes (`/api/reportes`)

| Método | Endpoint | Descripción | Rol Requerido |
|--------|----------|-------------|---------------|
| GET | `/api/reportes/tareas-pendientes` | Obtener tareas pendientes (personalizado por rol) | Todos |
| GET | `/api/reportes/tareas-cumplidas` | Obtener tareas cumplidas | Todos |
| GET | `/api/reportes/avance/:proyectoId` | Obtener avance de un proyecto | Todos |
| GET | `/api/reportes/tiempos-plazos` | Obtener reporte de tiempos y plazos | Todos |
| GET | `/api/reportes/estadisticas` | Obtener estadísticas del sistema | Administrador |

### 👥 Usuarios (`/api/usuarios`)

| Método | Endpoint | Descripción | Rol Requerido |
|--------|----------|-------------|---------------|
| GET | `/api/usuarios` | Listar usuarios | Administrador |
| GET | `/api/usuarios/tutores` | Listar tutores disponibles | Administrador |
| GET | `/api/usuarios/revisores` | Listar revisores disponibles | Administrador |

### 📁 Archivos

| Método | Endpoint | Descripción | Rol Requerido |
|--------|----------|-------------|---------------|
| GET | `/uploads/:filename` | Descargar archivo subido | Todos (con autenticación) |

---

## 🗄️ Base de Datos

### Tablas Principales

- **`usuarios`** - Usuarios del sistema (estudiantes, tutores, revisores, administradores)
- **`proyectos`** - Proyectos de grado registrados
- **`entregas`** - Documentos entregados con control de versiones
- **`observaciones`** - Retroalimentación de tutores y revisores
- **`notificaciones`** - Notificaciones del sistema
- **`proyecto_revisores`** - Asignación de revisores a proyectos
- **`bitacoras`** - Bitácoras detalladas de cambios y acciones

### Características de la Base de Datos

- **PostgreSQL** gestionado por Neon (serverless)
- **Triggers automáticos** para notificaciones
- **Funciones almacenadas** para actualización automática de timestamps
- **Índices optimizados** para consultas rápidas
- **Integridad referencial** mediante foreign keys
- **Backups automáticos** gestionados por Neon

### Migraciones

El proyecto incluye un sistema de migraciones SQL en `backend/migrations/`:

- `001_update_proyectos_fecha_entrega.sql` - Agregar campo fecha_entrega
- `002_add_estados_proyecto.sql` - Agregar estados adicionales
- `003_add_estados_tutor_revisor.sql` - Estados separados para tutor y revisor

---

## 🔐 Seguridad

### Medidas Implementadas

- ✅ **Autenticación JWT** - Tokens seguros con expiración configurable
- ✅ **Hash de Contraseñas** - bcryptjs con salt rounds
- ✅ **Validación de Datos** - Zod para validación de esquemas
- ✅ **Protección de Rutas** - Middleware de autenticación y autorización
- ✅ **CORS Configurado** - Solo permite origen del frontend
- ✅ **Validación de Permisos** - Verificación de roles en cada endpoint
- ✅ **Sanitización de Entradas** - Prevención de SQL injection y XSS

### Variables de Entorno Sensibles

Nunca compartas ni subas a repositorios públicos:
- `JWT_SECRET` - Debe ser una cadena aleatoria segura
- `DATABASE_URL` - Contiene credenciales de base de datos

---

## 📚 Tecnologías Utilizadas

### Frontend
- **React 18** - Biblioteca de UI
- **TypeScript 5.2** - Tipado estático
- **Vite 5.0** - Build tool y dev server
- **React Router DOM 6.21** - Enrutamiento
- **Zustand 4.4** - Gestión de estado global
- **Axios 1.6** - Cliente HTTP
- **CSS3** - Estilos con variables CSS
- **Jest** - Framework de testing
- **@testing-library/react** - Utilidades para testing de React

### Backend
- **Node.js 18+** - Runtime de JavaScript
- **Express.js 4.18** - Framework web
- **TypeScript 5.3** - Tipado estático
- **PostgreSQL** - Base de datos relacional
- **pg 8.11** - Cliente PostgreSQL
- **jsonwebtoken 9.0** - Autenticación JWT
- **bcryptjs 2.4** - Hash de contraseñas
- **Zod 3.22** - Validación de esquemas
- **multer 1.4** - Manejo de archivos
- **cors 2.8** - CORS middleware
- **Jest** - Framework de testing
- **ts-jest** - Preset de Jest para TypeScript

### Base de Datos
- **Neon** - Servicio PostgreSQL serverless
- **PostgreSQL** - Sistema de gestión de base de datos

### Herramientas de Desarrollo
- **Git** - Control de versiones
- **GitHub** - Repositorio remoto
- **Postman** - Pruebas de API
- **ESLint** - Linter de código
- **TypeScript Compiler** - Verificación de tipos
- **Jest** - Testing unitario (backend y frontend)

---

## 🧪 Scripts Disponibles

### Backend

```bash
# Desarrollo con hot reload
npm run dev

# Compilar TypeScript a JavaScript
npm run build

# Ejecutar en producción
npm start

# Ejecutar migraciones
npm run migrate

# Ejecutar tests unitarios
npm test

# Tests en modo watch (ejecuta tests al cambiar archivos)
npm run test:watch

# Tests con reporte de cobertura
npm run test:coverage
```

### Frontend

```bash
# Desarrollo con Vite (hot reload)
npm run dev

# Build de producción
npm run build

# Preview del build de producción
npm run preview

# Linter
npm run lint

# Ejecutar tests unitarios
npm test

# Tests en modo watch (ejecuta tests al cambiar archivos)
npm run test:watch

# Tests con reporte de cobertura
npm run test:coverage
```

### Tests Unitarios

El proyecto incluye una suite completa de tests unitarios implementada con Jest:

- **Backend:** 41 tests unitarios cubriendo middleware, validaciones, utilidades y seguridad
- **Frontend:** 10 tests unitarios cubriendo stores y utilidades
- **Total:** 51 tests unitarios, todos pasando ✅

**Ejecutar Tests:**

```bash
# Backend
cd backend
npm test

# Frontend
cd frontend
npm test
```

Para más detalles sobre los tests implementados, consulta el archivo [TESTS_UNITARIOS.md](./TESTS_UNITARIOS.md) que contiene la documentación completa con tablas de todos los tests.

---

## 📊 Diagramas UML

El proyecto incluye una colección completa de diagramas UML en formato Mermaid que documentan la arquitectura, diseño y flujos del sistema.

### Diagramas Disponibles

- **Diagrama de Casos de Uso** - Todos los casos de uso organizados por rol
- **Diagrama Entidad-Relación** - Modelo completo de la base de datos
- **Diagrama de Secuencia** - Flujos de subida/revisión y autenticación
- **Diagrama de Componentes** - Arquitectura del sistema
- **Diagrama de Estados** - Ciclo de vida de un proyecto
- **Diagrama de Clases** - Modelo de datos del backend
- **Diagrama de Flujo** - Proceso de revisión de documentos
- **Diagrama de Despliegue** - Arquitectura de despliegue

### Visualización

Los diagramas están disponibles en el archivo [DIAGRAMAS_UML.md](./DIAGRAMAS_UML.md) y pueden ser visualizados:

- **En GitHub**: Se renderizan automáticamente en archivos Markdown
- **En VS Code**: Con la extensión "Markdown Preview Mermaid Support"
- **En línea**: Copiando el código en [Mermaid Live Editor](https://mermaid.live)

### Ejemplo: Diagrama de Casos de Uso

```mermaid
graph TB
    subgraph "Actores"
        Estudiante[👨‍🎓 Estudiante]
        Tutor[👨‍🏫 Tutor]
        Revisor[👨‍⚖️ Revisor]
        Administrador[👨‍💼 Administrador]
    end

    subgraph "Casos de Uso - Estudiante"
        UC1[Crear Proyecto]
        UC2[Subir Documento]
        UC3[Ver Observaciones]
        UC4[Comparar Versiones]
    end

    Estudiante --> UC1
    Estudiante --> UC2
    Estudiante --> UC3
    Estudiante --> UC4
```

Para ver todos los diagramas completos, consulta [DIAGRAMAS_UML.md](./DIAGRAMAS_UML.md).

---

## 🚢 Despliegue

### Backend

1. Configurar variables de entorno en producción
2. Compilar TypeScript: `npm run build`
3. Ejecutar: `npm start`
4. Recomendado: Usar PM2 o similar para gestión de procesos

```bash
# Con PM2
pm2 start dist/index.js --name proyectos-backend
```

### Frontend

1. Build: `npm run build`
2. Desplegar carpeta `dist/` en Vercel, Netlify o similar
3. Configurar variables de entorno en la plataforma
4. Configurar proxy para `/api` hacia el backend

### Base de Datos

- Neon proporciona backups automáticos
- Configurar variables de entorno con la URL de producción
- Usar branching de Neon para entornos de desarrollo y producción separados

### Variables de Entorno en Producción

Asegúrate de configurar:
- `DATABASE_URL` - URL de producción de Neon
- `JWT_SECRET` - Secret diferente al de desarrollo
- `NODE_ENV=production`
- `FRONTEND_URL` - URL del frontend en producción
- `PORT` - Puerto del servidor (si aplica)

---

## 📖 Documentación Adicional

### Documentos del Proyecto

- `documento.md` - Documento completo del proyecto de grado
- `TESTS_UNITARIOS.md` - Documentación completa de tests unitarios con tablas
- `DIAGRAMAS_UML.md` - Diagramas UML completos en formato Mermaid
- `GESTION_ETAPAS.md` - **Documentación completa del sistema de gestión de etapas**
- `HAPPY_PATH_ESTUDIANTE.md` - Flujo completo del estudiante
- `HAPPY_PATH_TUTOR.md` - Flujo completo del tutor
- `HAPPY_PATH_REVISOR.md` - Flujo completo del revisor
- `HAPPY_PATH_ADMINISTRADOR.md` - Flujo completo del administrador

### Enlaces Útiles

- [Documentación de Neon](https://neon.tech/docs)
- [Documentación de PostgreSQL](https://www.postgresql.org/docs/)
- [Documentación de React](https://react.dev/)
- [Documentación de Express](https://expressjs.com/)
- [Documentación de TypeScript](https://www.typescriptlang.org/docs/)
- [Documentación de Vite](https://vitejs.dev/)

---

## 🐛 Solución de Problemas

### Error de Conexión a Base de Datos

- Verifica que `DATABASE_URL` esté correctamente configurada
- Asegúrate de que la base de datos en Neon esté activa
- Verifica que el esquema SQL se haya ejecutado correctamente

### Error de Autenticación

- Verifica que `JWT_SECRET` esté configurado
- Asegúrate de que el token JWT no haya expirado
- Verifica que el header `Authorization: Bearer <token>` esté presente

### Error al Subir Archivos

- Verifica que el directorio `uploads/` exista en el backend
- Verifica que el tamaño del archivo no exceda `MAX_FILE_SIZE`
- Verifica que el tipo de archivo sea permitido (PDF, DOCX)

### Error CORS

- Verifica que `FRONTEND_URL` en el backend coincida con la URL del frontend
- Verifica que el frontend esté haciendo peticiones a la URL correcta del backend

---

## 👨‍💻 Autor

**Josue Valentino Torrez Parra**  
Universidad Salesiana de Bolivia - Sede Cochabamba
Carrera de Ingeniería de Sistemas

---

## 📝 Licencia

Este proyecto es parte de un trabajo de grado académico desarrollado para la Universidad Salesiana de Bolivia, Sede Cochabamba.

---

## 🤝 Contribuciones

Este es un proyecto académico. Para mejoras o sugerencias, contactar al autor.

---

## ⚠️ Notas Importantes

- Asegúrate de configurar correctamente las variables de entorno antes de ejecutar la aplicación
- El sistema requiere que la tabla `bitacoras` esté creada en la base de datos (incluida en `schema.sql`)
- Los archivos subidos se almacenan localmente en `backend/uploads/` (configurable)
- En producción, considera usar un servicio de almacenamiento cloud (AWS S3, Cloudinary) para archivos
- El sistema de notificaciones funciona mediante triggers de base de datos que se crean automáticamente al ejecutar `schema.sql`

---

**Última actualización:** 2025
