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

2. **DESPLEGAR EL STACK**:
    
    Hecho el anterior paso toca desplegar nuestro stack, para ello hay un script ```./scripts/deploy.sh``` que recibe unos parametros y se encargará de desplegar nuestra         infraestructura.

    Para poder ejecutarlo pasamos los parametros 
    
         `-p`: Nuestra IP Pública.
         `-k`: KeyPair generado.
         `-b`: Nombre del bucket generado en el anterior script.

```sh
./scripts/deploy.sh -p 188.26.211.60/32 -k test-key -b my-s3-ander-templates
```
 
Tardará un poco en desplegarse ya que son varios recursos a crear. Podremos ver el proceso de creación desde el dashboard de AWS - CloudFormation.

## Pruebas

Hecho el despligue de nuestra infraestructura, en los outputs podremos una tabla donde se mostrará el DNS del ALB formateado con el puerto 8080

```sh
"http://loadBalancerApp-1904107911.us-east-1.elb.amazonaws.com:8080"
```

Con este dato desde nuestro host podremos realizar un **curl** y verifciar que nos da un 200 OK como respuesta. Ya que las instancias EC2 del autoescaling group estan provisioandas con el0 servicio httpd que está en la escucha del puerto 8080

```sh
curl -I "http://loadBalancerApp-1904107911.us-east-1.elb.amazonaws.com:8080"
```

Si queremos conectarnos  por ssh al bastion tendremos el output de la IP del bastion

```sh
ssh -i <ruta de la keyPair> ec2-user@<ip del bastion>
```

Ahora si queremos hacer conexión ssh desde el bastión a nuestras EC2 del autoescaling group tendremos que pasar nuestra clave .pem generada por el KeyPair desde nuestro host al bastion y ver las IP'S  desde el panel de Instancias de EC2

```sh
scp -i path/to/keyPair.pem path/to/keyPair.pem ec2-user@bastion-public-ip:/home/ec2-user/private-key.pem
```

## Problemas Conocidos

- **Acceso al ALB desde el Bastión**:  Uno de los problemas es que al configurar el grupo de seguridad solo doy acceso al puerto 8080 a mi IP Públic, y por ese motivo desde el bastion no se puede realizar un curl a la URL del ALB. 
- 
- **Salida de las IP'S privadas**: He investigado para ver de que forma podremos ver esos datos desde cloudformation, pero no la manera es crear otro script aparte con python como boto3.