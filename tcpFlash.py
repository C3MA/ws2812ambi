#!/usr/bin/python

import argparse
import socket
import os.path
import sys      #for exit
import time

def sendRecv(s, message, answer):
    msg = message + "\n"
    s.sendall(msg)
    reply = s.recv(4096)
    while (not reply):
        reply = s.recv(4096)
    if answer not in reply:
        return False
    else:
        return True

def sendCmd(s, message, cleaningEnter=False):
    msg = message + "\n"
    s.sendall(msg)
    time.sleep(0.010)
    reply = s.recv(4096)
    i=1
    while ((not (">" in reply)) and (i < 10)):
        time.sleep((0.010) * i)
        reply += s.recv(4096)
        i = i + 1

#    print "Send\t" + message
#    print "Got\t" + reply
    if (cleaningEnter):
        s.sendall("\n")
    if "stdin:1:" in reply:
       print "ERROR, received : " + reply
       return False
    elif ">" in reply:
        return True
    else:
        print "ERROR, received : " + reply
        return False

def main(nodeip, luafile):
    if ( not os.path.isfile(luafile) ):
        print "The file " + luafile + " is not available"
    else:
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.connect((nodeip, 80))
	    # Receive the hello Message of answer of the ESP
            s.send("bla\n")
            reply = s.recv(4096)
            if ("Welcome" not in reply):
                print "Cannot connect to the ESP"
                s.close()
                sys.exit(2)

            # Communication tests
            if ( not sendRecv(s, "print(12345)", "12345") ):
                print "NOT communicating with an ESP8266 running LUA (nodemcu) firmware"
                s.close()
                sys.exit(3)
            
            print "Flashing " + luafile
            sendCmd(s, "file.remove(\"" + luafile+"\");", True)
            sendCmd(s, "w= file.writeline", True)
            sendCmd(s, "file.open(\"" + luafile + "\",\"w+\");", True)
            with open(luafile) as f:
                contents = f.readlines()
                i=1
                for line in contents:
                    print "\rSending " + str(i) + "/" + str(len(contents)) + " ...",
                    l = line.rstrip()
                    if (not sendCmd(s, "w([[" + l + "]]);")):
                        print "Cannot write line " + str(i)
                        s.close()
                        sys.exit(4)
                    i=i+1

            # Finished with updating the file in LUA
            sendCmd(s, "file.close();")
            # Cleaning the socket by closing it
            s.close()
            sys.exit(0) # Report that the flashing was succesfull
        except socket.error, msg:
            print 'Failed to create socket. Error code: ' + str(msg[0]) + ' , Error message : ' + msg[1]
            sys.exit(1)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-t', '--target', help='IP address or dns of the ESP to flash')
    parser.add_argument('-f', '--file', help='LUA file, that should be updated')

    args = parser.parse_args()
    if (args.target and args.file): 
        main(args.target, args.file)
    else:
        parser.print_help()
