# Architecture — TP05 Nextcloud sur AWS

## Vue d'ensemble

L'infrastructure est déployée sur AWS à l'aide de Terraform selon une architecture modulaire. Chaque composant est isolé dans un module dédié afin de faciliter le développement collaboratif, la maintenance et l'intégration continue.

Les principaux modules sont :

* **Security** : gestion du chiffrement, des permissions IAM, des secrets et des Security Groups.
* **Data** : gestion du stockage des fichiers Nextcloud et de la base de données PostgreSQL.
* **Compute** : exécution de l'application Nextcloud sur une instance EC2 derrière un Application Load Balancer.

---

## Diagramme d'architecture

```mermaid
flowchart TB
    subgraph security["Module Security"]
        kms["AWS KMS CMK<br/>Chiffrement centralisé<br/>Rotation activée"]
        secrets["AWS Secrets Manager<br/>Mot de passe DB<br/>Mot de passe admin Nextcloud"]
        iam["IAM Role + Instance Profile<br/>Accès EC2 vers S3, KMS,<br/>Secrets Manager, CloudWatch, SSM"]

        sg_alb["Security Group ALB<br/>Entrée HTTP/HTTPS"]
        sg_app["Security Group App<br/>Trafic autorisé depuis ALB"]
        sg_db["Security Group DB<br/>PostgreSQL 5432 depuis App"]
    end

    subgraph data["Module Data"]
        rds[("Amazon RDS PostgreSQL 16<br/>Multi-AZ<br/>Chiffré avec KMS")]
        s3_primary["S3 Primary Storage<br/>Fichiers Nextcloud<br/>Versioning + SSE-KMS"]
        s3_logs["S3 Logs ALB<br/>Logs d'accès<br/>Lifecycle policy"]
    end

    subgraph compute["Module Compute"]
        ec2["EC2 Nextcloud<br/>Docker<br/>Utilise IAM Role"]
        alb["Application Load Balancer<br/>HTTPS 443"]
    end

    alb -->|Trafic HTTP vers App| ec2
    ec2 -->|Lecture secrets| secrets
    ec2 -->|Accès fichiers| s3_primary
    ec2 -->|Connexion PostgreSQL 5432| rds

    kms -.chiffre.-> secrets
    kms -.chiffre.-> rds
    kms -.chiffre.-> s3_primary
    kms -.chiffre.-> s3_logs

    iam -.attaché à.-> ec2

    sg_alb -.protège.-> alb
    sg_app -.protège.-> ec2
    sg_db -.protège.-> rds

    s3_logs -.reçoit logs.-> alb
```

---

## Description des composants

### Module Security

Le module Security constitue le socle de sécurité de l'infrastructure.

Il fournit :

* Une clé AWS KMS avec rotation automatique pour le chiffrement des données.
* Les secrets applicatifs stockés dans AWS Secrets Manager.
* Les rôles IAM et Instance Profiles nécessaires aux instances EC2.
* Les Security Groups protégeant l'ALB, les instances applicatives et la base de données.

### Module Data

Le module Data assure la gestion du stockage et de la persistance des données.

Il comprend :

* Une base de données Amazon RDS PostgreSQL 16 en mode Multi-AZ.
* Un bucket S3 principal pour les fichiers Nextcloud.
* Un bucket S3 dédié aux logs de l'Application Load Balancer.
* Le chiffrement SSE-KMS et les politiques de cycle de vie des données.

### Module Compute

Le module Compute héberge l'application Nextcloud.

Il comprend :

* Un Application Load Balancer accessible en HTTPS.
* Une instance EC2 exécutant Nextcloud dans Docker.
* L'utilisation du rôle IAM fourni par le module Security.
* L'accès sécurisé aux ressources S3, Secrets Manager et RDS.

---

## Flux principaux

1. L'utilisateur accède à Nextcloud via l'Application Load Balancer en HTTPS.
2. L'ALB redirige les requêtes vers l'instance EC2 hébergeant Nextcloud.
3. L'instance récupère ses secrets depuis AWS Secrets Manager.
4. Les fichiers utilisateurs sont stockés dans le bucket S3 principal.
5. Les métadonnées sont enregistrées dans PostgreSQL sur Amazon RDS.
6. Les logs de l'ALB sont envoyés dans le bucket S3 dédié.
7. Toutes les données sensibles sont chiffrées grâce à AWS KMS.

---

## Sécurité

Les mesures de sécurité mises en œuvre sont :

* Chiffrement KMS des données au repos.
* Gestion centralisée des secrets avec AWS Secrets Manager.
* Séparation des flux réseau via Security Groups.
* Principe du moindre privilège avec IAM.
* Blocage de l'accès public sur les buckets S3.
* Base de données accessible uniquement depuis l'application.
