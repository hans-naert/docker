FROM ubuntu
RUN apt-get -y update
RUN apt-get -y install bc
ADD ./script.sh ./
RUN ./script.sh > ./output.txt
CMD cat ./output.txt