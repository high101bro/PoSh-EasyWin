#!/usr/bin/env python2
# Evil Inject Finder
# By Phillip Smith
# https://github.com/psmitty7373/eif
#
# Based on code by Nikos Laleas
# https://github.com/nccgroup/memaddressanalysis
# Based on ideas presented by aking1012
# https://github.com/aking1012/dc20

import subprocess
import platform
import argparse
import os
import datetime
import time
import textwrap
import sys
import hashlib
import win32con
import win32file
import win32security
from ctypes import *
from ctypes.wintypes import *

args = {}
processes = {}
hash_db = ""

BUF_SIZE = 65536
INVALID_HANDLE_VALUE = c_void_p(-1).value
TH32CS_SNAPHEAPLIST = 0x00000001
TH32CS_SNAPMODULE = 0x00000008
TH32CS_SNAPMODULE32 = 0x00000010
TH32CS_SNAPPROCESS = 0x00000002
TH32CS_SNAPTHREAD = 0x00000004
TH32CS_SNAPALL = TH32CS_SNAPHEAPLIST | TH32CS_SNAPMODULE | TH32CS_SNAPPROCESS | TH32CS_SNAPTHREAD
MEMORY_STATES = {0x1000: "MEM_COMMIT", 0x10000: "MEM_FREE", 0x2000: "MEM_RESERVE"}
MEMORY_PROTECTIONS = {0x10: "EXECUTE", 0x20: "EXECUTE_READ", 0x40: "EXECUTE_READWRITE", 0x80: "EXECUTE_WRITECOPY", 0x01: "NOACCESS", 0x04: "READWRITE", 0x08: "WRITECOPY", 0x02: "READONLY"}
MEMORY_TYPES = {0x1000000: "MEM_IMAGE", 0x40000: "MEM_MAPPED", 0x20000: "MEM_PRIVATE"}
DOS_STRING = 'This program cannot be run in DOS mode.'

class Access:
    DELETE      = 0x00010000
    READ_CONTROL= 0x00020000
    SYNCHRONIZE = 0x00100000
    WRITE_DAC   = 0x00040000
    WRITE_OWNER = 0x00080000
    PROCESS_VM_WRITE = 0x0020
    PROCESS_VM_READ = 0x0010
    PROCESS_VM_OPERATION = 0x0008
    PROCESS_TERMINATE = 0x0001
    PROCESS_SUSPEND_RESUME = 0x0800
    PROCESS_SET_QUOTA = 0x0100
    PROCESS_SET_INFORMATION = 0x0200
    PROCESS_QUERY_LIMITED_INFORMATION = 0x1000
    PROCESS_QUERY_INFORMATION = 0x0400
    PROCESS_DUP_HANDLE = 0x0040
    PROCESS_CREATE_THREAD = 0x0002
    PROCESS_CREATE_PROCESS = 0x0080
    PROCESS_ALL_ACCESS = 0x1f0fff

class LUID(Structure):
    _fields_ = [
        ("LowPart", DWORD),
        ("HighPart", LONG)
    ]
    def __eq__(self, other):
        return (self.HighPart == other.HighPart and self.LowPart == other.LowPart)
    def __ne__(self, other):
        return not (self==other)
 
class LUID_AND_ATTRIBUTES(Structure):
    _fields_ = [
        ("Luid",        LUID),
        ("Attributes",  DWORD)
    ]
    def is_enabled(self):
        return bool(self.Attributes & SE_PRIVILEGE_ENABLED)
    def enable(self):
        self.Attributes |= SE_PRIVILEGE_ENABLED
    def get_name(self):
        size = wintypes.DWORD(10240)
        buf = ctypes.create_unicode_buffer(size.value)
        res = LookupPrivilegeName(None, self.Luid, buf, size)
        if res == 0: raise RuntimeError
        return buf[:size.value]
    def __str__(self):
        res = self.get_name()
        if self.is_enabled(): res += ' (enabled)'
        return res
        
class TOKEN_PRIVILEGES(Structure):
    _fields_ = [
        ("PrivilegeCount", DWORD),
        ("Privileges", LUID_AND_ATTRIBUTES)
    ]

