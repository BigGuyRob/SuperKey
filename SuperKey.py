import bluetooth
import numpy as np
import socket
def scan():

    print("Scanning for bluetooth devices:")

    devices = bluetooth.discover_devices(lookup_names = True, lookup_class = True)

    number_of_devices = len(devices)
    print(number_of_devices,"devices found")
    temp_dev = [0] * number_of_devices
    count = 0
    for addr, name, device_class in devices:
        print("\n")
        print(count + 1)
        print("Device:")
        print("Device Name: %s" % (name))
        print("Device MAC Address: %s" % (addr))
        temp_dev[count] = addr
        count += 1
        print("Device Class: %s" % (device_class))
        print("\n")

    return temp_dev


available_addresses = scan()
count = len(available_addresses)
if(count == 0):
    exit()

sel = input("Select Device from List\n")
while(sel.isdigit() == False):
    sel = input("Select Device from List\n")
    while(sel > count or sel < 1):
        sel = input("Select Device from List\n")

mysock = bluetooth.BluetoothSocket(bluetooth.RFCOMM)
mysock.connect((available_addresses[int(sel) - 1],1))

setting = True
while True:
    print("1. Set code")
    print("2. Get code")
    command = input("Please enter a command to continue")

    if command == "1":
        # set code logic here
        msg = "c"
        mysock.send(msg.encode())
        print("Setting new code")
        code = "0000"
        while(True):
            code = input("Enter a 4-digit integer: ")
            if code.isdigit() and len(code) == 4:
                print("Sending code:")
                print(code)
                break
            else:
                print("Input is not valid. Please enter a 4-digit integer.")
        counter = 0
        ack_counter = 0
        while(setting):
            msg = code[counter] #send the first character of the code
            mysock.send(msg.encode()) #send
            
            received_ack = mysock.recv(1024)#start receiving
            #print(received_ack)
            received_ack = received_ack.decode('utf-8')
            if(received_ack == code[counter]):
                #if we got what we expected back
                while(received_ack != 'x'): #obviously shouldnt be x if we got in here
                    msg = 'x' #send acknowledment symbol
                    mysock.send(msg.encode()) #send    
                    received_ack = mysock.recv(1024)#start receiving
                    received_ack = received_ack.decode('utf-8')
                    #print(received_ack)
                counter += 1 #if we get here received ack = x
                #print(counter)
                if(counter == 4):
                    setting = False #done setting
            #if we didnt get it back then we send the msg again that is code[counter] at the top of the loops
                msg = 'x' #send acknowledment symbol
                mysock.send(msg.encode()) #send
            
                
        #should be done here
        print("Finished Setting Code")            
        counter = 0
        setting = True
    elif(command == '2'):
        print("getting code")
        msg = "s"
        mysock.send(msg.encode())
        counter = 0
        setting = True
        code = ""
        while(setting):
            msg = "x" #ping for first char
            mysock.send(msg.encode())
            received_ack = mysock.recv(1024)#start a byte
            received_ack = received_ack.decode('utf-8')#only take the first char of what is returned
            if(received_ack == 'x'):
                setting = False
            code += received_ack #this should be first char
            msg = "a" #ping for next char
            mysock.send(msg.encode())
            
        counter = 0
        setting = True
        print(code[1:5]) #only 4 digits    
    else:
        print("Invalid command.")

