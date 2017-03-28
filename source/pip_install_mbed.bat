:: Copyright (c) 2015 ARM Limited. All rights reserved.
::
:: SPDX-License-Identifier: Apache-2.0
::
:: Licensed under the Apache License, Version 2.0 (the License); you may
:: not use this file except in compliance with the License.
:: You may obtain a copy of the License at
::
:: http://www.apache.org/licenses/LICENSE-2.0
::
:: Unless required by applicable law or agreed to in writing, software
:: distributed under the License is distributed on an AS IS BASIS, WITHOUT
:: WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
:: See the License for the specific language governing permissions and
:: limitations under the License.
::
:: Set python\scripts variable because the environment hasnt been updated since python install.
set MBED_PATH="%1;%1\gcc\bin;%1\cmake-3.4.0-rc3-win32-x86\bin;%2;%2Scripts;%2Tools\Scripts"
setx MBED_PATH %MBED_PATH%
set PATH=%MBED_PATH%;%PATH%

:: spaces -> ^spaces for string safety
set mbedlocation=%1
set mbedlocation=%mbedlocation: =^ %
setx MBED_INSTALL_LOCATION %mbedlocation%

:: install virtual environment
pip install virtualenv 

:: create virtual environment in \mbed-cli\workspace to sandbox mbed-cli from system.
cd %1
virtualenv --system-site-packages workspace
cmd /K "%1\workspace\Scripts\activate & pip install -I -U mbed-cli & exit"