class MEMORY_BASIC_INFORMATION32 (Structure):
    _fields_ = [
        ("BaseAddress", c_void_p),
        ("AllocationBase", c_void_p),
        ("AllocationProtect", DWORD),
        ("RegionSize", c_size_t),
        ("State", DWORD),
        ("Protect", DWORD),
        ("Type", DWORD)
    ]

class MEMORY_BASIC_INFORMATION64 (Structure):
    _fields_ = [
        ("BaseAddress", c_ulonglong),
        ("AllocationBase", c_ulonglong),
        ("AllocationProtect", DWORD),
        ("__alignment1", DWORD),
        ("RegionSize", c_ulonglong),
        ("State", DWORD),
        ("Protect", DWORD),
        ("Type", DWORD),
        ("__alignment2", DWORD)
    ]

class MODULEENTRY32(Structure):
    _fields_ = [
        ("dwSize", DWORD),
        ("th32ModuleID", DWORD),
        ("th32ProcessID", DWORD),
        ("GlblcntUsage", DWORD),
        ("ProccntUsage", DWORD),
        ("modBaseAddr", POINTER(BYTE)),
        ("modBaseSize", DWORD),
        ("hModule", HMODULE),
        ("szModule", c_char * 256),
        ("szExePath", c_char * 260)
    ]
        
class PROCESSENTRY(Structure):
    _fields_ = [
        ("dwSize", DWORD),
        ("cntUsage", DWORD),
        ("th32ProcessID", DWORD),
        ("th32DefaultHeapID", POINTER(ULONG)),
        ("th32ModuleID", DWORD),
        ("cntThreads", DWORD),
        ("th32ParentProcessID", DWORD),
        ("pcPriClassBase", LONG),
        ("dwFlags", DWORD),
        ("szExeFile", c_char * 260)
    ]

class SYSTEM_INFO(Structure):
    _fields_ = [
        ("wProcessorArchitecture", WORD),
        ("wReserved", WORD),
        ("dwPageSize", DWORD),
        ("lpMinimumApplicationAddress", LPVOID),
        ("lpMaximumApplicationAddress", LPVOID),
        ("dwActiveProcessorMask", DWORD),
        ("dwNumberOfProcessors", DWORD),
        ("dwProcessorType", DWORD),
        ("dwAllocationGranularity", DWORD),
        ("wProcessorLevel", WORD),
        ("wProcessorRevision", WORD)
    ]

class MEMORY_BASIC_INFORMATION:
    def __init__ (self, MBI):
        self.MBI = MBI
        self.set_attributes()
    def set_attributes(self):
        self.BaseAddress = self.MBI.BaseAddress
        self.AllocationBase = self.MBI.AllocationBase
        self.AllocationProtect = MEMORY_PROTECTIONS.get(self.MBI.AllocationProtect, self.MBI.AllocationProtect)
        self.RegionSize = self.MBI.RegionSize
        self.State = MEMORY_STATES.get(self.MBI.State, self.MBI.State)
        self.Protect = MEMORY_PROTECTIONS.get(self.MBI.Protect, self.MBI.Protect)
        self.Type = MEMORY_TYPES.get(self.MBI.Type, self.MBI.Type)
        self.ProtectBits = self.MBI.Protect
        
def test():
    h = HANDLE(INVALID_HANDLE_VALUE)
    print h
    h = win32file.CreateFile(
        "\\??\\kp",
        win32con.GENERIC_READ, # | win32con.GENERIC_WRITE,
        0,#win32con.FILE_SHARE_WRITE | win32con.FILE_SHARE_DELETE | win32con.FILE_SHARE_READ,
        None,
        win32con.OPEN_EXISTING,
        0,#win32con.FILE_ATTRIBUTE_NORMAL,# | win32con.FILE_FLAG_OVERLAPPED,
        None)
    printt(WinError(GetLastError())[1], True)
    print dir(h)
    res = windll.ntdll.ZwDeviceIoControlFile(h,
        0,
        0,
        0,
        byref(c_ulong(8)),
        0,
        0,
        0,
        0,
        0
    )
    print res
    printt(WinError(GetLastError())[1], True)
    sys.exit(1)
    
