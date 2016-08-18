# Copyright 2015-2016 Gu Zhengxiong <rectigu@gmail.com>
#
# This file is part of Unish.
#
# Unish is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License
# as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Unish is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Unish.  If not, see <http://www.gnu.org/licenses/>.


# Saving keystrokes and memory of my mind.


unalias prepvm 2> /dev/null
prepvm() {
    local vm_name=${1}

    verbose VBoxManage sharedfolder add "${vm_name}" \
               --name 'shared' --hostpath "${HOME}/shared"
    verbose VBoxManage modifyvm "${vm_name}" --clipboard bidirectional
}


unalias vminfo 2> /dev/null
vminfo() {
    local vm_name=${1}

    verbose VBoxManage showvminfo "${vm_name}" | less
}


unalias vmrename 2> /dev/null
vmrename() {
    local vm_name=${1}
    local new_name=${2}

    verbose VBoxManage modifyvm "${vm_name}" --name "${new_name}"
}


unalias lsvms 2> /dev/null
lsvms() {
    verbose VBoxManage list vms
    verbose VBoxManage list runningvms
}
