# Mittel Infra

Infraestructura de la plataforma de blogging [Mittel](https://mittel.unilife.lat) declarada en Terraform.

## Uso

La Infraestructura requiere las siguientes variables:

- `vpc_id`: ID de la VPC donde provisionar la infraestructura.
- `subnet_a_id`, `subnet_b_id`: IDs de dos subnets (preferiblemente en zonas de
  disponibilidad distintas) para las MVs de producción.
- `databases_vm_private_ip`: Una dirección IP para usar como IP privada fija de
  la MV de bases de datos.
- `ec2_key_name`: Nombre de la llave a usar como acceso para las MVs.
- `data_analysis_bucket_name`: Nombre del bucket a crear para análisis de datos.
- `domain`: Dominio donde desplegar los microservicios y el frontend (por
- ejemplo, `"unilife.lat"`).
- `frontend_repo`: URL del repositorio del frontend.
- `github_token`: Un token de GitHub con acceso al repositorio del frontend.

Establecer estas variables en un archivo `terraform.tfvars` y ejecutar los
siguientes comandos debería aprovisionar la infraestructura:

```bash
terraform init
terraform apply
```

> [!NOTE]
> Es necesario completar manualmente en ACM la verificación del certificado SSL para el
> dominio establecido en las variables.