def main():
    global args
    args = parse_args()
    if not windll.Shell32.IsUserAnAdmin():
        printt('This program must be run with administrative privileges.', True)
        sys.exit(1)
    else:
       enable_privilege("SeDebugPrivilege")
    print "+"+58*"-"+"+"
    print "Evil Inject Finder"
    print "Originally by: Nikos Laleas"
    print "Modified by: Phillip Smith"
    print "+"+58*"-"+"+\n"
    pid = args.p
    if not pid:
        pid = 0
    if args.o:
        try:
            args.of = open(args.o,'w')
            print 'Sending output to: ' + args.o
        except:
            args.o = None
            printt('Unable to open output file... writing to STDOUT\n',True)
    if args.s:
        try:
            args.sigs = open(args.s,'r').readlines()
        except:
            printt('Unable to open signatures file.\n',True)
            sys.exit(1)
    permissions = args.i
    min_address = int(args.min, 16)
    max_address = int(args.max, 16)      
    si = SYSTEM_INFO()
    psi = byref(si)
    windll.kernel32.GetSystemInfo(psi)
    printt('Starting memory analysis...\n')
    scan_processes(pid)
    header = 147*"-"+"\n"
    header += '{:>14} | {:<17} | {:>10} | {:<36} | {:<3} | {:<3} | {:<4} | {:>4} | {:<32}'.format("Address", "Permissions", "Size", 'File', 'MZ', 'DOS', 'NOPS', 'Sigs', 'MD5 Sum')
    header += "\n"+147*"-"+'\n'
    for pid in sorted(processes.iterkeys()):
        args.p = pid
        if pid == 0:
            continue
        processes[args.p]['pages'] = {}
        processes[args.p]['modules'] = {}
        printt('Analyzing pid: ' + str(pid) + ' : ' + processes[pid]['exe'] + '\n')
        scan_modules(pid)
        arch, type = platform.architecture()
        hProc = None
        processes[args.p]['protected'] = 'No'
        if arch == '32bit':
            hProc = windll.kernel32.OpenProcess(Access.PROCESS_QUERY_INFORMATION | Access.PROCESS_VM_READ, 0, int(pid))
        else:
            hProc = windll.kernel32.OpenProcess(Access.PROCESS_QUERY_LIMITED_INFORMATION | Access.PROCESS_VM_READ, 0, int(pid))
        if not hProc:
            processes[args.p]['protected'] = 'YES'
            hProc = windll.kernel32.OpenProcess(Access.PROCESS_QUERY_LIMITED_INFORMATION, 0, int(pid))
            if not hProc:
                printt('Unable to open PID: ' + str(args.p) + ' : ' + processes[args.p]['exe'] + ' : ' + WinError(GetLastError())[1] + '\n',True)
                continue
        if arch == '64bit':
            success, process_is32 = validate_process(hProc)
            if not success:
                windll.kernel32.CloseHandle(hProc)
                continue
        else:
            process_is32 = c_bool(True)
        if process_is32:
            processes[args.p]['arch'] = '32bit'
        else:
            processes[args.p]['arch'] = '64bit'
        if arch == "32bit" and not process_is32:
            printt('Error: Can\'t analyze a 64bit processes from a 32bit Python.\n', True)
            continue     
        base_address = si.lpMinimumApplicationAddress
        if max_address is 0:
            if process_is32 and si.lpMaximumApplicationAddress > 0xFFFFFFFF:
                max_address = 0xFFFEFFFF
            else:
                max_address = si.lpMaximumApplicationAddress
        page_address = base_address
        while page_address < max_address:
            next_page = scan_page(hProc, page_address, process_is32, min_address, permissions)
            if next_page < 0:
                break
            page_address = next_page
        windll.kernel32.CloseHandle(hProc)
        if len(processes[args.p]['pages']) > 0:
            printt('Results for PID: ' + str(args.p) + ' : ' + processes[args.p]['exe'] + ' (' + processes[args.p]['arch'] + ') ' + 'Protected?: ' + processes[args.p]['protected'] + '\n', True)
            printnt(header,True)
            for i in sorted(processes[args.p]['pages'].iterkeys()):
                printnt('{:>14} | {:<17} | {:>10} | {:<36} | {:<3} | {:<3} | {:<4} | {:>4} | {:>32}'.format(
                    "0x"+format(i,'x'),
                    processes[args.p]['pages'][i]['permissions'],
                    convert_bytes(processes[args.p]['pages'][i]['region_size']),
                    processes[args.p]['pages'][i]['module'][:36],
                    processes[args.p]['pages'][i]['mz'],
                    processes[args.p]['pages'][i]['dos'],
                    processes[args.p]['pages'][i]['nops'],
                    processes[args.p]['pages'][i]['sigs'],
                    processes[args.p]['pages'][i]['md5']
                ) + '\n',True)
            printnt("\n",True)
    if args.o:
        args.of.close()

