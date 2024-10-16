### 2024-10-16  10:21
---------------------

### Stage 1 -- Test on Vagrant VM
---------------------------------
    $ vagrant ssh
...
Last login: Wed Oct 16 08:19:07 2024 from 10.0.2.2

    $ cp -r /Vagrant/Pet-lab /home/vagrant/

    $ cd Pet-lab
    $ bash 1-pulling-images.sh
    ...
Successfully pulled eclipse-temurin:18-jre-jammy
All images pulled successfully.

    $ docker compose up -d
    ...
    $ vagrant@tfbuntu:~$ docker ps
CONTAINER ID   IMAGE                         COMMAND                  CREATED         STATUS                   PORTS                                                  NAMES
966edda74646   sample1-petclinic-petclinic   "java -Djava.securit…"   2 minutes ago   Up 2 minutes (healthy)   0.0.0.0:8080->8080/tcp, :::8080->8080/tcp              sample1-petclinic-petclinic-1
b386ce11aa34   hlebsur/mysql:8               "docker-entrypoint.s…"   2 minutes ago   Up About a minute        0.0.0.0:3306->3306/tcp, :::3306->3306/tcp, 33060/tcp   sample1-petclinic-mysqlserver-1

    $ curl localhost:8080
<!DOCTYPE html>
...

  <script src="/webjars/bootstrap/5.1.3/dist/js/bootstrap.bundle.min.js"></script>

</body>

</html>

    $ docker compose down



### Stage 2 -- DockerHub
------------------------
A bash script to do the next steps:
1. Create a docker image from the Dockerfile in the current directory;
2. Rename the created docker image with the tag 'azrubael/petlab:latest';
3. Push the image 'azrubael/petlab:latest' into docker hub repository.
4. Remove the local image 'azrubael/petlab:latest' and clean the docker cache;
5. Try to pull the image 'azrubael/petlab:latest'.

    $ bash 2-pushing-petlab.sh