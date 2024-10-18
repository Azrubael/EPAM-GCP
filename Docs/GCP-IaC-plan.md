### 2024-10-16    09:27
-----------------------

Work plan for the project of launching the web application infrastructure.
The application must be launched in the Google Cloud environment.
The "Infrastructure as a Code" principle must be implemented using Terraform and previously encountered technologies: web server, database, request queue processing service, scheduled instance group management.

1. Выбор веб-проекта, веб-сервера и базы данных (уточнить по ранее выполненным проектам).
    - Imran Vprofile
    - Docker-L6 Petclinic
2. Запуск веб-проекта и сервера с использованием терраформ и контейнеров локально на виртуальной машине.
3. Реализация Lift-and-Shift из On-Premise в Google Cloud.



### 2024-10-17  11:35
---------------------

По итогам вчерашнего дня стало ясно, что потребуется дополнительно автоматизировать создание в Google Cloud образа диска, шаблона виртуальной машины и Cloud Sorage. Только после этого следует создавать инфраструктуру.
В качестве базового проекта выбран Docker-L6 Petclinic просто потому, что он быстро запустился и был проверен пр помощи Docker Compose.


1. Извлечение из Docker образа 'azrubael/petlab:latest' артефакта '/app/spring-petclinic.jar' и сохранение его локально.

```bash
vagrant@tfbuntu:~$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

vagrant@tfbuntu:~$ docker images
REPOSITORY                    TAG            IMAGE ID       CREATED         SIZE
azrubael/petlab               latest         222b2725bdeb   29 hours ago    373MB

vagrant@tfbuntu:~$ docker run -it 222b2725bdeb bash
root@66cdc1e1fa12:/# cd app
root@66cdc1e1fa12:/app# ls
__cacert_entrypoint.sh  spring-petclinic.jar

root@66cdc1e1fa12:/app# 
exit
vagrant@tfbuntu:~$ docker ps -a
CONTAINER ID   IMAGE          COMMAND   CREATED         STATUS                      PORTS     NAMES
66cdc1e1fa12   222b2725bdeb   "bash"    3 minutes ago   Exited (0) 19 seconds ago             tender_bouman

vagrant@tfbuntu:~$ docker cp 66cdc1e1fa12:/app/spring-petclinic.jar .
Successfully copied 53.2MB to /home/vagrant/.
```


2. Подготовка Google Cloud Storage:
    a) создание Cloud Storage 'az-537298-petclinic', включение на нем поддержки версионирования;
    b) выгрузка в Cloud Storage 'az-537298-petclinic' артефакта 'gs://az-537298-petclinic/app/spring-petclinic.jar' и скрипта 'gs://az-537298-petclinic/app/__cacert_entrypoint.sh'.


3. Написание скриптов и запуск двух виртуальных машин на локальном сервере Xubuntu 22.04 инфраструктуры:
    a) создание и запуск VirtualBox VM 'mysqlserver' на базе Ubuntu 20.04:
        - уточнение необходимой версии MySQL
  `docker exec -it mysqlserver-petclinic mysql --version`
### OR 
```bash
vagrant@tfbuntu:~/Pet-lab$ docker ps
CONTAINER ID   IMAGE                    COMMAND                  CREATED              STATUS                        PORTS                                                  NAMES
a9e5b280b732   azrubael/petlab:latest   "java -Djava.securit…"   About a minute ago   Up About a minute (healthy)   0.0.0.0:8080->8080/tcp, :::8080->8080/tcp              pet-lab-petclinic-1
3d8c7c192b71   hlebsur/mysql:8          "docker-entrypoint.s…"   About a minute ago   Up 46 seconds                 0.0.0.0:3306->3306/tcp, :::3306->3306/tcp, 33060/tcp   pet-lab-mysqlserver-1
vagrant@tfbuntu:~/Pet-lab$ docker exec -it 3d8c7c192b71 mysql --version
mysql  Ver 8.0.31 for Linux on x86_64 (MySQL Community Server - GPL)
vagrant@tfbuntu:~/Pet-lab$ apt-cache policy mysql-server
mysql-server:
  Installed: (none)
  Candidate: 8.0.39-0ubuntu0.20.04.1
  Version table:
     8.0.39-0ubuntu0.20.04.1 500
        500 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 Packages
        500 http://security.ubuntu.com/ubuntu focal-security/main amd64 Packages
     8.0.19-0ubuntu5 500
        500 http://archive.ubuntu.com/ubuntu focal/main amd64 Packages
```
        - написание скрипта Баш для установки MySQL и ее конфигурации;
        - запуск виртуальной машины и проверка работы MySQL.

    b) создание и запуск VirtualBox VM 'petclinic' на базе Ubuntu 20.04:
        - установка JRE 18;
        - загрузка на нее артефакта и скрипта из Cloud Storage;
        - загрузка на нее скриптов start_app.sh и petclinic.service;
        - создание службы '/etc/systemd/system/petclinic.service';
        - активация и запуск службы; 


4. Создание в среде Google Cloud двух Compute Instance на базе 'g1-small' и Debian 11 с применением скриптов, разработанных для п.3.


5. Тестирование п.4


6. Разработка скрипта для создания в Google Cloud образа диска и шаблона для виртуальной машины 'petclinic'.


7. Запуск веб-проекта с использованием терраформ в среде Google Cloud.




### 2024-10-18  11:20
---------------------

##### Команды, использованные при отладке по п.4.b:
vagrant@petclinic:~$ sudo journalctl -u petclinic.service -f

vagrant@petclinic:~$ echo $JAVA_HOME
vagrant@petclinic:~$ readlink -f $(which java)
/usr/lib/jvm/java-17-openjdk-amd64/bin/java

vagrant@petclinic:~$ java -XshowSettings:properties -version
#### максимально подробная информация
...

vagrant@petclinic:~$ update-alternatives --config java