def enable_privilege(privilegeStr, hToken = None):
    if hToken == None:
        TOKEN_ADJUST_PRIVILEGES = 0x00000020
        TOKEN_QUERY = 0x0008
        hToken = HANDLE(INVALID_HANDLE_VALUE)
        hProcess = windll.kernel32.OpenProcess(Access.PROCESS_QUERY_INFORMATION, False, windll.kernel32.GetCurrentProcessId())
        success = windll.advapi32.OpenProcessToken(hProcess, (TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY), byref(hToken))
        windll.kernel32.CloseHandle(hProcess)
        if not success:
            printt(WinError(GetLastError())[1], True)
            sys.exit(1)
    privilege_id = LUID()
    windll.advapi32.LookupPrivilegeValueA(None, privilegeStr, byref(privilege_id))
    e=GetLastError()
    if e!=0:
        printt(WinError(GetLastError())[1], True)
    SE_PRIVILEGE_ENABLED = 0x00000002
    laa = LUID_AND_ATTRIBUTES(privilege_id, SE_PRIVILEGE_ENABLED)
    tp  = TOKEN_PRIVILEGES(1, laa)
    windll.advapi32.AdjustTokenPrivileges(hToken, False, byref(tp), sizeof(tp), None, None)
    e=GetLastError()
    if e!=0:
        printt(WinError(GetLastError())[1], True)
        
def scan_drivers():
    if args.arch == '64bit':
        image_base = (c_ulonglong * 1024)()
        lpcb_needed = c_longlong()
        windll.Psapi.GetDeviceDriverBaseNameA.argtypes = [c_longlong, POINTER(c_char), c_uint32]
        windll.Psapi.GetDeviceDriverFileNameA.argtypes = [c_longlong, POINTER(c_char), c_uint32]
    else:
        image_base = (c_ulong * 1024)()
        lpcb_needed = c_long()
    if windll.Psapi.EnumDeviceDrivers(byref(image_base), c_int(1024), byref(lpcb_needed)):
        print 'Num:', int(lpcb_needed.value / sizeof(c_void_p))
        for b in image_base:
            driver_name = (c_char * 260)()
            if b:
                windll.Psapi.GetDeviceDriverBaseNameA(b,driver_name,48)
                driver_path = (c_char * 260)()
                windll.Psapi.GetDeviceDriverFileNameA(b,driver_path,260)
                #print 'Driver:',b,driver_name.value,driver_path.value

def validate_process(hProc):
    process_is32 = c_bool()
    success = windll.kernel32.IsWow64Process(hProc, byref(process_is32))
    if not success:
        printt('Unable to verify process architecture. Pid: ' + str(args.p) + ' : ' + processes[args.p]['exe'] + ' (Permissions?)\n\n', True)
    return success, process_is32
    
def generate_hash_db(filename):
    outfile = open(filename,'w')
    for root, dirs, files in os.walk('c:\\'):
        for file in files:
            if file.endswith(".dll") or file.endswith(".exe"):
                md5 = hashlib.md5()
                sha1 = hashlib.sha1()
                with open(os.path.join(root, file), 'rb') as f:
                    while True:
                        data = f.read(BUF_SIZE)
                        if not data:
                            break
                        md5.update(data)
                        sha1.update(data)
                outfile.write(os.path.join(root, file) + ',' + md5.hexdigest() + ',' + sha1.hexdigest() + '\n')
    
