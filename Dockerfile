# Use an official Ubuntu base image
FROM ubuntu:16.04

# Install necessary packages
RUN apt-get update && apt-get install -y \
    openssh-server \
    apache2 \
    mysql-server-5.6 \
    python-pip \
    python-dev \
    libmysqlclient-dev \
    software-properties-common \
    unoconv \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set up SSH
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd

# Clone the Django project repository
RUN git clone https://github.com/jasonshea/django-15.git /var/www/html/mysite

# Set the working directory to the project folder
WORKDIR /var/www/html/mysite

# Copy requirements.txt and install Python packages
COPY requirements.txt /var/www/html/mysite/
RUN pip install -r requirements.txt

# Install DCMTK 3.6.1
RUN wget -q http://dicom.offis.de/download/dcmtk/dcmtk361/dcmtk-3.6.1.tar.gz -O /tmp/dcmtk.tar.gz && \
    tar -xzf /tmp/dcmtk.tar.gz -C /tmp && \
    cd /tmp/dcmtk-3.6.1 && \
    ./configure && make && make install

# Install Abbyy OCR (manual download and installation step needed)
# Replace this section with the correct Abbyy OCR installation steps

# Copy the Apache configuration file
COPY ./mysite.conf /etc/apache2/sites-available/mysite.conf

# Enable the site and WSGI module
RUN a2ensite mysite.conf && a2enmod wsgi

# Expose ports
EXPOSE 22 80

# Command to start Apache
CMD service apache2 start && tail -f /var/log/apache2/error.log
