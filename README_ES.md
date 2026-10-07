# Análisis de Engagement, Conversión y Retención de Producto

🌐 Idioma: [English](README.md) | **Español**

## Resumen Ejecutivo

Este proyecto end-to-end de Product Analytics investiga si los usuarios adquiridos están interactuando con el producto, convirtiéndose en clientes de pago y manteniendo su suscripción a lo largo del tiempo.

El análisis mostró que la adquisición general se mantuvo relativamente estable, pero la calidad de los usuarios presentó diferencias significativas entre los distintos canales de adquisición.

El deterioro más evidente apareció en **Paid Social durante H1 2026**:

- La tasa de activación cayó del **38,6% al 25,9%**
- La tasa de conversión cayó del **22,5% al 17,0%**
- El volumen de adquisición se mantuvo prácticamente sin cambios (**1.000 vs 988 usuarios**)

En el conjunto completo de usuarios, **los usuarios activados convirtieron 3,86 veces más** que los usuarios no activados y presentaron una **retención a 90 días 13,55 puntos porcentuales superior**.

Estos resultados sugieren que mejorar el engagement inicial con el producto —especialmente entre los usuarios procedentes de Paid Social— debería ser una prioridad para futuras investigaciones.

---

## Problema de Negocio

Product Management quiere entender si los usuarios adquiridos se están convirtiendo en clientes valiosos, activos y retenidos.

El análisis se centra en tres preguntas:

1. ¿Los canales de adquisición están generando usuarios que consiguen activarse y convertir?
2. ¿Qué relación existe entre el engagement inicial con el producto y la conversión y retención?
3. ¿Dónde se ha deteriorado el rendimiento del producto y qué debería investigar el negocio a continuación?

Periodo de análisis: **enero de 2025 – agosto de 2026**

---

## Dataset

Este proyecto utiliza un **dataset relacional sintético** diseñado para simular el entorno de un producto digital.

El dataset contiene:

- **12.000 usuarios**
- **73.151 sesiones**
- **307.067 eventos de producto sin procesar**
- **2.786 suscripciones**
- **1.162 tickets de soporte**

Entidades principales:

- Usuarios
- Sesiones
- Eventos de producto
- Suscripciones
- Tickets de soporte

El dataset incluye intencionadamente varios problemas de calidad de datos para que la validación y limpieza formen parte del flujo de trabajo analítico.

---

## Metodología

### 1. Calidad y Preparación de los Datos

Los datos sin procesar se cargaron en PostgreSQL y se validaron antes de comenzar el análisis.

La auditoría identificó:

- **100 registros de eventos duplicados**
- **60 valores de país ausentes**
- **40 valores de dispositivo de registro ausentes**

Se creó una capa analítica limpia utilizando vistas de PostgreSQL.

Los eventos duplicados se eliminaron utilizando `ROW_NUMBER()`, mientras que los valores categóricos ausentes se estandarizaron como `Unknown`.

---

### 2. Modelo Analítico a Nivel de Usuario

Se creó una vista analítica a nivel de usuario con una fila por usuario.

Las métricas incluidas fueron:

- Sesiones durante los primeros 7 días
- Número de funcionalidades distintas utilizadas durante los primeros 7 días
- Estado de activación
- Estado de conversión
- Información de suscripción
- Elegibilidad para la retención a 90 días
- Estado de retención a 90 días

### Definición de Activación

Un usuario se clasificó como **Activado** cuando completó:

- Al menos **2 sesiones**
- Al menos **3 funcionalidades distintas del producto**

durante sus primeros **7 días después del registro**.

### Definición de Retención

La retención se midió utilizando la **retención de suscripción a 90 días**.

Solo se incluyeron las suscripciones con suficiente antigüedad para haber completado la ventana completa de observación de 90 días.

---

## Principales Hallazgos

### 1. La adquisición se mantuvo estable en lugar de crecer

La adquisición mensual de nuevos usuarios se mantuvo aproximadamente entre **630 y 740 usuarios**.

Esto cuestionó la hipótesis inicial de que la adquisición estaba experimentando un crecimiento sostenido y desplazó la investigación hacia la **calidad de la adquisición en lugar del volumen de adquisición**.

---

### 2. La activación está fuertemente asociada con la conversión

| Segmento de Usuarios | Tasa de Conversión |
|---|---:|
| Activados | **43,74%** |
| No activados | **11,33%** |

Los usuarios activados convirtieron aproximadamente **3,86 veces más**.

Sin embargo, solo el **36,68% de los usuarios se activaron**, lo que convierte el engagement inicial en un área importante para la investigación de producto.

---

### 3. La activación también está asociada con una mayor retención

Entre las suscripciones elegibles para el análisis de retención a 90 días:

