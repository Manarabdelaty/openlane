# Copyright 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM swift:5.3.3-centos7 as build

# Install Basics
RUN yum groupinstall -y "Development Tools"

# Swift requires 2.x verison of git
RUN yum remove git -y
RUN yum install https://repo.ius.io/ius-release-el7.rpm -y
RUN yum install git224 -y

# Install Python
RUN yum install -y python36u python36u-pip python36u-tkinter python36u-devel.x86_64

# Install jinja
RUN python3.6 -m pip install --upgrade pip
RUN python3.6 -m pip install jinja2

# Install pyverilog
RUN python3.6 -m pip install https://github.com/PyHDI/Pyverilog/archive/develop.zip

# Install IcarusVerilog 10.2+
RUN yum install -y iverilog

# Install Swift
# RUN mkdir -p /build/share
# WORKDIR /build/share
# RUN curl -sL https://swift.org/builds/swift-5.3.2-release/centos7/swift-5.3.2-RELEASE/swift-5.3.2-RELEASE-centos7.tar.gz | tar -xzf -
# RUN yum install -y binutils gcc glibc-static libbsd-devel libedit libedit-devel \
#     libicu-devel libstdc++-static pkgconfig  python2 sqlite

# __block conflicts with clang's __block qualifier
# RUN sed -i -e 's/\*__block/\*__libc_block/g' /usr/include/unistd.h

ENV PATH=/build/share/swift-5.3.2-RELEASE-centos7/usr/bin:"${PATH}"
ENV PYVERILOG_IVERILOG="/build/bin/iverilog"
ENV FAULT_IVERILOG="/build/bin/iverilog"
ENV FAULT_VVP="/build/bin/vvp"
ENV FAULT_YOSYS="yosys"
ENV FAULT_IVL_BASE="/build/lib/ivl"
ENV PYTHON_LIBRARY="/usr/lib64/libpython3.6m.so.1.0"

# Install Fault
RUN mkdir -p /share/Fault
WORKDIR /share/Fault
RUN git clone https://github.com/Cloud-V/Fault.git
WORKDIR Fault

# Link swift libs statically to be able to export the binary
# https://bugs.swift.org/browse/SR-648
RUN yum install -y libxml2-devel
RUN FAULT_VVP=$FAULT_VVP \ 
    FAULT_IVL_BASE=$FAULT_IVL_BASE \
    FAULT_IVERILOG=$FAULT_IVERILOG \
    PYVERILOG_IVERILOG=$PYVERILOG_IVERILOG \
    FAULT_YOSYS=$FAULT_YOSYS \
    PYTHON_LIBRARY=$PYTHON_LIBRARY \
    swift build -Xswiftc -static-stdlib

RUN mkdir -p /build/bin/ \ &&\
    cp .build/debug/Fault /build/bin/fault  && \
    cp -r Tech/ /build/bin/Tech &&\
    cp /usr/bin/iverilog /build/bin/iverilog &&\
    cp /usr/bin/vvp /build/bin/vvp

RUN mkdir -p /build/lib \ &&\    
    cp -r /usr/lib64/ivl /build/lib/ivl

# For Pyverilog:
#RUN ln -s $FAULT_IVL_BASE "/usr/local/lib/ivl" 

RUN mkdir -p /build/version
RUN date +"Build Timestamp: %Y-%m-%d_%H-%M-%S" > /build/version/fault.version
RUN git rev-parse HEAD >> /build/version/fault.version
RUN tar -czf /build.tar.gz /build
