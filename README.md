TrankDashboards: Cliente de Gestión para Ecosistema de Salud Digital

📋 Descripción del Proyecto

TrankDashboards es la interfaz de gestión multiplataforma desarrollada en Flutter para el ecosistema Tranquiliza.360.

Este proyecto no actúa simplemente como una capa visual, sino que fue diseñado como una Implementación de Referencia (Reference Implementation) para validar, consumir y estresar los servicios del backend TrankAPI. Su arquitectura modular permite administrar el ciclo de vida de los datos clínicos, gestionar licencias institucionales y visualizar métricas complejas mediante patrones de diseño avanzados.

🏗️ Arquitectura y Decisiones de Ingeniería

1. Cliente de Validación y Seguridad

Router de Seguridad Activo: Implementación de un sistema de ruteo inteligente que intercepta la navegación. Verifica los permisos del Token JWT antes de renderizar cualquier vista, expulsando activamente a usuarios que intenten forzar accesos no autorizados (e.g., manipulación de URL).

Gestión de Estado Centralizada: Uso del patrón Provider para manejar el ciclo de vida de la sesión, persistencia segura del token y reactividad de la interfaz ante cambios de estado.

2. Patrones de Rendimiento y Visualización

Lazy Loading (Carga Diferida): En los paneles de alta densidad (como el de Residencias), se implementó carga bajo demanda para optimizar el ancho de banda y la memoria, solicitando datos detallados solo cuando el usuario expande un registro.

Widgets Recursivos (Data Mirroring): Para el dashboard clínico, se desarrolló una arquitectura de widgets anidados que replica visualmente la estructura jerárquica del JSON del backend (Sesión -> Ejercicios -> Métricas), validando la integridad referencial de los datos recibidos.

3. Privacidad por Diseño

Enmascaramiento en Cliente: Implementación de lógica de presentación condicional. El dashboard de Administrador recibe los datos técnicos para auditoría, pero aplica automáticamente una máscara de privacidad (Confidencial) sobre los identificadores de pacientes para cumplir con normativas éticas.

📱 Módulos y Funcionalidades

🛡️ Dashboard de Administrador

Gestión global de SuperUsers (Residencias).

Generador de Licencias: Interfaz para creación y configuración de claves de acceso hasheadas.

Auditoría técnica de sesiones con privacidad aplicada.

🏥 Dashboard de Residencia

Gestión de personal profesional.

Visualización de rendimiento institucional.

Optimizado con Lazy Loading para listas masivas.

👨‍⚕️ Dashboard de Profesional

Acceso exclusivo a pacientes asignados (Contexto Institucional).

Visualización detallada de métricas cognitivas y motrices.

Navegación jerárquica de la historia clínica.

🛠️ Stack Tecnológico

Framework: Flutter (Dart).

State Management: Provider.

Networking: http / Dio (Manejo de interceptores para JWT).

Storage: Shared Preferences / Flutter Secure Storage.

Diseño: Material Design 3 con componentes personalizados responsivos.

📸 Capturas de Pantalla

Login
<img width="1102" height="557" alt="image" src="https://github.com/user-attachments/assets/edaf897f-f9fd-4498-9b75-1ff9a5ce07fa" />

Register
<img width="983" height="487" alt="image" src="https://github.com/user-attachments/assets/e399475f-9ad5-4074-ae27-228ba8e5510c" />

Dashboard Admin
<img width="1920" height="948" alt="image" src="https://github.com/user-attachments/assets/e3ba1cf7-6fce-4ac2-bffa-f9a0d2068716" />

Dashboard Residencia
<img width="1918" height="946" alt="image" src="https://github.com/user-attachments/assets/4b58e485-f469-49fb-a7d0-3ec7db8daa6d" />

Dashboard Profesional
<img width="1908" height="802" alt="image" src="https://github.com/user-attachments/assets/7eb35efe-8f69-4575-8cb7-2ac4230a36e9" />

Detalle Clínico

✒️ Autor

Facundo Ariel Antivero - Ingeniero de Sistemas


Este proyecto es parte del Trabajo Final de Ingeniería de Sistemas para UNICEN, actuando como cliente oficial para la validación de TrankAPI.