| Segmento de Usuarios | Retención a 90 Días |
|---|---:|
| Activados | **91,24%** |
| No activados | **77,69%** |

Los usuarios activados mostraron una **tasa de retención a 90 días 13,55 puntos porcentuales superior**.

Esto no demuestra causalidad, pero aporta evidencia de que el engagement inicial está asociado con mejores resultados posteriores del cliente.

---

### 4. Paid Social se deterioró significativamente en H1 2026

El volumen de adquisición de Paid Social se mantuvo prácticamente sin cambios:

**H1 2025:** 1.000 usuarios  
**H1 2026:** 988 usuarios

Sin embargo:

| Métrica | H1 2025 | H1 2026 | Cambio |
|---|---:|---:|---:|
| Tasa de Activación | 38,60% | 25,91% | **-12,69 pp** |
| Tasa de Conversión | 22,50% | 17,00% | **-5,50 pp** |

Esto sugiere que el principal problema no fue la cantidad de usuarios adquiridos, sino lo que ocurrió **después de la adquisición**.

---

### 5. El engagement inicial se debilitó a lo largo del recorrido de Paid Social

Los usuarios procedentes de Paid Social también mostraron un comportamiento inicial más débil dentro del producto.

El promedio de sesiones durante los primeros 7 días disminuyó aproximadamente un **24,3%**, mientras que el promedio de funcionalidades distintas utilizadas disminuyó aproximadamente un **19,4%**.

La adopción disminuyó en los siete comportamientos de producto analizados:

- Dashboard View
- Search
- Save Item
- Create List
- Share
- Notification Setup
- Export

Debido a que el deterioro se produjo en múltiples comportamientos, la evidencia apunta hacia un **problema general de engagement inicial en lugar de una única funcionalidad con bajo rendimiento**.

---

## Recomendaciones de Negocio

### Investigar la calidad de adquisición de Paid Social

Revisar la segmentación de las campañas, la composición de las audiencias y el mix de campañas para determinar si las campañas de H1 2026 atrajeron usuarios con una menor intención de utilizar el producto.

### Investigar la experiencia posterior a la adquisición

Evaluar el onboarding y la experiencia durante la primera semana de los usuarios procedentes de Paid Social para identificar posibles fricciones que estén impidiendo que alcancen la activación.

### Monitorizar la activación por cohorte de adquisición

La activación debería monitorizarse junto con el volumen de adquisición y la conversión, en lugar de evaluar los canales únicamente por el número de usuarios adquiridos.

### Centrarse en el engagement inicial general

Dado que la adopción de funcionalidades disminuyó en todo el producto y no únicamente en una funcionalidad aislada, las mejoras deberían centrarse inicialmente en la experiencia general del usuario durante sus primeros días.

---

## Limitaciones

- El dataset es sintético y representa un escenario de negocio simulado.
- El análisis identifica **asociaciones, no relaciones causales**.
- No se dispone de datos sobre inversión publicitaria, CAC, segmentación de campañas ni creatividades.
- Por lo tanto, no es posible evaluar la rentabilidad de los canales.
- El análisis de retención a 90 días solo incluye suscripciones con una ventana de observación completa.
- La definición de activación es una regla de negocio analítica y necesitaría una validación adicional en un entorno de producto real.

---

## Próximos Pasos

Con datos adicionales, el análisis podría ampliarse mediante:

- Conexión de los costes de adquisición con los resultados de los clientes
- Análisis de campañas y segmentos de audiencia de Paid Social
- Investigación de los pasos del onboarding previos a la activación
- Ejecución de experimentos para probar mejoras en el engagement inicial
- Evaluación del valor y la retención de clientes a más largo plazo

---

## Dashboard

### Resumen Ejecutivo

![Executive Overview](executive_overview.png)

### Análisis de Activación y Conversión

![Activation and Conversion](activation_conversion.png)

---

## Herramientas y Habilidades

**PostgreSQL**
- Validación y limpieza de datos
- Joins
- CTEs
- Lógica condicional
- Agregaciones
- Window functions
- Vistas analíticas

**Excel / Power Query**
- Importación de datos
- Validación
- Conciliación de KPIs
- PivotTables

**Power BI**
- Modelado de datos
- Medidas DAX
- Desarrollo de KPIs
- Comparación de cohortes
- Reporting interactivo
- Diseño de dashboards

---

## Archivos del Repositorio

- `Product_Engagement_Conversion_Retention_Analysis.pbix` — informe de Power BI
- `Product_Engagement_Conversion_Retention_Analysis.xlsx` — workbook de validación en Excel
- `executive_overview.png` — dashboard ejecutivo
- `activation_conversion.png` — dashboard de activación y conversión
