---

# Proyecto de Infraestructura en AWS con CloudFormation

Este proyecto crea una infraestructura en AWS utilizando CloudFormation, en este caso me basé en la creación de templates y luego orquestarlos en un stack principal. Este stack principal tomará los templates que subiremos a un bucket S3 apartir de ahi se iran anindando de forma que se creara la infraestructura.

## Requisitos

- **Tener instalado AWS CLI**
- **Configurar el fichero de creedenciales de aws por lo general se encuentra en ~/.aws/credentials**

## Cómo Ejecutar el Proyecto

1. **CREAR BUCKET S3**:
    
    Primero crearemos un bucket S3 para subir nuestros templates, de esta forma desde el stack            principal podremos llamarlos usando el atributo **TemplateURL**.
    
    Hay un script que se encarga de esto. Se encuentra en ```./scripts/deploy_templates_s3.sh```         habrá que darle permisos de ejecución.
    
    ```sh
    chmod u+x ./scripts/deploy_templates_s3.sh
    ```

    Este script recibe como parametros el nombre que le daremos al bucket la región deonde se creará y     los templates a subir que en este caso es el dir ```./templates```.

    Para poder ejecutarlo pasamos los parametros 
    
         `-b`: Nombre del bucket S3 que deseas crear.
         `-r`: Región donde se creará el bucket.
         `-d`: Directorio que contiene los templates que deseas subir.
    
    Por defecto hay que dejar ./templates
    ```sh
    ./scripts/deploy_templates_s3.sh -b my-s3-ander-templates -r us-east-1 -d ./templates
    ```
    
    El script ya por defecto cambia los permisos del bucket y se encarga de subir los templates. 


---