def read_process_mem(h, address, size):
    global args
    processes[args.p]['pages'][address]['md5'] = '?'
    processes[args.p]['pages'][address]['sha1'] = '?'
    processes[args.p]['pages'][address]['mz'] = '?'
    processes[args.p]['pages'][address]['dos'] = '?'
    processes[args.p]['pages'][address]['sigs'] = 0
    processes[args.p]['pages'][address]['nops'] = '?'
    if size > 128000000:
        return
    on_disk = False
    buf = create_string_buffer(size)
    gotBytes = c_ulong(0)
    success = windll.kernel32.ReadProcessMemory(h, c_void_p(address), buf, size, byref(gotBytes))
    if success:
        md5 = hashlib.md5()
        sha1 = hashlib.sha1()
        md5.update(buf)
        sha1.update(buf)
        if args.s:
            for s in args.sigs:
                if s.strip() in buf.raw or '\x00'.join(s).strip() in buf.raw:
                    processes[args.p]['pages'][address]['sigs'] += 1
            if args.S and processes[args.p]['pages'][address]['sigs'] == 0:
                del processes[args.p]['pages'][address]
                return
        if args.w:
            open('c:\\temp\\' + str(args.p) + '-' + str(hex(address)) + '.dll','wb+').write(buf)
        if args.d:
            with open(args.d, "r") as f:
                lines = f.readlines()
                for line in lines:
                    if md5.hexdigest() in line:
                        on_disk = True
        nop_count = buf.raw.count('\x90')
        processes[args.p]['pages'][address]['md5'] = md5.hexdigest()
        processes[args.p]['pages'][address]['sha1'] = sha1.hexdigest()
        processes[args.p]['pages'][address]['mz'] = 'No'
        processes[args.p]['pages'][address]['dos'] = 'No'
        if buf[:2] == 'MZ':
            processes[args.p]['pages'][address]['mz'] = 'Yes'
        if DOS_STRING in buf.raw:
            processes[args.p]['pages'][address]['dos'] = 'Yes'
        processes[args.p]['pages'][address]['nops'] = str(nop_count / len(buf)) + '%'

def scan_processes(pid):
    sh = windll.kernel32.CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
    ps = PROCESSENTRY()
    ps.dwSize = sizeof(PROCESSENTRY)
    p = windll.kernel32.Process32First(sh, pointer(ps))
    while True:
        if pid == 0 or int(pid) == int(ps.th32ProcessID):
            processes[ps.th32ProcessID] = {'exe':ps.szExeFile,'ppid':ps.th32ParentProcessID}
        if not windll.kernel32.Process32Next(sh, pointer(ps)):
            break
    windll.kernel32.CloseHandle(sh)

def scan_modules(pid):
    sh = windll.kernel32.CreateToolhelp32Snapshot(TH32CS_SNAPMODULE | TH32CS_SNAPMODULE32, int(pid))
    e = MODULEENTRY32()
    e.dwSize = sizeof(MODULEENTRY32)
    if windll.kernel32.Module32First(sh, pointer(e)):
        while windll.kernel32.Module32Next(sh, pointer(e)):
            processes[pid]['modules'][e.szModule] = [addressof(e.modBaseAddr.contents), e.modBaseSize]
    windll.kernel32.CloseHandle(sh)

def scan_page(process_handle, page_address, process_is32, min, permissions):
    success, info = VirtualQueryEx(process_handle, page_address, process_is32)
    if not success:
        return -1
    base_address = info.BaseAddress
    region_size = info.RegionSize
    next_region = base_address + region_size
    if info.Protect != 0 and page_address >= min:
        modifier = None
        protect = info.Protect
        if info.ProtectBits & 0x100:
            modifier = "GUARD"
            perm = info.ProtectBits ^ 0x100
            protect = MEMORY_PROTECTIONS.get(perm, perm)
        elif info.ProtectBits & 0x200:
            modifier = "NOCACHE"
            perm = info.ProtectBits ^ 0x200
            protect = MEMORY_PROTECTIONS.get(perm, perm)
        elif info.ProtectBits & 0x400:
            modifier = "WRITECOMBINE"
            perm = info.ProtectBits ^ 0x400
            protect = MEMORY_PROTECTIONS.get(perm, perm)
        if permissions is None or protect in permissions:
            module = ''
            for i in processes[args.p]['modules']:
                if page_address >= processes[args.p]['modules'][i][0] and page_address <= processes[args.p]['modules'][i][0] + processes[args.p]['modules'][i][1]:
                    module = i
                    break
            if not args.b or (args.b and module == ''):
                processes[args.p]['pages'][page_address] = {'permissions':protect, 'region_size':region_size, 'module':module}
                read_process_mem(process_handle, page_address, region_size)
    return next_region

