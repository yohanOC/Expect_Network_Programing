#!/usr/bin/expect -f

 set message "Log already collect" #message notification to telegram
 set time [exec date "+%d"] #date execute
 set output [exec date "+%b"] #date execute
 set fd "/home/Log_report/device_list/$time" #file device list to be remote/ip device list
 set fp [open "$fd" r] #open file
 set data [read $fp] #read file 
 set nonremote \[[join $data , ]\]  
 #open configuration for catalyst
 set fc "../Configuration/3750.txt" #file configuration, this is for cisco devices
 set fca [open "$fc" r] #open file
 set fcat [read $fca] #read file 
 close $fca
 #open configuration for firewall
 set ff "../Configuration/asa.txt"
 set ffi [open "$ff" r]
 set ffir [read $ffi]
 close $ffi
 #open configuration for coreSW
 set fdi "../Configuration/core.txt"
 set fdis [open "$fdi" r]
 set fdist [read $fdis]
 close $fdis
 #open configurasi for H3C
 set fh3c "../Configuration/h3c.txt"
 set fh3cc [open "$fh3c" r]
 set ch3c [read $fh3cc]
 close $fh3cc

 set username "xxxxx" #this is username for ssh server
 set password "xxxxx" #this is password for ssh server
 set teluser "xxxx" #this is username for telnet
 set telpass "xxxxx" #this is password for telnet
 set userper "xxxx" #this is username for telnet
 set passper "xxxxx" #this is username for telnet
 set enablepassword {xxxxxxxx} #enable password for cisco
 set dir "/home/Log_report/file/$output" #output file path
 #close session
 close $fp   
 # check host base on date
 if { $time == 06 || $time == 20 || $time == 13 || $time == 27} {
	foreach hostname $data {
        #exception if in same date have more than one vendor 
		if { $hostname == "x.x.x.x" || $hostname == "x.x.x.x" } { 
			#send Notification via telegram 
			spawn curl -s -X POST https://api.telegram.org/"your boot id"/sendMessage -d chat_id="your chat id" -d text=$hostname$message
			send_user "\n"
			send_user ">>>>>  Working on $hostname @ [exec date] <<<<<\n" 
			send_user "\n"
			#Don't check keys / using telnet session for remote devices
			spawn ssh -o StrictHostKeyChecking=no $username\@$hostname
			exp_log_file -noappend $dir/$time-$hostname.txt
			# Allow this script to handle ssh connection issues
 				expect {
					timeout { send_user "\nTimeout Exceeded - Check Host\n"; exit 1 }
					eof { send_user "\nSSH Connection To $hostname Failed\n"; exit 1 }
					"*#" {}
					"*assword:" {
					   send "$password\n"
					   }
				}
			#If we're not already in enable mode, get us there
				expect {
					default { send_user "\nEnable Mode Failed - Check Password\n"; exit 1 }
					"*#" {}
 					"*>" {
 					      send "enable\n"
 					      expect "*assword"
					      send "$enablepassword\n"
					      expect "*#"
					      }
 				}
 			expect "#"
            #send configuration 
			send "$ffir"
			expect "#"
            #close connection
			expect eof
 			exp_log_file
		} else {
 			#send Notification via telegram
			spawn curl -s -X POST https://api.telegram.org/"your bootid"/sendMessage -d chat_id="your chat id" -d text=$hostname$message
			send_user "\n"
			send_user ">>>>>  Working on $hostname @ [exec date] <<<<<\n"
			send_user "\n"
			# Don't check keys / using telnet session for remote devices
			spawn ssh -o StrictHostKeyChecking=no $username\@$hostname
			exp_log_file -noappend $dir/$time-$hostname.txt
			#Allow this script to handle ssh connection issues
 			expect {
				timeout { send_user "\nTimeout Exceeded - Check Host\n"; exit 1 }
				eof { send_user "\nSSH Connection To $hostname Failed\n"; exit 1 }
				"*#" {}
				"*assword:" {
					send "$password\n"
				}
			}
			# If we're not already in enable mode, get us there
			expect {
				default { send_user "\nEnable Mode Failed - Check Password\n"; exit 1 }
				"*#" {}
 				"*>" {
 					send "enable\n"
 					expect "*assword"
 					send "$enablepassword\n"
 					expect "*#"
				    }
        	}
 			expect "#"
            #send configuration
			send "$fdist"
			expect "#"
            #close  session
	 		expect eof
 			exp_log_file
		}
	}  
} elseif { $time == 14 || $time == 28 } {
	spawn curl -s -X POST https://api.telegram.org/("your bootid")/sendMessage -d chat_id="your chat id" -d text=$nonremote$message
} elseif { $time == 11 || $time == 12 } {
	foreach hostname $data {
		#send Notification via telegram
        spawn curl -s -X POST https://api.telegram.org/("your bootid")/sendMessage -d chat_id="your chat id" -d text=$hostname$message
        #Announce which device we are working on and at what time
        send_user "\n"
        send_user ">>>>>  Working on $hostname @ [exec date] <<<<<\n"
        send_user "\n"
		#using telnet session for remote devices
        spawn telnet $hostname
        exp_log_file -noappend $dir/$time-$hostname.txt
		# Allow this script to handle ssh connection issues
        expect "*sername:"
		send "$userper\n"
		expect "*assword:"
		send "$passper\n"
        # If we're not already in enable mode, get us there
        expect "#"
        #send configuration
		send "$ch3c"
        expect "#"
        #close session
        expect eof
        exp_log_file
    }

} elseif { $time == 03 || $time == 05 || $time == 15 || $time == 26 || $time == 25 || $time == 17 || $time == 24 || $time == 16 || $time == 10 } {
	foreach hostname $data { 
        #exception other deivices
		if { $hostname == "x.x.x.x" } {
			#send Notification via telegram
            spawn curl -s -X POST https://api.telegram.org/"your bootid"/sendMessage -d chat_id="your chat id" -d text=$hostname$message
            #Announce which device we are working on and at what time
            send_user "\n"
            send_user ">>>>>  Working on $hostname @ [exec date] <<<<<\n"
            send_user "\n"
			# Don't check keys / using SSH session for remote devices
            spawn ssh -o StrictHostKeyChecking=no $username\@$hostname
            exp_log_file -noappend $dir/$time-$hostname.txt
			# Allow this script to handle ssh connection issues
                expect {
                    timeout { send_user "\nTimeout Exceeded - Check Host\n"; exit 1 }
                    eof { send_user "\nSSH Connection To $hostname Failed\n"; exit 1 }
                    "*#" {}
                    "*assword:" {
                        send "$password\n"
                    }
                }
                # If we're not already in enable mode, get us there
                expect {
                   	default { send_user "\nEnable Mode Failed - Check Password\n"; exit 1 }
                    "*#" {}
                    "*>" {
                        send "enable\n"
                        expect "*assword"
                        send "$enablepassword\n"
                        expect "*#"
                    }
                }
                expect "#"
                #send configuration
			    send "$fcat"
                expect "#"
                #close session
                expect eof
                exp_log_file
        } else {
			#send Notification via telegram
            spawn curl -s -X POST https://api.telegram.org/"your bootid"/sendMessage -d chat_id="your chat id" -d text=$hostname$message
            #Announce which device we are working on and at what time
            #save file to specific directory
            #exp_log_file -noappend $dir/$time-$hostname.txt
            send_user "\n"
            send_user ">>>>>  Working on $hostname @ [exec date] <<<<<\n"
            send_user "\n"
			# Don't check keys / using telnet session for remote devices
            spawn telnet $hostname
            exp_log_file -noappend $dir/$time-$hostname.txt
			# Allow this script to handle ssh connection issues
            expect "*sername:"
			send "$teluser\n"
			expect "*assword:"
			send "$telpass\n"
            # If we're not already in enable mode, get us there
            expect {
                default { send_user "\nEnable Mode Failed - Check Password\n"; exit 1 }
                "*#" {}
                "*>" {
                    send "enable\n"
                    expect "*assword"
                    send "$enablepassword\n"
                    expect "*#"
                }
            }
            expect "#"
            #send configuration
			send "$fcat"
            expect "#"
            #close session
            expect eof
            exp_log_file
        	}
	}
} else {
	foreach hostname $data {
        #exception other devices
		if { $hostname == "x.x.x.x" } {
			#send Notification via telegram
            spawn curl -s -X POST https://api.telegram.org/bot533346734:AAFOlUFYWEOK6nV9k4sB98kZRNbcIXgZS8U/sendMessage -d chat_id=-256279976 -d text=$hostname+log_wes_siap_dijupuk_JUM
            #save file into specific directory
            send_user "\n"
            send_user ">>>>>  Working on $hostname @ [exec date] <<<<<\n"
            send_user "\n"
            # Don't check keys / using telnet session for remote devices
            spawn ssh -o StrictHostKeyChecking=no $teluser\@$hostname
            exp_log_file -noappend $dir/$time-$hostname.txt
			#Allow this script to handle ssh connection issues
            expect {
                timeout { send_user "\nTimeout Exceeded - Check Host\n"; exit 1 }
                eof { send_user "\nSSH Connection To $hostname Failed\n"; exit 1 }
                "*#" {}
                "*assword:" {
                    send "$telpass\n"
                    }
                }
            expect "#"
            #send configuration
            send "$fdist"
            expect "#"
            #close session
            expect eof
            exp_log_file
		} else {
 			#send Notification via telegram
			spawn curl -s -X POST https://api.telegram.org/bot533346734:AAFOlUFYWEOK6nV9k4sB98kZRNbcIXgZS8U/sendMessage -d chat_id=-256279976 -d text=$hostname+log_wes_siap_dijupuk_JUM
			#Announce which device we are working on and at what time
 			send_user "\n"
 			send_user ">>>>>  Working on $hostname @ [exec date] <<<<<\n"
 			send_user "\n"
			# Don't check keys / using SSH session for remote devices
 			spawn ssh -o StrictHostKeyChecking=no $username\@$hostname
			exp_log_file -noappend $dir/$time-$hostname.txt
			# Allow this script to handle ssh connection issues
 			expect {
 				timeout { send_user "\nTimeout Exceeded - Check Host\n"; exit 1 }
 				eof { send_user "\nSSH Connection To $hostname Failed\n"; exit 1 }
 				"*#" {}
 				"*assword:" {
 				   send "$password\n"
				}
 			}
			# If we're not already in enable mode, get us there
		 	expect {
 				default { send_user "\nEnable Mode Failed - Check Password\n"; exit 1 }
				"*#" {}
 				"*>" {
 					send "enable\n"
 					expect "*assword"
 					send "$enablepassword\n"
 					expect "*#"
        		}
        	}
 			expect "#"
            #send configuration
 			send "$fcat"
 			expect "#"
            #close session
 			expect eof
 			exp_log_file
		}
	}
} 
	
