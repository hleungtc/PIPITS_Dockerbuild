FROM ubuntu:trusty

MAINTAINER Hilary Leung <leung_h@kids.wustl.edu>

LABEL \
version = "Revision 2" \
description = "16s microbiome analyses with fungal pipeline - for gsc"

RUN \
apt-get update && \
apt-get install -y \
build-essential \
make \
curl \
git \
zlib1g-dev \
autoconf \
cmake \
wget \
unzip \
libnss-sss \
libreadline-dev

RUN mkdir /home/tools/

WORKDIR /home/tools/

RUN apt-get update && apt-get install -y \
    software-properties-common
RUN add-apt-repository universe
RUN apt-get update && apt-get install -y \
    apache2 \
    libapache2-mod-php5 \
    php5 \
    php5-mcrypt \
    php5-mysql \
    python3.4 \ 
    python3-pip

RUN \
cd /home/tools/ && \
wget https://bootstrap.pypa.io/get-pip.py && \
python3 get-pip.py && \
pip install numpy && \
pip install biom-format

RUN \
curl http://ccb.jhu.edu/software/fqtrim/dl/fqtrim-0.9.4.tar.gz > /home/tools/fqtrim-0.9.4.tar.gz && \
tar xvfz /home/tools/fqtrim-0.9.4.tar.gz -C /home/tools && \
cd /home/tools/fqtrim-0.9.4 && \
make release && \
cp fqtrim /usr/local/bin

RUN \
git clone https://github.com/lh3/seqtk.git /home/tools/seqtk && \
cd /home/tools/seqtk && \
make && \
cp seqtk /usr/local/bin

RUN \
wget http://github.com/bbuchfink/diamond/archive/v0.8.36.tar.gz && \
tar xvfz /home/tools/v0.8.36.tar.gz -C /home/tools && \
cd /home/tools/diamond-0.8.36 && \
mkdir bin && \
cd bin && \
cmake .. && \
make install

RUN \ 
cd /home/tools/ && \ 
wget https://github.com/mothur/mothur/releases/download/v1.39.5/Mothur.linux_64.zip && \
unzip Mothur.linux_64.zip && \
sudo mv /home/tools/mothur/ /usr/local/bin/
#cd /home/tools/mothur/ && \
#ln -s /home/tools/mothur/mothur /usr/bin/mothur

RUN \
echo 'deb http://nebc.nerc.ac.uk/bio-linux/ unstable bio-linux' >> /etc/apt/sources.list && \
echo 'deb http://ppa.launchpad.net/nebc/bio-linux/ubuntu trusty main' /etc/apt/sources.list && \
echo 'deb-src http://ppa.launchpad.net/nebc/bio-linux/ubuntu trusty main' /etc/apt/sources.list

RUN \
sudo apt-get update && \
sudo apt-get install bio-linux-keyring -y --force-yes && \
sudo apt-get install fastx-toolkit hmmer -y --force-yes

RUN \
cd /home/tools/ && \
wget https://github.com/hsgweon/pipits/releases/download/1.4.1/pipits-1.4.1.tar.gz && \
tar xvfz pipits-1.4.1.tar.gz && \
cd pipits-1.4.1 && \
python setup.py clean --all && \
python setup.py install --prefix=/home/tools/pipits

RUN \
cd /home/tools/ && \
wget http://microbiology.se/sw/ITSx_1.0.11.tar.gz && \
tar xvfz ITSx_1.0.11.tar.gz && \
ln -s /home/tools/pipits/ITSx_1.0.11/ITSx /usr/bin/ITSx && \
ln -s /home/tools/pipits/ITSx_1.0.11/ITSx_db /usr/bin/ITSx_db

RUN \
cd /home/tools/pipits/ && \
wget http://sco.h-its.org/exelixis/web/software/pear/files/pear-0.9.10-bin-64.tar.gz && \
tar xvfz pear-0.9.10-bin-64.tar.gz && \
ln -s /home/tools/pipits/pear-0.9.10-bin-64/pear-0.9.10-bin-64 /usr/local/bin/pear

RUN \
cd /home/tools/pipits && \
wget https://sourceforge.net/projects/rdp-classifier/files/rdp-classifier/rdp_classifier_2.12.zip && \
unzip rdp_classifier_2.12.zip && \
ln -s rdp_classifier_2.12/dist/classifier.jar ./classifier.jar

RUN \
mkdir -p /home/tools/pipits/refdb && \
cd /home/tools/pipits/refdb && \
wget http://sourceforge.net/projects/pipits/files/UNITE_retrained_22.08.2016.tar.gz && \
tar xvfz UNITE_retrained_22.08.2016.tar.gz

RUN \
mkdir -p /home/tools/pipits/refdb && \
cd /home/tools/pipits/refdb && \
wget https://unite.ut.ee/sh_files/uchime_reference_dataset_01.01.2016.zip && \
unzip uchime_reference_dataset_01.01.2016.zip

RUN \
mkdir -p /home/tools/pipits/refdb && \
cd /home/tools/pipits/refdb && \
wget https://sourceforge.net/projects/pipits/files/warcup_retrained_V2.tar.gz && \
tar xvfz warcup_retrained_V2.tar.gz

RUN \
# cd /home/tools/pipits/ITSx_1.0.11/ITSx_db/HMMs && \
cd /home/tools/ITSx_1.0.11/ITSx_db/HMMs && \
rm -f *.hmm.* && \
# echo *.hmm | xargs -n1 hmmpress
for i in *hmm; do hmmpress $i; done

RUN \
rm /home/tools/*zip && \
rm /home/tools/*tar.gz


ENV PATH /home/tools/pipits:/home/tools/vsearch-2.1.2-linux-x86_64/bin:/home/tools/ITSx_1.0.11:/usr/local/bin/mothur:/usr/local/bin/mothur/blast/bin:/home/tools/pipits-1.4.1/bin:/home/tools/pipits-1.4.1:/home/tools/fastx/bin:$PATH
ENV PYTHONPATH /home/tools/pipits/lib/python2.7/site-packages:$PYTHONPATH
ENV PIPITS_UNITE_REFERENCE_DATA_CHIMERA /home/tools/pipits/refdb/uchime_reference_dataset_01.01.2016/uchime_reference_dataset_01.01.2016.fasta
ENV PIPITS_UNITE_RETRAINED_DIR /home/tools/pipits/refdb/UNITE_retrained
ENV PIPITS_WARCUP_RETRAINED_DIR /home/tools/pipits/refdb/warcup_retrained_V2
ENV PIPITS_RDP_CLASSIFIER_JAR /home/tools/pipits/classifier.jar
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8


RUN sudo apt-get install vim -y --force-yes
RUN apt-get install default-jre -y

RUN \
cd /home/tools/ && \
python2.7 get-pip.py && \
pip2.7 install numpy

RUN sed -i 's/python$/python3/g' /home/tools/pipits-1.4.1/bin/pipits_getreadpairslist

RUN \
sudo su && \
chmod -R 777 /home/tools/

# --END--