def VirtualQueryEx (hProcess, lpAddress, process_is32):
    if process_is32:
        lpBuffer = MEMORY_BASIC_INFORMATION32()
    else:
        lpBuffer = MEMORY_BASIC_INFORMATION64()
    success = windll.kernel32.VirtualQueryEx(hProcess, LPVOID(lpAddress), byref(lpBuffer), sizeof(lpBuffer))
    if not success:
        printt('VirtualQueryEx failed for pid: ' + str(args.p) + ' : ' + processes[args.p]['exe'] + ' : ' + WinError(GetLastError())[1] + '\n\n', True)
    return success, MEMORY_BASIC_INFORMATION(lpBuffer)

def parse_args():
    permissions = textwrap.dedent('''\
                    Available Permissions:  EXECUTE, EXECUTE_READ, EXECUTE_READWRITE,
                                            EXECUTE_WRITECOPY, NOACCESS, READWRITE,
                                            WRITECOPY, READONLY''')
    parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
                                     description=textwrap.dedent(''),
                                     epilog=permissions)
    parser.add_argument('-d', metavar='HASH_FILE', required=False, type=str, help='Generate or use existing hash db.')
    parser.add_argument('-p', metavar='PID', required=False, type=str, help='Scan only a specific PID.')
    parser.add_argument('-o', metavar='FILENAME', type=str, help='Save the results to a file.')
    parser.add_argument('-v', action='store_true', help='Verbose output.')
    parser.add_argument('-w', action='store_true', help='Extract copies of pages from memory.')
    parser.add_argument('-b', action='store_true', help='Only show pages without backing file on disk.')
    parser.add_argument('-s', metavar='FILENAME', type=str, help='Signature file.')
    parser.add_argument('-S', action='store_true', help='Only show pages with at least one signature match.')
    parser.add_argument('-min', type=str, metavar='ADDRESS', default="0x0", help='Print only the addresses that are higher than the specified one. (e.g. 0x000A0000)')
    parser.add_argument('-max', type=str, metavar='ADDRESS', default="0x0", help='Scan up to a max address. (e.g. 0x000B0000)')
    parser.add_argument('-i', metavar='PERMS', nargs='+', help='Print specific permissions. Default is EXECUTE_READWRITE')
    args = parser.parse_args()
    if args.min is not "0x0":
        try:
            int(args.min, 16)
        except ValueError:
            printt('Error: Invalid minimum address. Format must be: 0xDEADBEEF\n')
            sys.exit(1)
            
    if args.max is not "0x0":
        try:
            int(args.max, 16)
        except ValueError:
            printt('Error: Invalid maximum address. Format must be: 0xDEADBEEF\n')
            sys.exit(1)
        if args.min > args.max:
            tmp = args.min
            args.min = args.max
            args.max = tmp

    if args.d is not None:
        if not os.path.isfile(args.d):
            printt('Generating hash database...\n', True)
            generate_hash_db(args.d)
            printt('Hash database complete!\n', True)
            sys.exit(0)
        else:
            printt('Loading hash database...\n')
            hash_db = open(args.d,'r').read()
            
    if args.i is not None:
        for x in args.i:
            if x not in MEMORY_PROTECTIONS.values():
                printt('Error: Invalid permission: %s\n\n' % x, True)
                sys.exit(1)
    else:
        args.i = ['EXECUTE_READWRITE']
    return args

def printnt(string, always=False):
    if ('v' in args and args.v) or always:
        if 'o' in args and args.o:
            args.of.write(string)
        else:
            sys.stdout.write(string)

def printt(string, always=False):
    if ('v' in args and args.v) or always:
        ts = time.strftime("%H:%M:%S", time.gmtime())
        if 'o' in args and args.o:
            args.of.write("[*][%s] %s" % (ts, string))
        else:
            sys.stdout.write("[*][%s] %s" % (ts, string))

def convert_bytes(bytes):
    bytes = float(bytes)
    if bytes >= 1099511627776:
        terabytes = bytes / 1099511627776
        size = '%.2fTB' % terabytes
    elif bytes >= 1073741824:
        gigabytes = bytes / 1073741824
        size = '%.2fGB' % gigabytes
    elif bytes >= 1048576:
        megabytes = bytes / 1048576
        size = '%.2fMB' % megabytes
    elif bytes >= 1024:
        kilobytes = bytes / 1024
        size = '%.2fKB' % kilobytes
    else:
        size = '%.2fb' % bytes
    return size

if __name__ == '__main__':
    main()