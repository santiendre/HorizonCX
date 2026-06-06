# Horizon CX - Salesforce Developer Challenge

## Descripción
Este proyecto implementa las siguientes funcionalidades sobre una org de Salesforce:
- Sincronización diaria de datos de países desde la API de countrylayer hacia un objeto custom `Country__c`
- Un trigger en Lead que completa los campos de región y capital en base al código de país del lead
- Una regla de validación que restringe el cambio de propietario en Leads a menos que ciertos campos estén completos, con excepciones por perfil
- Un flow que registra la fecha y hora de asignación del propietario de un Lead

## Decisiones de diseño
- **Custom Metadata Type** (`External_API_Configuration__mdt`) se utilizó para almacenar el endpoint y la clave de la API, lo que permite desplegar la configuración entre entornos sin modificar código. Se descartó Named Credential ya que está orientado a flujos de autenticación (OAuth, certificados) y resulta excesivo para una clave estática.
- **Upsert completo en cada sincronización** en lugar de comparar registros, dado que la API no provee un endpoint de cambios y el volumen (~250 países) es bajo. Se utiliza `Alpha_2_Code__c` como ID externo.
- **`SyncCountriesQueueable`** gestiona el callout e es invocado por `SyncCountriesSchedule`, ya que las clases Schedulable no permiten callouts directamente.

## Supuestos
- El requerimiento del trigger ("mostrar información en los leads basándose en su país") fue interpretado como la población de los campos `Country_Capital__c` y `Country_Region__c` en el Lead, cruzando el campo estándar `CountryCode` con los registros de `Country__c`.
- El campo `regionalBlocs` ya no es devuelto por la API de countrylayer a pesar de estar documentado. La lógica de parsing está implementada y cubierta por los tests mediante datos mockeados.
