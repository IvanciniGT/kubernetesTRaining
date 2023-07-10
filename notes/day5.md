kubectl describe pod my-first-pod -n my-namespace

kubectl get pod my-first-pod -n my-namespace  -o wide

kubectl create namespace my-second-namespace
> This creates a new namespaces... We also can do that thru YAML file... and kubectl apply -f...
> Always file.... We always want to be able to tack whats going on... 
> We are never going to execute this king of commands... no command at all.
> We want all the production environment inside a git repository.
> An then a program (Jenkins, ansible...) who calls kubernetes and supplies those files

# Can I open additional processes inside a container in kubernetes?


kubectl exec my-first-pod -n my-namespace -c container1 -- ls /
kubectl exec -it my-first-pod -n my-namespace -c container1 -- bash


    Client
        |
    ----------------------- Kubernetes cluster -----------------------
    |                                                           |
    my-namespace                                        my-second-namespace
    |                                                           |
    my-first-pod - 10.10.51.214                            my-first-pod - 10.10.51.217
         |                                                           |
         container1                                              container1
         |                                                           |
         nginx                                                     nginx
         bash*
          |
          curl localhost
          curl 10.10.51.214
          curl 10.10.51.217
          curl 10.96.224.30:81
          curl nginx-service:81
          curl nginx-service.my-namespace:81
          curl nginx-service.my-second-namespace:81

    nginx-service - 10.96.224.30                            nginx-service -  10.111.122.134 
        :81 -> 10.10.51.214:80

---

# Container images:

6.2.2-apache, 6.2-apache, 6-apache, apache, 6.2.2, 6.2, 6, latest, 6.2.2-php8.0-apache, 6.2-php8.0-apache, 6-php8.0-apache, php8.0-apache, 6.2.2-php8.0, 6.2-php8.0, 6-php8.0, php8.0
6.2.2-fpm, 6.2-fpm, 6-fpm, fpm, 6.2.2-php8.0-fpm, 6.2-php8.0-fpm, 6-php8.0-fpm, php8.0-fpm
6.2.2-fpm-alpine, 6.2-fpm-alpine, 6-fpm-alpine, fpm-alpine, 6.2.2-php8.0-fpm-alpine, 6.2-php8.0-fpm-alpine, 6-php8.0-fpm-alpine, php8.0-fpm-alpine
6.2.2-php8.1-apache, 6.2-php8.1-apache, 6-php8.1-apache, php8.1-apache, 6.2.2-php8.1, 6.2-php8.1, 6-php8.1, php8.1
6.2.2-php8.1-fpm, 6.2-php8.1-fpm, 6-php8.1-fpm, php8.1-fpm
6.2.2-php8.1-fpm-alpine, 6.2-php8.1-fpm-alpine, 6-php8.1-fpm-alpine, php8.1-fpm-alpine
6.2.2-php8.2-apache, 6.2-php8.2-apache, 6-php8.2-apache, php8.2-apache, 6.2.2-php8.2, 6.2-php8.2, 6-php8.2, php8.2
6.2.2-php8.2-fpm, 6.2-php8.2-fpm, 6-php8.2-fpm, php8.2-fpm
6.2.2-php8.2-fpm-alpine, 6.2-php8.2-fpm-alpine, 6-php8.2-fpm-alpine, php8.2-fpm-alpine
cli-2.8.1, cli-2.8, cli-2, cli, cli-2.8.1-php8.0, cli-2.8-php8.0, cli-2-php8.0, cli-php8.0
cli-2.8.1-php8.1, cli-2.8-php8.1, cli-2-php8.1, cli-php8.1
cli-2.8.1-php8.2, cli-2.8-php8.2, cli-2-php8.2, cli-php8.2
beta-6.3-beta3-apache, beta-6.3-apache, beta-6-apache, beta-apache, beta-6.3-beta3, beta-6.3, beta-6, beta, beta-6.3-beta3-php8.0-apache, beta-6.3-php8.0-apache, beta-6-php8.0-apache, beta-php8.0-apache, beta-6.3-beta3-php8.0, beta-6.3-php8.0, beta-6-


Software version: Wordpress     6.2.1       6.3.0         4.1.0
-apache
-fpm    (don't contain a webserver)
-alpine  That means that this image is based on the alpine image


Wordpress is a web app developed in php
- We need a web server (with phh support) to execute that app: Apache, nginx
                - database URL
                - database Name
                - databse User
                - database password
                                 WORDPRESS_DB_HOST=...
                                 WORDPRESS_DB_USER=...
                                 WORDPRESS_DB_PASSWORD=...
                                 WORDPRESS_DB_NAME=...

- We need a database: MySQL or "MariaDB"
        MARIADB_ROOT_PASSWORD
        MARIADB_DATABASE
        MARIADB_USER 
        MARIADB_PASSWORD

Pod: Set of containers that:
- are deployed to the same host
    - the may share local volumes.
- are going to scale together --------> 
- share network configuration
---

6.2.2       That exact version                                                          *** I 
6.2         The latest 6.2 (Could be 6.2.0.... an leter on 6.2.1)                       *** III
6           The latest 6   (could be 6.1.4 nowadays... maybe tomorrow: 6.9.2)
latest      The latest image... that could be 6.3.4 today... maybe tomorrow 8.9.0

What sould we use in a productionn environment? 

6.2.1
            When do we increment that
6 Major         Breaking changes
2 Minor         New features
                New Deprecateds
1 Patch         When we fix a bug
